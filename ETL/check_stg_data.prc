create or replace procedure etl.CHECK_STG_DATA(p_FILE_TYPE varchar2, p_OWNER varchar default 'STG_XLS') as
    v_file_type varchar2(100):= trim(upper(p_FILE_TYPE));
    v_crical_er_flg number := 0;
    v_file_id number;
    v_sql                    CLOB;
    v_sql_query              DBMS_SQL.varchar2s;
    v_rowcnt                 NUMBER;
    v_dbms_sql_cursor        NUMBER;
    v_clob clob;
    v_sql_stg_count          varchar2(32767);
begin
    v_sql_stg_count:='select max(file_id) into :v from '||p_OWNER||'.'||p_FILE_TYPE;
    dbms_output.put_line(v_sql_stg_count);
    begin
    execute immediate 'select max(file_id) into :v from '||p_OWNER||'.'||p_FILE_TYPE into v_file_id;
    exception when others then
    execute immediate 'select max(replace(f3,''.'')) into :v from '||p_OWNER||'.'||p_FILE_TYPE||' where rownum<3' into v_file_id;
    end;
    for rec in (select SQL_TEXT,ERROR_TYPE from CTL_CHECK_DATA_RULES where FILE_TYPE = v_file_type) loop

    --    DBMS_OUTPUT.PUT_LINE(rec.SQL_TEXT);

--        DBMS_OUTPUT.PUT_LINE(v_crical_er_flg);


         v_sql_query := CONVERT_CLOB_TO_VARCHAR2S(rec.SQL_TEXT);
         dbms_output.put_line(rec.SQL_TEXT);
         v_dbms_sql_cursor := DBMS_SQL.open_cursor;
         DBMS_SQL.parse (v_dbms_sql_cursor,
                         v_sql_query,
                         1,
                         v_sql_query.COUNT,
                         FALSE,
                         DBMS_SQL.native);
         v_rowcnt := DBMS_SQL.execute (v_dbms_sql_cursor);
         COMMIT;
         DBMS_SQL.close_cursor (v_dbms_sql_cursor);

        if (rec.ERROR_TYPE = 'C') then
             v_crical_er_flg := v_crical_er_flg + v_rowcnt;
        end if;

--        if (v_crical_er_flg > 0) then
--             insert into kav_clob values (rec.SQL_TEXT,sysdate, v_crical_er_flg);
--        end if;


--        DBMS_OUTPUT.PUT_LINE(v_crical_er_flg);

        commit;
    end loop;

    if v_crical_er_flg > 0 then

        for rec in (select STG_TABLE_NAME from etl.CTL_ACTUAL_FILE_TYPES where upper(FILE_TYPE_CD) = p_FILE_TYPE) loop
            begin
            execute immediate 'create table '||p_OWNER||'.T$'||rec.STG_TABLE_NAME ||' as select * from '||p_OWNER||'.'||rec.STG_TABLE_NAME||' where 1=2';
            exception when others then
              null;
            end;
            begin
            execute immediate 'insert into '||p_OWNER||'.T$'||rec.STG_TABLE_NAME ||'  select * from '||p_OWNER||'.'||rec.STG_TABLE_NAME;
            exception when others then
              null;
            end;
            execute immediate 'truncate table '||p_OWNER||'.'||rec.STG_TABLE_NAME ;

        end loop;

        set_loading_file_status(p_file_id =>  v_file_id, p_status => '-211');

    end if;

    commit;


/*      EXCEPTION
         WHEN OTHERS
         THEN

            ETL.SET_FILE_STATUS(v_file_id, '-23');

            IF DBMS_SQL.IS_OPEN (v_dbms_sql_cursor)
            THEN
               DBMS_SQL.close_cursor (v_dbms_sql_cursor);
            END IF;

            raise_application_error(sqlerrm,dbms_utility.format_error_backtrace);
            
*/
end;
/

