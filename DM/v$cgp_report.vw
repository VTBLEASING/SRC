CREATE OR REPLACE FORCE VIEW DM.V$CGP_REPORT AS
SELECT
a.ReportingDate as snapshot_dt,
pp.CONTRACT_KEY,
cc.CONTRACT_ID_CD,
pp.CONTRACT_APP_KEY,
cc.CLIENT_KEY,
curr.CURRENCY_cd,
CC.CONTRACT_ID_CD ||'#'|| lapp.PRESENTATION as CURRENT_ACCOUNT_NUMBER,
lapp.PRESENTATION as TRANCHE_NUMBER,
pp.date_,
a.xirr,
sum(pp.sum_) as sum_ ,
sum(pp.sum_/power((1+(a.xirr/100)),((pp.date_ - a.ReportingDate)/365))) as sum_discount
FROM
--(select a.contract_app_key, a.reportingdate, a.contract_key, a.xirr, a.CLIENT_KEY, a.valid_to_dttm from DWH.REPORTLOANPORTFOLIO a) a
DWH.REPORTLOANPORTFOLIO a
LEFT JOIN (select p.contract_key, p.CONTRACT_APP_KEY, p.PAYMENT_ITEM_KEY, MAX(p.REGISTRATORDATE) mr_dt from dwh.PAYMENTSCHEDULEIFRS p
where p.PAYMENT_ITEM_KEY IN ('50','49','48','77') group by p.contract_key, p.CONTRACT_APP_KEY, p.PAYMENT_ITEM_KEY) p
on p.CONTRACT_KEY = A.CONTRACT_KEY and p.CONTRACT_APP_KEY = a.CONTRACT_APP_KEY
LEFT JOIN (select pp.contract_key, pp.CONTRACT_APP_KEY, pp.PAYMENT_ITEM_KEY, pp.REGISTRATORDATE , pp.valid_to_dttm, pp.date_, pp.sum_
from dwh.PAYMENTSCHEDULEIFRS pp) pp on pp.CONTRACT_APP_KEY = p.CONTRACT_APP_KEY and pp.registratordate = p.mr_dt
and  pp.payment_item_key = p.PAYMENT_ITEM_KEY  and pp.DATE_ > a.reportingdate and pp.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy')
LEFT JOIN dwh.payment_items pi on pp.PAYMENT_ITEM_KEY = pi.PAYMENT_ITEM_KEY and pi.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy')
LEFT JOIN DWH.CONTRACTS CC ON CC.CONTRACT_KEY = A.CONTRACT_KEY and cc.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy')
LEFT JOIN DWH.CURRENCIES CURR on cc.currency_key = CURR.CURRENCY_KEY and CURR.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy')
LEFT JOIN DWH.LEASING_CONTRACTS_APPLS LAPP ON LAPP.CONTRACT_KEY = a.CONTRACT_KEY and LAPP.CONTRACT_APP_KEY = A.CONTRACT_APP_KEY and lapp.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy')
where a.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy') and pp.contract_app_key is not null
group by a.ReportingDate,
pp.CONTRACT_KEY,
cc.CONTRACT_ID_CD,
pp.CONTRACT_APP_KEY,
cc.CLIENT_KEY,
curr.CURRENCY_cd,
CC.CONTRACT_ID_CD ||'#'|| lapp.PRESENTATION,
lapp.PRESENTATION,
pp.date_,
a.xirr
;

