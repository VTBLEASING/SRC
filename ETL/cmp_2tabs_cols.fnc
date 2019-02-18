CREATE OR REPLACE FUNCTION ETL.cmp_2tabs_cols(     p_tab1_name   VARCHAR2,
                             p_tab2_name   VARCHAR2,
                             p_except_cols VARCHAR2 DEFAULT NULL,
                             p_tab1_owner VARCHAR2 DEFAULT NULL,
                             p_tab2_owner VARCHAR2 DEFAULT NULL) RETURN BOOLEAN IS
         PRAGMA AUTONOMOUS_TRANSACTION;
     
         v_tab1_name   VARCHAR2(30 BYTE) := upper(TRIM(p_tab1_name));
         v_tab2_name   VARCHAR2(30 BYTE) := upper(TRIM(p_tab2_name));
         v_tab1_owner VARCHAR2(30 BYTE) := upper(TRIM(p_tab1_owner));
         v_tab2_owner VARCHAR2(30 BYTE) := upper(TRIM(p_tab2_owner));
         v_except_cols VARCHAR2(32000) := upper(TRIM(p_except_cols));
         v_sql         VARCHAR2(32000);
         v_sel_table   VARCHAR2(30 BYTE);
         v_sel_fields  VARCHAR2(32000);
         v_sel_where   VARCHAR2(32000);
         v_cnt         NUMBER;
     BEGIN
         -- поля-исключения. По этим полям различия игнорируются.
         IF v_except_cols IS NOT NULL THEN
             v_except_cols := ' AND column_name NOT IN (' || get_csv_double_quotes(v_except_cols) || ') ';
         END IF;
     
         -- оперделяем тип сравниваемых полей
        --  и соответствующие этому типу параметры запроса
             -- сравниваются все поля кроме полей-исключений
             v_sel_fields := 'column_name, data_type, data_length';
             v_sel_table  := 'all_tab_columns';
             v_sel_where  := NULL;
     
         -- собираем запрос для сравнения таблиц
        v_sql := 'SELECT COUNT(*) RET
           FROM
             (SELECT 1 as FLG
             FROM
                 (SELECT ' || v_sel_fields || '
                        FROM ' || v_sel_table    ||' 
                      WHERE table_name = :tab1 ' || 
                       ' and owner = :owner1 '   || v_except_cols ||
                     'UNION ALL
                  SELECT ' || v_sel_fields || '
                        FROM ' || v_sel_table    ||'
                      WHERE table_name = :tab2 ' || 
                       ' and owner = :owner2 '   || v_except_cols ||
                  ')
             GROUP BY ' || v_sel_fields || '
             HAVING COUNT(*) <> 2)';
     
         -- выполняем скрипт сравнения таблиц
--        DBMS_OUTPUT.put_line(v_sql);
         EXECUTE IMMEDIATE v_sql
             INTO v_cnt
             USING v_tab1_name,p_tab1_owner, v_tab2_name,p_tab2_owner;
     
--        DBMS_OUTPUT.put_line(v_cnt);     
         ROLLBACK;
         RETURN v_cnt = 0;
     END;
/

