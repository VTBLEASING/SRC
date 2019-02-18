create or replace procedure etl.P_RUN_COPY_HIST_DATA
--authid current_user
as
    v_prc_id number;
    v_cnt number;
    v_step_name varchar2(100);
    v_add_inf varchar2(4000);
    v_status varchar2(100);
begin
    -------------------------------------------------------------------------------------- 
    -- Проверка запуска процедуры
    --------------------------------------------------------------------------------------
    select max(step_name) keep (dense_rank first order by prc_id, prc_timestamp desc)
    into v_step_name
    from etl.CTL_COPY_HIST_DATA_LOG
    where PRC_NAME = 'RUN_LOAD_HIST_DATA';
    if v_step_name <> 'END' then
        raise_application_error(-20001, 'Процедура уже запущена...'); 
    end if;                 
    -------------------------------------------------------------------------------------- 
    v_prc_id := etl.SQ_LOAD_HIST_DATA_PRC.nextval;
    SELECT 'Информация о рабочей станции, с которой был осуществлен запус процедуры. Учетная запись: ' ||SYS_CONTEXT ('userenv', 'os_user') 
            || ', IP: ' ||SYS_CONTEXT ('userenv', 'ip_address')
            || ', учетная запись в БД: ' ||SYS_CONTEXT ('userenv', 'session_user')
    into v_add_inf            
    FROM DUAL;
    etl.LOG_PRC_COPY_HIST_DATA(p_prc_id => v_prc_id,p_prc_name=>'RUN_LOAD_HIST_DATA',p_step_name => 'START'
                            ,p_prc_status=>null, p_prc_add_inf =>  v_add_inf);
    for rec in (select * from etl.CTL_COPY_HIST_DATA_PARAMS where ACTUAL_FLG = '1' ) loop
            P_TO_HIST_TABLE (
            p_prc_id => v_prc_id , 
            p_table_name => rec.TABLE_NAME,
            p_hist_table_name => rec.HIST_TABLE_NAME, 
            p_owner => rec.TABLE_OWNER
            );
    end loop;
    -------------------------------------------------------------------------------------- 
      
    select decode(cnt, 0, 'SUCCEEDED', 'ERROR')
    into v_status
    from   
    (
        select count(1)  cnt
        from etl.CTL_COPY_HIST_DATA_LOG
        where prc_id = v_prc_id
        and status = 'ERROR' 
    );
    etl.LOG_PRC_COPY_HIST_DATA(p_prc_id => v_prc_id,p_prc_name=>'RUN_LOAD_HIST_DATA',p_step_name => 'END'
                            ,p_prc_status=>v_status);
    etl.SEND_LOAD_HIST_DATA_STATUS(v_prc_id);                                
exception
    when others then
        LOG_PRC_COPY_HIST_DATA(p_prc_id => v_prc_id,p_prc_name=>'RUN_LOAD_HIST_DATA',p_step_name => 'END'
                                ,p_prc_status=>'ERROR', p_prc_add_inf=>substr(SQLERRM || chr(10) || dbms_utility.format_error_backtrace, 1, 4000));                                                                  
    etl.SEND_LOAD_HIST_DATA_STATUS(v_prc_id);
end;
/

