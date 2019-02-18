create or replace procedure etl.P_CHECK_FILLING_STG_XLS_TABLES
as
    v_cnt number;
begin
    for rec in (select a.FILE_ID,a.FILE_TYPE_CD 
                from CTL_INPUT_FILES_LOADING a,CTL_INPUT_FILES b
                where a.file_id = b.file_id
                and b.SOURCE_NAME = 'XLS'
                and b.STATUS_CD = 1
                ) loop
    v_cnt := 0;
    execute immediate 'select count(*) into :v_cnt from STG_XLS.'||rec.FILE_TYPE_CD into v_cnt;
        if v_cnt = 0 then 
            update CTL_INPUT_FILES
            set STATUS_CD = -11
            where file_id = rec.file_id
            and STATUS_CD = 1;
            update CTL_INPUT_FILES_LOADING
            set STATUS_CD = -11
            where file_id = rec.file_id;
            insert into CTL_INPUT_FILES_LOG(file_id, status_cd, create_dt) values(rec.file_id, -11, sysdate);
            commit;
        end if; 
    end loop;    
end;
/

