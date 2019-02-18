create or replace procedure etl.P_CHECK_FILLING_STG_TABLES(p_source_name varchar2)
as
    v_cnt number;
    v_schema_name varchar2(100);
    v_sql varchar2(10000);
begin
    select SCHEMA_NAME 
    into v_schema_name
    from REF_STG_SCHEMA_SOURCE_NAME
    where SOURCE_NAME = trim(upper(p_source_name));

    for rec in (select a.FILE_ID,c.STG_TABLE_NAME 
                from CTL_INPUT_FILES_LOADING a,CTL_INPUT_FILES b,CTL_ACTUAL_FILE_TYPES c 
                where a.file_id = b.file_id
                and trim(upper(b.SOURCE_NAME))= trim(upper(p_source_name))
                and trim(upper(a.FILE_TYPE_CD))= trim(upper(c.FILE_TYPE_CD))
                and b.STATUS_CD = 1
                ) loop
    v_cnt := 0;
    v_sql:='select count(*) into :v_cnt from '||v_schema_name||'.'||rec.STG_TABLE_NAME;
    dbms_output.put_line(v_sql);
    execute immediate 'select count(*) into :v_cnt from '||v_schema_name||'.'||rec.STG_TABLE_NAME into v_cnt;
        if v_cnt = 0 then 
            update CTL_INPUT_FILES
            set STATUS_CD = -11
            where file_id = rec.file_id
            and STATUS_CD = 1;
            update CTL_INPUT_FILES_LOADING
            set STATUS_CD = -11
            where file_id = rec.file_id;
            commit;
        end if; 
    end loop;    
--exception
--    when others then
--        dbms_output.put_line(dbms_utility.format_error_backtrace);    
end;
/

