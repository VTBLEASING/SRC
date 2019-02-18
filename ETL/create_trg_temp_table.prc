CREATE OR REPLACE PROCEDURE ETL.create_trg_temp_table(p_tab_name       VARCHAR2,
                                    p_owner_table    VARCHAR2,
                                    p_tmp_tab_name   VARCHAR2,
                                    p_tmp_tab_type   VARCHAR2,
                                    p_cols_list_type VARCHAR2,
                                    p_cols_list      VARCHAR2 DEFAULT NULL,
                                    p_cols_prefix    VARCHAR2 DEFAULT NULL,
                                    p_cols_postfix   VARCHAR2 DEFAULT NULL) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    
        v_cols_array     dbms_sql.varchar2s;
        v_cols_str       VARCHAR2(32000);
        v_sql            VARCHAR2(32000);
        v_tab_name       VARCHAR2(30) := upper(TRIM(p_tab_name));
        v_owner_table    VARCHAR2(30) := upper(TRIM(p_owner_table));
        v_cols_list      VARCHAR2(32000) := upper(TRIM(p_cols_list));
        v_cols_prefix    VARCHAR2(500) := upper(TRIM(p_cols_prefix));
        v_cols_postfix   VARCHAR2(500) := upper(TRIM(p_cols_postfix));
        v_tmp_tab_name   VARCHAR2(500) := upper(TRIM(p_tmp_tab_name));
        v_cols_list_type VARCHAR2(500) := upper(p_cols_list_type);
        v_tmp_tab_type   VARCHAR2(100) := upper(p_tmp_tab_type);
        v_cnt            NUMBER;
    BEGIN
        -- проверка существования таблицы
        SELECT COUNT(*) INTO v_cnt FROM user_tables WHERE table_name = v_tab_name;
        IF v_cnt <> 1 THEN
            raise_application_error(-20001, 'Table (' || v_tab_name || ') does not exists'); --UTIL_ERR
        END IF;
    
        -- тип списка полей
        IF v_cols_list_type = 'EXCEPT' THEN
            -- все поля кроме полей из списка.
            v_cols_array := util_std.get_table_cols('ALL', v_tab_name, v_cols_list);
        ELSIF v_cols_list_type = 'KEEP' THEN
            -- только поля из списка.
            v_cols_array := util_std.tokenize(v_cols_list, ',', 1);
        ELSIF v_cols_list_type = 'ALL' THEN
            -- все поля
            v_cols_array := util_std.get_table_cols('ALL', v_tab_name);
        ELSE
            raise_application_error(-20001, 'Unknown columns list type:' || v_cols_list_type); --UTIL_ERR
        END IF;
    
        IF v_cols_array.count = 0 THEN
            raise_application_error(-20001, 'Can NOT create temporary table (' || v_tmp_tab_type || ') without columns'); --UTIL_ERR
        END IF;
    
        FOR i IN 1 .. v_cols_array.count
        LOOP
            v_cols_str := v_cols_str || v_cols_array(i) || ' ' || v_cols_prefix || v_cols_array(i) || v_cols_postfix || CASE
                              WHEN i <> v_cols_array.count THEN
                               ',' || chr(10)
                          END;
        END LOOP;
    
        v_sql := 'CREATE GLOBAL TEMPORARY TABLE ' || v_tmp_tab_name || ' ON COMMIT ' || v_tmp_tab_type ||
                 ' ROWS AS
                    SELECT ' || v_cols_str || '
                    FROM '||v_owner_table||'.'|| v_tab_name || '
                    WHERE 1=0';
        --        DBMS_OUTPUT.put_line(v_sql);
        EXECUTE IMMEDIATE v_sql;
    END;
/

