CREATE OR REPLACE FUNCTION ETL.F_APEX_NAVIGATION_OBJECTS
(
    p_apex_user     varchar2,
    p_apex_object_nam     varchar2
)
RETURN NUMBER is
v_flg varchar2 (5);
BEGIN

IF p_apex_object_nam = 'FILES' THEN                  -- Доступ к загрузке файлов

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FILES_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DATA_MARTS' THEN                  -- Доступ к расчету витрин

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and DATA_MARTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_CGP' THEN                  -- Форма рачета витрины КГП

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and CGP_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'NIL_CORRECTS' THEN                  -- Форма внесеняи корректировоко NIL

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and NIL_CORRECTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_REG' THEN                   -- Форма расчета витрины по инстурментам

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_SWAP' THEN                   -- Форма расчета витрины по SWAP

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_SWAP_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_BOND' THEN                   -- Форма расчета витрины по BONDS

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_BOND_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_OWNBILLS' THEN                   -- Форма расчета витрины по OWNBILLS

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_OWNBILLS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_IRS' THEN                   -- Форма расчета витрины по IRS

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_IRS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_DEPOSIT' THEN                   -- Форма расчета витрины по DEPOSIT

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_DEPOSIT_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_IR_GAP' THEN                   -- Форма расчета витрины по IR_GAP

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_IR_GAP_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_KS' THEN                   -- Форма расчета витрины по KS

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_KS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_MISC' THEN                   -- Форма расчета витрины по MISC

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_MISC_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REG_NOSTRO' THEN                   -- Форма расчета витрины по NOSTRO

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and REG_FLG = '1'
  and REG_NOSTRO_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_CLIENTS' THEN                   -- Форма расчета витрины по клиентским данным

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and DM_CLIENTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_CGP_UAKR' THEN                   -- Форма расчета витрины КГП для УАКР

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and CGP_UAKR_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_UAKR_DAILY' THEN                   -- Форма расчета витрины по инстурментам

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and UAKR_DAILY_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_IFRS_NSBU' THEN                   -- Форма расчета витрины по МСФО и НСБУ

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and DM_IFRS_NSBU_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_NIL_PAYM_PERIOD' THEN                   -- Форма расчета отчета NIL по месяцам, годам, кварталам

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

ELSIF p_apex_object_nam = 'FORMS' THEN                   -- Формы редактирования и добавления данных НСИ (Группа 1-3)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FORMS_GR1_REGION' THEN                   -- Формы редактирования и добавления данных НСИ (Группа 1)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'SWAP_CONTRACTS' THEN                  -- Форма редактирования и добавления данных Конверсионные операции (своп, форвард, опцион)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and SWAP_CONTRACTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'IR_GAP' THEN                          -- Форма редактирования и добавления данных Ввод данных отчетности КИС (IR-GAP)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and IR_GAP_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'GRF_VTB_GROUP' THEN                   -- Форма редактирования и добавления данных Организации Группы ВТБ для ФГО

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and GRF_VTB_GROUP_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'GROUPS' THEN                          -- Форма редактирования и добавления данных Группы контрагентов

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and GROUPS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'CLIENTS' THEN                         -- Форма редактирования и добавления данных Контрагенты

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and CLIENTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'BANKS' THEN                            -- Форма редактирования и добавления данных Банки

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and BANKS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'BANK_ACCOUNTS' THEN                     -- Форма редактирования и добавления данных Банковские Счета

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and BANK_ACCOUNTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FACT_ACCOUNT_BALANCE' THEN             -- Форма редактирования и добавления данных Остатки на расчетных и текущих счетах

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and FACT_ACCOUNT_BALANCE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'CONTRACTS' THEN                          -- Форма редактирования и добавления данных Договоры

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
                           THEN                          -- Форма редактирования и добавления данных Договоры

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and etl.F_APEX_CHECK_ADM_FIN_DEV (p_apex_user, p_apex_object_nam) = 1
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and CONTRACTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'COMMIT_BTN_LEASING' THEN                          -- Форма редактирования и добавления данных Договоры

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and etl.F_APEX_CHECK_ADM_FIN_DEV (p_apex_user, p_apex_object_nam) = 1
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and CONTRACTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'COMMIT_BTN_LEASING_USER' THEN                          -- Форма редактирования и добавления данных Договоры

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and etl.F_APEX_CHECK_ADM_FIN_DEV (p_apex_user, p_apex_object_nam) != 1
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and CONTRACTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'EXCHANGE_RATES' THEN                     -- Форма редактирования и добавления данных Курсы валют

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and EXCHANGE_RATES_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'ORG_STRUCTURE' THEN                      -- Форма редактирования и добавления данных Структура организаций (участие в отчетности КИС)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and ORG_STRUCTURE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'TRADE_PLATFORMS' THEN                      -- Форма редактирования и добавления данных по торговым площадкам

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and TRADE_PLATFORMS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'SECURITIES_REF' THEN                      -- Форма редактирования и добавления данных по общему справчонику по ценным бумагам

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR1_FLG = '1'
  and SECURITIES_REF_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FORMS_GR2_REGION' THEN                   -- Формы редактирования и добавления данных по плановым и фактическим платежам (Группа 2)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR2_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FACT_PLAN_PAYMENTS' THEN                      -- Форма редактирования и добавления данных по планоым платежам)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR2_FLG = '1'
  and FACT_PLAN_PAYMENTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FACT_REAL_PAYMENTS' THEN                      -- Форма редактирования и добавления данных по фактическим платежам)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR2_FLG = '1'
  and FACT_REAL_PAYMENTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FORMS_GR3_REGION' THEN                   -- Формы редактирования и добавления данных по ценным бумагам (Группа 3)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'ACT_PORTFOLIO_ACT' THEN                      -- Форма редактирования и добавления данных по акциям

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and ACT_PORTFOLIO_ACT_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'ACT_DETAILS' THEN                      -- Форма редактирования и добавления данных по структуре владения в группе компаний

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and ACT_DETAILS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'ACT_PORTFOLIO' THEN                      -- Форма редактирования и добавления данных по почим ценным бумагам

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and ACT_PORTFOLIO_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'BILLS_REF' THEN                      -- Форма редактирования и добавления данных по векселям

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and BILLS_REF_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_BILL_PORTFOLIO_BTN' THEN                          -- Форма по расчету данных по собственным векселям

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and DM_BILL_PORTFOLIO_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'BONDS_PORTFOLIO' THEN                      -- Форма редактирования и добавления данных по облигациям

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and BONDS_PORTFOLIO_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_BOND_PORTFOLIO_BTN' THEN                          -- Форма по расчету данных по облигациям

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and DM_BOND_PORTFOLIO_FLG = '1'
  and ACTUAL_FLG = '1';


ELSIF p_apex_object_nam = 'REPO_DETAILS' THEN                      -- Форма редактирования и добавления данных по РЕПО

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR3_FLG = '1'
  and REPO_DETAILS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FORMS_GR4_REGION' THEN                   -- Формы редактирования и добавления данных по УАКР (Группа 4)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR4_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FACT_FRAUD' THEN                   -- Формы редактирования и добавления данных по УАКР (Группа 4)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR4_FLG = '1'
  and FACT_FRAUD_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FACT_INSURANCE_EVENTS' THEN                   -- Формы редактирования и добавления данных по УАКР (Группа 4)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR4_FLG = '1'
  and FACT_INSURANCE_EVENTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FACT_RARE_EVENTS' THEN                   -- Формы редактирования и добавления данных по УАКР (Группа 4)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR4_FLG = '1'
  and FACT_RARE_EVENTS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FORMS_GR5_REGION' THEN                   -- Формы редактирования и добавления данных по Экономическому капиталу (Группа 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_PD' THEN                   -- Формы редактирования и добавления данных по Экономическому капиталу (Группа 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and REF_PD_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_RATINGS' THEN                   -- Формы редактирования и добавления данных по Экономическому капиталу (Группа 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and REF_RATINGS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_LGD' THEN                   -- Формы редактирования и добавления данных по Экономическому капиталу (Группа 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and REF_LGD_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_COUNTRY_RATING' THEN                   -- Формы редактирования и добавления данных по Экономическому капиталу (Группа 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and REF_COUNTRY_RATING_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_CLIENT_RATINGS' THEN                   -- Формы редактирования и добавления данных по Экономическому капиталу (Группа 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and REF_CLIENT_RATINGS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'RISK_EC_CLIENT_DATA' THEN                   -- Формы редактирования и добавления данных по Экономическому капиталу (Группа 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and RISK_EC_CLIENT_DATA_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'RISK_EC_CONTRACT_DATA' THEN                   -- Формы редактирования и добавления данных по Экономическому капиталу (Группа 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and RISK_EC_CONTRACT_DATA_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_RISK_VTB_GROUP' THEN                   -- Формы редактирования и добавления данных по Экономическому капиталу (Группа 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and REF_RISK_VTB_GROUP_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_RISK_PARAMS' THEN                   -- Формы редактирования и добавления данных по Экономическому капиталу (Группа 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and REF_RISK_PARAMS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_LIP' THEN                   -- Формы редактирования и добавления данных по Экономическому капиталу (Группа 5)

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_FLG = '1'
  and FORMS_GR5_FLG = '1'
  and REF_LIP_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'LEASING_FILES' THEN                          -- Форма по загрузке файлов по лизингу

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and LEASING_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'EXCHANGE_RATES_FILE' THEN                          -- Форма по загрузке файлов по курсам валют

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and EXCHANGE_RATES_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'INSTR_FILES' THEN                          -- Форма по загрузке файлов по типам инструментов

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'KS_FILE' THEN                          -- Форма по загрузке файлов по КС потокам

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and KS_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'BOND_FILE' THEN                          -- Форма по загрузке файлов по облигациям

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and BOND_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'BORROW_FILE' THEN                          -- Форма по загрузке файлов по займам

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and BORROW_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'COMISSION_FILE' THEN                          -- Форма по загрузке файлов по комиссиям

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and COMISSION_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'MISCELLANOUS_FILE' THEN                          -- Форма по загрузке файлов по прочим

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and MISCELLANOUS_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'ALL_CCY_CURVES_FILE' THEN                          -- Форма по загрузке файлов по кривым курсов валют

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and ALL_CCY_CURVES_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'IRS_FILE' THEN                          -- Форма по загрузке файлов по кривым IRS

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and IRS_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'XLS_BANK_ACCOUNTS_FILE' THEN                          -- Форма по загрузке файлов по НОСТРО дочерних

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and XLS_BANK_ACCOUNTS_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'XLS_BA_DEPOSIT_FILE' THEN                          -- Форма по загрузке файлов по депозитам ДО

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and INSTR_FILE_FLG = '1'
  and XLS_BA_DEPOSIT_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'CATALOGS_FILES' THEN                          -- Форма по загрузке файлов по НСИ

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and CATALOGS_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'UAKR_FILES' THEN                          -- Форма по загрузке файлов по УАКР

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and UAKR_FILES_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_CGP_HIST' THEN                          -- Форма по загрузке файлов по КГП

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and DM_CGP_HIST_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'BONDS_GROUP_FILE' THEN                          -- Форма по загрузке файлов по облигациям с группой

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and BONDS_GROUP_FILE_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'RISK_IFRS_CGP_FILE' THEN                          -- Форма по загрузке файлов по ЛП МСФО

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and RISK_IFRS_CGP_FILE_FLG = '1'
  and ACTUAL_FLG = '1';


ELSIF p_apex_object_nam = 'PROVISIONS_FILE' THEN                          -- Форма по загрузке файлов по Loans

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and PROVISIONS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'FORMS_GR7_REGION' THEN                          -- Форма по редактирования данных по Loans

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_GR7_REGION_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'REF_PARAMS' THEN                          -- Форма по редактирования данных по Loans

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FORMS_GR7_REGION_FLG = '1'
  and ACTUAL_FLG = '1';


ELSIF p_apex_object_nam = 'FACT_PROVISIONS_LOSS' THEN                          -- Форма по редактирования данных Списания резервов по договорам

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and FACT_PROVISIONS_LOSS_FLG = '1'
  and ACTUAL_FLG = '1';


ELSIF p_apex_object_nam = 'RELATED_PARTIES' THEN                          -- Форма по редактирования справочник Связанных сторон

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and RELATED_PARTIES_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'DM_LOANS' THEN                          -- Форма по редактирования справочник Связанных сторон

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and DM_LOANS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'GRF_GROUPS' THEN                          -- Форма по редактирования справочника групп взаимосвязанных заемщиков

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and GRF_GROUPS_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'CLOSE_DATE_CONTR_FILE' THEN                          -- Форма по редактирования справочника групп взаимосвязанных заемщиков

  select count (1) into v_flg from etl.CTL_APEX_USER_MATRIX
  where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  and sysdate between begin_dt and end_dt
  and apex_user = p_apex_user
  and CLOSE_DATE_CONTR_FLG = '1'
  and ACTUAL_FLG = '1';

ELSIF p_apex_object_nam = 'RESERVES_FILE' THEN                          -- Форма по редактирования справочника групп взаимосвязанных заемщиков

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

