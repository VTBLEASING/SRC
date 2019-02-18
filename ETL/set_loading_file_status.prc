create or replace procedure etl.set_loading_file_status(p_file_id number, p_status varchar2)
is

PRAGMA AUTONOMOUS_TRANSACTION;

begin
    
    update CTL_INPUT_FILES_LOADING
    set STATUS_CD = upper(trim(p_status))
    where FILE_ID = p_file_id;
    
    insert into CTL_INPUT_FILES_LOG(file_id, status_cd, create_dt)
    values(p_file_id,p_status ,sysdate);

    if p_status = 'DWH' then 
        insert into CTL_INPUT_FILES_LOG(file_id, status_cd, create_dt)
        values(p_file_id,'3' ,sysdate);
    end if;


    commit;
    
    
end;
/

