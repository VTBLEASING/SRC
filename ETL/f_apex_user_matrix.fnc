CREATE OR REPLACE FUNCTION ETL.F_APEX_USER_MATRIX
(
    p_apex_user     varchar2,
    p_apex_object_nam     varchar2    
)
RETURN NUMBER is
v_check_flg varchar2 (5);
v_check_function_nam varchar2 (255);
v_str varchar2 (4000);
BEGIN

select check_function_nam into v_check_function_nam 
from etl.ctl_apex_objects
where ACTUAL_FLG = '1'
and sysdate between begin_dt and end_dt 
and valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
and apex_object_nam = p_apex_object_nam;

v_str := 'select etl.' || v_check_function_nam || '(''' || p_apex_user || ''',''' || p_apex_object_nam || ''') from dual';
--dbms_output.put_line (v_str);
execute immediate (v_str) into v_check_flg;

    RETURN v_check_flg;
END;
/

