create or replace procedure etl.rollback_data(p_file_id number, p_table_name varchar2, p_owner varchar2 default 'DWH') is
    v_file_id number;
    v_table_name varchar2(30);
    v_owner  varchar2(30);

    v_cnt number;


    v_sel_col varchar2(30000) := '';
    v_uk_col  varchar2(30000) := '';    
    
    v_load_dt DATE;
    
    p_cur integer;
    p_res integer;

    --v_sql     CLOB := '';
    v_sql   varchar2(30000);
    v_update_dt date := sysdate;     

begin
    
    execute immediate 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';

    v_file_id := p_file_id;
    v_table_name := upper(trim(p_table_name));
    v_owner := upper(trim(p_owner));
   
    v_sql := ' select max(VALID_FROM_DTTM) into :v_dt from '||v_owner ||'.'||v_table_name || ' where file_id = ' || v_file_id;
    
    execute immediate  v_sql into v_load_dt;

    ----------------------------------------------------------------------------
    -- Закрытие записей из файла с идентификатором p_file_id
    ----------------------------------------------------------------------------
    
     v_sql := 'update ' ||v_owner || '.' ||  v_table_name ||
               ' set valid_to_dttm = to_date('''|| to_char(v_update_dt)||''', ''DD.MM.YYYY HH24:MI:SS'')
               where file_id = ' || v_file_id 
               || ' and valid_from_dttm = to_date('''|| to_char(nvl(v_load_dt,to_date('01.01.0001','dd.mm.yyyy')  ), 'DD.MM.YYYY HH24:MI:SS') ||''', ''DD.MM.YYYY HH24:MI:SS'')'
               || ' and valid_to_dttm = to_date(''01.01.2400'',''dd.mm.yyyy'') ';

      dbms_output.put_line(substr(v_sql,1,4000));
    
     execute immediate v_sql;
    
    
    

    
    
    for cols in (select column_name
                  from all_tab_columns
                  where table_name = v_table_name
                  and owner = v_owner
                  and column_name not in ('VALID_FROM_DTTM',
                                           'VALID_TO_DTTM')
                ) 
    loop
        v_sel_col :=  v_sel_col || ',' || cols.column_name || chr(10); 
    end loop;   
    
    for ind_cols in (   select * from all_ind_columns
                        where TABLE_OWNER = v_owner
                        and TABLE_NAME = v_table_name
                        and INDEX_NAME like 'U!_%' escape '!'
                        and column_name <> 'VALID_TO_DTTM'  
                    ) loop

        v_uk_col :=  v_uk_col || ',' || ind_cols.column_name || chr(10);
    end loop;
    

    v_sel_col := SUBSTR(v_sel_col, 2);    
    v_uk_col := SUBSTR(v_uk_col, 2);

     if v_table_name like '%FACT_PLAN_PAYMENTS%' then
        update DWH.FACT_PLAN_PAYMENTS
            set END_DT = to_date('31.12.3999','dd.mm.yyyy')
        where CLOSED_ROW_FILE_ID = v_file_id;
    
     else     

        v_sql := 'insert into '|| v_owner || '.' ||  v_table_name || '
                  (' || v_sel_col || ',valid_from_dttm,valid_to_dttm) 
                  select ' || v_sel_col || ',to_date('''|| to_char(v_update_dt)||''', ''DD.MM.YYYY HH24:MI:SS''), to_date(''01.01.2400'',''dd.mm.yyyy'')
                  from '||v_owner || '.'|| v_table_name || 
                  ' where rowid in 
                    (   select rid 
                        from (     
                                 select lag(rowid) over (partition by '|| replace(v_uk_col,chr(10)) || ' order by valid_from_dttm  ) rid 
                                 , file_id, valid_to_dttm
                                 from '||v_owner || '.' ||  v_table_name ||'
                            )
                     where  file_id = ' || v_file_id || '
                     and valid_to_dttm = to_date('''|| to_char(v_update_dt)||''', ''DD.MM.YYYY HH24:MI:SS'') 
                  )
                    and valid_to_dttm = to_date('''|| to_char(nvl(v_load_dt,to_date('01.01.0001','dd.mm.yyyy')  ), 'DD.MM.YYYY HH24:MI:SS') ||''', ''DD.MM.YYYY HH24:MI:SS'')
                  ';  
        
                
          dbms_output.put_line(substr(v_sql,1,4000));

          p_cur := dbms_sql.open_cursor;

         dbms_sql.parse(p_cur,v_sql,dbms_sql.native);

         p_res := dbms_sql.execute(p_cur);
     
         dbms_sql.close_cursor(p_cur);
     
     end if;

      
     if v_table_name = 'FACT_REAL_PAYMENTS' then
        update DWH.FACT_REAL_PAYMENTS
            set VALID_TO_DTTM = to_date('01.01.2400','dd.mm.yyyy')
        where CLOSED_ROW_FILE_ID = v_file_id;
     end if;    



    
    commit;    

end;
/

