CREATE OR REPLACE FUNCTION ETL.F_APEX_CHECK_USER_GROUPS
(
    p_apex_user     varchar2,
    p_apex_object_nam     varchar2    
)
RETURN NUMBER is
v_flg varchar2 (5);
BEGIN

IF p_apex_object_nam in ('REGION_UPLOAD',
                         'LEASING_FILES_LOG',
                         'BRANCH',
                         'CONTRACT_SEARCH',
                         'CGP_CALC_LOG',
                         'CONTRACTS_REPORT',
                         'P80_CONTRACT_ID_CD',
                         'FACT_PLAN_PAYMENTS_REPORT',
                         'P10_BRANCH',
                         'FACT_PLAN_PAYMENTS_LOG',
                         'P14_CONTRACT_ID_CD',
                         'P16_BRANCH',
                         'FACT_REAL_PAYMENTS_LOG')
                         
          THEN                   

  select count (1) into v_flg from dual
  where etl.F_APEX_CHECK_ADM_FIN_DEV (p_apex_user, p_apex_object_nam) = 1;

ELSIF p_apex_object_nam in ('REG_UPLOAD', 'INSTR_FILES_LOG') THEN                   -- Формы редактирования и добавления данных НСИ (Группа 1)

  select count (1) into v_flg from dual
  where etl.F_APEX_CHECK_ADM_FIN_DEV (p_apex_user, p_apex_object_nam) = 1
  
  or p_apex_user in (
                    select apex_user 
                    from etl.CTL_APEX_USER_MATRIX 
                    where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
                    and sysdate between begin_dt and end_dt  
                    and apex_user_group in ('TREASURY') 
                    and instr_file_flg = '1'
                    and ACTUAL_FLG = '1');
  
ELSIF p_apex_object_nam in ('REG_GROUP', 'REG_CALC_LOG') THEN                   -- Формы редактирования и добавления данных НСИ (Группа 1)

  select count (1) into v_flg from dual
  where etl.F_APEX_CHECK_ADM_FIN_DEV (p_apex_user, p_apex_object_nam) = 1
  
  or p_apex_user in (
                    select apex_user 
                    from etl.CTL_APEX_USER_MATRIX 
                    where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
                    and sysdate between begin_dt and end_dt  
                    and apex_user_group in ('TREASURY') 
                    and reg_flg = '1'
                    and ACTUAL_FLG = '1'
                    and HEAD_OFFICE_FLG = '0');
                    
ELSIF p_apex_object_nam in ('P120_BRANCH_NAM') THEN                   -- Формы редактирования и добавления данных НСИ (Группа 1)

  select count (1) into v_flg from dual
  where etl.F_APEX_CHECK_ADM_FIN_DEV (p_apex_user, p_apex_object_nam) = 1
  
  or p_apex_user in (
                    select apex_user 
                    from etl.CTL_APEX_USER_MATRIX 
                    where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
                    and sysdate between begin_dt and end_dt  
                    and apex_user_group in ('TREASURY') 
                    and forms_gr1_flg = '1'
                    and contracts_flg = '1' 
                    and ACTUAL_FLG = '1');
                    
ELSIF p_apex_object_nam in ('BANK_ACCOUNTS_REPORT') THEN                   -- Формы редактирования и добавления данных НСИ (Группа 1)

  select count (1) into v_flg from dual
  where etl.F_APEX_CHECK_ADM_FIN_DEV (p_apex_user, p_apex_object_nam) = 1
  
  or p_apex_user in (
                    select apex_user 
                    from etl.CTL_APEX_USER_MATRIX 
                    where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
                    and sysdate between begin_dt and end_dt  
                    and apex_user_group in ('TREASURY') 
                    and forms_gr1_flg = '1'
                    and bank_accounts_flg = '1' 
                    and ACTUAL_FLG = '1');
                    
ELSIF p_apex_object_nam in ('FACT_ACCOUNT_BALANCE_REPORT', 'FAB_BRANCH_NAM') THEN                   -- Формы редактирования и добавления данных НСИ (Группа 1)

  select count (1) into v_flg from dual
  where etl.F_APEX_CHECK_ADM_FIN_DEV (p_apex_user, p_apex_object_nam) = 1
  
  or p_apex_user in (
                    select apex_user 
                    from etl.CTL_APEX_USER_MATRIX 
                    where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
                    and sysdate between begin_dt and end_dt  
                    and apex_user_group in ('TREASURY') 
                    and forms_gr1_flg = '1'
                    and fact_account_balance_flg = '1' 
                    and ACTUAL_FLG = '1');
                    
ELSIF p_apex_object_nam in ('P26_SHORT_CLIENT_RU_NAM', 
                            'P26_INN', 
                            'P26_CLIENT_ID',
                            'P26_CLIENT_CRM_CD',
                            'P26_FULL_CLIENT_RU_NAM',
                            'P26_CREDIT_RATING_VIS',
                            'P26_ACTIVITY_TYPE_RU_DESC_VIS',
                            'P26_BUSINESS_CAT_RU_NAM_VIS',
                            'P26_PARTIES_TYPE_RU_NAM_VIS',
                            'P26_REG_COUNTRY_RU_NAM_VIS',
                            'P26_RISK_COUNTRY_RU_NAM_VIS',
                            'P26_ORG_TYPE_RU_NAM_VIS',
                            'P26_GROUP_TYPE_RU_NAM_VIS',
                            'P26_GRF_GROUP_RU_NAM_VIS',
                            'P26_MEMBER_RU_NAM_VIS',
                            'P26_CGP_FLG_VIS',
                            'P26_CLIENTS_BTN',
                            'P26_SCORE_POINTS_CNT_VIS',
                            'P26_GRF_ENTITY_RU_NAM_VIS',
                            'P26_RELATED_PARTIES_NAM',
                            'P26_OKVED_CODE',
                            'P26_ECONOMIC_SECTOR_RU_NAM',
                            'P26_OPF_NAM_VIS'
                            ) THEN                   -- Формы редактирования и добавления данных НСИ (Группа 1)

  select count (1) into v_flg from dual
  where etl.F_APEX_CHECK_ADM_FIN_DEV (p_apex_user, p_apex_object_nam) = 1;
  
ELSIF p_apex_object_nam in ('P26_SHORT_CLIENT_RU_NAM_VIS_U', 
                            'P26_INN_VIS_U', 
                            'P26_CLIENT_ID_U',
                            'P26_CLIENT_CRM_CD_VIS_U',
                            'P26_FULL_CLIENT_RU_NAM_VIS_U',
                            'P26_CREDIT_RATING_VIS_U',
                            'P26_ACTIVITY_TYPE_DESC_VIS_U',
                            'P26_BUSINESS_CAT_RU_NAM_VIS_U',
                            'P26_PARTIES_TYPE_RU_NAM_VIS_U',
                            'P26_REG_COUNTRY_RU_NAM_VIS_U',
                            'P26_RISK_COUNTRY_RU_NAM_VIS_U',
                            'P26_ORG_TYPE_RU_NAM_VIS_U',
                            'P26_GROUP_TYPE_RU_NAM_VIS_U',
                            'P26_GRF_GROUP_RU_NAM_VIS_U',
                            'P26_MEMBER_RU_NAM_VIS_U',
                            'P26_CGP_FLG_VIS_U',
                            'P26_CLIENTS_BTN_U',
                            'P26_SCORE_POINTS_CNT_VIS_U',
                            'P26_OKVED_CODE_U',
                            'P26_ECONOMIC_SECTOR_RU_NAM_VIS_U',
                            'P26_OPF_NAM_U'
                            ) THEN                   -- Формы редактирования и добавления данных НСИ (Группа 1)

  select count (1) into v_flg from dual
  where p_apex_user in (
                    select apex_user 
                    from etl.CTL_APEX_USER_MATRIX 
                    where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
                    and sysdate between begin_dt and end_dt  
                    and apex_user_group in ('UAKR_ENTERPRISE') 
                    and clients_flg = '1'
                    and ACTUAL_FLG = '1');
                    
ELSIF p_apex_object_nam in ('P26_SHORT_CLIENT_RU_NAM_A', 
                            'P26_INN_A',
                            'P26_CLIENT_ID_VIS_A',
                            'P26_CLIENT_CRM_CD_A',
                            'P26_FULL_CLIENT_RU_NAM_A',
                            'P26_CREDIT_RATING_VIS_A',
                            'P26_ACTIVITY_TYPE_DESC_VIS_A',
                            'P26_BUSINESS_CAT_RU_NAM_VIS_A',
                            'P26_PARTIES_TYPE_RU_NAM_VIS_A',
                            'P26_REG_COUNTRY_RU_NAM_VIS_A',
                            'P26_RISK_COUNTRY_RU_NAM_VIS_A',
                            'P26_ORG_TYPE_RU_NAM_VIS_A',
                            'P26_GROUP_TYPE_RU_NAM_VIS_A',
                            'P26_GRF_GROUP_RU_NAM_VIS_A',
                            'P26_MEMBER_RU_NAM_VIS_A',
                            'P26_CGP_FLG_VIS_A',
                            'P26_CLIENTS_BTN_A',
                            'P26_SCORE_POINTS_CNT_VIS_A',
                            'P26_OKVED_CODE_A',
                            'P26_ECONOMIC_SECTOR_RU_NAM_VIS_A',
                            'P26_OPF_NAM_A'
                            ) THEN                   -- Формы редактирования и добавления данных НСИ (Группа 1)

  select count (1) into v_flg from dual
  where p_apex_user in (
                    select apex_user 
                    from etl.CTL_APEX_USER_MATRIX 
                    where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') 
                    and sysdate between begin_dt and end_dt  
                    and apex_user_group in ('ACCOUNTING_DEPT') 
                    and clients_flg = '1'
                    and ACTUAL_FLG = '1');

END IF;
    RETURN v_flg;
END;
/

