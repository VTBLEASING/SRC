create or replace procedure etl.P_DM_LOG(p_dm_name varchar2) is
 PRAGMA AUTONOMOUS_TRANSACTION;
begin
    insert into etl.dm_log (dm_name,log_timestamp) 
        values(trim(upper(p_dm_name)),systimestamp);
    commit;        
end;
/

