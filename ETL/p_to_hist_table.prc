create or replace procedure etl.P_TO_HIST_TABLE (p_prc_id number, p_table_name varchar2, p_hist_table_name varchar2, p_owner varchar2)
--authid current_user
as
--    p_prc_id number :=1; 
--    p_table_name varchar2(100) := 'contracts'; 
--    p_hist_table_name varchar2(100) := 'contracts_hist';
--    p_owner varchar2(100) := 'dwh';
--------------------------------------------------------------------------------------     
    v_prc_id number:= p_prc_id;  
    v_table_name varchar2(100) := upper(trim(p_table_name));
    v_hist_table_name varchar2(100) := upper(trim(p_hist_table_name));
    v_owner  varchar2(100) := upper(trim(p_owner));
    v_tmp_table_name  varchar2(100) := 'TMP_'||v_table_name;
    v_inf varchar2(32000);
    v_msg varchar2(32000);
    v_sql varchar2(32000);
    v_crlf  VARCHAR2(2)  := chr(13)||chr(10);
    v_fields_list varchar2(32000);
    v_cnt number;
    v_flg BOOLEAN;
    v_load_hist_params varchar2(32000);
    v_sel_cols varchar2(32000) := '';
    v_cnt_row_trg_b number;
    v_cnt_row_trg_a number;
    v_cnt_row_hist_b number;
    v_cnt_row_hist_a number;
    v_prc_name varchar2(32000):= 'LOAD_TO_HIST_'||v_table_name;
    v_ddl_scripts_tab ddl_script_tab_type := ddl_script_tab_type();
    v_ddl_script  varchar2(32000) := '';
    v_index_name  varchar2(32000) := '';  
    v_rebuild_index_flg varchar2(1) := '0';  
begin
    -------------------------------------------------------------------------------------- 
    -- ќпределение условий выборки записей дл€ переноса
    --------------------------------------------------------------------------------------             
    select LOAD_HIST_PARAMS,cnt, REBULID_INFEX_FLG 
    into v_load_hist_params,v_cnt,v_rebuild_index_flg
    from 
    (
        select LOAD_HIST_PARAMS, count(TABLE_NAME) over(order by -1) cnt, REBULID_INFEX_FLG
        from 
        (   select LOAD_HIST_PARAMS, TABLE_NAME, 1 flg, REBULID_INFEX_FLG
            from etl.CTL_COPY_HIST_DATA_PARAMS
            where table_name = v_table_name
            and actual_flg = '1'
            union all
            select null, null, -1, '0' from dual
        )
        order by flg desc
    )
    where rownum < 2;    
    if (v_cnt = 0 or v_cnt > 1 ) then
            raise_application_error(-20001, '“аблица параметров содержит некорректное число параметров дл€ целевой таблицы '||v_owner||'.'||v_table_name);
    end if;
    etl.LOG_PRC_COPY_HIST_DATA(p_prc_id => v_prc_id,p_prc_name=>v_prc_name,p_step_name => 'START',p_prc_status=> null
                            ,p_prc_add_inf=> 'PARAMS:'||v_load_hist_params||'; '
                            ||case when v_rebuild_index_flg = '1' then 'пересоздание индекса: вкл' else 'пересоздание индекса: выкл' end);
    v_sql := 'select count(*)  from '||v_owner||'.'||v_table_name;
    execute immediate v_sql into v_cnt_row_trg_b; 
    v_inf := v_inf || ' оличество записей в целевой таблице '||v_owner||'.'||v_table_name||' до переноса исторических данных: ' ||v_cnt_row_trg_b||';'||v_crlf;
    v_sql := 'select count(*)  from '||v_owner||'.'||v_hist_table_name;
    execute immediate v_sql into v_cnt_row_hist_b; 
    v_inf := v_inf || ' оличество записей в исторической таблице '||v_owner||'.'||v_hist_table_name||' до переноса исторических данных: ' ||v_cnt_row_hist_b||';'||v_crlf;
    --------------------------------------------------------------------------------------
    -- ”даление индексов и сохранение в логах их DDL
    --------------------------------------------------------------------------------------      
    if (v_rebuild_index_flg = '1')  then
        v_ddl_scripts_tab := GET_DDL_INDEXES('FACT_PLAN_PAYMENTS', 'DWH');
        for i in 1..v_ddl_scripts_tab.count loop
            v_ddl_script := v_ddl_scripts_tab(i);
            v_index_name := trim(BOTH '"' from substr(v_ddl_script, instr(v_ddl_script,'.')+1,instr(v_ddl_script, ' ON ') -instr(v_ddl_script,'.')-1));
            LOG_PRC_COPY_HIST_DATA(p_prc_id => v_prc_id,p_prc_name=>v_prc_name,p_step_name => 'DROP INDEX',p_prc_status=> null
                            ,p_prc_add_inf=> 'DDL DROPPED INDEX:'||v_ddl_script);
            execute immediate 'drop index '||v_owner||'.'||v_index_name;                                            
        end loop;
    end if;
    -------------------------------------------------------------------------------------- 
    if not etl.cmp_2tabs_cols(   p_tab1_name   => v_table_name,
                             p_tab2_name   => v_hist_table_name,
                             p_except_cols => 'PRC_ID, PRC_TIMESTAMP',
                             p_tab1_owner  => v_owner,
                             p_tab2_owner  => v_owner) 
        then raise_application_error(-20001, '÷елева€ таблица '||v_owner||'.'||v_table_name
                                              ||' и таблица исторических данных '||v_owner||'.'||v_hist_table_name
                                              ||' различаютс€ по составу и(или) типу полей.');                              
    end if;                             
    --------------------------------------------------------------------------------------
    -- ѕроверка наличи€ темповой таблицы, создание, удаление данных в ней
    v_cnt := 0;
    v_sql := 'select count(*) from all_tables where owner = ''ETL'' and table_name = :tmp_table_name';
    dbms_output.put_line(v_cnt);
    execute immediate v_sql into v_cnt using v_tmp_table_name;
    v_flg := etl.cmp_2tabs_cols(   p_tab1_name   => v_table_name,
                             p_tab2_name   => v_tmp_table_name,
                             p_except_cols => 'PRC_ID,PRC_TIMESTAMP', 
                             p_tab1_owner  => 'DWH',
                             p_tab2_owner  => 'ETL'); 
    if (v_cnt = 0 or (not v_flg)) then 
        if (v_cnt <> 0 ) then 
            execute immediate 'drop table ETL.'||v_tmp_table_name;
        end if;            
        execute immediate 'create table ETL.'||v_tmp_table_name||' as select * from '||v_owner||'.'||v_table_name||' where 1=0';
    else
        execute immediate 'truncate table ETL.'||v_tmp_table_name;
    end if;        
    --------------------------------------------------------------------------------------
    -- —оздание BACK UP  
    --------------------------------------------------------------------------------------
    v_cnt := 0;
    v_sql := 'create table vtbl_bkp.BKP_'||v_prc_id||'_'||v_table_name||'
                 as select * from '||v_owner||'.'||v_table_name;
    execute immediate v_sql;
    v_sql :=    'select count(*) from  vtbl_bkp.BKP_'||v_prc_id||'_'||v_table_name||'
                 where rownum < 2';
    execute immediate v_sql into v_cnt;  
    if v_cnt = 0 then 
            raise_application_error(-20001, 'ќшибка создани€ BACK_UP целевой таблицы.');                              
    end if;
    etl.LOG_PRC_COPY_HIST_DATA(p_prc_id => v_prc_id,p_prc_name=>v_prc_name,p_step_name => 'BACK UP CREATED',p_prc_status=>null);                               
    --------------------------------------------------------------------------------------
    -- ”даление данных 
    --------------------------------------------------------------------------------------
    for rec in (select column_name 
                from all_tab_cols
                where TABLE_NAME = v_table_name
                and OWNER = v_owner 
                ) loop
        v_sel_cols := v_sel_cols || ',' || rec.column_name;                    
    end loop;                        
    v_sel_cols := substr(v_sel_cols, 2);
    -------------------------------------------------------------------------------------- 
    -- «агрузка TMP  табылицы
    v_sql := ' insert into etl.'||v_tmp_table_name||' ('||v_sel_cols||')
               select '||v_sel_cols||
             ' from '||v_owner||'.'||v_table_name||' where not ( 1=1 '||v_load_hist_params||')';
    dbms_output.put_line(v_sql);             
    execute immediate v_sql;
    etl.LOG_PRC_COPY_HIST_DATA(p_prc_id => v_prc_id,p_prc_name=>v_prc_name,p_step_name => 'LOAD TMP TABLE',p_prc_status=>null);
    -- «агрузка HIST таблицы
    v_sql := ' insert into '||v_owner||'.'||v_hist_table_name||' ('||v_sel_cols||', PRC_ID, PRC_TIMESTAMP)
               select '||v_sel_cols||','||v_prc_id||',systimestamp 
               from '||v_owner||'.'||v_table_name||' where 1=1 '||v_load_hist_params;
    dbms_output.put_line(v_sql);             
    execute immediate v_sql;
    etl.LOG_PRC_COPY_HIST_DATA(p_prc_id => v_prc_id,p_prc_name=>v_prc_name,p_step_name => 'LOAD HIST TABLE',p_prc_status=>null);
    -- ќчистка целевой таблицы
    v_sql := ' truncate table '|| v_owner||'.'||v_table_name;
    dbms_output.put_line(v_sql);
    execute immediate v_sql;
    v_sql := ' insert into '||v_owner||'.'||v_table_name|| '('||v_sel_cols||')
               select '||v_sel_cols||
             ' from etl.'||v_tmp_table_name;
    dbms_output.put_line(v_sql);  
    execute immediate v_sql;
    etl.LOG_PRC_COPY_HIST_DATA(p_prc_id => v_prc_id,p_prc_name=>v_prc_name,p_step_name => 'LOAD TRG TABLE',p_prc_status=>null);
    -------------------------------------------------------------------------------------- 
    v_sql := 'select count(*)  from '||v_owner||'.'||v_table_name;
    execute immediate v_sql into v_cnt_row_trg_a; 
    v_inf := v_inf || ' оличество записей в целевой таблице '||v_owner||'.'||v_table_name||' после переноса исторических данных: ' ||v_cnt_row_trg_a||';'||v_crlf;
    v_sql := 'select count(*)  from '||v_owner||'.'||v_hist_table_name;
    execute immediate v_sql into v_cnt_row_hist_a; 
    v_inf := v_inf || ' оличество записей в исторической таблице '||v_owner||'.'||v_hist_table_name||' после переноса исторических данных: ' ||v_cnt_row_hist_a||';'||v_crlf;
    v_cnt := v_cnt_row_trg_b - v_cnt_row_trg_a;
    v_inf := v_inf || v_crlf || ' оличество перенесенных записей из целевой таблицы '||v_owner||'.'||v_table_name||': ' ||v_cnt||';'||v_crlf;
    commit;
    -------------------------------------------------------------------------------------- 
    -- ѕроверка успешности переноса иторических данных
    --------------------------------------------------------------------------------------
    v_cnt := 0;
    v_sql :=    'select count(*) from
                (
                     select 1, '||v_sel_cols||',cnt from 
                     (
                        select 1,'||v_sel_cols||', count(*) cnt
                        from
                        ( 
                            select 1, '||v_sel_cols||'
                            from '||v_owner||'.'||v_hist_table_name||'
                            where prc_id = '|| v_prc_id ||'                        
                            union all
                            select 1, '||v_sel_cols||'
                            from '||v_owner||'.'||v_table_name||'
                        )
                        group by  '||v_sel_cols||'                                   
                        union all
                        select 2, '||v_sel_cols||', count(*) cnt
                        from  vtbl_bkp.BKP_'||v_prc_id||'_'||v_table_name||'
                        group by '||v_sel_cols||'
                     )
                    group by '||v_sel_cols||',cnt
                    having count(1) <> 2
                ) where rownum < 2';                    
--    dbms_output.put_line(v_sql); 
    execute immediate v_sql into v_cnt;
    if v_cnt <> 0 then
            raise_application_error(-20001, 'ƒанные целевой таблицы '||v_owner||'.'||v_hist_table_name
                                            ||' перенесены некорректно. Ќеобходимо востановить данные из BACK UP таблицы vtbl_bkp.BKP_'||v_prc_id||'_'||v_table_name
                                            ||case when v_rebuild_index_flg = '1' then 'и пересоздать индексы(ddl в etl.CTL_COPY_HIST_DATA_LOG)' else '' end);                              
    end if;      
    etl.LOG_PRC_COPY_HIST_DATA(p_prc_id => v_prc_id,p_prc_name=>v_prc_name,p_step_name => 'CHECK LOADED DATA',p_prc_status=>null);    
    --------------------------------------------------------------------------------------
    -- ѕересоздание индексов 
    --------------------------------------------------------------------------------------
    if (v_rebuild_index_flg = '1')  then
            for i in 1..v_ddl_scripts_tab.count loop
            v_ddl_script := v_ddl_scripts_tab(i);
            v_index_name := trim(BOTH '"' from substr(v_ddl_script, instr(v_ddl_script,'.')+1,instr(v_ddl_script, ' ON ') -instr(v_ddl_script,'.')-1));
--            dbms_output.put_line(v_ddl_script);
            execute immediate v_ddl_script;
            etl.LOG_PRC_COPY_HIST_DATA(p_prc_id => v_prc_id,p_prc_name=>v_prc_name,p_step_name => 'CREATE INDEX',p_prc_status=> null
                            ,p_prc_add_inf=> 'CREATE INDEX:'||v_ddl_script);
        end loop;        
    end if;                      
    etl.LOG_PRC_COPY_HIST_DATA(p_prc_id => v_prc_id,p_prc_name=>v_prc_name,p_step_name=> 'END', p_prc_status=> 'SUCCEEDED', p_prc_add_inf=>v_inf);
    commit;
exception
    when others then
        etl.LOG_PRC_COPY_HIST_DATA(p_prc_id => v_prc_id,p_prc_name=>v_prc_name,p_step_name=> 'END',p_prc_status=> 'ERROR', p_prc_add_inf=>substr(SQLERRM || chr(10) || dbms_utility.format_error_backtrace, 1, 4000));
end;
/

