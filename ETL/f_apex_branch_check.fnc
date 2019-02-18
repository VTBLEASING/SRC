CREATE OR REPLACE FUNCTION ETL.F_APEX_BRANCH_CHECK
(
    p_apex_user     varchar2,
    p_apex_object_nam     varchar2    
)
RETURN VARCHAR2 is
v_apex_user_group varchar2 (50);
BEGIN

IF p_apex_object_nam in ('REGION_UPLOAD', 'LEASING_FILES_LOG') THEN                   -- Список организаций для загрузки файлов по лизингу

  select nvl (APEX_USER_GROUP, '-1') into v_apex_user_group
  from etl.CTL_APEX_USER_MATRIX 
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
  and sysdate between begin_dt and end_dt 
  and actual_flg = '1' 
  and apex_user = p_apex_user
  and leasing_flg = '1';
  
ELSIF p_apex_object_nam in ('BRANCH', 'CGP_CALC_LOG', 'CONTRACT_SEARCH') THEN                   -- Список организаций для расчета витрины КГП

  select nvl (APEX_USER_GROUP, '-1') into v_apex_user_group
  from etl.CTL_APEX_USER_MATRIX 
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
  and sysdate between begin_dt and end_dt 
  and actual_flg = '1' 
  and apex_user = p_apex_user
  and cgp_flg = '1';
  
ELSIF p_apex_object_nam in ('REG_UPLOAD', 'INSTR_FILES_LOG') THEN                   -- Список организаций для загрузки файлов по инстурментам

  select nvl (APEX_USER_GROUP, '-1') into v_apex_user_group
  from etl.CTL_APEX_USER_MATRIX 
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
  and sysdate between begin_dt and end_dt 
  and actual_flg = '1' 
  and apex_user = p_apex_user
  and instr_file_flg = '1';
  
ELSIF p_apex_object_nam in ('REG_GROUP', 'REG_CALC_LOG') THEN                   -- Список организаций для расчета витрин по инстурментам

  select case 
        when HEAD_OFFICE_FLG = '1' and APEX_USER_GROUP = 'TREASURY'
            then 'VTB_LEASING_USER'
        else nvl (APEX_USER_GROUP, '-1')
        end as apex_group into v_apex_user_group
  from etl.CTL_APEX_USER_MATRIX 
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
  and sysdate between begin_dt and end_dt 
  and actual_flg = '1' 
  and apex_user = p_apex_user
  and reg_flg = '1';
  
ELSIF p_apex_object_nam in ('BANK_ACCOUNTS_REPORT') THEN                   -- Список организаций для формы по банковским счетам

  select nvl (APEX_USER_GROUP, '-1') into v_apex_user_group
  from etl.CTL_APEX_USER_MATRIX 
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
  and sysdate between begin_dt and end_dt 
  and actual_flg = '1' 
  and apex_user = p_apex_user
  and forms_gr1_flg = '1'
  and bank_accounts_flg = '1' ;
  
ELSIF p_apex_object_nam in ('CONTRACTS_REPORT', 'P120_BRANCH_NAM') THEN                   -- Список организаций для формы по договорам

  select nvl (APEX_USER_GROUP, '-1') into v_apex_user_group
  from etl.CTL_APEX_USER_MATRIX 
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
  and sysdate between begin_dt and end_dt 
  and actual_flg = '1' 
  and apex_user = p_apex_user
  and forms_gr1_flg = '1'
  and contracts_flg = '1' ;
  
ELSIF p_apex_object_nam in ('FACT_ACCOUNT_BALANCE_REPORT', 'FAB_BRANCH_NAM') THEN                   -- Список организаций для формы по остаткам на банковских счетах

  select nvl (APEX_USER_GROUP, '-1') into v_apex_user_group
  from etl.CTL_APEX_USER_MATRIX 
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
  and sysdate between begin_dt and end_dt 
  and actual_flg = '1' 
  and apex_user = p_apex_user
  and forms_gr1_flg = '1'
  and fact_account_balance_flg = '1' ;
  
ELSIF p_apex_object_nam in ('P80_CONTRACT_ID_CD', 'FACT_PLAN_PAYMENTS_REPORT', 'P10_BRANCH', 'FACT_PLAN_PAYMENTS_LOG') THEN                   -- Список организаций для формы по плановым платежам

  select nvl (APEX_USER_GROUP, '-1') into v_apex_user_group
  from etl.CTL_APEX_USER_MATRIX 
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
  and sysdate between begin_dt and end_dt 
  and actual_flg = '1' 
  and apex_user = p_apex_user
  and forms_gr2_flg = '1'
  and fact_plan_payments_flg = '1' ;
  
ELSIF p_apex_object_nam in ('P14_CONTRACT_ID_CD', 'FACT_REAL_PAYMENTS_REPORT', 'P16_BRANCH', 'FACT_REAL_PAYMENTS_LOG') THEN                   -- Список организаций для формы по плановым платежам

  select nvl (APEX_USER_GROUP, '-1') into v_apex_user_group
  from etl.CTL_APEX_USER_MATRIX 
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
  and sysdate between begin_dt and end_dt 
  and actual_flg = '1' 
  and apex_user = p_apex_user
  and forms_gr2_flg = '1'
  and fact_real_payments_flg = '1' ;

END IF;
    RETURN v_apex_user_group;
END;
/

