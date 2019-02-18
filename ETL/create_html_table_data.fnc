create or replace function etl.create_html_table_data (p_sql varchar2, p_table_title varchar2, p_color_settings varchar2 default null, p_set_colour_col varchar default null) return clob
as
    v_crlf        varchar2(2)  := chr(13)||chr(10);
    v_sql_result  clob;--varchar2(32000);
    v_table_title varchar2(32000);
    v_sql         varchar2(32000);
    v_html_table_data clob := '';
    v_color_settings varchar2(32000);
    type T_TABEL_RECS is table of varchar2(32000);
    v_table_recs T_TABEL_RECS;
begin
    if p_set_colour_col is not null and p_color_settings is not null then
        v_color_settings := ' style="background:''||decode('||p_set_colour_col||','||p_color_settings||')||''"';
    dbms_output.put_line(p_set_colour_col);
    dbms_output.put_line(v_color_settings);        
    end if;
    v_table_title := '<th>'||replace(p_table_title,',', '</th><th>')||'</th>';
    v_sql := 'select ''<tr '||v_color_settings||'><td>''||'  
       || replace(substr(replace(p_sql,'select'), 1, instr(replace(p_sql,'select'), 'from')-1),',','||''</td><td>''||')||'||''</td></tr>'' table_values'
       || ' '|| substr(p_sql, instr(p_sql,'from') );
--    v_sql := 'select listagg(table_values, chr(10)) WITHIN GROUP (order by -1 )  from (' 
--             ||v_sql
--             ||')'; 
             
    dbms_output.put_line(v_sql);
    
    execute immediate v_sql
        bulk collect into v_table_recs;
    
    
    v_sql_result := '';
    

    
    for i in v_table_recs.first..v_table_recs.last loop   
         v_sql_result := v_sql_result || v_table_recs(i) || chr(10);     
    end loop;     
        
    v_html_table_data := '<table border="1" bordercolor="#000000">'||v_crlf
                ||v_table_title||v_crlf
                ||v_sql_result||v_crlf
                ||'</table>';
    return v_html_table_data;                                   
end;

/*declare
    v_message clob;
    v_table_title varchar2(32000) := '项脲_1,项脲_2,项脲_1,项脲_1,项脲_1,项脲_1,项脲_1,项脲_1';
    v_sql varchar2(32000) := 'select log_date, file_id, file_type, file_name, user#, ERROR_TYPE, ERROR_TEXT,ROW_NUM
                            from(
                            select err_log.log_date, err_log.file_id, err_log.file_type
                            , substr (FILE_NAME, INSTR (FILE_NAME, ''\'', -1) + 1) file_name
                            , user#, err_log.ERROR_TYPE, err_log.ERROR_TEXT, err_log.ROW_NUM 
                            from etl.ctl_error_load_log err_log inner join etl.ctl_input_files ctf on ctf.file_id = err_log.file_id
                            where ctf.file_id = 3853
                            )';
    v_sql_result varchar2(32000);
    v_crlf       VARCHAR2(2)  := chr(13)||chr(10);
begin
    v_table_title := '<th>'||replace(v_table_title,',', '</th><th>')||'</th>';
    v_sql := 'select ''<tr><td>''||'  
       || replace(substr(replace(v_sql,'select'), 1, instr(replace(v_sql,'select'), 'from')-1),',','||''</td><td>''||')||'||''</td></tr>'' table_values'
       || ' '|| substr(v_sql, instr(v_sql,'from') );
    v_sql := 'select listagg(table_values, chr(10)) WITHIN GROUP (order by -1 )  from (' 
             ||v_sql
             ||')';       
--    dbms_output.put_line(v_sql);
    execute immediate v_sql into v_sql_result;
    v_message := '<table border="1" bordercolor="#000000">'||v_crlf
                ||v_table_title||v_crlf
                ||v_sql_result||v_crlf
                ||'</table>';
    --dbms_output.put_line(v_message);
    mail_pkg.set_mailserver('10.0.2.79', 25);
                mail_pkg.send( mailto => 'AKolobkov@vtb-leasing.com'
                                , subject => 'ETL error'
                                , message => v_message
                                , mailfrom => 'bi@vtb-leasing.com'
                                , mimetype => 'text/html'
                                , priority => 0 );                    
end;
*/
/

