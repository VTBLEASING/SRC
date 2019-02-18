create or replace procedure etl.SET_FILE_STATUS(p_file_id number, p_status_cd varchar2) AS
pragma autonomous_transaction;
begin
    update ctl_input_files
    set STATUS_CD = p_status_cd
    ,status_dt=sysdate
    where file_id = p_file_id;

    update  CTL_INPUT_FILES_LOADING
    set STATUS_CD = p_status_cd
    where file_id = p_file_id;

    insert into CTL_INPUT_FILES_LOG(file_id, status_cd, create_dt)
    values(p_file_id,p_status_cd ,sysdate);
    commit;
end;
/

