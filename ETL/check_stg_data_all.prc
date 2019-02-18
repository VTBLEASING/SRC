create or replace procedure etl.CHECK_STG_DATA_ALL as
begin
    for rec in (select distinct a.FILE_TYPE  from CTL_CHECK_DATA_RULES a, CTL_INPUT_FILES_LOADING b
                where upper(a.FILE_TYPE) = b.FILE_TYPE_CD
                order by FILE_TYPE ) loop
        CHECK_STG_DATA( p_FILE_TYPE=> rec.FILE_TYPE);
    end loop;
end;
/

