CREATE OR REPLACE FORCE VIEW DM.V$CC_CONTRACT AS
select
       contract_key as "contract_key",
       CONTRACT_NUM as "contract_number", --ovilkova 1.11.2017 due to test
       --leasing_date
       to_char(act_dt, 'yyyy-mm-dd') as "act_dt",
       to_char(end_dt, 'yyyy-mm-dd') as "date_close",
       vehicle_category_cd as "vehicle_category_cd",
       SHORT_CLIENT_RU_NAM as "name",
       INN as "inn",
       round(ADVANCE_RUB,4) as "prepaid",
       STATUS_1C_DESC as "status",
       round(CONTRACT_STATUS_KEY,4) as "work_status",
       round(SUPPLY_RUB,4) as "leasing_cost",
       round(nvl(BALANCE, 0),4) as "balance",
       round(LEASING_PAYMENTS_COUNT,4) as "payments_total",
       round(LEASING_PAYMENTS_COUNT_12,4) as "payments_year",
       round(CUR_LEAS_OVERDUE_AMT,4) as "current_arrears",
       --max_arrears,
       --AVERAGE_ARREARS,
       cis_avg_overdue_amt as "cis_avg_overdue_amt",
--  case when dcg.rehiring_flg = 'Да' then '1' else '0' end as "rescheduled", --5332 22102018 instead of rehiring_flg
       dcg.rehiring_flg  as "rescheduled", --5332 22102018 instead of rehiring_flg
     case when dcg.rehireable_flg = 1 then null else dcg.LEASE_SUBJECT_CNT end as "lease_subject_cnt", --5332
--  case when dcg.rehiring_flg = 'Да' then 'Активный' else null end as "work_statuses", --5332
       case when dcg.rehiring_flg = 1 then 'Активный' else null end as "work_statuses", --5332
       to_char(doc_from, 'yyyy-mm-dd') as "doc_from", --5332
       case when dcg.rehireable_flg = 1 then null else dcg.leasing_offer_num end as "leasing_offer_num", --5332
       case when dcg.rehireable_flg = 1 then null else dcg.lease_term_cnt end as "lease_term_cnt", --5332
       pay_sum as "pay_sum", --5332
       case when dcg.rehireable_flg = 1 then null else dcg.LEASING_SUBJECT_nam end as "leasing_subject_nam", --5332
       case when dcg.rehireable_flg = 1 then null else dcg.Prepay_Rate end as "adv_payment", --5332
       case when dcg.rehireable_flg = 1 then null else (nvl(dcg.CIS_TERM_AMT_TAX_RISK,0) + nvl(dcg.CIS_OVERDUE_AMT_TAX,0)) end "overdue_amt", --5332 22102018 instead of overdue_term_amt
       --case when dcg.rehiring_flg = 'Да' then dcg.CONTRACT_STAGE else null end "contract_stage", --5332
       case when dcg.rehiring_flg = 1 then dcg.CONTRACT_STAGE else null end "contract_stage", --5332
       --case when dcg.rehireable_flg = 1 then null else dcg.PTS_FLG end "pts_flg", --5332
     case when dcg.rehireable_flg = 1 then null else (case when dcg.PTS_FLG = 'Да' then '1' else '0' end) end "pts_flg", --5332 22102018 Should be 1/0 or true/false
     case when dcg.rehireable_flg = 1 then null else to_char(dcg.PTS_dt, 'yyyy-mm-dd') end "pts_dt", --5332
       case when dcg.rehireable_flg = 1 then null else dcg.pts_comm end "pts_comm", --5332
       round(CUR_ADV_OVERDUE_AMT,4) as "prepaid_expense_amount",
       round(CUR_ADV_OVERDUE_DAYS,4) as "prepaid_expense_days",
       round(CUR_RED_OVERDUE_AMT,4) as "redemption_amount",
       round(CUR_RED_OVERDUE_DAYS,4) as "redemption_days",
       round(CUR_OTH_COM_OVERDUE_AMT,4) as "commission_oth_amount",
       round(CUR_OTH_COM_OVERDUE_DAYS,4) as "commission_oth_days",
       round(CUR_FIX_COM_OVERDUE_AMT,4) as "commission_fix_amount",
       round(CUR_FIX_COM_OVERDUE_DAYS,4) as "commission_fix_days",
       round(CUR_SUB_OVERDUE_AMT,4) as "subsidy_amount",
       round(CUR_SUB_OVERDUE_DAYS,4) as "subsidy_days",
       round(CUR_ADD_OVERDUE_AMT,4) as "comp_add_amount",
       round(CUR_ADD_INS_OVERDUE_DAYS,4) as "comp_add_days",
       round(CUR_INS_OVERDUE_AMT,4) as "comp_ins_amount",
       round(CUR_INS_OVERDUE_DAYS,4) as "comp_ins_days",
       round(CUR_REG_OVERDUE_AMT,4) as "comp_reg_amount",
       round(CUR_REG_OVERDUE_DAYS,4) as "comp_reg_days",
       round(CUR_FOR_OVERDUE_AMT,4) as "comp_for_amount",
       round(CUR_FOR_OVERDUE_DAYS,4) as "comp_for_days",
       round(CUR_PEN_OVERDUE_AMT,4) as "penalty_amount",
       round(CUR_PEN_OVERDUE_DAYS,4) as "penalty_days",
       round(CUR_OVR_OVERDUE_AMT,4) as "overpayment_amount",
       round(CUR_OVR_OVERDUE_DAYS,4) as "overpayment_days",
       round(CUR_INSUR_OVERDUE_AMT,4) as "insur_amount",
       round(CUR_INSUR_OVERDUE_DAYS,4) as "insur_days",
       round(CUR_OTH_OVERDUE_AMT,4) as "other_amount",
       round(CUR_OTH_OVERDUE_DAYS,4) as "other_days",
       round(CUR_LEAS_OVERDUE_DAYS,4) as "arrears_days",
       round(MAX_LEAS_OVERDUE_DAYS,4) as "arrears_days_max",
       cis_overdue_amt as "cis_overdue_amt",
       round(MAX_LEAS_OVERDUE_DAYS_12,4) as "arrears_days_max_year",
       round(LEAS_COUNT_12,4) as "arrears_days_year",
       round(AVG_LEAS_OVERDUE_DAYS,4) as "arrears_days_average",
       round(AVG_LEAS_OVERDUE_DAYS_12,4) as "arrears_days_average_year",
       round(OVERDUE_LEASING_PAYMENTS_COUNT,4) as "payments_debts",
       round(FINANCE_AMT,4) as "financing_amount",
       SNAPSHOT_DT
  from (SELECT a.*
               --row_number() over(partition by CONTRACT_NUM, snapshot_dt order by to_char(end_dt, 'yyyy-mm-dd')) rn
               from dm.dm_cgp_daily a
               --where a.cr_ch_flg = 1
               ) dcg--ovilkova 27/12/2017
where /*contract_status_key in(15,25) and */ /*cr_ch_flg = 1 and  rn=1 */
--and snapshot_dt=trunc(sysdate)
CONTRACT_NUM is not null
and SHORT_CLIENT_RU_NAM is not null
and contract_id_cd is not null
;
comment on column DM.V$CC_CONTRACT.contract_key is 'ID договора';
comment on column DM.V$CC_CONTRACT.contract_number is 'Номер договора';
comment on column DM.V$CC_CONTRACT.act_dt is 'Дата акта передачи в лизинг';
comment on column DM.V$CC_CONTRACT.date_close is 'Дата закрытия договора';
comment on column DM.V$CC_CONTRACT.vehicle_category_cd is 'Идентификатор CRM категории ТС в предложение';
comment on column DM.V$CC_CONTRACT.name is 'Краткое наименование контрагента';
comment on column DM.V$CC_CONTRACT.inn is 'ИНН контрагента';
comment on column DM.V$CC_CONTRACT.prepaid is 'Аванс в рублях';
comment on column DM.V$CC_CONTRACT.status is 'Статус договора 1С';
comment on column DM.V$CC_CONTRACT.work_status is 'Рабочий статус договора';
comment on column DM.V$CC_CONTRACT.leasing_cost is 'Стоимость предмета лизинга в рублях по оплаченным поставкам';
comment on column DM.V$CC_CONTRACT.balance is 'Остаток долга с НДС, руб. по состоянию на 1 число';
comment on column DM.V$CC_CONTRACT.payments_total is 'Кол-во внесенных лизинговых платежей';
comment on column DM.V$CC_CONTRACT.payments_year is 'Кол-во внесенных лизинговых платежей за последние 12 мес.';
comment on column DM.V$CC_CONTRACT.current_arrears is 'Просроченная задолженность по лиз. платежам, руб, текущая';
comment on column DM.V$CC_CONTRACT.cis_avg_overdue_amt is 'Средняя просроченная задолженность без НДС (КИС)';
comment on column DM.V$CC_CONTRACT.lease_subject_cnt is 'Количество ПЛ';
comment on column DM.V$CC_CONTRACT.work_statuses is 'Статус ДЛ';
comment on column DM.V$CC_CONTRACT.doc_from is 'Дата ДЛ/Перенайма';
comment on column DM.V$CC_CONTRACT.leasing_offer_num is 'Номер предложения';
comment on column DM.V$CC_CONTRACT.lease_term_cnt is 'Срок лизинга';
comment on column DM.V$CC_CONTRACT.pay_sum is 'Лизинговый платеж';
comment on column DM.V$CC_CONTRACT.leasing_subject_nam is 'ПЛ';
comment on column DM.V$CC_CONTRACT.adv_payment is 'Аванс с учетом субсидии';
comment on column DM.V$CC_CONTRACT.contract_stage is 'Этап ДЛ';
comment on column DM.V$CC_CONTRACT.pts_flg is 'Наличие ПТС/ПСМ';
comment on column DM.V$CC_CONTRACT.pts_dt is 'Дата получения';
comment on column DM.V$CC_CONTRACT.pts_comm is 'Комментарии';
comment on column DM.V$CC_CONTRACT.prepaid_expense_amount is 'Сумма просроченной задолженности по статье «Аванс (с НДС)»';
comment on column DM.V$CC_CONTRACT.prepaid_expense_days is 'Количество дней просрочки по статье «Аванс (с НДС)», текущее';
comment on column DM.V$CC_CONTRACT.redemption_amount is 'Сумма просроченной задолженности по статье «Выкупная стоимость (с НДС)»';
comment on column DM.V$CC_CONTRACT.redemption_days is 'Количество дней просрочки по статье «Выкупная стоимость (с НДС)»», текущее';
comment on column DM.V$CC_CONTRACT.commission_oth_amount is 'Сумма просроченной задолженности по статье «Иные комиссии за оказанные услуги (предусмотренные ДЛ)»';
comment on column DM.V$CC_CONTRACT.commission_oth_days is 'Количество дней просрочки по статье «Иные комиссии за оказанные услуги (предусмотренные ДЛ)», текущее';
comment on column DM.V$CC_CONTRACT.commission_fix_amount is 'Сумма просроченной задолженности по статье «Комиссия фиксированная»';
comment on column DM.V$CC_CONTRACT.commission_fix_days is 'Количество дней просрочки по статье «Комиссия фиксированная», текущее';
comment on column DM.V$CC_CONTRACT.subsidy_amount is 'Сумма просроченной задолженности по статье «Компенсационный платеж (субсидия)»';
comment on column DM.V$CC_CONTRACT.subsidy_days is 'Количество дней просрочки по статье «Компенсационный платеж (субсидия)», текущее';
comment on column DM.V$CC_CONTRACT.comp_add_amount is 'Сумма просроченной задолженности по статье «Компенсация затрат (доп. услуги)»';
comment on column DM.V$CC_CONTRACT.comp_add_days is 'Количество дней просрочки по статье «Компенсация затрат (доп. услуги)», текущее';
comment on column DM.V$CC_CONTRACT.comp_ins_amount is 'Сумма просроченной задолженности по статье «Компенсация затрат (страхование ПЛ)»';
comment on column DM.V$CC_CONTRACT.comp_ins_days is 'Количество дней просрочки по статье «Компенсация затрат (страхование ПЛ)», текущее';
comment on column DM.V$CC_CONTRACT.comp_reg_amount is 'Сумма просроченной задолженности по статье «Компенсация затрат (услуга регистрации ТС в ГИБДД)»';
comment on column DM.V$CC_CONTRACT.comp_reg_days is 'Количество дней просрочки по статье «Компенсация затрат (услуга регистрации ТС в ГИБДД)», текущее';
comment on column DM.V$CC_CONTRACT.comp_for_amount is 'Сумма просроченной задолженности по статье «Компенсация затрат (штрафы за нарушение ПДД)»';
comment on column DM.V$CC_CONTRACT.comp_for_days is 'Количество дней просрочки по статье «Компенсация затрат (штрафы за нарушение ПДД)», текущее';
comment on column DM.V$CC_CONTRACT.penalty_amount is 'Сумма просроченной задолженности по статье «Пени»';
comment on column DM.V$CC_CONTRACT.penalty_days is 'Количество дней просрочки по статье «Пени», текущее';
comment on column DM.V$CC_CONTRACT.overpayment_amount is 'Сумма просроченной задолженности по статье «Переплата»';
comment on column DM.V$CC_CONTRACT.overpayment_days is 'Количество дней просрочки по статье «Переплата», текущее';
comment on column DM.V$CC_CONTRACT.insur_amount is 'Сумма просроченной задолженности по статье «Страховое возмещение»';
comment on column DM.V$CC_CONTRACT.insur_days is 'Количество дней просрочки по статье «Страховое возмещение», текущее';
comment on column DM.V$CC_CONTRACT.other_amount is 'Сумма просроченной задолженности по прочим статьям';
comment on column DM.V$CC_CONTRACT.other_days is 'Количество дней просрочки по прочим статьям, текущее';
comment on column DM.V$CC_CONTRACT.arrears_days is 'Количество дней просрочки по лизинговым платежам, текущее';
comment on column DM.V$CC_CONTRACT.arrears_days_max is 'Количество дней просрочки по лизинговым платежам, максимальное';
comment on column DM.V$CC_CONTRACT.cis_overdue_amt is 'Просроченная задолженность без НДС (КИС)';
comment on column DM.V$CC_CONTRACT.arrears_days_max_year is 'Количество дней просрочки по лизинговым платежам, максимальное за последние 12 мес.';
comment on column DM.V$CC_CONTRACT.arrears_days_year is 'Количество раз просрочек за последние 12 мес.';
comment on column DM.V$CC_CONTRACT.arrears_days_average is 'Количество дней просрочки по лизинговым платежам, среднее';
comment on column DM.V$CC_CONTRACT.arrears_days_average_year is 'Количество дней просрочки по лизинговым платежам, среднее за последние 12 мес.';
comment on column DM.V$CC_CONTRACT.payments_debts is 'Количество лизинговых платежей с текущей просроченной задолженностью';
comment on column DM.V$CC_CONTRACT.financing_amount is 'Сумма финансирования по договору со стороны ВТБЛ, руб, первоначальная';

