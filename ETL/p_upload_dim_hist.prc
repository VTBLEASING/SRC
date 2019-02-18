CREATE OR REPLACE PROCEDURE ETL.p_upload_dim_hist
                             (p_sys_dt date,
                              p_src_table              VARCHAR2,
                              p_trg_table              VARCHAR2,
                              p_src_owner              VARCHAR2,
                              p_process_key            NUMBER,
                              p_indx_substr_src NUMBER default 3
                              ) IS
        v_sys_dt DATE;
        v_sys_dt_char VARCHAR2(100 BYTE);
        v_src_table   VARCHAR2(30 BYTE) := upper(p_src_table);
        v_trg_table   VARCHAR2(30 BYTE) := upper(p_trg_table);
        v_src_owner   VARCHAR2(30 BYTE) := upper(p_src_owner);
        v_process_key NUMBER := p_process_key;
    
        v_tmp_update_tab VARCHAR2(30 BYTE) := substr('TU_' || upper(p_trg_table), 1, 30); --временна¤ таблица. ?анные дл¤ обновлени¤ старых версий
        v_tmp_insert_tab VARCHAR2(30 BYTE) := substr('TI_' || upper(p_trg_table), 1, 30); --временна¤ таблица. ?анные дл¤ вставки новых версий
    
        v_all_cols_tab_cnt number;
        v_key_cols_tab_cnt number;
    
        v_all_cols_list VARCHAR2(32000); -- список всех полей через зап¤тую
        v_key_cols_list VARCHAR2(32000); -- список ключевых полей через зап¤тую
    
        v_cnt        NUMBER;
        v_i          NUMBER;
        v_tmp_sql    VARCHAR2(32000);
        v_update_sql VARCHAR2(32000);
        v_insert_sql VARCHAR2(32000);
    
        v_delete_sql   VARCHAR2(32000);
        v_on_condition VARCHAR2(32000);
    
        v_ins_cnt NUMBER;
        v_upd_cnt NUMBER;
    BEGIN
    
        -- расчет бизнес-даты 
        v_sys_dt := p_sys_dt;
        v_sys_dt_char := to_char (v_sys_dt, 'dd.mm.yyyy hh24:mi:ss');
    
        select count (*) into v_all_cols_tab_cnt from all_tab_columns where OWNER = 'DWH' and TABLE_NAME = v_trg_table AND column_name NOT IN ('VALID_FROM_DTTM', 'VALID_TO_DTTM', 'PROCESS_KEY', 'FILE_ID');
        select count (*) into v_key_cols_tab_cnt from all_ind_columns where index_owner = 'DWH' and TABLE_NAME = v_trg_table;
    
        /*******************************************************/
        -- генераци¤ кода по списку всех полей
        FOR v_i IN 
                    (select 
                            column_name,
                            row_number () over (order by column_name) cnt
                     from all_tab_columns where OWNER = 'DWH' and TABLE_NAME = v_trg_table
                     AND column_name NOT IN ('VALID_FROM_DTTM', 'VALID_TO_DTTM', 'PROCESS_KEY', 'FILE_ID')
                    )
        LOOP
            v_all_cols_list := v_all_cols_list || v_i.column_name || CASE
                                   WHEN v_i.cnt <> v_all_cols_tab_cnt THEN
                                    ','
                               END;
        END LOOP;
        
        --dbms_output.put_line(v_all_cols_list);
    
        -- генераци¤ кода по списку ключевых полей
        FOR v_i IN (select 
                            column_name,
                            row_number () over (order by column_name) RN,
                            COUNT (1) OVER () CNT
                     from all_ind_columns where index_owner = 'DWH' and TABLE_NAME = v_trg_table and upper (index_name) like 'U!_%' escape '!'
                     AND column_name != 'VALID_TO_DTTM'
                    )
        LOOP
            v_key_cols_list := v_key_cols_list || v_i.column_name || CASE
                                   WHEN v_i.cnt <> v_i.RN THEN
                                    ','
                               END;
        END LOOP;
        
        --dbms_output.put_line(v_key_cols_list);
        
        -- генераци¤ кода дл¤ condition
        FOR v_i IN (select 
                            column_name,
                            row_number () over (order by column_name) rn,
                            COUNT (1) OVER () CNT
                     from all_ind_columns 
                     where index_owner = 'DWH' 
                     and TABLE_NAME = v_trg_table 
                     and upper (index_name) like 'U!_%' escape '!'
                     and column_name NOT IN ('BEGIN_DT', 'VALID_TO_DTTM')
                    )
        LOOP
            v_on_condition := v_on_condition || ' a.' || v_i.column_name || ' = ' || 'b.' || v_i.column_name || CASE
                                  WHEN v_i.cnt <> v_i.rn THEN
                                   ' AND '
                              END;
        END LOOP;
    
    --  dbms_output.put_line(v_on_condition);
        /*******************************************************/
        -- ѕроверка/подготовка временных таблиц
        -- INSERT
        SELECT COUNT(*) INTO v_cnt FROM user_tables WHERE table_name = v_tmp_insert_tab;
        IF v_cnt <> 1 -- ?сли нет временной таблицы - создаем
         THEN
            v_tmp_sql := 'create global temporary table ' || v_tmp_insert_tab || ' on commit delete
                          rows as 
                                  select ' || v_all_cols_list || '
                                  from DWH.' || v_trg_table || ' 
                                  where 1 = 0';
        dbms_output.put_line(v_tmp_sql);
        EXECUTE IMMEDIATE v_tmp_sql;
--        dbms_output.put_line(v_tmp_sql);
        /*ELSIF NOT (util_std.cmp_2tabs_cols('ALL', v_trg_table, v_tmp_insert_tab, 'EFFECTIVE_FROM_DTTM, EFFECTIVE_TO_DTTM')) -- ?сли структура таблицы помен¤лась - пересоздаем 
         THEN
            util_std.exec_sql_autonomous('DROP TABLE ' || v_tmp_insert_tab);
            to_upload_log('WARNING', 'TMP table ' || v_tmp_insert_tab || ' dropped', p_load_id);
        
            create_trg_temp_table(v_trg_table, v_tmp_insert_tab, 'DELETE', 'KEEP', v_all_cols_list);
            to_upload_log('WARNING', 'TMP table ' || v_tmp_insert_tab || ' created', p_load_id);
        END IF;
        */
        END IF;
        -- UPDATE
        SELECT COUNT(*) INTO v_cnt FROM user_tables WHERE table_name = v_tmp_update_tab;
        IF v_cnt <> 1 -- ?сли нет временной таблицы - создаем
         THEN
            EXECUTE IMMEDIATE ('CREATE GLOBAL TEMPORARY TABLE ' || v_tmp_update_tab ||
                                         ' (trg_rowid ROWID) ON COMMIT DELETE ROWS');           
        END IF;
    
        /*******************************************************/
        -- «агрузка временных таблиц
        v_tmp_sql := 'INSERT ALL
            -------
                WHEN 
                    (cnt_by_key = 1 AND upload_table_type = ''TRG'') OR
                    (cnt_by_key = 2 AND cnt_by_all = 1 AND upload_table_type = ''TRG'')
                THEN   
                    INTO ' || v_tmp_update_tab || '
                        (trg_rowid)
                    VALUES (trg_rowid)
            -------    
                WHEN 
                    (cnt_by_key = 1 AND upload_table_type = ''SRC'') OR
                    (cnt_by_key = 2 AND cnt_by_all = 1 AND upload_table_type = ''SRC'')
                THEN   
                    INTO ' || v_tmp_insert_tab || '
                        (' || v_all_cols_list || ')
                    VALUES (' || v_all_cols_list || ') 

            SELECT
                ' || v_all_cols_list || ',
                upload_table_type,
                trg_rowid,
                COUNT(*) OVER (PARTITION BY ' || v_key_cols_list ||
                     ') cnt_by_key,
                COUNT(*) OVER (PARTITION BY ' || v_all_cols_list || ') cnt_by_all
             FROM        
                (
                SELECT  
                    ' || v_all_cols_list || ',
                    ''SRC'' upload_table_type,
                    NULL trg_rowid
                  FROM ' || v_src_owner || '.' || v_src_table ||'
                UNION ALL
                SELECT  
                    ' || v_all_cols_list || ',
                    ''TRG'' upload_table_type,
                    ROWID trg_rowid
                  FROM DWH.' || v_trg_table || ' A
                WHERE VALID_TO_DTTM = TO_DATE (''01.01.2400'', ''DD.MM.YYYY'')
                AND  EXISTS
                (
                  SELECT 1 
                  FROM ' || v_src_owner || '.' || SUBSTR (v_src_table, p_indx_substr_src) || ' B
                  WHERE ' ||
                  v_on_condition || '
                )
              )
            ';

--dbms_output.put_line('--' || v_src_dblink);
dbms_output.put_line(v_tmp_sql);

        EXECUTE IMMEDIATE v_tmp_sql;
        -------------------------------------------------------------------------------------- 
    
        /*******************************************************/
        -- UPDATE. «акрываем старые версии бизнес-датой
        v_update_sql := 'MERGE INTO DWH.' || v_trg_table || ' trg
                USING ' || v_tmp_update_tab || ' src
                    ON (trg.ROWID = src.trg_rowid)
             WHEN MATCHED THEN
                UPDATE SET trg.VALID_TO_DTTM = to_date (''' || v_sys_dt_char|| ''', ''dd.mm.yyyy hh24:mi:ss'')'
            ;
    
        EXECUTE IMMEDIATE v_update_sql;
            --USING v_business_dt;
        --v_upd_cnt := SQL%ROWCOUNT;
dbms_output.put_line(v_update_sql);    
        /*******************************************************/
        -- INSERT. ¬ставка новых версий
        v_insert_sql := 'INSERT INTO DWH.' || v_trg_table || '(' || v_all_cols_list || ', VALID_FROM_DTTM, VALID_TO_DTTM, PROCESS_KEY, FILE_ID)
            SELECT '
                || v_all_cols_list || ', 
                to_date (''' || v_sys_dt_char || ''', ''dd.mm.yyyy hh24:mi:ss''),'
                || 'TO_DATE (''01.01.2400'', ''DD.MM.YYYY''), '
                || v_process_key || ', 0 
              FROM ' || v_tmp_insert_tab;

dbms_output.put_line(v_insert_sql);    
        EXECUTE IMMEDIATE v_insert_sql;
            --USING v_business_dt;
        --v_ins_cnt := SQL%ROWCOUNT;
    

    END;
/

