CREATE OR REPLACE FUNCTION ETL.F_APEX_CHECK_ADM_FIN_DEV
(
    p_apex_user     varchar2,
    p_apex_object_nam     varchar2
)
RETURN NUMBER is
v_flg varchar2 (5);
BEGIN

  select count (1) into v_flg from dual 
  where p_apex_user in (
        select apex_user 
        from etl.CTL_APEX_USER_MATRIX 
        where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
        and sysdate between begin_dt and end_dt
        and actual_flg = '1'
        and apex_user_group in ('ADMINISTRATORS', 'DEVELOPERS', 'FINANCIAL_DEPT'));
   
    RETURN v_flg;
END;
/

