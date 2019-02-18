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
--  case when dcg.rehiring_flg = '��' then '1' else '0' end as "rescheduled", --5332 22102018 instead of rehiring_flg
       dcg.rehiring_flg  as "rescheduled", --5332 22102018 instead of rehiring_flg
     case when dcg.rehireable_flg = 1 then null else dcg.LEASE_SUBJECT_CNT end as "lease_subject_cnt", --5332
--  case when dcg.rehiring_flg = '��' then '��������' else null end as "work_statuses", --5332
       case when dcg.rehiring_flg = 1 then '��������' else null end as "work_statuses", --5332
       to_char(doc_from, 'yyyy-mm-dd') as "doc_from", --5332
       case when dcg.rehireable_flg = 1 then null else dcg.leasing_offer_num end as "leasing_offer_num", --5332
       case when dcg.rehireable_flg = 1 then null else dcg.lease_term_cnt end as "lease_term_cnt", --5332
       pay_sum as "pay_sum", --5332
       case when dcg.rehireable_flg = 1 then null else dcg.LEASING_SUBJECT_nam end as "leasing_subject_nam", --5332
       case when dcg.rehireable_flg = 1 then null else dcg.Prepay_Rate end as "adv_payment", --5332
       case when dcg.rehireable_flg = 1 then null else (nvl(dcg.CIS_TERM_AMT_TAX_RISK,0) + nvl(dcg.CIS_OVERDUE_AMT_TAX,0)) end "overdue_amt", --5332 22102018 instead of overdue_term_amt
       --case when dcg.rehiring_flg = '��' then dcg.CONTRACT_STAGE else null end "contract_stage", --5332
       case when dcg.rehiring_flg = 1 then dcg.CONTRACT_STAGE else null end "contract_stage", --5332
       --case when dcg.rehireable_flg = 1 then null else dcg.PTS_FLG end "pts_flg", --5332
     case when dcg.rehireable_flg = 1 then null else (case when dcg.PTS_FLG = '��' then '1' else '0' end) end "pts_flg", --5332 22102018 Should be 1/0 or true/false
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
comment on column DM.V$CC_CONTRACT.contract_key is 'ID ��������';
comment on column DM.V$CC_CONTRACT.contract_number is '����� ��������';
comment on column DM.V$CC_CONTRACT.act_dt is '���� ���� �������� � ������';
comment on column DM.V$CC_CONTRACT.date_close is '���� �������� ��������';
comment on column DM.V$CC_CONTRACT.vehicle_category_cd is '������������� CRM ��������� �� � �����������';
comment on column DM.V$CC_CONTRACT.name is '������� ������������ �����������';
comment on column DM.V$CC_CONTRACT.inn is '��� �����������';
comment on column DM.V$CC_CONTRACT.prepaid is '����� � ������';
comment on column DM.V$CC_CONTRACT.status is '������ �������� 1�';
comment on column DM.V$CC_CONTRACT.work_status is '������� ������ ��������';
comment on column DM.V$CC_CONTRACT.leasing_cost is '��������� �������� ������� � ������ �� ���������� ���������';
comment on column DM.V$CC_CONTRACT.balance is '������� ����� � ���, ���. �� ��������� �� 1 �����';
comment on column DM.V$CC_CONTRACT.payments_total is '���-�� ��������� ���������� ��������';
comment on column DM.V$CC_CONTRACT.payments_year is '���-�� ��������� ���������� �������� �� ��������� 12 ���.';
comment on column DM.V$CC_CONTRACT.current_arrears is '������������ ������������� �� ���. ��������, ���, �������';
comment on column DM.V$CC_CONTRACT.cis_avg_overdue_amt is '������� ������������ ������������� ��� ��� (���)';
comment on column DM.V$CC_CONTRACT.lease_subject_cnt is '���������� ��';
comment on column DM.V$CC_CONTRACT.work_statuses is '������ ��';
comment on column DM.V$CC_CONTRACT.doc_from is '���� ��/���������';
comment on column DM.V$CC_CONTRACT.leasing_offer_num is '����� �����������';
comment on column DM.V$CC_CONTRACT.lease_term_cnt is '���� �������';
comment on column DM.V$CC_CONTRACT.pay_sum is '���������� ������';
comment on column DM.V$CC_CONTRACT.leasing_subject_nam is '��';
comment on column DM.V$CC_CONTRACT.adv_payment is '����� � ������ ��������';
comment on column DM.V$CC_CONTRACT.contract_stage is '���� ��';
comment on column DM.V$CC_CONTRACT.pts_flg is '������� ���/���';
comment on column DM.V$CC_CONTRACT.pts_dt is '���� ���������';
comment on column DM.V$CC_CONTRACT.pts_comm is '�����������';
comment on column DM.V$CC_CONTRACT.prepaid_expense_amount is '����� ������������ ������������� �� ������ ������ (� ���)�';
comment on column DM.V$CC_CONTRACT.prepaid_expense_days is '���������� ���� ��������� �� ������ ������ (� ���)�, �������';
comment on column DM.V$CC_CONTRACT.redemption_amount is '����� ������������ ������������� �� ������ ��������� ��������� (� ���)�';
comment on column DM.V$CC_CONTRACT.redemption_days is '���������� ���� ��������� �� ������ ��������� ��������� (� ���)��, �������';
comment on column DM.V$CC_CONTRACT.commission_oth_amount is '����� ������������ ������������� �� ������ ����� �������� �� ��������� ������ (��������������� ��)�';
comment on column DM.V$CC_CONTRACT.commission_oth_days is '���������� ���� ��������� �� ������ ����� �������� �� ��������� ������ (��������������� ��)�, �������';
comment on column DM.V$CC_CONTRACT.commission_fix_amount is '����� ������������ ������������� �� ������ ��������� ��������������';
comment on column DM.V$CC_CONTRACT.commission_fix_days is '���������� ���� ��������� �� ������ ��������� ��������������, �������';
comment on column DM.V$CC_CONTRACT.subsidy_amount is '����� ������������ ������������� �� ������ ���������������� ������ (��������)�';
comment on column DM.V$CC_CONTRACT.subsidy_days is '���������� ���� ��������� �� ������ ���������������� ������ (��������)�, �������';
comment on column DM.V$CC_CONTRACT.comp_add_amount is '����� ������������ ������������� �� ������ ������������ ������ (���. ������)�';
comment on column DM.V$CC_CONTRACT.comp_add_days is '���������� ���� ��������� �� ������ ������������ ������ (���. ������)�, �������';
comment on column DM.V$CC_CONTRACT.comp_ins_amount is '����� ������������ ������������� �� ������ ������������ ������ (����������� ��)�';
comment on column DM.V$CC_CONTRACT.comp_ins_days is '���������� ���� ��������� �� ������ ������������ ������ (����������� ��)�, �������';
comment on column DM.V$CC_CONTRACT.comp_reg_amount is '����� ������������ ������������� �� ������ ������������ ������ (������ ����������� �� � �����)�';
comment on column DM.V$CC_CONTRACT.comp_reg_days is '���������� ���� ��������� �� ������ ������������ ������ (������ ����������� �� � �����)�, �������';
comment on column DM.V$CC_CONTRACT.comp_for_amount is '����� ������������ ������������� �� ������ ������������ ������ (������ �� ��������� ���)�';
comment on column DM.V$CC_CONTRACT.comp_for_days is '���������� ���� ��������� �� ������ ������������ ������ (������ �� ��������� ���)�, �������';
comment on column DM.V$CC_CONTRACT.penalty_amount is '����� ������������ ������������� �� ������ �����';
comment on column DM.V$CC_CONTRACT.penalty_days is '���������� ���� ��������� �� ������ �����, �������';
comment on column DM.V$CC_CONTRACT.overpayment_amount is '����� ������������ ������������� �� ������ ����������';
comment on column DM.V$CC_CONTRACT.overpayment_days is '���������� ���� ��������� �� ������ ����������, �������';
comment on column DM.V$CC_CONTRACT.insur_amount is '����� ������������ ������������� �� ������ ���������� ����������';
comment on column DM.V$CC_CONTRACT.insur_days is '���������� ���� ��������� �� ������ ���������� ����������, �������';
comment on column DM.V$CC_CONTRACT.other_amount is '����� ������������ ������������� �� ������ �������';
comment on column DM.V$CC_CONTRACT.other_days is '���������� ���� ��������� �� ������ �������, �������';
comment on column DM.V$CC_CONTRACT.arrears_days is '���������� ���� ��������� �� ���������� ��������, �������';
comment on column DM.V$CC_CONTRACT.arrears_days_max is '���������� ���� ��������� �� ���������� ��������, ������������';
comment on column DM.V$CC_CONTRACT.cis_overdue_amt is '������������ ������������� ��� ��� (���)';
comment on column DM.V$CC_CONTRACT.arrears_days_max_year is '���������� ���� ��������� �� ���������� ��������, ������������ �� ��������� 12 ���.';
comment on column DM.V$CC_CONTRACT.arrears_days_year is '���������� ��� ��������� �� ��������� 12 ���.';
comment on column DM.V$CC_CONTRACT.arrears_days_average is '���������� ���� ��������� �� ���������� ��������, �������';
comment on column DM.V$CC_CONTRACT.arrears_days_average_year is '���������� ���� ��������� �� ���������� ��������, ������� �� ��������� 12 ���.';
comment on column DM.V$CC_CONTRACT.payments_debts is '���������� ���������� �������� � ������� ������������ ��������������';
comment on column DM.V$CC_CONTRACT.financing_amount is '����� �������������� �� �������� �� ������� ����, ���, ��������������';

