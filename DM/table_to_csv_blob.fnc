create or replace function dm.table_to_csv_blob( p_tname in varchar2,
 p_query varchar2,
 p_dir in varchar2 default 'CC_OUT' ,
 p_filename in varchar2 default 'out.txt',
 p_header in char default 'Y',
 p_arg_dt date default null
 --p_snapshot_dt date default date'2017-06-30'
 ) return blob
 is
 --l_output utl_file.file_type;
 l_theCursor integer default dbms_sql.open_cursor;
 l_columnValue varchar2(4000);
 l_status integer;
-- l_query varchar2(1000) default 'select * from ' || p_tname || ' where snapshot_dt=date''2017-06-30''';--;;||p_snapshot_dt;
 l_colCnt number := 0;
 l_separator varchar2(1);
 l_descTbl dbms_sql.desc_tab;
 debug_cnt number :=0;
 b_temp raw(8000);
 b_body blob;
 begin
 dbms_lob.createtemporary(b_body,true);
-- dbms_lob.createtemporary(b_temp,true);
 
  --l_output := utl_file.fopen(p_dir, p_filename, 'wb' );
 --execute immediate 'alter session set nls_date_format=''dd-mon-yyyy hh24:mi:ss'' ';
 execute immediate Q'~alter session set nls_numeric_characters='. '~';

 dbms_sql.parse( l_theCursor, p_query, dbms_sql.native );
 dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl );

 for i in 1 .. l_colCnt loop
  --Формирование заголовка 
 if p_header='Y' then
    b_temp:=utl_raw.cast_to_raw (convert (l_separator || '"' || l_descTbl(i).col_name || '"' , 'CL8MSWIN1251', 'UTF8' ));
    dbms_lob.append(b_body,b_temp);
-- comment    utl_file.put_raw( l_output,b_temp );
 end if;
 dbms_sql.define_column( l_theCursor, i, l_columnValue, 4000 );
 l_separator := ',';
--end if;
/*if 90=i then
 utl_file.fclose( l_output );
 return;
end if;
*/
 end loop;
 if p_header='Y' then
    --coment utl_file.put_raw(l_output,utl_raw.cast_to_raw(chr(13))); 
    dbms_lob.append(b_body,utl_raw.cast_to_raw(chr(13)));
 end if;
 --utl_file.new_line( l_output );
----
 --utl_file.fclose( l_output );
 --return;

---
 dbms_sql.bind_variable(l_theCursor,':p_arg_dt',p_arg_dt);
 l_status := dbms_sql.execute(l_theCursor);

 while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
   debug_cnt:=debug_cnt+1;
 l_separator := '';
 for i in 1 .. l_colCnt loop

   dbms_sql.column_value( l_theCursor, i, l_columnValue );
   -- comment_file utl_file.put_raw (l_output, utl_raw.cast_to_raw (convert (l_separator || l_columnValue, 'CL8MSWIN1251', 'UTF8' )));
   b_temp:= utl_raw.cast_to_raw (convert (l_separator || l_columnValue, 'CL8MSWIN1251', 'UTF8' ));
   if b_temp is not null then 
      dbms_lob.append (b_body,b_temp);
   end if;
   l_separator := ',';
 end loop;

 -- comment_file utl_file.put_raw(l_output,utl_raw.cast_to_raw(chr(13)));
 dbms_lob.append(b_body,utl_raw.cast_to_raw(chr(13)));
/*if debug_cnt>10000 then
 utl_file.fclose( l_output );
 return; end if;*/
 end loop;
 dbms_sql.close_cursor(l_theCursor);
 --comment utl_file.fclose( l_output );
 execute immediate Q'~alter session set nls_numeric_characters=', '~';
 return b_body;
-- execute immediate 'alter session set nls_date_format=''dd-MON-yy'' ';
 exception
 when others then
 execute immediate Q'~alter session set nls_numeric_characters=', '~';

-- execute immediate 'alter session set nls_date_format=''dd-MON-yy'' ';
 raise_application_error(-20666,SQLERRM); 
end;
/

