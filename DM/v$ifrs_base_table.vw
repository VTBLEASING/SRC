CREATE OR REPLACE FORCE VIEW DM.V$IFRS_BASE_TABLE AS
with calendar as (select trunc(sysdate,'yy')+level-1 snapshot_dt from dual connect by level<365)
,rrate_avg AS (select concl.client_key, cm.snapshot_dt, avg(iracb.rate) as AVG_CORP_RES_RATE from dwh.ifrs_rate iracb
        inner join dwh.contracts concl on iracb.contract_key = concl.contract_key and concl.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
        inner join dwh.leasing_contracts lconcl on lconcl.contract_key = iracb.contract_key and lconcl.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') and lconcl.auto_flg = 0
        inner join calendar cm on cm.snapshot_dt = trunc(cm.snapshot_dt,'MM') and cm.snapshot_dt between iracb.from_dttm and iracb.to_dttm
        where iracb.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
        group by concl.client_key, cm.snapshot_dt)
,exr_avg AS (select snapshot_dt, currency_key, avg(EXR_RUR.EXCHANGE_RATE) as EXCHANGE_RATE_AVG  from dwh.EXCHANGE_RATES  EXR_RUR
      join calendar on 1=1 and
            EXR_RUR.BASE_CURRENCY_KEY = 125
              AND EXR_RUR.valid_to_dttm = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
              and ex_rate_dt>=TRUNC(snapshot_dt, 'MM') and ex_rate_dt<=trunc(snapshot_dt) --06072018 DECIDED TO COUNT AVG FOR THE MONTH, NOT QUARTER
              group by snapshot_dt,currency_key)
SELECT a.ReportingDate as snapshot_dt,
ostr.OWNER as SHORT_NAM,
CAST(NULL as VARCHAR2(100)) as ASSET_TYPE,
lcc.auto_flg as AUTO_FLG,
cl.client_id,
cl.client_cd,
cl.short_client_ru_nam as client_cis,
cl.full_client_ru_nam,
cc.contract_id_cd,
cc.contract_num,
lapp.contract_num as CONTRACT_APP_NUM,
Case when cl.BRANCH_KEY is not NULL then 'YES' else 'NO' end as VTBL_FLG,
lapp.LEASING_SUBJECT_DESC as LEASING_SUBJECT,
cc.contract_num || ' от ' || cc.oper_start_dt as CONTRACT_NUM_FULL,
lapp.presentation,
REGEXP_SUBSTR (presentation,'(\S*)(\s)', 1,4) as presentation_num,
REGEXP_SUBSTR (presentation,'(\S*)(\s)', 1) || REGEXP_SUBSTR (presentation,'(\S*)(\s)', 1,2) || REGEXP_SUBSTR (presentation,'(\S*)(\s)', 1,3) || REGEXP_SUBSTR (presentation,'(\S*)(\s)', 1,4) as presentation_short,
(CASE WHEN ostr.OWNER  = 'FBG' then 'No' else 'Yes' end) as FLG_VTB_GROUP,
(CASE WHEN ostr.OWNER  = 'FBG' then 'No' else 'Yes' end) as FLG_VTB_LEASING_GROUP,
curr.currency_ru_nam,
a.contract_key,
a.contract_app_key,
a.client_key,
(nvl(A.EXPOSUREPRINCIPAL,0) + nvl(A.ACCRUEDINTEREST,0) - nvl(A.ExposurePrincipalOverdue,0) - nvl(A.AccruedInterestOverdue,0)) AS NIL, -- алгоритм из dm.v$cl_pl
(nvl(A.ExposurePrincipalOverdue,0) + nvl(A.AccruedInterestOverdue,0)) AS OVD, -- из dm.v$cl_pl для просрочки
(nvl(A.EXPOSUREPRINCIPAL,0) + nvl(A.ACCRUEDINTEREST,0) - nvl(A.ExposurePrincipalOverdue,0) - nvl(A.AccruedInterestOverdue,0)) + (nvl(A.ExposurePrincipalOverdue,0) + nvl(A.AccruedInterestOverdue,0)) as BALANCE_AMT, -- NIL + OVD
CASE WHEN a.overduestartdate != date'0001-01-01' then (a.reportingdate - a.overduestartdate) else 0 end as OVD_DAYS,
CASE WHEN lcc.auto_flg = 1 THEN nvl(COALESCE (ir.rate, ira.rate),0) ELSE nvl(COALESCE (ir.rate, ir_avg.AVG_CORP_RES_RATE, ira.rate),0) END AS CLOSING_RATE, -- алгоритм из dm.v$cl_pl
exr_avg.EXCHANGE_RATE_AVG as AVERAGE_RATE, -- алгоритм из dm.v$cl_pl
((nvl(a.EXPOSUREPRINCIPAL,0) + nvl(a.ACCRUEDINTEREST,0) - nvl(a.ExposurePrincipalOverdue,0) - nvl(a.AccruedInterestOverdue,0))) * (CASE WHEN lcc.auto_flg = 1 THEN nvl(COALESCE (ir.rate, ira.rate),0) ELSE nvl(COALESCE (ir.rate, ir_avg.AVG_CORP_RES_RATE, ira.rate),0) END) as NIL_WO_SA_RUB, -- NIL_WO_SA * CLOSING_RATE
((nvl(a.ExposurePrincipalOverdue,0) + nvl(a.AccruedInterestOverdue,0))) * (CASE WHEN lcc.auto_flg = 1 THEN nvl(COALESCE (ir.rate, ira.rate),0) ELSE nvl(COALESCE (ir.rate, ir_avg.AVG_CORP_RES_RATE, ira.rate),0) END) as OVERDUE_AMOUNT_WO_SA_RUB, -- OVERDUE_AMOUNT_WO_SA * CLOSING_RATE
(nvl(A.EXPOSUREPRINCIPAL,0) + nvl(A.ACCRUEDINTEREST,0) - nvl(A.ExposurePrincipalOverdue,0) - nvl(A.AccruedInterestOverdue,0)) + (nvl(A.ExposurePrincipalOverdue,0) + nvl(A.AccruedInterestOverdue,0)) * (CASE WHEN lcc.auto_flg = 1 THEN nvl(COALESCE (ir.rate, ira.rate),0) ELSE nvl(COALESCE (ir.rate, ir_avg.AVG_CORP_RES_RATE, ira.rate),0) END)  as BALANCE_AMT_RUB,
XIRR as EFF_PRC_RATE,
a.Startdate as START_DT,
a.StartDate as TRANSFER_DT,
a.maturitydate as MATURITY_DT
FROM dwh.reportloanportfolio a
LEFT JOIN (select client_key, client_id, client_cd, full_client_ru_nam ,SHORT_CLIENT_RU_NAM, branch_key from DWH.CLIENTS where valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) cl
on a.client_key = cl.client_key
LEFT JOIN (select contract_key, contract_num, oper_start_dt, currency_key, branch_key, contract_id_cd from DWH.CONTRACTS where valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) cc
on a.contract_key = cc.contract_key
LEFT JOIN (select contract_key, auto_flg from dwh.leasing_contracts where valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) lcc
on lcc.contract_key = a.contract_key
LEFT JOIN (select branch_key, owner from dwh.org_structure where valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) ostr
on ostr.branch_key = cc.branch_key
LEFT JOIN (select contract_app_key, presentation, leasing_subject_desc, contract_num from dwh.leasing_contracts_appls where valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) lapp
on a.contract_app_key = lapp.contract_app_key
LEFT JOIN (select currency_key, currency_ru_nam from dwh.currencies where valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')) curr
on curr.currency_key = cc.currency_key
LEFT JOIN dwh.ifrs_rate ir
on ir.contract_key = a.contract_key and ir.contract_app_key = a.contract_app_key and a.reportingdate between ir.from_dttm and ir.to_dttm and ir.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN dwh.ifrs_rate
ira on ira.contract_key = 999999999 and ira.contract_app_key = case when lcc.auto_flg = 1 then 999999999 else 999999998 end and a.reportingdate between ira.from_dttm and ira.to_dttm and ira.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') -- алгоритм из dm.v$cl_pl
LEFT JOIN rrate_avg ir_avg on lcc.auto_flg = 0 and ir_avg.snapshot_dt = trunc(a.reportingdate,'MM') and ir_avg.client_key = a.CLIENT_KEY -- алгоритм из dm.v$cl_pl
LEFT JOIN exr_avg on exr_avg.currency_key = cc.currency_key and A.reportingdate = exr_avg.snapshot_dt
where a.valid_to_dttm=to_date ('01.01.2400', 'dd.mm.yyyy')
;

