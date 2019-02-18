CREATE OR REPLACE PROCEDURE ETL.EXTRACT_XLS_FILES
IS

 vblob BLOB;
 vstart NUMBER := 1;
 bytelen NUMBER := 32000;
 len NUMBER;
 my_vr RAW(32000);
 x NUMBER;
 v_dir_name varchar2 (256);
 v_dir_path varchar2 (1000);
 l_output utl_file.file_type;
 v_file_name varchar2 (1000);
 v_short_file_name varchar2 (1000);
 BEGIN
 -- define output directory
 for rec in (
 select
      fp.UPLOAD_DATE,
      fp.USERNAME,
      fp.FILE_NAME,
      fp.FILE_TYPE,
      fo.FILENAME short_name,
      fp.ORG,
      fp.file_id
 from etl.ctl_xls_input_file_params fp
 inner join WWV_FLOW_FILE_OBJECTS$ fo
    on fp.file_name = fo.NAME
)
loop
 v_dir_name :=null;
 select (substr (rec.file_name, 1, INSTR (rec.file_name, '.',-1) - 1))|| '_' ||
                        to_char (rec.UPLOAD_DATE, 'yyyymmdd_hh24miss') || '.' || lower (substr (rec.file_name, INSTR (rec.file_name, '.',-1) + 1)) into v_file_name
                from dual;
 select (substr (rec.short_name, 1, INSTR (rec.short_name, '.',-1) - 1))|| '_' ||
                        to_char (rec.UPLOAD_DATE, 'yyyymmdd_hh24miss') || '.' || lower (substr (rec.short_name, INSTR (rec.short_name, '.',-1) + 1)) into v_short_file_name
                from dual;

 v_dir_name := upper (rec.file_type) || '_' || rec.ORG;
-- dbms_output.put_line(v_dir_name);
 l_output := utl_file.fopen(v_dir_name,convert (v_file_name, 'CL8MSWIN1251'),'wb', 32760);
 vstart := 1;
 -- get length of blob
 SELECT dbms_lob.getlength(BLOB_CONTENT) into len from WWV_FLOW_FILE_OBJECTS$ where NAME=rec.file_name;
 -- save blob length
 x := len;
 -- select blob into variable
 select BLOB_CONTENT  INTO vblob from WWV_FLOW_FILE_OBJECTS$ where NAME=rec.file_name;


 -- if small enough for a single write
 IF len < 32760 THEN
  utl_file.put_raw(l_output,vblob);
  utl_file.fflush(l_output);
 ELSE -- write in pieces
  vstart := 1;
  bytelen := 32000;
  WHILE vstart < len and bytelen > 0
  LOOP
    dbms_lob.read(vblob,bytelen,vstart,my_vr);
    utl_file.put_raw(l_output,my_vr);
    utl_file.fflush(l_output);
    vstart := vstart + bytelen;
    -- set the end position if less than 32000 bytes
    x := x - bytelen;
    IF x < 32000 THEN
       bytelen := x;
    END IF;
  END LOOP;
 END IF;
utl_file.fclose(l_output);
DELETE FROM WWV_FLOW_FILE_OBJECTS$ WHERE NAME = rec.file_name;

select upper (replace (directory_path, '/', '\')) into v_dir_path from all_directories where DIRECTORY_NAME = v_dir_name;

INSERT into ETL.CTL_INPUT_FILES (
            FILE_ID,
            STATUS_CD,
            CREATE_DT,
            FILE_TYPE_CD,
            FILE_NAME,
            SOURCE_NAME,
            TIMESTAMP#,
            USER#,
            LOAD_DT
            ) values
            (nvl(rec.file_id,SQ_INPUT_FILE.nextval),
            '1',
            rec.UPLOAD_DATE,
            rec.FILE_TYPE,
            v_dir_path || '\' || v_short_file_name,
            'XLS',
            rec.UPLOAD_DATE,
            rec.USERNAME,
            sysdate);

merge into etl.ctl_input_files_hist trg
using ctl_input_files src
on (src.file_id = trg.file_id)
when not matched then
    insert (trg.FILE_ID, trg.STATUS_CD, trg.CREATE_DT, trg.FILE_TYPE_CD, trg.FILE_NAME, trg.SOURCE_NAME, trg.TIMESTAMP#, trg.USER#, trg.ENTITY, trg.BASE, trg.META_NAME, trg.META_MESSAGE_NO, trg.LOAD_DT)
    values (src.FILE_ID, src.STATUS_CD, src.CREATE_DT, src.FILE_TYPE_CD, src.FILE_NAME, src.SOURCE_NAME, src.TIMESTAMP#, src.USER#, src.ENTITY, src.BASE, src.META_NAME, src.META_MESSAGE_NO, src.LOAD_DT);



commit;
end loop;
END;
/

