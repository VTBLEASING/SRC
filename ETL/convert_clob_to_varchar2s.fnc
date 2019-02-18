create or replace function etl.convert_clob_to_varchar2s(p_clob clob)
return dbms_sql.VARCHAR2S
is
v_loblen  PLS_INTEGER;
v_accum   INTEGER := 0;
v_beg     INTEGER := 1;
v_end     INTEGER := 128;
sql_table dbms_sql.VARCHAR2S;

c_buf_len CONSTANT BINARY_INTEGER := 128;

begin

--    dbms_output.put_line(p_clob);

v_loblen := DBMS_LOB.GETLENGTH(p_clob);

 LOOP
    -- Set the length to the remaining size
    -- if there are < c_buf_len characters remaining.
    IF v_accum + c_buf_len > v_loblen THEN
      v_end := v_loblen - v_accum;
    END IF;

    dbms_output.put_line(DBMS_LOB.SUBSTR(p_clob, v_end, v_beg));

    sql_table(NVL(sql_table.LAST, 0) + 1) :=
    DBMS_LOB.SUBSTR(p_clob, v_end, v_beg);

    v_beg := v_beg + c_BUF_LEN;
    v_accum := v_accum + v_end;

    IF v_accum >= v_loblen THEN
      EXIT;
    END IF;
  END LOOP;

return sql_table;

end;
/

