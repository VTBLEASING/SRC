create or replace force view dm.v$cc_one_contract as
select CONTRACT_NUM as "contract_number", --ovilkova 1.11.2017 due to test
       to_char(end_dt, 'yyyy-mm-dd') as "date_close",
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
       round(MAX_LEAS_OVERDUE_DAYS_12,4) as "arrears_days_max_year",
       round(LEAS_COUNT_12,4) as "arrears_days_year",
       round(AVG_LEAS_OVERDUE_DAYS,4) as "arrears_days_average",
       round(AVG_LEAS_OVERDUE_DAYS_12,4) as "arrears_days_average_year",
       round(OVERDUE_LEASING_PAYMENTS_COUNT,4) as "payments_debts",
       round(FINANCE_AMT,4) as "financing_amount",
       case when dcg.rehireable_flg = 1 then null else dcg.LEASE_SUBJECT_CNT end "lease_subject_cnt"
       ,case when dcg.rehiring_flg = 'Да' then 'Активный' else null end "work_statuses"
       ,doc_from as "doc_from"
       ,case when dcg.rehireable_flg = 1 then null else dcg.leasing_offer_num end "leasing_offer_num"
       ,case when dcg.rehireable_flg = 1 then null else dcg.lease_term_cnt end "lease_term_cnt"
       ,pay_sum as "pay_sum"
       ,case when dcg.rehireable_flg = 1 then null else dcg.LEASING_SUBJECT_nam end "leasing_subject_nam"
       ,case when dcg.rehireable_flg = 1 then null else dcg.Prepay_Rate end "adv_payment"
       ,case when dcg.rehireable_flg = 1 then null
       else (dcg.CIS_TERM_AMT_TAX_RISK +dcg.CIS_OVERDUE_AMT_TAX) end "overdue_term_amt"
       ,case when dcg.rehiring_flg = 'Да' then dcg.CONTRACT_STAGE else null end "contract_stage"
       ,case when dcg.rehireable_flg = 1 then null else dcg.PTS_FLG end "pts_flg"
       ,case when dcg.rehireable_flg = 1 then null else dcg.PTS_dt end "pts_dt"
       ,case when dcg.rehireable_flg = 1 then null else dcg.pts_comm end "pts_comm"
       ,'UDF'	"rescheduled"
       --,SNAPSHOT_DT
   from dm.dm_cgp_daily dcg where dcg.snapshot_dt>trunc(sysdate-365) and rownum<2
;

