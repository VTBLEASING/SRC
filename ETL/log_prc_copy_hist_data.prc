create or replace procedure etl.LOG_PRC_COPY_HIST_DATA(p_prc_id number, p_prc_name varchar2,p_step_name varchar2,  p_prc_status varchar2, p_prc_add_inf varchar2 default null) as
    pragma autonomous_transaction;
begin
    insert into etl.CTL_COPY_HIST_DATA_LOG(PRC_ID,PRC_NAME,STEP_NAME, STATUS,PRC_TIMESTAMP,ADD_INF)
        values(p_prc_id,p_prc_name,p_step_name, p_prc_status,systimestamp, p_prc_add_inf );
    commit;        
end;
/

