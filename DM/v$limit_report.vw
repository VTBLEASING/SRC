CREATE OR REPLACE FORCE VIEW DM.V$LIMIT_REPORT AS
SELECT
a.ReportingDate as snapshot_dt
,a.CONTRACT_KEY as CONTRACT_KEY
,cc.CONTRACT_ID_CD as CONTRACT_ID_CD
,a.CONTRACT_APP_KEY as CONTRACT_APP_KEY
,cc.CLIENT_KEY
,cl.full_client_ru_nam as full_client_ru_nam
,cc.CONTRACT_NUM
,lapp.contract_num as APP_NUM
--,curr.exchange_rate as exchange_rate
,SUM(cpl.NIL) as NIL_NDS
,SUM(cpl.NIL *(1-cc.contract_vat_rate)) as NIL_NO_NDS
,SUM(cpl.OVD) as OVD_NDS
,SUM(cpl.OVD * (1-cc.contract_vat_rate)) as OVD_NO_NDS
,1 as FLG
FROM
(select ReportingDate, CONTRACT_KEY, CONTRACT_APP_KEY from DWH.REPORTLOANPORTFOLIO where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy')) a
LEFT JOIN (select p.contract_key, p.CONTRACT_APP_KEY, MAX(p.REGISTRATORDATE) mr_dt from  dwh.PAYMENTSCHEDULEIFRS p where valid_to_dttm =  to_date ('01.01.2400', 'dd.mm.yy')
group by p.contract_key, p.CONTRACT_APP_KEY) p
on p.CONTRACT_KEY = A.CONTRACT_KEY and p.CONTRACT_APP_KEY = a.CONTRACT_APP_KEY
LEFT JOIN (select pp.contract_key, pp.CONTRACT_APP_KEY, pp.REGISTRATORDATE , pp.date_, pp.valid_to_dttm from dwh.PAYMENTSCHEDULEIFRS pp where pp.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy')) pp on pp.CONTRACT_APP_KEY = p.CONTRACT_APP_KEY and pp.registratordate = p.mr_dt and pp.DATE_ > a.reportingdate
LEFT JOIN (select CONTRACT_KEY,CONTRACT_ID_CD, CLIENT_KEY, CONTRACT_NUM, CURRENCY_KEY,CONTRACT_VAT_RATE from DWH.CONTRACTS where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy')) CC ON CC.CONTRACT_KEY = A.CONTRACT_KEY
--LEFT JOIN (SELECT currency_key, exchange_rate, BASE_CURRENCY_KEY, valid_to_dttm from DWH.EXCHANGE_RATES where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy') and BASE_CURRENCY_KEY = 125) CURR on cc.currency_key = CURR.CURRENCY_KEY
LEFT JOIN (SELECT contract_key, contract_app_key, contract_num, valid_to_dttm from DWH.LEASING_CONTRACTS_APPLS where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy')) LAPP ON LAPP.CONTRACT_KEY = a.CONTRACT_KEY and LAPP.CONTRACT_APP_KEY = A.CONTRACT_APP_KEY
LEFT JOIN (SELECT full_client_ru_nam, client_key, valid_to_dttm from DWH.CLIENTS where VALID_TO_DTTM = to_date ('01.01.2400', 'dd.mm.yy')) CL ON CC.CLIENT_KEY = CL.CLIENT_KEY
LEFT JOIN (SELECT NIL, OVD, contract_key, contract_app_key, snapshot_dt from DM.V$CL_PL) cpl ON cpl.snapshot_dt = snapshot_dt and cpl.contract_key = pp.contract_key and cpl.contract_app_key = pp.contract_app_key
/*where a.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yy') and */ where pp.contract_app_key is not null
group by a.ReportingDate,
a.CONTRACT_KEY,
cc.CONTRACT_ID_CD,
cc.CONTRACT_NUM,
a.CONTRACT_APP_KEY,
cc.CLIENT_KEY,
cl.full_client_ru_nam,
--curr.exchange_rate,
lapp.contract_num
;

