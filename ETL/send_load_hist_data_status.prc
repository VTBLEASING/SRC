create or replace procedure etl.SEND_LOAD_HIST_DATA_STATUS(p_prc_id number)
as
    v_subject varchar2(1000);
    v_msg_text clob;
    v_txt varchar2(32000);
    v_sql varchar2(32000);
    v_table_title varchar2(500);
    v_recipients varchar2(32000);
    v_status varchar2(100);
    v_dt date;
begin
    
    v_subject := 'Результат выполнения этапа: Перенос исторических данных';


    select decode(nvl(status, 'ERROR'), 'ERROR', 'завершено с ошибками', 'завершено успешно'), nvl(prc_timestamp, sysdate)
    into v_status, v_dt
    from
    ( 
        select max(status)  keep (dense_rank first order by prc_id, prc_timestamp desc) status
        ,max(cast(PRC_TIMESTAMP as date))  keep (dense_rank first order by prc_id, prc_timestamp desc) PRC_TIMESTAMP
        from CTL_COPY_HIST_DATA_LOG
        where PRC_NAME in ( 'RUN_LOAD_HIST_DATA','COPY_HIST_DATA_DM_CGP_DAILY')
        and 1=1
        and prc_id = p_prc_id
    );

    v_msg_text := 'Результат выполнения этапа: '|| v_status ||' <br>'
                || 'Дата выполнения: '||to_char(v_dt, 'dd.mm.yyyy') || '<br><br>';
    

    for rec in (select PRC_NAME, replace(ADD_INF, chr(13)||chr(10),'<br>')   ADD_INF
                from CTL_COPY_HIST_DATA_LOG 
                where STEP_NAME = 'END' 
                and STATUS = 'SUCCEEDED'
                and PRC_NAME like 'LOAD%'
                and prc_id = p_prc_id) loop
        v_msg_text := v_msg_text || 'Результат выполнения этапа '||rec.PRC_NAME|| '<br>'||rec.ADD_INF||'<br><br><br>';
    end loop;
    
    select listagg(recipient_email, ';') WITHIN group (order by -1 )
    into v_recipients
    from (
            select distinct EMAIL recipient_email
            from CTL_USERS cu
            inner join REF_USER_GROUP rug
                on cu.USER_ID = rug.USER_ID
                and rug.ACTUAL_FLG = '1'
            inner join REF_GROUP_ROLE rgr
                on rgr.GROUP_ID = rug.GROUP_ID
                and rgr.ACTUAL_FLG = '1'
            inner join CTL_ROLES cr
                on cr.ROLE_ID = rgr.ROLE_ID
                and cr.ACTUAL_FLG = '1'
                and cr.ROLE_CD = 'SEND_LOAD_HIST_DATA_STATUS'                   
            where cu.ACTUAL_FLG = '1'    
    );
     
    
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

