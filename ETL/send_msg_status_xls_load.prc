create or replace procedure etl.send_msg_status_xls_load(p_file_id number)
is
    v_cnt_error number;
    v_subject varchar2(1000);
    v_msg_text clob;
    v_flg number;
    v_txt varchar2(32000);
    v_sql varchar2(32000);
    v_table_title varchar2(500);
    v_recipients varchar2(32000);
    v_file_type_cd varchar2(500);
    v_branch_cd varchar2(500); 
begin
    select 1, file_type_cd
    ,substr (file_name,   instr (file_name,'\',-1,2)+ 1,
                                instr (file_name,'\',-1,1)
                              - instr (file_name,'\',-1,2)-1)    
    into v_flg, v_file_type_cd,v_branch_cd
    from etl.ctl_input_files
    where file_id = p_file_id
    and SOURCE_NAME = 'XLS'
    and rownum < 2;
    --and upper(FILE_TYPE_CD) in (select distinct upper(FILE_TYPE_CD) from CTL_CHECK_DATA_RULES );
    
    if v_flg = 0 then 
        return;
    end if;
    
    select count(*)
    into v_cnt_error
    from etl.ctl_error_load_log
    where file_id = p_file_id;
    
    select 'Результат выполнения этапа: Загрузка файла '||FILE_TYPE_CD
    into v_subject
    from  ctl_input_files
    where file_id =   p_file_id;
    
    v_msg_text := 'Результат выполнения этапа: завершено '
                    ||case when v_cnt_error = 0 then  'успешно.' else 'с ошибками.' end || '<br><br>';
    
    select 'Параметры выполнения этапа:'||'<br>'
    || 'Организация: ' || nvl(os.BRANCH_NAM,
                            (select BRANCH_NAM from DWH.ORG_STRUCTURE 
                            where BRANCH_CD = 'VTB_LEASING' 
                            and VALID_TO_DTTM = to_date('01.01.2400','dd.mm.yyyy')
                            and rownum < 2
                            )) || '<br>'
    || 'Период отчета: ' ||     (select max(PARAM_VALUE) from etl.CTL_PARAM
                                where PARAM_NAME = 'p_REPORT_DT'
                                and PARAM_FUNC = 'WF_LOAD_STG_XLS'
                                and OWNER = 'AAP'
                                and VALID_FROM_DTTM < sysdate
                                and VALID_TO_DTTM >= sysdate
                                ) ||'<br>'
    || 'Пользователь: ' || ctl.user# ||'<br>'
    || 'Дата выполнения: ' || to_char(ctl.CREATE_DT, 'dd.mm.yyyy hh24:mi:ss') ||'<br>'
    || 'Информационная база: ' || ( select HOST_NAME from v$instance) ||'<br>'
    into v_txt
    from ctl_input_files ctl
        left join DWH.ORG_STRUCTURE os
            on SUBSTR (file_name,
                  INSTR (file_name,
                         '\',
                         -1,
                         2)
                + 1,
                  INSTR (file_name,
                         '\',
                         -1,
                         1)
                - INSTR (file_name,
                         '\',
                         -1,
                         2)
                - 1) = os.BRANCH_CD
                and VALID_TO_DTTM = to_date('01.01.2400','dd.mm.yyyy') 
     where ctl.file_id =p_file_id;
     
     v_msg_text := v_msg_text || v_txt;
     
     if v_cnt_error <> 0 then
     
            v_msg_text := v_msg_text ||'<br><br>'|| 'Протокол ошибок:' ||'<br><br>'; 
            v_table_title := 'Номер строки,Дата загрузки, ID файла,Тип файла, Название файла, Пользователь,Тип ошибки,Текст ошибки'; 
            
            v_sql :=   'select ROW_NUM, log_date, file_id, file_type, file_name , user# ,ERROR_TYPE , ERROR_TEXT
                        from
                            (select err_log.log_date, err_log.file_id, err_log.file_type
                                                    , substr (FILE_NAME, INSTR (FILE_NAME, ''\'', -1) + 1) file_name
                                                    , user#, err_log.ERROR_TYPE, err_log.ERROR_TEXT, err_log.ROW_NUM 
                                                    from etl.ctl_error_load_log err_log inner join etl.ctl_input_files ctf on ctf.file_id = err_log.file_id
                                                    where ctf.file_id = '||p_file_id||'
                             )';  
        
            v_msg_text := v_msg_text || create_html_table_data(v_sql,v_table_title );
     
     end if;
     
    v_recipients := '';
    
    for rec in (    select distinct EMAIL
                    from (
                        select cu.EMAIL
                        from CTL_USERS cu 
                            inner join REF_USER_GROUP rug
                                on cu.USER_ID = rug.USER_ID
                                and rug.ACTUAL_FLG = 1
                            inner join REF_GROUP_ROLE rgr 
                                on rug.GROUP_ID = rgr.GROUP_ID
                                and rgr.ACTUAL_FLG = 1
                            inner join CTL_ROLES cr
                                on rgr.ROLE_ID = cr.ROLE_ID
                                and cr.ACTUAL_FLG = 1
                                and cr.ROLE_CD = 'SEND_XLS_FILE_STATUS'
                            inner join REF_GROUP_FILE_TYPE rgft
                                on rug.GROUP_ID = rgft.group_id
                                and rgft.ACTUAL_FLG = 1      
                            inner join CTL_FILE_TYPES cft
                                on rgft.FILE_TYPE_ID = cft.FILE_TYPE_ID
                                and cft.ACTUAL_FLG = 1     
                                and cft.FILE_TYPE_CD = v_file_type_cd
                            left join REF_GROUP_BRANCH rgb
                                on rgr.GROUP_ID = rgb.GROUP_ID 
                                and rgb.ACTUAL_FLG = 1  
                            left join CTL_BRANCHES cb 
                                on rgb.BRANCH_ID = cb.BRANCH_ID
                                and cb.ACTUAL_FLG = 1
                        where (cft.BRANCH_FLG = 0 or (cft.BRANCH_FLG = 1 and cb.BRANCH_CD = v_branch_cd))  
                        and cu.ACTUAL_FLG = 1                               
                        union 
                        select cu.EMAIL
                        from CTL_USERS cu 
                            inner join REF_USER_GROUP rug
                                on cu.USER_ID = rug.USER_ID
                                and rug.ACTUAL_FLG = 1     
                            inner join CTL_USER_GROUPS cug
                                on cug.GROUP_ID = rug.GROUP_ID
                                and cug.ACTUAL_FLG = 1  
                        where cug.GROUP_CD in ('ADMIN','OPERATOR')    
                        and cu.ACTUAL_FLG = 1                               
                    )
                ) loop
        v_recipients := v_recipients||';'||rec.EMAIL;                       
    end loop;                
    
    
    
    v_recipients := substr(v_recipients,2);

dbms_output.put_line(v_recipients);    
dbms_output.put_line('');
dbms_output.put_line(v_msg_text);    

    mail_pkg.set_mailserver('10.0.2.79', 25);
                mail_pkg.send( mailto =>  v_recipients
                                , subject => v_subject
                                , message => v_msg_text
                                , mailfrom => 'support@vtb-leasing.ru'
                                , mimetype => 'text/html'
                                , priority => 0 );
     

end;
/

