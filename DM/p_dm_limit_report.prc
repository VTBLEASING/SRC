CREATE OR REPLACE PROCEDURE DM.P_DM_LIMIT_REPORT(
p_REPORT_DT date
)
is

BEGIN

  /* Процедура расчета витрины DM_LIMIT_REPORT полностью.
     В качестве входного параметра подается дата составления отчета
  */
  dm.u_log(p_proc => 'DM.P_DM_LIMIT_REPORT',
           p_step => 'INPUT PARAMS',
           p_info => 'p_REPORT_DT: '||p_REPORT_DT);

 delete from DM.DM_LIMIT_REPORT
 where snapshot_dt = p_REPORT_DT;

  dm.u_log(p_proc => 'DM.P_DM_LIMIT_REPORT',
           p_step => 'delete from DM_LIMIT_REPORT',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');

  commit;

INSERT /*+ APPEND */ INTO DM.DM_LIMIT_REPORT
select
snapshot_dt,
contract_key,
contract_id_cd,
contract_app_key,
client_key,
FULL_CLIENT_RU_NAM,
contract_num,
app_num,
NIL_NDS,
NIL_NO_NDS,
OVD_NDS,
OVD_NO_NDS,
FLG
from DM.V$LIMIT_REPORT
where snapshot_dt = p_REPORT_DT
UNION ALL
select
p_REPORT_DT as snapshot_dt,
fpp.contract_key as contract_key,
ccc.contract_id_cd as contract_id_cd,
fpp.contract_app_key as contract_app_key,
ccc.client_key as client_key,
cll.full_client_ru_nam as full_client_ru_nam,
ccc.contract_num as contract_num,
lappp.contract_num as APP_NUM,
--currr.exchange_rate as exchange_rate,
(fpp.PAY_AMT - fpp_av.PAY_AMT) as NIL_NDS,
(fpp.PAY_AMT - fpp_av.PAY_AMT) * (1-ccc.contract_vat_rate) as NIL_NO_NDS,
CAST (NULL AS NUMBER) as OVD_NDS,
CAST (NULL AS NUMBER) as OVD_NO_NDS,
0 as FLG
from
(select contract_app_key, contract_key, sum(pay_amt) pay_amt from dwh.fact_plan_payments fpp
where pay_dt <= p_report_dt and cbc_desc like '%ОД.3.1%' and fpp.VALID_TO_DTTM = to_date ('01.01.2400', 'dd.mm.yy')
group by contract_key, contract_app_key) fpp
LEFT JOIN (select contract_app_key, contract_key, sum(pay_amt) pay_amt from dwh.fact_plan_payments fpp
where pay_dt <= p_report_dt and cbc_desc like '%ОД.3.1%' and fpp.payment_item_key in (8, 2) and fpp.VALID_TO_DTTM = to_date ('01.01.2400', 'dd.mm.yy')
group by contract_key, contract_app_key) fpp_av
on fpp.contract_key = fpp_av.contract_key and fpp.contract_app_key = fpp_av.contract_app_key
INNER JOIN (select CONTRACT_KEY,CONTRACT_ID_CD, CLIENT_KEY, CONTRACT_NUM, CURRENCY_KEY, CONTRACT_VAT_RATE from DWH.CONTRACTS where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy')) CCC ON CCC.CONTRACT_KEY = FPP.CONTRACT_KEY
INNER JOIN (SELECT full_client_ru_nam, client_key from DWH.CLIENTS where VALID_TO_DTTM = to_date ('01.01.2400', 'dd.mm.yy')) CLL ON CCC.CLIENT_KEY = CLL.CLIENT_KEY
--LEFT JOIN (SELECT currency_key, exchange_rate,BASE_CURRENCY_KEY, valid_to_dttm from DWH.EXCHANGE_RATES) CURRR on ccc.currency_key = CURRR.CURRENCY_KEY and CURRR.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy') and currr.BASE_CURRENCY_KEY = 125
INNER JOIN (SELECT contract_key, contract_app_key, contract_num, valid_to_dttm from DWH.LEASING_CONTRACTS_APPLS) LAPPP ON LAPPP.CONTRACT_KEY = fpp.CONTRACT_KEY and LAPPP.CONTRACT_APP_KEY = fpp.CONTRACT_APP_KEY and lappp.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy')
INNER JOIN (select contract_app_key from dwh.LEASING_SUBJECT_TRANSMIT lst where (lst.act_num IS NULL OR lst.ACT_DT > snapshot_DT) and lst.contract_app_key is not null and lst.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy')) lst ON fpp.contract_app_key = lst.contract_app_key
INNER JOIN (select contract_key from dwh.fact_leasing_contracts_status flc where flc.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy') and status_desc in ('Подписан (вступил в силу)', 'Страховой случай')) flc ON fpp.contract_key = flc.contract_key
;

  dm.u_log(p_proc => 'DM.P_DM_LIMIT_REPORT',
           p_step => 'insert DM.DM_LIMIT_REPORT',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');

      commit;

   dm.analyze_table(p_table_name => 'DM_LIMIT_REPORT',p_schema => 'DM');

   dm.u_log(p_proc => 'DM.P_DM_LIMIT_REPORT',
           p_step => 'analyze_table DM.DM_LIMIT_REPORT',
           p_info => 'analyze_table done');
  etl.P_DM_LOG('DM_LIMIT_REPORT');
END;
/

