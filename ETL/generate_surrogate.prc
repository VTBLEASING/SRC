CREATE OR REPLACE PROCEDURE ETL."GENERATE_SURROGATE" (
   p_table_name    VARCHAR2,
   p_owner         VARCHAR2,
   p_sys           VARCHAR2)
IS
   -- GS#DIM_LANGUAGE#01#0
   x_k_table_name        t_table_rule.k_table_name%TYPE;
   collist               VARCHAR2 (400);
   k_collist             VARCHAR2 (400);
   str                   VARCHAR2 (4000);
   lockid                VARCHAR2 (30);
   code                  NUMBER;
   x_code                CHAR (2);
   x_table_name          VARCHAR2 (30);
   x_owner               VARCHAR2 (30);
   v_start_dt            DATE;
BEGIN

   DBMS_OUTPUT.enable(1000000);
   v_start_dt := SYSDATE;
   x_table_name := p_table_name;
   x_owner := p_owner;
   x_code := p_sys;

   DBMS_OUTPUT.put_line (x_table_name);
   DBMS_OUTPUT.put_line (x_owner);
   DBMS_OUTPUT.put_line (x_code);

   FOR x
      IN (SELECT rule_id, tr.k_table_name, tr.k_pk_filed
            FROM t_table t, t_table_rule tr
           WHERE     t.table_id = tr.table_id
                 AND t.table_name = x_table_name
                 AND t.sys_code = x_code
                 AND t.actual_flag = 1
                 AND tr.actual_flag = 1
                 and t.owner=x_owner)
   LOOP
      x_k_table_name := x.k_table_name;

      DBMS_LOCK.allocate_unique (x_k_table_name, lockid);
      code := -1;

      WHILE code != 0
      LOOP
         code :=
            sys.DBMS_LOCK.request (lockid,
                                   sys.DBMS_LOCK.x_mode,
                                   10,
                                   TRUE);
      END LOOP;

      collist := '';
      k_collist := '';

      FOR xx IN (SELECT t.field_name, t.k_field_name
                   FROM ref_rule_field t
                  WHERE t.rule_id = x.rule_id AND t.actual_flag = 1)
      LOOP
         collist := collist || ',' || xx.field_name;
         k_collist := k_collist || ',' || xx.k_field_name;
      END LOOP;

      collist := SUBSTR (collist, 2);
      k_collist := SUBSTR (k_collist, 2);
      str :=
            'insert into lnk.'
         || x_k_table_name
         || '('
         || x.k_pk_filed
         || ',sys_code, '
         || k_collist
         || ')'
         || CHR (10)
         || ' select
(select decode(max('
         || x.k_pk_filed
         || '),null,0,-999,0,-1,0,max('
         || x.k_pk_filed
         || ')) from '
         || 'LNK'
         || '.'
         || x_k_table_name
         || ')+rownum,'''
         || x_code
         || ''','
         || collist
         || CHR (10)
         || 'from (select '
         || collist
         || ' from '
         || x_owner
         || '.'
         || x_table_name
         || ' minus select '
         || k_collist
         || ' from lnk.'
         || x_k_table_name
         || ')';

      DBMS_OUTPUT.put_line (str);

      EXECUTE IMMEDIATE 'alter session force parallel query parallel 2';

      EXECUTE IMMEDIATE str;
      DBMS_OUTPUT.put_line ('inserted rows:'||SQL%ROWCOUNT); --add  for debug mode

      EXECUTE IMMEDIATE 'alter session disable parallel query';

      COMMIT;
      code := DBMS_LOCK.release (lockid);
   END LOOP;
--etl.ctl_log_pkg.ctl_insert_log('GENERATE_SURROGATE '||x_postfix||'.'||x_table_name, null, null, null, null, null, null, v_start_dt,sysdate);

EXCEPTION
   WHEN OTHERS
   THEN
--            etl.ctl_log_pkg.ctl_log_err(str);
      RAISE;
END;
/

