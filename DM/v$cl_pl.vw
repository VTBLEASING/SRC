CREATE OR REPLACE FORCE VIEW DM.V$CL_PL AS
with
calendar AS (select trunc(sysdate,'yy')+level-367 as snapshot_dt from dual connect by level<=(trunc(sysdate) - trunc(sysdate,'yy') + 367))
,exr_avg AS (select snapshot_dt, currency_key, avg(EXR_RUR.EXCHANGE_RATE) as EXCHANGE_RATE_AVG  from dwh.EXCHANGE_RATES  EXR_RUR
			join calendar on 1=1 and
            EXR_RUR.BASE_CURRENCY_KEY = 125
              AND EXR_RUR.valid_to_dttm = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
              and ex_rate_dt>=TRUNC(snapshot_dt, 'MM') and ex_rate_dt<=trunc(snapshot_dt) --06072018 DECIDED TO COUNT AVG FOR THE MONTH, NOT QUARTER
              group by snapshot_dt,currency_key)
,rrate_avg AS (select concl.client_key, cm.snapshot_dt, avg(iracb.rate) as AVG_CORP_RES_RATE from dwh.ifrs_rate iracb
				inner join dwh.contracts concl on iracb.contract_key = concl.contract_key and concl.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
				inner join dwh.leasing_contracts lconcl on lconcl.contract_key = iracb.contract_key and lconcl.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') and lconcl.auto_flg = 0
				inner join calendar cm on cm.snapshot_dt = trunc(cm.snapshot_dt,'MM') and cm.snapshot_dt between iracb.from_dttm and iracb.to_dttm
				where iracb.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
				group by concl.client_key, cm.snapshot_dt)
/*,subs_calc AS (select max(lcsub.subsidization_amt) as old_subsidization_amt, lcsub.contract_key, trunc(lcsub.valid_from_dttm, 'YY') AS valid_from_dttm from DWH.LEASING_CONTRACTS lcsub
				where lcsub.valid_to_dttm < to_date ('01.01.2400', 'dd.mm.yyyy') group by lcsub.contract_key, trunc(lcsub.valid_from_dttm, 'YY'))*/ --14112018 CHR-402 Commented
,subs_fact AS (select sum(subsfact.pay_amt) as subs_sum, subsfact.contract_key, subsfact.contract_app_key, trunc(subsfact.real_pay_dt, 'YY') as real_pay_yy from dwh.fact_real_payments subsfact
				where subsfact.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') and subsfact.payment_item_key in
				(select pik.payment_item_key from dwh.payment_items pik where pik.payment_item_nam = '��������������� ������ (��������)' and pik.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy'))
				group by subsfact.contract_key, subsfact.contract_app_key, trunc(subsfact.real_pay_dt, 'YY'))
select
CAST (NULL AS NUMBER) AS DEAL_ID
, 32 AS ID_DFK
,CAST (NULL AS NUMBER) AS DFK
, 19 AS DEALTYPE_ID
, 59 AS RESSYST_ID
,CAST (NULL AS VARCHAR2(100)) AS RESSYST_NAME
, 1 AS RECORDTYPE_ID --01112018 CHR-402
, A.REPORTINGDATE AS DATE_CORRENFORCE
, 1 AS ONEDAY_CORR --01112018 CHR-402
, 'A' AS CORR_STATUS
, A.slx_code  AS SLX_CODE --02072018 IN REPORT CALLED CLIENT_ID
,CAST (NULL AS NUMBER) AS CLIENT_NAME
, A.PORTFOLIO_NONUNI_ID AS PORTFOLIO_NONUNI_ID
,CAST (NULL AS NUMBER) AS PORTFOLIO_NAME
,CAST (NULL AS NUMBER) AS CLIENTUNI_ID
,CAST (NULL AS NUMBER) AS CLIENTUNI_NAME
,CAST (NULL AS NUMBER) AS CLIENTGROUP_ID
,CAST (NULL AS NUMBER) AS CLIENTGROUP_NAME
,CAST (NULL AS NUMBER) AS PORTFOLIOUNI_ID
,CAST (NULL AS NUMBER) AS PORTFOLIOUNI_NAME
, CASE WHEN A.AUTOFLG =1 THEN 'NON_DEFINED' ELSE 'CORP' END AS CLIENT_TYPE
, 0 AS INTPORTFOLIO_DEAL
, 32 AS SUBDIVISIONUNI_ID
,CAST (NULL AS NUMBER) AS SUBDIVISIONUNI_NAME
,CAST (NULL AS NUMBER) AS SUBDIVISION
,CAST (NULL AS NUMBER) AS SALESMAN_ID
,CAST (NULL AS NUMBER) AS SALESMAN_NAME
,CAST (NULL AS NUMBER) AS BUSNCATEG_ID
,CAST (NULL AS NUMBER) AS BUSNCATEG
, CASE WHEN AA.string = 0 THEN 80 ELSE 153 END AS PRODUCT_NONUNI --03072018 80/153 WAS A.TRANSFERALLOCATIONCODE
,CAST (NULL AS NUMBER) AS PRODUCTUNI_ID
,CAST (NULL AS NUMBER) AS PRODUCT_NAME
,CAST (NULL AS NUMBER) AS INDUSTRY_ID
,CAST (NULL AS NUMBER) AS INDUSTRY_NAME
, A.STARTDATE AS DATE_DEALBEGIN
,CAST (NULL AS DATE) AS DATE_1TRANCHE
,CAST (NULL AS DATE) AS DATE_2TRANCHE
,CAST (NULL AS VARCHAR2(10)) AS CURRENCY_TITLENOM
,CAST (NULL AS VARCHAR2(10)) AS CURRENCY_2TITLENOM
,CAST (NULL AS VARCHAR2(10)) AS FINCOMP_CURRENCY
,CAST (NULL AS NUMBER) AS DEALCATEG_ID
,CAST (NULL AS NUMBER) AS DEALCATEGUNI_ID
,CAST (NULL AS NUMBER) AS DEALCATEG
,CAST (NULL AS NUMBER) AS OPTIONTYPE_ID
,CAST (NULL AS NUMBER) AS OPTIONTYPEUNI_ID
,CAST (NULL AS NUMBER) AS OPTION_TYPE
,CAST (NULL AS NUMBER) AS SECURITIES_ID
,CAST (NULL AS NUMBER) AS DEAL_EXCHRATE
,CAST (NULL AS NUMBER) AS PRECMET_GRAM
,CAST (NULL AS NUMBER) AS PRECMET_GRAMATTR
,CAST (NULL AS NUMBER) AS NONDEL_FORWARDATTR
, nvl(A.XIRR/100,0) AS DEAL_INTRATE
,CAST (NULL AS NUMBER) AS DEAL_AMTCURR1
,CAST (NULL AS NUMBER) AS DEAL_AMTCURR2
,CAST (NULL AS NUMBER) AS EXCHRATE_2
,CAST (NULL AS NUMBER) AS DEAL_AMTCURR1LEG2
,CAST (NULL AS NUMBER) AS DEAL_AMTCURR2LEG2
, A.MATURITYDATE AS DATE_DEALACCOMP
,CAST (NULL AS NUMBER) AS DEAL_STATUS
,CAST (NULL AS DATE) AS DATE_CHANGE
,CAST (NULL AS DATE) AS DATE_CORRECTION
,CAST (NULL AS DATE) AS DATE_RECORDCHNG
,CAST (NULL AS DATE) AS DATE_RECVALIDFROM
,CAST (NULL AS DATE) AS DATE_RECVALIDUPTO
,CAST (NULL AS NUMBER) AS FLAG_TOREPORT
,CAST (NULL AS NUMBER) AS REPORTING_YEAR
,CAST (NULL AS NUMBER) AS FLAG_TOCORRECT
,CAST (NULL AS NUMBER) AS FLAG_RECCHANGACCNT
,CAST (NULL AS DATE) AS DATE_77
,CAST (NULL AS NUMBER) AS SLXUNI_ID
,CAST (NULL AS NUMBER) AS SALESCREDIT_EFFDATE
,CAST (NULL AS DATE) AS SALESCREDIT_CORRDATE
,CAST (NULL AS NUMBER) AS SALESCREDIT_CURR
,CAST (NULL AS DATE) AS SALESCREDITSTRT_EFFDATE
,CAST (NULL AS DATE) AS SALESCREDITSTRT_CORRDATE
,CAST (NULL AS NUMBER) AS SALESCREDITSTRT_CURR
, CASE WHEN AA.string = 0 THEN nvl(A.ACCRUEDINTERESTYTD * exr_avg.EXCHANGE_RATE_AVG,0) ELSE 0 END AS PERC_EARNCOST_EFFDATE
,CAST (NULL AS NUMBER) AS PERC_EARNCOST_CORRDATE
, 'RUB' AS PERC_EARNCOST_CURR
, CASE WHEN AA.string = 0 THEN nvl(A.TRANSFER * exr_avg.EXCHANGE_RATE_AVG,0) ELSE 0 END AS TRAN_EARNCOST_EFFDATE --02112018 CHR-468 deleted *(-1)
,CAST (NULL AS NUMBER) AS TRAN_EARNCOST_CORRDATE
, 'RUB' AS TRAN_EARNCURR
, CASE WHEN AA.string = 0 THEN A.SUBSIDIZATIONAMT ELSE 0 END AS COMMISSIONS_EFFDATE --14112018 CHR-402
,CAST (NULL AS NUMBER) AS COMMISSIONS_CORRDATE
, 'RUB' AS COMMISSIONS_CURR
,CAST (0 AS NUMBER) AS COMMISSIONS_EXP_EFFDATE
,CAST (NULL AS NUMBER) AS COMMISSIONS_EXP_CORRDATE
, 'RUB' AS COMMISSIONS_EXP_CURR ------------------
,CAST (NULL AS NUMBER) AS RESERVES_CVA_EFFDATE --14112018 CHR-402 was exr_avg.EXCHANGE_RATE_AVG 12072018 was ((NIL+OVD)*IFRSRATE)*exchange_rate_avg
,CAST (NULL AS NUMBER) AS RESERVES_CVA_CORRDATE
, 'RUB' AS RESERVES_CURR
,CAST (0 AS NUMBER) AS REAL_REVAL_EFFDATE
,CAST (NULL AS NUMBER) AS REAL_REVAL_CORRDATE
, 'RUB' AS REAL_REVAL_CURR
,CAST (NULL AS NUMBER) AS NONREAL_REVAL_CURR_EFFDATE
,CAST (NULL AS NUMBER) AS NONREAL_REVAL_CURR_CORRDATE
,CAST (NULL AS NUMBER) AS NONREAL_REVAL_CURR_CURR
,CAST (NULL AS NUMBER) AS NONREAL_REVAL_PAST_EFFDATE
,CAST (NULL AS NUMBER) AS NONREAL_REVAL_PAST_CORRDATE
,CAST (NULL AS NUMBER) AS NONREAL_REVAL_PAST_CURR
,CAST (NULL AS NUMBER) AS OCI_DEVAL_EFFDATE
,CAST (NULL AS NUMBER) AS OCI_DEVAL_CORRDATE
,CAST (NULL AS NUMBER) AS OCI_DEVAL_CURR
,CAST (NULL AS NUMBER) AS PL_DEVAL_EFFDATE
,CAST (NULL AS NUMBER) AS PL_DEVAL_CORRDATE
,CAST (NULL AS NUMBER) AS PL_DEVAL_CURR
, CASE WHEN AA.string = 0 THEN NULL ELSE '�1.1' END AS ALLOCATION_CATEGORY --22012019 CHR-1088
, CASE WHEN AA.string = 0 THEN 0 ELSE nvl(A.TRANSFERALLOCATION,0) * exr_avg.EXCHANGE_RATE_AVG END AS ALLOCATION_EFFDATE --03072018 SHOULD BE ONLY FOR SEPARATE STRING 153 WAS A.TRANSFERALLOCATION 08112018 CHR-452 Conversation to rub
,CAST (NULL AS NUMBER) AS ALLOCATION_CORRDATE
, 'RUB' AS ALLOCATION_CURR
,CAST (NULL AS NUMBER) AS FUNDING_NPL_EFFDATE --23072018 NEW TEMPLATE
,CAST (NULL AS NUMBER) AS FUNDING_NPL_CORRDATE --23072018 NEW TEMPLATE
, 'RUB' AS FUNDING_NPL_CURR --23072018 NEW TEMPLATE 08112018 CHR-402
, CASE WHEN AA.string = 0 THEN A.ExposurePrincipal - A.ExposurePrincipalOverdue ELSE 0 END AS BAL_RESIDVAL_EFFDATE --13112018 CHR-240 was NIL 09072018 was NIL + OVD
,CAST (NULL AS NUMBER) AS BAL_RESIDVAL_CORRDATE
,CAST (NULL AS NUMBER) AS AVERBAL_RESIDVAL_EFFDATE --13112018 CHR-402 03072018 was A.NIL + A.OVD
,CAST (NULL AS NUMBER) AS AVERBAL_RESIDVAL_CORRDATE
, A.currency_letter_cd AS BAL_RESIDVAL_CURR -- REPORTLOANPORTFOLIO.LEASINGCONTRACT -> NUMBER -> LEASINGCONTRACT.CURRENCY NEED TO BE VALIDATED - DIFFERS FROM FILE CONTENT
, CASE WHEN AA.string = 0 THEN OVD ELSE 0 END AS OVERD_RESIDVAL_EFFDATE
,CAST (NULL AS NUMBER) AS OVERD_RESIDVAL_CORRDATE
, A.currency_letter_cd AS OVERD_RESIDVAL_CURR --02072018 CHANGED FROM 'RUB'
,CAST (NULL AS NUMBER) AS OFFBAL_ITEM_EFFDATE
,CAST (NULL AS NUMBER) AS OFFBAL_ITEM_CORRDATE
,CAST (NULL AS NUMBER) AS AVEROFFBAL_RESIDVAL_EFFDATE
,CAST (NULL AS NUMBER) AS AVEROFFBAL_RESIDVAL_CORRDATE
,CAST (NULL AS NUMBER) AS OFFBAL_ITEM_CURR
, CASE WHEN AA.string = 0 THEN nvl(A.AccruedInterest - A.AccruedInterestOverdue,0) ELSE 0 END AS PERC_BAL_RESIDVAL_EFFDATE --13112018 CHR-402
,CAST (NULL AS NUMBER) AS PERC_BAL_RESIDVAL_CORRDATE
, A.currency_letter_cd AS PERC_BAL_RESIDVAL_CURR --08112018 CHR-402
,CAST (NULL AS NUMBER) AS PERC_AVER_ACC_EFFDATE --23072018 NEW TEMPLATE
,CAST (NULL AS NUMBER) AS PERC_AVER_ACC_CORRDATE --23072018 NEW TEMPLATE
, A.currency_letter_cd AS PERC_AVER_ACC_CURR --23072018 NEW TEMPLATE 08112018 CHR-402
,CAST (NULL AS NUMBER) AS COMM_BAL_RESIDVAL_EFFDATE
,CAST (NULL AS NUMBER) AS COMM_BAL_RESIDVAL_CORRDATE
,CAST (NULL AS VARCHAR2(10)) AS COMM_BAL_RESIDVAL_CURR
, CASE WHEN AA.string = 0 THEN nvl((-1)*(A.NIL + A.OVD) * A.IFRSRATE,0) ELSE 0 END AS RESERV_BAL_RESIDVAL_EFFDATE
,CAST (NULL AS NUMBER) AS RESERV_BAL_RESIDVAL_CORRDATE
, A.currency_letter_cd AS RESERV_BAL_RESIDVAL_CURR --REPORTLOANPORTFOLIO.LEASINGCONTRACT -> NUMBER -> LEASINGCONTRACT.CURRENCY
,CAST (NULL AS NUMBER) AS ACTBAL_NONREAL_RESVAL_EFFDATE
,CAST (NULL AS NUMBER) AS ACTBAL_NONREAL_RESVAL_CORRDATE
,CAST (NULL AS VARCHAR2(10)) AS ACTBAL_NONREAL_RESVAL_CURR
,CAST (NULL AS NUMBER) AS PBAL_NONREAL_RESVAL_EFFDATE
,CAST (NULL AS NUMBER) AS PSBAL_NONREAL_RESVAL_CORRDATE
,CAST (NULL AS VARCHAR2(10)) AS PSBAL_NONREAL_RESVAL_CURR
,CAST (NULL AS NUMBER) AS OPEX_EFFDATE--01112018 CHR-402 09072018 was CASE WHEN A.PORTFOLIO_NONUNI_ID LIKE 'VTBL_LND_017_NPL_%' AND IFRSRATE < 1 THEN 1 ELSE 0 END
,CAST (NULL AS NUMBER) AS OPEX_CORRDATE
, 'RUB' AS OPEX_CURR
, A.contract_id_cd||'#'||A.PRESENTATION AS FACILITY_NUM --18072018 INSTEAD A.contract_num - USING NEW FIELD
,CAST (NULL AS DATE) AS DATE_FACIL_AGRMNT
,CAST (NULL AS NUMBER) AS TENOR
,CAST (NULL AS NUMBER) AS WAL
,CAST (NULL AS NUMBER) AS WAL0
,CAST (NULL AS NUMBER) AS EFFECTIVE_NIM
,CAST (NULL AS NUMBER) AS RUNNING_NIM
, CASE WHEN A.FLOATFLG =1 THEN 'FLT' ELSE 'FIX' END  AS BASE_RATE
,CAST (NULL AS NUMBER) AS TOTAL_DISBURSEMENTS_LTD
,CAST (NULL AS NUMBER) AS TOTAL_REPAID_LTD
,CAST (NULL AS NUMBER) AS INTERRATE_MARGIN_FLOATTYPE
,CAST (NULL AS NUMBER) AS FUNDING_RATE_FLOATTYPE
,CAST (NULL AS NUMBER) AS NPL_STATUS
,CAST (NULL AS NUMBER) AS RATING_INTERNAL
,CAST (NULL AS NUMBER) AS RATING_EXTERNAL
,CAST (NULL AS NUMBER) AS RATING_EXPERT
,CAST (NULL AS NUMBER) AS PD
,CAST (NULL AS NUMBER) AS LGD
,CAST (NULL AS NUMBER) AS EL
,CAST (NULL AS NUMBER) AS EAD
,CAST (NULL AS NUMBER) AS RWA_WEIGHT
,CAST (NULL AS NUMBER) AS H1_WEIGHT
,CAST (NULL AS NUMBER) AS IFRS_BASEL_RWA
,CAST (NULL AS NUMBER) AS RAS_RWA
,CAST (NULL AS NUMBER) AS SALES_DIRECTOR
,CAST (NULL AS NUMBER) AS TRADING_DIRECTOR
,CAST (NULL AS NUMBER) AS STRUCTURING_DIRECTOR
,CAST (NULL AS NUMBER) AS COVERAGE_DIRECTOR
,CAST (NULL AS NUMBER) AS COMMITTED_MARK
,CAST (NULL AS NUMBER) AS NUMBER_OF_RESTRUCT
,CAST (NULL AS NUMBER) AS RESTRUCT_ROLLED_REFIN
,CAST (NULL AS NUMBER) AS DATE_RESTRUCT_ROLLED_REFIN
,CAST (NULL AS NUMBER) AS INITIAL_VOLUME
, nvl(A.FTPFullRate/100,0) AS FUNDING_RATE
,CAST (NULL AS NUMBER) AS TP_CHARGE
,CAST (NULL AS NUMBER) AS DATE_TP_CHARGE
,CAST (NULL AS NUMBER) AS RISK_COST
,CAST (NULL AS NUMBER) AS COMMITMENT_VOLUME
,CAST (NULL AS NUMBER) AS LIMIT_MARK
,CAST (NULL AS NUMBER) AS LIMIT_CCY
,CAST (NULL AS NUMBER) AS COLLATERAL_TYPE
,CAST (NULL AS NUMBER) AS COLLATERAL_AMOUNT
,CAST (NULL AS NUMBER) AS COLLATERAL_QUALITY
,CAST (NULL AS NUMBER) AS COL_AMT_PROVIS_RAS
,CAST (NULL AS NUMBER) AS TRADING_RESULT
,CAST (NULL AS NUMBER) AS LLP
,CAST (NULL AS NUMBER) AS ILLP_PLLP_CLASSIF
,CAST (NULL AS NUMBER) AS ACCRUAL_BASIS_MTM
,CAST (NULL AS NUMBER) AS BANK_AGENT
,CAST (NULL AS NUMBER) AS ID_FIN_PURP
,CAST (NULL AS NUMBER) AS FIN_PURP
,CAST (NULL AS NUMBER) AS CESSION
,CAST (NULL AS NUMBER) AS SUBORDINATED_LOAN
,CAST (NULL AS NUMBER) AS SYNDICATED_LOAN
,CAST (NULL AS NUMBER) AS NORMAL_PROBLEM_TYPE
,CAST (NULL AS NUMBER) AS LOAN_TYPE
,CAST (NULL AS NUMBER) AS REPMNT_FREQ_BASIC_DEBT
,CAST (NULL AS NUMBER) AS REPMNT_FREQ_PERC
,CAST (NULL AS NUMBER) AS AVAILABILITY_PERIOD
,CAST (NULL AS NUMBER) AS COMP_SPREAD_EARLY_REPMNT
,CAST (NULL AS NUMBER) AS COMP_SPREAD_FIX_RATE
,CAST (NULL AS NUMBER) AS COMMENTS
,CAST (NULL AS NUMBER) AS ACCOUNT_NUMBER
,nvl(A.NIL + A.OVD,0) AS TOTAL_NIL_OVD
,nvl(A.NIL,0) AS NIL
,nvl(A.OVD,0) AS OVD
,A.ExposurePrincipal AS ExposurePrincipal --13112018 CHR-402
,A.ExposurePrincipalOverdue AS ExposurePrincipalOverdue --13112018 CHR-402
,A.AccruedInterest AS AccruedInterest --13112018 CHR-402
,A.AccruedInterestOverdue AS AccruedInterestOverdue --13112018 CHR-402
,exr_avg.EXCHANGE_RATE_AVG AS EXCHANGE_RATE_AVG
,A.contract_key AS CONTRACT_KEY
,A.contract_app_key AS CONTRACT_APP_KEY
,A.reportingdate AS snapshot_dt
,A.IFRSRATE AS IFRSRATE
,A.RATE_START_DT AS RATE_START_DT --08112018 5972
,A.LOANS_NAM AS LOANS_NAM --08112018 5972
FROM
(SELECT
 A.XIRR AS XIRR
,A.CLIENT AS CLIENT
,A.MATURITYDATE AS MATURITYDATE
,A.STARTDATE AS STARTDATE
,A.FTPFullRate AS FTPFullRate
,A.ReportingDate AS REPORTINGDATE
,A.Transfer AS TRANSFER
,A.ACCRUEDINTERESTYTD AS ACCRUEDINTERESTYTD
,A.TRANSFERALLOCATION
,CASE WHEN nvl(A.TRANSFERALLOCATION,0) = 0 THEN 80 ELSE 153 END AS TRANSFERALLOCATIONCODE
,lc.currency_key
--,case when nvl(lc.subsidization_amt,0) <> nvl(sb_cl.old_subsidization_amt,0) then nvl(lc.subsidization_amt,0) else 0 end AS SUBSIDIZATIONAMT --14112018 CHR-402 Commented
,nvl(sb_ft.subs_sum,0) AS SUBSIDIZATIONAMT --14112018 CHR-402
,lc.auto_flg AS AUTOFLG --IF =1 THEN AUTOLEASING FLG, ELSE CORP BLOCK
--,ir_avg.AVG_CORP_RES_RATE AS AVG_CORP_RES_RATE --AVERAGE RESERVE RATE FOR CORPORATE CONTRACTS
,con.float_flg AS FLOATFLG
,con.contract_id_cd
,con.client_key
,lapp.contract_num
,lapp.PRESENTATION
,cur.currency_letter_cd
,CASE WHEN  A.reportingDate-A.OverdueStartDate>90 and a.overduestartdate != date'0001-01-01' THEN orgstr.owner||'_LND_017_'||lc.sector||'_NPL_'||mc.COL_MirCode ELSE orgstr.owner||'_LND_017_'||lc.sector||'_'||mc.COL_MirCode END--30/11/2018 ovilkova replaced startdate with reportingdate
AS PORTFOLIO_NONUNI_ID --02112018 CHR-401
,cl.slx_code
,(nvl(A.EXPOSUREPRINCIPAL,0) + nvl(A.ACCRUEDINTEREST,0) - nvl(A.ExposurePrincipalOverdue,0) - nvl(A.AccruedInterestOverdue,0)) AS NIL
,(nvl(A.ExposurePrincipalOverdue,0) + nvl(A.AccruedInterestOverdue,0)) AS OVD
,CASE WHEN lc.auto_flg = 1 THEN nvl(COALESCE (ir.rate, ira.rate),0) ELSE nvl(COALESCE (ir.rate, ir_avg.AVG_CORP_RES_RATE, ira.rate),0) END AS IFRSRATE
,A.contract_key
,A.contract_app_key
,A.EXPOSUREPRINCIPAL --13112018 CHR-402
,A.ExposurePrincipalOverdue --13112018 CHR-402
,A.ACCRUEDINTEREST --13112018 CHR-402
,A.AccruedInterestOverdue --13112018 CHR-402
--,con.branch_key --02112018 CHR-401
--,orgstr.owner --02112018 CHR-401
,trunc(ir.from_dttm) AS RATE_START_DT --08112018 5972
,nvl(substr(lprt.file_name,32),'') AS LOANS_NAM --08112018 5972
FROM DWH.REPORTLOANPORTFOLIO A
LEFT JOIN DWH.CONTRACTS con on con.contract_key = a.contract_key
and con.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN DWH.LEASING_CONTRACTS lc on lc.contract_key = a.contract_key
and lc.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN DWH.LEASING_CONTRACTS_APPLS  lapp on lapp.contract_app_key = a.contract_app_key
and lapp.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN DWH.MIRCODE MC ON MC.MIRCODE_KEY = lc.mircode_key
and mc.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN DWH.CLIENTS cl on cl.client_key=con.CLIENT_KEY --=a.CLIENT_KEY
and cl.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN DWH.Currencies cur on cur.currency_key = lc.currency_key
and cur.end_dt = to_date ('31.12.2099', 'dd.mm.yyyy')
and cur.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN DWH.org_structure orgstr on orgstr.branch_key = con.branch_key and orgstr.VALID_TO_DTTM = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.ifrs_rate ir on ir.contract_key = a.contract_key and ir.contract_app_key = a.contract_app_key and a.reportingdate between ir.from_dttm and ir.to_dttm and ir.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')--27082018 New IFRS Rates
LEFT JOIN dwh.ifrs_rate ira on ira.contract_key = 999999999 and ira.contract_app_key = case when lc.auto_flg = 1 then 999999999 else 999999998 end and a.reportingdate between ira.from_dttm and ira.to_dttm and ira.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') --27082018 New IFRS Rates
LEFT JOIN rrate_avg ir_avg on lc.auto_flg = 0 and ir_avg.snapshot_dt = trunc(a.reportingdate,'MM') and ir_avg.client_key = con.CLIENT_KEY --27082018 Also for New IFRS Rates
LEFT JOIN etl.ctl_input_files lprt on ir.rate is not null and lprt.file_id = ir.file_id
--LEFT JOIN subs_calc sb_cl on sb_cl.contract_key = a.contract_key and sb_cl.valid_from_dttm = trunc(a.reportingdate , 'YY') --14112018 CHR-402 Commented
LEFT JOIN subs_fact sb_ft on sb_ft.contract_key = a.contract_key and sb_ft.contract_app_key = a.contract_app_key and sb_ft.real_pay_yy = trunc(a.reportingdate , 'YY') --14112018 CHR-402
WHERE a.valid_to_dttm=to_date ('01.01.2400', 'dd.mm.yyyy')
) A LEFT JOIN (select level-1 string from dual connect by level<=2) AA on AA.string = case when A.TRANSFERALLOCATIONCODE = 153 then AA.string else 0 end --03072018 String=0 means 80 code; String=1 means 153 code, Allocations = duplicated string
LEFT JOIN exr_avg on exr_avg.currency_key = A.currency_key and A.reportingdate = exr_avg.snapshot_dt
;

