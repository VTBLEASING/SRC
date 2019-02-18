CREATE OR REPLACE FUNCTION ETL.F_APEX_NAVIGATION_OBJECTS
(
    p_apex_user     varchar2,
    p_apex_object_nam     varchar2
)
RETURN NUMBER is
v_flg varchar2 (5);
BEGIN

IF p_apex_object_nam = 'FILES' THEN                  -- ������ � �������� ������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FILES_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DATA_MARTS' THEN                  -- ������ � ������� ������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and DATA_MARTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_CGP' THEN                  -- ����� ������ ������� ���

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and CGP_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'NIL_CORRECTS' THEN                  -- ����� �������� �������������� NIL

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and NIL_CORRECTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_REG' THEN                   -- ����� ������� ������� �� ������������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_SWAP' THEN                   -- ����� ������� ������� �� SWAP

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_SWAP_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_BOND' THEN                   -- ����� ������� ������� �� BONDS

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_BOND_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_OWNBILLS' THEN                   -- ����� ������� ������� �� OWNBILLS

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_OWNBILLS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_IRS' THEN                   -- ����� ������� ������� �� IRS

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_IRS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_DEPOSIT' THEN                   -- ����� ������� ������� �� DEPOSIT

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_DEPOSIT_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_IR_GAP' THEN                   -- ����� ������� ������� �� IR_GAP

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_IR_GAP_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_KS' THEN                   -- ����� ������� ������� �� KS

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_KS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_MISC' THEN                   -- ����� ������� ������� �� MISC

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_MISC_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_NOSTRO' THEN                   -- ����� ������� ������� �� NOSTRO

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_NOSTRO_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_CLIENTS' THEN                   -- ����� ������� ������� �� ���������� ������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and DM_CLIENTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_CGP_UAKR' THEN                   -- ����� ������� ������� ��� ��� ����

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and CGP_UAKR_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_UAKR_DAILY' THEN                   -- ����� ������� ������� �� ������������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and UAKR_DAILY_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_IFRS_NSBU' THEN                   -- ����� ������� ������� �� ���� � ����

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and DM_IFRS_NSBU_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_NIL_PAYM_PERIOD' THEN                   -- ����� ������� ������ NIL �� �������, �����, ���������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and NIL_PAYM_PERIOD_FLG = '1'
  and ACTUAL_FLG = '1';

 ELSIF p_apex_object_nam = 'DM_RPL_NOTA' THEN                          -- Form calculation datamarts Daily PL, Nota, 2 CGP List

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and DM_RPL_NOTA_FLG = '1'
  and ACTUAL_FLG = '1';

 ELSIF p_apex_object_nam = 'IFRS_NINE' THEN                          -- Form calculation datamarts IFRS9

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and IFRS_NINE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FORMS' THEN                   -- ����� �������������� � ���������� ������ ��� (������ 1-3)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FORMS_GR1_REGION' THEN                   -- ����� �������������� � ���������� ������ ��� (������ 1)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'SWAP_CONTRACTS' THEN                  -- ����� �������������� � ���������� ������ ������������� �������� (����, �������, ������)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and SWAP_CONTRACTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'IR_GAP' THEN                          -- ����� �������������� � ���������� ������ ���� ������ ���������� ��� (IR-GAP)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and IR_GAP_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'GRF_VTB_GROUP' THEN                   -- ����� �������������� � ���������� ������ ����������� ������ ��� ��� ���

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and GRF_VTB_GROUP_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'GROUPS' THEN                          -- ����� �������������� � ���������� ������ ������ ������������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and GROUPS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'CLIENTS' THEN                         -- ����� �������������� � ���������� ������ �����������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and CLIENTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'BANKS' THEN                            -- ����� �������������� � ���������� ������ �����

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and BANKS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'BANK_ACCOUNTS' THEN                     -- ����� �������������� � ���������� ������ ���������� �����

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and BANK_ACCOUNTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FACT_ACCOUNT_BALANCE' THEN             -- ����� �������������� � ���������� ������ ������� �� ��������� � ������� ������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and FACT_ACCOUNT_BALANCE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'CONTRACTS' THEN                          -- ����� �������������� � ���������� ������ ��������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and CONTRACTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam in('P35_IAS3_TERM_AMT',
                           'P35_IAS3_OVERDUE_AMT',
                           'P35_DQ_CATEGORY_RU_DESC',
                           'P35_BAD_FLG_VIS',
                           'P35_LENDING_PURPOSE_RU_NAM_VIS',
                           'P35_RISK_COUNTRY_RU_NAM_VIS',
                           'P35_CONTRACT_FIN_KIND_DESC_VIS')
                           THEN                          -- ����� �������������� � ���������� ������ ��������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and etl.F_APEX_CHECK_ADM_FIN_DEV (p_apex_user, p_apex_object_nam) = 1
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and CONTRACTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'COMMIT_BTN_LEASING' THEN                          -- ����� �������������� � ���������� ������ ��������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and etl.F_APEX_CHECK_ADM_FIN_DEV (p_apex_user, p_apex_object_nam) = 1
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and CONTRACTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'COMMIT_BTN_LEASING_USER' THEN                          -- ����� �������������� � ���������� ������ ��������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and etl.F_APEX_CHECK_ADM_FIN_DEV (p_apex_user, p_apex_object_nam) != 1
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and CONTRACTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'EXCHANGE_RATES' THEN                     -- ����� �������������� � ���������� ������ ����� �����

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and EXCHANGE_RATES_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'ORG_STRUCTURE' THEN                      -- ����� �������������� � ���������� ������ ��������� ����������� (������� � ���������� ���)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and ORG_STRUCTURE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'TRADE_PLATFORMS' THEN                      -- ����� �������������� � ���������� ������ �� �������� ���������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and TRADE_PLATFORMS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'SECURITIES_REF' THEN                      -- ����� �������������� � ���������� ������ �� ������ ����������� �� ������ �������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and SECURITIES_REF_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FORMS_GR2_REGION' THEN                   -- ����� �������������� � ���������� ������ �� �������� � ����������� �������� (������ 2)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR2_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FACT_PLAN_PAYMENTS' THEN                      -- ����� �������������� � ���������� ������ �� ������� ��������)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR2_FLG = '1'
  and FACT_PLAN_PAYMENTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FACT_REAL_PAYMENTS' THEN                      -- ����� �������������� � ���������� ������ �� ����������� ��������)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR2_FLG = '1'
  and FACT_REAL_PAYMENTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FORMS_GR3_REGION' THEN                   -- ����� �������������� � ���������� ������ �� ������ ������� (������ 3)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'ACT_PORTFOLIO_ACT' THEN                      -- ����� �������������� � ���������� ������ �� ������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and ACT_PORTFOLIO_ACT_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'ACT_DETAILS' THEN                      -- ����� �������������� � ���������� ������ �� ��������� �������� � ������ ��������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and ACT_DETAILS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'ACT_PORTFOLIO' THEN                      -- ����� �������������� � ���������� ������ �� ����� ������ �������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and ACT_PORTFOLIO_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'BILLS_REF' THEN                      -- ����� �������������� � ���������� ������ �� ��������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and BILLS_REF_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_BILL_PORTFOLIO_BTN' THEN                          -- ����� �� ������� ������ �� ����������� ��������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and DM_BILL_PORTFOLIO_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'BONDS_PORTFOLIO' THEN                      -- ����� �������������� � ���������� ������ �� ����������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and BONDS_PORTFOLIO_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_BOND_PORTFOLIO_BTN' THEN                          -- ����� �� ������� ������ �� ����������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and DM_BOND_PORTFOLIO_FLG = '1'
  and ACTUAL_FLG = '1';


ELSIF p_apex_object_nam = 'REPO_DETAILS' THEN                      -- ����� �������������� � ���������� ������ �� ����

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and REPO_DETAILS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FORMS_GR4_REGION' THEN                   -- ����� �������������� � ���������� ������ �� ���� (������ 4)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR4_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FACT_FRAUD' THEN                   -- ����� �������������� � ���������� ������ �� ���� (������ 4)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR4_FLG = '1'
  and FACT_FRAUD_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FACT_INSURANCE_EVENTS' THEN                   -- ����� �������������� � ���������� ������ �� ���� (������ 4)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR4_FLG = '1'
  and FACT_INSURANCE_EVENTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FACT_RARE_EVENTS' THEN                   -- ����� �������������� � ���������� ������ �� ���� (������ 4)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR4_FLG = '1'
  and FACT_RARE_EVENTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FORMS_GR5_REGION' THEN                   -- ����� �������������� � ���������� ������ �� �������������� �������� (������ 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_PD' THEN                   -- ����� �������������� � ���������� ������ �� �������������� �������� (������ 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and REF_PD_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_RATINGS' THEN                   -- ����� �������������� � ���������� ������ �� �������������� �������� (������ 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and REF_RATINGS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_LGD' THEN                   -- ����� �������������� � ���������� ������ �� �������������� �������� (������ 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and REF_LGD_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_COUNTRY_RATING' THEN                   -- ����� �������������� � ���������� ������ �� �������������� �������� (������ 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and REF_COUNTRY_RATING_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_CLIENT_RATINGS' THEN                   -- ����� �������������� � ���������� ������ �� �������������� �������� (������ 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and REF_CLIENT_RATINGS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'RISK_EC_CLIENT_DATA' THEN                   -- ����� �������������� � ���������� ������ �� �������������� �������� (������ 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and RISK_EC_CLIENT_DATA_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'RISK_EC_CONTRACT_DATA' THEN                   -- ����� �������������� � ���������� ������ �� �������������� �������� (������ 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and RISK_EC_CONTRACT_DATA_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_RISK_VTB_GROUP' THEN                   -- ����� �������������� � ���������� ������ �� �������������� �������� (������ 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and REF_RISK_VTB_GROUP_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_RISK_PARAMS' THEN                   -- ����� �������������� � ���������� ������ �� �������������� �������� (������ 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and REF_RISK_PARAMS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_LIP' THEN                   -- ����� �������������� � ���������� ������ �� �������������� �������� (������ 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and REF_LIP_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'LEASING_FILES' THEN                          -- ����� �� �������� ������ �� �������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and LEASING_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'EXCHANGE_RATES_FILE' THEN                          -- ����� �� �������� ������ �� ������ �����

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and EXCHANGE_RATES_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'INSTR_FILES' THEN                          -- ����� �� �������� ������ �� ����� ������������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'KS_FILE' THEN                          -- ����� �� �������� ������ �� �� �������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and KS_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'BOND_FILE' THEN                          -- ����� �� �������� ������ �� ����������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and BOND_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'BORROW_FILE' THEN                          -- ����� �� �������� ������ �� ������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and BORROW_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'COMISSION_FILE' THEN                          -- ����� �� �������� ������ �� ���������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and COMISSION_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'MISCELLANOUS_FILE' THEN                          -- ����� �� �������� ������ �� ������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and MISCELLANOUS_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'ALL_CCY_CURVES_FILE' THEN                          -- ����� �� �������� ������ �� ������ ������ �����

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and ALL_CCY_CURVES_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'IRS_FILE' THEN                          -- ����� �� �������� ������ �� ������ IRS

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and IRS_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'XLS_BANK_ACCOUNTS_FILE' THEN                          -- ����� �� �������� ������ �� ������ ��������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and XLS_BANK_ACCOUNTS_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'XLS_BA_DEPOSIT_FILE' THEN                          -- ����� �� �������� ������ �� ��������� ��

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and XLS_BA_DEPOSIT_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'CATALOGS_FILES' THEN                          -- ����� �� �������� ������ �� ���

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and CATALOGS_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'UAKR_FILES' THEN                          -- ����� �� �������� ������ �� ����

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and UAKR_FILES_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_CGP_HIST' THEN                          -- ����� �� �������� ������ �� ���

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and DM_CGP_HIST_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'BONDS_GROUP_FILE' THEN                          -- ����� �� �������� ������ �� ���������� � �������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and BONDS_GROUP_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'RISK_IFRS_CGP_FILE' THEN                          -- ����� �� �������� ������ �� �� ����

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and RISK_IFRS_CGP_FILE_FLG = '1'
  and ACTUAL_FLG = '1';


ELSIF p_apex_object_nam = 'PROVISIONS_FILE' THEN                          -- ����� �� �������� ������ �� Loans

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and PROVISIONS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FORMS_GR7_REGION' THEN                          -- ����� �� �������������� ������ �� Loans

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_GR7_REGION_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_PARAMS' THEN                          -- ����� �� �������������� ������ �� Loans

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_GR7_REGION_FLG = '1'
  and ACTUAL_FLG = '1';


ELSIF p_apex_object_nam = 'FACT_PROVISIONS_LOSS' THEN                          -- ����� �� �������������� ������ �������� �������� �� ���������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FACT_PROVISIONS_LOSS_FLG = '1'
  and ACTUAL_FLG = '1';


ELSIF p_apex_object_nam = 'RELATED_PARTIES' THEN                          -- ����� �� �������������� ���������� ��������� ������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and RELATED_PARTIES_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_LOANS' THEN                          -- ����� �� �������������� ���������� ��������� ������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and DM_LOANS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'GRF_GROUPS' THEN                          -- ����� �� �������������� ����������� ����� ��������������� ���������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and GRF_GROUPS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'CLOSE_DATE_CONTR_FILE' THEN                          -- ����� �� �������������� ����������� ����� ��������������� ���������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and CLOSE_DATE_CONTR_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'RESERVES_FILE' THEN                          -- ����� �� �������������� ����������� ����� ��������������� ���������

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and RESERVES_FLG = '1'
  and ACTUAL_FLG = '1';

   ELSIF p_apex_object_nam = 'ADM_SEC' THEN                          -- Form for links configuration etc.

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and ADM_SEC_FLG = '1'
  and ACTUAL_FLG = '1';

END IF;
    RETURN v_flg;
END;
/

