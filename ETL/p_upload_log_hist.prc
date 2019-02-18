CREATE OR REPLACE PROCEDURE ETL.p_upload_log_hist
                             (p_sys_dt date,
                              p_src_table              VARCHAR2,
                              p_trg_table              VARCHAR2,
                              p_log_table              VARCHAR2,
                              p_username               VARCHAR2,
                              p_owner                  VARCHAR2
                              ) IS
        v_sys_dt DATE;
        v_sys_dt_char VARCHAR2(100 BYTE);
        v_src_table   VARCHAR2(30 BYTE) := upper(p_src_table);
        v_trg_table   VARCHAR2(30 BYTE) := upper(p_trg_table);
        v_log_table   VARCHAR2(30 BYTE) := upper(p_log_table);
        v_username    VARCHAR2(255 BYTE) := upper(p_username);
        v_owner    VARCHAR2(255 BYTE) := upper(p_owner);
    
        v_tmp_update_tab VARCHAR2(30 BYTE) := substr('TU_' || upper(p_trg_table), 1, 30); --временная таблица. Данные для обновления старых версий
        v_tmp_insert_tab VARCHAR2(30 BYTE) := substr('TI_' || upper(p_trg_table), 1, 30); --временная таблица. Данные для вставки новых версий
    
        v_all_cols_tab_cnt number;
        v_key_cols_tab_cnt number;
    
        v_all_cols_list VARCHAR2(32000); -- список всех полей через запятую
        v_key_cols_list VARCHAR2(32000); -- список ключевых полей через запятую
    
        v_cnt        NUMBER;
        v_i          NUMBER;
        v_tmp_sql    VARCHAR2(32000);
        v_old_sql VARCHAR2(32000);
        v_new_sql VARCHAR2(32000);
    
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
        -- генерация кода по списку всех полей
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
    
        -- генерация кода по списку ключевых полей
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
        
        -- генерация кода для condition
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
    
      --dbms_output.put_line(v_on_condition);
    
        /*******************************************************/
        -- UPDATE. Записываем старую запись в таблицу логов
        
         v_old_sql := 'INSERT INTO ' || v_owner || '.' || v_log_table || '(' || v_all_cols_list || ', VALID_FROM_DTTM, VALID_TO_DTTM, PROCESS_KEY, FILE_ID, USERNAME, OPER_TYPE)
            SELECT '
                || v_all_cols_list || ', 
                VALID_FROM_DTTM, '
                || 'VALID_TO_DTTM, '
                || 'PROCESS_KEY, 
                FILE_ID, '''
                || v_username ||''',
                -1                
              FROM DWH.' || v_trg_table || ' a
              WHERE EXISTS (
                  SELECT 1 
                  FROM dwh.' || v_trg_table || ' B
                  WHERE ' ||
                  v_on_condition || ')
                  AND VALID_TO_DTTM =  to_date (''' || v_sys_dt_char || ''', ''dd.mm.yyyy hh24:mi:ss'')
                  ';
    
        EXECUTE IMMEDIATE v_old_sql;
            --USING v_business_dt;
        --v_upd_cnt := SQL%ROWCOUNT;
        --dbms_output.put_line(v_old_sql);    
        /*******************************************************/
        -- INSERT. Записываем новые записи в таблицу логов
        v_new_sql := 'INSERT INTO ' || v_owner || '.' || v_log_table || '(' || v_all_cols_list || ', VALID_FROM_DTTM, VALID_TO_DTTM, PROCESS_KEY, FILE_ID, USERNAME, OPER_TYPE)
            SELECT '
                || v_all_cols_list || ', 
                to_date (''' || v_sys_dt_char || ''', ''dd.mm.yyyy hh24:mi:ss''),'
                || 'TO_DATE (''01.01.2400'', ''DD.MM.YYYY''), '
                || '777, 0, '''
                || v_username ||''',
                3
              FROM ' || v_tmp_insert_tab;

--dbms_output.put_line(v_new_sql);    
        EXECUTE IMMEDIATE v_new_sql;
            --USING v_business_dt;
        --v_ins_cnt := SQL%ROWCOUNT;
    

    END;
/

