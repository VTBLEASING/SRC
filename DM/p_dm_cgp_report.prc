CREATE OR REPLACE PROCEDURE DM.P_DM_CGP_REPORT(
p_REPORT_DT date
)
is

BEGIN

  /* Процедура расчета витрины DM_CGP_REPORT полностью.
     В качестве входного параметра подается дата составления отчета
  */
  dm.u_log(p_proc => 'DM.P_DM_CGP_REPORT',
           p_step => 'INPUT PARAMS',
           p_info => 'p_REPORT_DT: '||p_REPORT_DT);

 delete from DM_CGP_REPORT
 where snapshot_dt = p_REPORT_DT;

  dm.u_log(p_proc => 'DM.P_DM_CGP_REPORT',
           p_step => 'delete from DM_CGP_REPORT',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');

  commit;

INSERT /*+ APPEND */ INTO DM.DM_CGP_REPORT
select
/*snapshot_dt,
contract_key,
contract_app_key,
client_key,
currency_cd,
contract_id_cd,
tranche_number,
date_,
sum_,
sum_discount,
xirr*/
--================================================================
a.ReportingDate as snapshot_dt,
pp.CONTRACT_KEY,
pp.CONTRACT_APP_KEY,
cc.CLIENT_KEY,
curr.CURRENCY_cd,
CC.CONTRACT_ID_CD ||'#'|| lapp.PRESENTATION as CURRENT_ACCOUNT_NUMBER,
lapp.PRESENTATION as TRANCHE_NUMBER,
pp.date_,
sum(pp.sum_) as sum_ ,
sum(pp.sum_/power((1+(a.xirr/100)),((pp.date_ - a.ReportingDate)/365))) as sum_discount,
a.xirr
FROM
--(select a.contract_app_key, a.reportingdate, a.contract_key, a.xirr, a.CLIENT_KEY, a.valid_to_dttm from DWH.REPORTLOANPORTFOLIO a) a
DWH.REPORTLOANPORTFOLIO a
LEFT JOIN (select p.contract_key, p.CONTRACT_APP_KEY/*, p.PAYMENT_ITEM_KEY*/, MAX(p.REGISTRATORDATE) mr_dt from dwh.PAYMENTSCHEDULEIFRS p --ovilkova 15/10 due to methodology correction
where --p.PAYMENT_ITEM_KEY IN ('50','49','48','77') and --ovilkova 15/10 due to methodology correction
to_date(substr(REGISTRATORDATE,0,10),'yyyy-mm-dd') <= p_REPORT_DT
and p.valid_to_dttm = '01.01.2400'-- 16/11 ovilkova
group by p.contract_key, p.CONTRACT_APP_KEY/*, p.PAYMENT_ITEM_KEY*/) p --ovilkova 15/10 due to methodology correction
on p.CONTRACT_KEY = A.CONTRACT_KEY and p.CONTRACT_APP_KEY = a.CONTRACT_APP_KEY
LEFT JOIN (select pp.contract_key, pp.CONTRACT_APP_KEY, pp.PAYMENT_ITEM_KEY, pp.REGISTRATORDATE , pp.valid_to_dttm, pp.date_, pp.sum_
from dwh.PAYMENTSCHEDULEIFRS pp
where pp.valid_to_dttm = '01.01.2400'--16/11 ovilkova
) pp on pp.CONTRACT_KEY = p.CONTRACT_KEY and pp.CONTRACT_APP_KEY = p.CONTRACT_APP_KEY and pp.registratordate = p.mr_dt
and  /*pp.payment_item_key = p.PAYMENT_ITEM_KEY  and*/ pp.DATE_ > a.reportingdate and pp.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy') --ovilkova 15/10 due to methodology correction
LEFT JOIN dwh.payment_items pi on pp.PAYMENT_ITEM_KEY = pi.PAYMENT_ITEM_KEY and pi.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy')
LEFT JOIN DWH.CONTRACTS CC ON CC.CONTRACT_KEY = A.CONTRACT_KEY and cc.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy')
LEFT JOIN DWH.CURRENCIES CURR on cc.currency_key = CURR.CURRENCY_KEY and CURR.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy')
LEFT JOIN DWH.LEASING_CONTRACTS_APPLS LAPP ON LAPP.CONTRACT_KEY = a.CONTRACT_KEY and LAPP.CONTRACT_APP_KEY = A.CONTRACT_APP_KEY and lapp.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy')
where a.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy') and pp.contract_app_key is not null and a.ReportingDate = p_REPORT_DT
and pp.payment_item_key IN ('50',/*'49',*/'48' /*,'77'*/) --ovilkova 15/10 due to methodology correction
group by a.ReportingDate,
pp.CONTRACT_KEY,
cc.CONTRACT_ID_CD,
pp.CONTRACT_APP_KEY,
cc.CLIENT_KEY,
curr.CURRENCY_cd,
CC.CONTRACT_ID_CD ||'#'|| lapp.PRESENTATION,
lapp.PRESENTATION,
pp.date_,
a.xirr;
--======
--from DM.V$CGP_REPORT
--where snapshot_dt = p_REPORT_DT;

  dm.u_log(p_proc => 'DM.P_DM_CGP_REPORT',
           p_step => 'insert DM.DM_CGP_REPORT',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');

      commit;

   dm.analyze_table(p_table_name => 'DM_CGP_REPORT',p_schema => 'DM');

   dm.u_log(p_proc => 'DM.P_DM_CGP_REPORT',
           p_step => 'analyze_table DM.DM_CGP_REPORT',
           p_info => 'analyze_table done');
  etl.P_DM_LOG('DM_CGP_REPORT');
END;
/

