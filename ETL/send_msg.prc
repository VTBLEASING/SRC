create or replace procedure etl.SEND_MSG(p_msg_txt varchar2, p_msg_subject varchar2, p_msg_type varchar2 )
is
    v_recipients varchar2(32000);
begin
   
    select listagg(recipient_email, ';') WITHIN group (order by -1 )
    into v_recipients
    from ctl_recipients
    where upper(msg_type) = upper(p_msg_type);     
    

     
    mail_pkg.set_mailserver('10.0.2.79', 25);
                mail_pkg.send( mailto =>  v_recipients
                                , subject => p_msg_subject
                                , message => p_msg_txt
                                , mailfrom => 'support@vtb-leasing.ru'
                                , mimetype => 'text/html'
                                , priority => 0 );
     

end;
/

