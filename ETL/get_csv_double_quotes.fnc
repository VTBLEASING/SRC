CREATE OR REPLACE FUNCTION ETL.get_csv_double_quotes(p_csv VARCHAR2) RETURN VARCHAR2 IS
        v_csv       VARCHAR2(32000) := TRIM(p_csv);
        v_names_tab dbms_sql.varchar2s;
        v_retval    VARCHAR2(32000);
        v_row_index NUMBER;
    BEGIN
        v_names_tab := etl.util_std.tokenize(v_csv, ',', 1);
        v_row_index := v_names_tab.first;
    
        LOOP
            EXIT WHEN v_row_index IS NULL;
            v_retval := v_retval || '''' || v_names_tab(v_row_index) || '''' || CASE
                            WHEN v_row_index <> v_names_tab.last THEN
                             ','
                        END;
        
            v_row_index := v_names_tab.next(v_row_index);
        END LOOP;
        RETURN v_retval;
    END;
/

