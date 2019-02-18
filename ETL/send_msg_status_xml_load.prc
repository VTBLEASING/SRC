create or replace procedure etl.send_msg_status_xml_load(p_date date)
is
    v_subject varchar2(1000);
    v_msg_text clob;
    v_txt varchar2(32000);
    v_sql varchar2(32000);
    v_table_title varchar2(500);
    v_recipients varchar2(32000);
    v_host v$instance.host_name%Type;
begin
    select host_name into v_host from v$instance;
    v_subject := 'Стенд:'||v_host||' Результат выполнения этапа: Загрузка файлов ХомнетЛизинг и Консолидации ';

    
    v_msg_text := '<font size="10" color="red">Стенд:'||v_host||'</font><br>Результат выполнения этапа: завершено. <br>'
                || 'Дата выполнения: '||to_char(p_date, 'dd.mm.yyyy') || '<br><br>';

            v_table_title := 'Тип файла,Источник данных, Имя файла, Статус загрузки файла, Технический код статуса'; 
            
            v_sql :=   'select F_TYPE,  F_SRC, F_NAM ,F_STAT_D,F_STAT
                        from (
                        select d.r_dt as F_DT, f.FILE_TYPE_CD as F_TYPE, t.FILE_NAME as F_NAM, 
                        case when f.SOURCE_NAME = ''XL_BI'' then ''1С Хомнет Лизинг'' when f.SOURCE_NAME = ''KONS_BI'' then ''1С Консолидация'' else null end as F_SRC,
                        nvl(t.status_cd,0) as F_STAT, nvl(t2.STATUS_DESC,''файл не выгружался из системы-источника'') as F_STAT_D from 
                        (select trunc(sysdate) + Level - 500 as r_dt
                        FROM DUAL CONNECT BY LEVEL <= 1000) d
                        left join (select distinct FILE_TYPE_CD, SOURCE_NAME from etl.ctl_input_files where file_type_cd is not null and source_name <> ''XLS'') f on 1=1
                        left join etl.ctl_input_files t on trunc(t.load_dt)=d.r_dt and t.FILE_TYPE_CD=f.FILE_TYPE_CD
                        left join etl.CTL_FILE_STATUSES t2 on t2.STATUS_CD=t.STATUS_CD
                        --group by d.r_dt, f.FILE_TYPE_CD
                        where f.SOURCE_NAME in (''XL_BI'',''KONS_BI'')
                        order by 1
                        ) 
                        where F_DT=to_date('''||to_char(p_date , 'dd.mm.yyyy')||''',''dd.mm.yyyy'') order by F_SRC desc, F_STAT ';  
        
            v_msg_text := v_msg_text || create_html_table_data(v_sql,v_table_title,'3, ''#C5ECD7'',0,''#FFAC9B'',''#F8D785''','F_STAT');
     
     
    v_recipients := '';
    
    for rec in (select distinct EMAIL
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
                                and cr.ROLE_CD = 'SEND_XML_FILE_STATUS'
                        where cu.ACTUAL_FLG = 1                                
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
     --dbms_output.put_line(v_msg_text);
    mail_pkg.set_mailserver('10.0.2.79', 25);
                mail_pkg.send( mailto =>  v_recipients
                                , subject => v_subject
                                , message => v_msg_text
                                , mailfrom => 'support@vtb-leasing.ru'
                                , mimetype => 'text/html'
                                , priority => 0 );
     
    
end;
/

