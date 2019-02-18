CREATE OR REPLACE FORCE VIEW DM.V$NOTA_PL AS
with
calendar AS (select trunc(sysdate,'yy')+level-2 snapshot_dt from dual connect by level<=(trunc(sysdate) - trunc(sysdate,'yy') + 2))
,rrate_avg AS (select concl.client_key, cm.snapshot_dt, avg(iracb.rate) AVG_CORP_RES_RATE from dwh.ifrs_rate iracb
				inner join dwh.contracts concl on iracb.contract_key = concl.contract_key and concl.valid_to_dttm=to_date ('01.01.2400', 'dd.mm.yyyy')
				inner join dwh.leasing_contracts lconcl on lconcl.contract_key = iracb.contract_key and lconcl.valid_to_dttm=to_date ('01.01.2400', 'dd.mm.yyyy') and lconcl.auto_flg = 0
				inner join calendar cm on cm.snapshot_dt = trunc(cm.snapshot_dt,'MM') and cm.snapshot_dt between iracb.from_dttm and iracb.to_dttm
				where iracb.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
				group by concl.client_key, cm.snapshot_dt)
select
(case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0)  else nvl(exr.EXCHANGE_RATE,0) end) as EXCHANGE_RATE, --учет трансл€ционных разниц 27.08.2018
A.contract_app_key as contract_app_key,
A.reportingdate as snapshot_dt,
A.COL_MIRCODE as MIRCODE,
'CLFI' as DESK,
'LND' as LND,
CASE WHEN A.EXPOSURE_PRINCIPAL_OVERDUE <> 0 AND (A.reportingdate-A.OVERDUE_START_DATE)>90 then 'Non-performing' else 'Performing' end as NPL,
A.SECTOR AS SECTOR,
A.CONTRACT_ID_CD ||'#'|| A.PRESENTATION as CURRENT_ACCOUNT_NUMBER,
A.SLX_CODE as LOCAL_CLIENT_ID,
A.VTB_CLIENT_GROUP AS VTB_GROUP,
A.SHORT_CLIENT_RU_NAM as BORROWER,
'VTB Leasing' as BOOKING_ENTITY,
'VTB Leasing' as FUNDING_BANK,
'VTB' as VTB_NWRC,
CAST (NULL AS NUMBER) AS CLFI,
CAST (NULL AS NUMBER) AS SHARING_DESC,
A.CURRENCY_LETTER_CD as ORIGINAL_LOAN_CURRENCY,
'UCL_NREV' as DEAL_TYPE,
A.START_DATE as START_DATE,
A.MATURITY_DATE as MATURITY_DATE,
(MATURITY_DATE-START_DATE)/365 as INITIAL_WAL,
A.rate_en_nam as FIXED_FLOATING_RATE_BASE,
case when A.rate_en_nam = 'Fixed' then A.xirr else A.add_amt end as BASE_INTEREST_RATE, -- 31.07.2018
A.xirr as FULL_INTEREST_RATE, -- 31.07.2018
CAST (NULL AS NUMBER) as UPFRONT_FEE,
A.FTP_BASE_RATE as FTP_BASE_RATE,
A.FTP_FULL_RATE as FTP_FULL_RATE,
(A.xirr - A.FTP_FULL_RATE)  as NET_RUNNING_MARGIN, --(FULL_INTEREST_RATE - FTP_FULL_RATE) 31.07.2018
CAST(NULL AS NUMBER) as UPFRONT_RUNNING_MARGIN, --(NET_RUNNING_MARGIN + UPFRONT_FEE)
A.EXPOSURE_PRINCIPAL as EXPOSURE_PRINCIPAL,
A.ACCRUED_INTEREST as ACCRUED,
(nvl(A.EXPOSURE_PRINCIPAL,0)+nvl(A.ACCRUED_INTEREST,0)) * nvl(IFRSRATE,0) *(-1) as PROVISIONS, --11092018 No averbal 02102018 *(-1)
--case when A.reportingdate = to_date('31.12.2017','dd.mm.yyyy') then nvl(savrb.averbal_residval,0) * nvl(IFRSRATE,0) else (nvl(A.EXPOSURE_PRINCIPAL,0)+nvl(A.ACCRUED_INTEREST,0))* nvl(IFRSRATE,0) end as PROVISIONS, --27.08.2018
--case when A.reportingdate = A.reportingdate = trunc(A.reportingdate+1,'YY')-1 then nvl(savrb.averbal_residval,0) * nvl(IFRSRATE,0) else (nvl(A.EXPOSURE_PRINCIPAL,0)+nvl(A.ACCRUED_INTEREST,0))* nvl(IFRSRATE,0) end as PROVISIONS,
A.EXPOSURE_PRINCIPAL * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as EXPOSURE_PRINCIPAL_RUR, -- учет трансл€ционных разниц 27.08.2018, здесь и далее
A.ACCRUED_INTEREST * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as ACCRUED_RUR,
(nvl(A.EXPOSURE_PRINCIPAL,0)+nvl(A.ACCRUED_INTEREST,0))* nvl(IFRSRATE,0) * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) *(-1) as PROVISIONS_RUR, --11092018 No averbal 02102018 *(-1)
case when A.EXPOSURE_PRINCIPAL_OVERDUE = 0 then CAST (NULL AS DATE) else A.OVERDUE_START_DATE end as OVERDUE_START_DATE,
A.EXPOSURE_PRINCIPAL_OVERDUE * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as EXPOSURE_PRINCIPAL_OVERDUE_RUR,
case when A.ACCRUED_INTEREST_OVERDUE = 0 then CAST (NULL AS DATE) else A.OVERDUE_START_DATE end as OVERDUE_ACCRUED_START_DATE,
A.ACCRUED_INTEREST_OVERDUE * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as ACCRUED_INTEREST_OVERDUE,
CAST (NULL AS NUMBER) as OVERDUE_PENALTY_FEE,
CAST (NULL AS NUMBER) as OVERDUE_PENALTY_FEE_START_DATE,
CAST (NULL AS NUMBER) as OVERDUE_PENALTY_FEE_RUR,
--объемы на начало года (31.12.2017), пересчитанные по курсу на начало года с учетом трансл€ционных разниц
A.EXPOSURE_PRINCIPAL_BOY * (case when A.branch_key = '14' then nvl(b_exr_yy.EXCHANGE_RATE,0)* nvl(b_yy.EXCHANGE_RATE,0) else nvl(exr_yy.EXCHANGE_RATE,0) end) as BS_EXPOSURE_BOY,
A.ACCRUED_INTEREST_BOY * (case when A.branch_key = '14' then nvl(b_exr_yy.EXCHANGE_RATE,0)* nvl(b_yy.EXCHANGE_RATE,0) else nvl(exr_yy.EXCHANGE_RATE,0) end) as ACCRUED_BOY,
--(nvl(A.EXPOSURE_PRINCIPAL_BOY,0) + nvl(A.ACCRUED_INTEREST_BOY,0)) * nvl(A.IFRSRATE_YY,0) * (case when A.branch_key = '14' then nvl(b_exr_yy.EXCHANGE_RATE,0)*nvl(b_yy.EXCHANGE_RATE,0) else nvl(exr_yy.EXCHANGE_RATE,0) end) *(-1) as PROVISIONS_EXPOSURE_BOY, --02102018 *(-1)
case when trunc(A.reportingdate,'YY') = to_date('01.01.2018','dd.mm.yyyy') then nvl(plcorr.corr_sum,0) else (nvl(A.EXPOSURE_PRINCIPAL_BOY,0) + nvl(A.ACCRUED_INTEREST_BOY,0)) * nvl(A.IFRSRATE_YY,0) end * (case when A.branch_key = '14' then nvl(b_exr_yy.EXCHANGE_RATE,0)*nvl(b_yy.EXCHANGE_RATE,0) else nvl(exr_yy.EXCHANGE_RATE,0) end) *(-1) as PROVISIONS_EXPOSURE_BOY, --04102018 *(-1) and 2018 hand provisions
case when trunc(A.reportingdate,'YY') = to_date('01.01.2018','dd.mm.yyyy') then nvl(plcorr.corr_sum,0) else (nvl(A.EXPOSURE_PRINCIPAL_BOY,0) + nvl(A.ACCRUED_INTEREST_BOY,0)) * nvl(A.IFRSRATE_YY,0) end *(-1) as PROVISIONS_EXPOSURE_BOY_IND, --04102018 No curr
--================================================================
--объемы на начало квартала (на последний день предыдущего квартала), пересчитанные по курсу на начало квартала с учетом трансл€ционных разниц
A.EXPOSURE_PRINCIPAL_BOQ * (case when A.branch_key = '14' then nvl(b_exr_qq.EXCHANGE_RATE,0)*nvl(b_qq.EXCHANGE_RATE,0) else nvl(exr_qq.EXCHANGE_RATE,0) end) as BS_EXPOSURE_BOQ,
A.ACCRUED_INTEREST_BOQ * (case when A.branch_key = '14' then nvl(b_exr_qq.EXCHANGE_RATE,0)*nvl(b_qq.EXCHANGE_RATE,0) else nvl(exr_qq.EXCHANGE_RATE,0) end) as ACCRUED_BOQ,
(nvl(A.EXPOSURE_PRINCIPAL_BOQ,0) + nvl(A.ACCRUED_INTEREST_BOQ,0)) * nvl(A.IFRSRATE_QQ,0) * (case when A.branch_key = '14' then nvl(b_exr_qq.EXCHANGE_RATE,0)*nvl(b_qq.EXCHANGE_RATE,0) else nvl(exr_qq.EXCHANGE_RATE,0) end) *(-1) as PROVISIONS_EXPOSURE_BOQ, --02102018 *(-1)
--объемы на начало мес€ца (на последний день предыдущего мес€ца), пересчитанные по курсу на начало квартала с учетом трансл€ционных разниц
A.EXPOSURE_PRINCIPAL_BOM * (case when A.branch_key = '14' then nvl(b_exr_mm.EXCHANGE_RATE,0)*nvl(b_mm.EXCHANGE_RATE,0) else nvl(exr_mm.EXCHANGE_RATE,0) end) as BS_EXPOSURE_BOM,
A.ACCRUED_INTEREST_BOM * (case when A.branch_key = '14' then nvl(b_exr_mm.EXCHANGE_RATE,0)*nvl(b_mm.EXCHANGE_RATE,0) else nvl(exr_mm.EXCHANGE_RATE,0) end) as ACCRUED_BOM,
(nvl(A.EXPOSURE_PRINCIPAL_BOM,0) + nvl(A.ACCRUED_INTEREST_BOM,0)) * nvl(A.IFRSRATE_MM,0) * (case when A.branch_key = '14' then nvl(b_exr_mm.EXCHANGE_RATE,0)*nvl(b_mm.EXCHANGE_RATE,0) else nvl(exr_mm.EXCHANGE_RATE,0) end) *(-1) as PROVISIONS_EXPOSURE_BOM, --02102018 *(-1)
--объемы на начало недели (-7 дней от отчетной даты), пересчитанные по курсу на начало недели с учетом трансл€ционных разниц
A.EXPOSURE_PRINCIPAL_BOW * (case when A.branch_key = '14' then nvl(b_exr_iw.EXCHANGE_RATE,0)*nvl(b_iw.EXCHANGE_RATE,0) else nvl(exr_iw.EXCHANGE_RATE,0) end) as BS_EXPOSURE_BOW,
A.ACCRUED_INTEREST_BOW * (case when A.branch_key = '14' then nvl(b_exr_iw.EXCHANGE_RATE,0)*nvl(b_iw.EXCHANGE_RATE,0) else nvl(exr_iw.EXCHANGE_RATE,0) end) as ACCRUED_BOW,
(nvl(A.EXPOSURE_PRINCIPAL_BOW,0) + nvl(A.ACCRUED_INTEREST_BOW,0)) * nvl(A.IFRSRATE_IW,0) * (case when A.branch_key = '14' then nvl(b_exr_iw.EXCHANGE_RATE,0)*nvl(b_iw.EXCHANGE_RATE,0) else nvl(exr_iw.EXCHANGE_RATE,0) end) *(-1) as PROVISIONS_EXPOSURE_BOW, --02102018 *(-1)
--объемы на отчетную дату, пересчитанные по курсу на отчетную дату с учетом трансл€ционных разниц
A.EXPOSURE_PRINCIPAL * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as BS_EXPOSURE_SNAPSHOTDT,
A.ACCRUED_INTEREST * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as ACCRUED_SNAPSHOTDT,
(nvl(A.ACCRUED_INTEREST,0)+nvl(A.EXPOSURE_PRINCIPAL,0)) * nvl(IFRSRATE,0) * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) *(-1) as PROVISIONS_SNAPSHOTDT, --11092018 No averbal 02102018 *(-1)
--ƒинамика BS, RUR / BS Dynamics, RUR выдано и погашено за год
A.PRINCIPAL_NEW_TRANCHE_YTD * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as NEW_TRANCHE_YTD,
A.PRINCIPAL_REPAID_TRANCHE_YTD * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as REPAID_TRANCHE_YTD,
--ƒинамика BS, RUR / BS Dynamics, RUR выдано и погашено за квартал
A.PRINCIPAL_NEW_TRANCHE_QTD * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as NEW_TRANCHE_QTD,
A.PRINCIPAL_REPAID_TRANCHE_QTD * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as REPAID_TRANCHE_QTD,
--ƒинамика BS, RUR / BS Dynamics, RUR выдано и погашено за мес€ц
A.PRINCIPAL_NEW_TRANCHE_MTD * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as NEW_TRANCHE_MTD,
A.PRINCIPAL_REPAID_TRANCHE_MTD * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(exr.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as REPAID_TRANCHE_MTD,
--ƒинамика BS, RUR / BS Dynamics, RUR выдано и погашено за неделю
A.PRINCIPAL_NEW_TRANCHE_WTD * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as NEW_TRANCHE_WTD,
A.PRINCIPAL_REPAID_TRANCHE_WTD * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as REPAID_TRANCHE_WTD,
--возобновл€емый и невозобновл€емый лимит
CAST (NULL AS NUMBER) as REVOLVING,
CAST (NULL AS NUMBER) as UNREVOLVING,
CAST (NULL AS NUMBER) as TOTAL_LIMIT,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0M1,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0M2,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0M3,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0Q1,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0M4,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0M5,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0M6,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0Q2,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0M7,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0M8,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0M9,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0Q3,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0M10,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0M11,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0M12,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0Q4,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y0,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1M1,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1M2,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1M3,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1Q1,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1M4,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1M5,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1M6,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1Q2,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1M7,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1M8,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1M9,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1Q3,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1M10,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1M11,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1M12,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1Q4,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y1,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2M1,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2M2,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2M3,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2Q1,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2M4,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2M5,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2M6,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2Q2,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2M7,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2M8,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2M9,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2Q3,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2M10,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2M11,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2M12,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2Q4,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y2,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y3,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y4,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y5,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y6,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_Y7,
CAST (NULL AS NUMBER) as UNSELECTED_LIMIT_AFTER_Y7,
CAST (NULL AS NUMBER) as BLANK_1,
--===============================================================================================================
--02112018 CHR-420 Added exchange rate
A.CONTRACT_REPAYMENT_Y0M1 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0M1,
A.CONTRACT_REPAYMENT_Y0M2 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0M2,
A.CONTRACT_REPAYMENT_Y0M3 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0M3,
A.CONTRACT_REPAYMENT_Y0Q1 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0Q1,
A.CONTRACT_REPAYMENT_Y0M4 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0M4,
A.CONTRACT_REPAYMENT_Y0M5 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0M5,
A.CONTRACT_REPAYMENT_Y0M6 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0M6,
A.CONTRACT_REPAYMENT_Y0Q2 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0Q2,
A.CONTRACT_REPAYMENT_Y0M7 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0M7,
A.CONTRACT_REPAYMENT_Y0M8 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0M8,
A.CONTRACT_REPAYMENT_Y0M9 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0M9,
A.CONTRACT_REPAYMENT_Y0Q3 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0Q3,
A.CONTRACT_REPAYMENT_Y0M10 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0M10,
A.CONTRACT_REPAYMENT_Y0M11 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0M11,
A.CONTRACT_REPAYMENT_Y0M12 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0M12,
A.CONTRACT_REPAYMENT_Y0Q4 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0Q4,
A.CONTRACT_REPAYMENT_Y0 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y0,
A.PRINCIPALAS_OF_Y0 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as PRINCIPALAS_OF_Y0,
A.CONTRACT_REPAYMENT_Y1M1 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1M1,
A.CONTRACT_REPAYMENT_Y1M2 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1M2,
A.CONTRACT_REPAYMENT_Y1M3 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1M3,
A.CONTRACT_REPAYMENT_Y1Q1 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1Q1,
A.CONTRACT_REPAYMENT_Y1M4 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1M4,
A.CONTRACT_REPAYMENT_Y1M5 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1M5,
A.CONTRACT_REPAYMENT_Y1M6 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1M6,
A.CONTRACT_REPAYMENT_Y1Q2 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1Q2,
A.CONTRACT_REPAYMENT_Y1M7 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1M7,
A.CONTRACT_REPAYMENT_Y1M8 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1M8,
A.CONTRACT_REPAYMENT_Y1M9 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1M9,
A.CONTRACT_REPAYMENT_Y1Q3 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1Q3,
A.CONTRACT_REPAYMENT_Y1M10 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1M10,
A.CONTRACT_REPAYMENT_Y1M11 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1M11,
A.CONTRACT_REPAYMENT_Y1M12 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1M12,
A.CONTRACT_REPAYMENT_Y1Q4 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1Q4,
A.CONTRACT_REPAYMENT_Y1 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y1,
A.PRINCIPALAS_OF_Y1 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as PRINCIPALAS_OF_Y1,
A.CONTRACT_REPAYMENT_Y2M1 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2M1,
A.CONTRACT_REPAYMENT_Y2M2 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2M2,
A.CONTRACT_REPAYMENT_Y2M3 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2M3,
A.CONTRACT_REPAYMENT_Y2Q1 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2Q1,
A.CONTRACT_REPAYMENT_Y2M4 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2M4,
A.CONTRACT_REPAYMENT_Y2M5 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2M5,
A.CONTRACT_REPAYMENT_Y2M6 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2M6,
A.CONTRACT_REPAYMENT_Y2Q2 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2Q2,
A.CONTRACT_REPAYMENT_Y2M7 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2M7,
A.CONTRACT_REPAYMENT_Y2M8 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2M8,
A.CONTRACT_REPAYMENT_Y2M9 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2M9,
A.CONTRACT_REPAYMENT_Y2Q3 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2Q3,
A.CONTRACT_REPAYMENT_Y2M10 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2M10,
A.CONTRACT_REPAYMENT_Y2M11 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2M11,
A.CONTRACT_REPAYMENT_Y2M12 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2M12,
A.CONTRACT_REPAYMENT_Y2Q4 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2Q4,
A.CONTRACT_REPAYMENT_Y2 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y2,
A.PRINCIPALAS_OF_Y2 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as PRINCIPALAS_OF_Y2,
A.CONTRACT_REPAYMENT_Y3 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y3,
A.PRINCIPALAS_OF_Y3 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as PRINCIPALAS_OF_Y3,
A.CONTRACT_REPAYMENT_Y4 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y4,
A.PRINCIPALAS_OF_Y4 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as PRINCIPALAS_OF_Y4,
A.CONTRACT_REPAYMENT_Y5 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y5,
A.PRINCIPALAS_OF_Y5 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as PRINCIPALAS_OF_Y5,
A.CONTRACT_REPAYMENT_Y6 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y6,
A.PRINCIPALAS_OF_Y6 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as PRINCIPALAS_OF_Y6,
A.CONTRACT_REPAYMENT_Y7 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_Y7,
A.PRINCIPALAS_OF_Y7 * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as PRINCIPALAS_OF_Y7,
A.contract_repayment_other * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as CONTRACT_REPAYMENT_AFTER,
A.EXPOSURE_PRINCIPAL_OVERDUE * (case when A.branch_key = '14' then nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0) else nvl(exr.EXCHANGE_RATE,0) end) as FINAL_MATURITY_DATE_PASS_DUE, --02112018 CHR-420 was A.EXPOSURE_PRINCIPAL_OVERDUE+A.ACCRUED_INTEREST_OVERDUE
--02112018 CHR-420 Added exchange rate
--===============================================================================================================
CAST (NULL AS NUMBER) as PAYMENT_LOCKOUT_PERIOD,
CAST (A.CLIENT_CD as NUMBER) as column_209,
A.RATE_START_DT AS RATE_START_DT, --08112018 5972
A.LOANS_NAM AS LOANS_NAM, --08112018 5972
A.branch_key,
A.BASE_CURRENCY_KEY,
A.currency_key,
A.auto_flg,
A.IFRSRATE,
A.IFRSRATE_IW,
A.IFRSRATE_MM,
A.IFRSRATE_QQ,
A.IFRSRATE_YY,
A.EXPOSURE_PRINCIPAL_BOY,
A.EXPOSURE_PRINCIPAL_BOQ,
A.EXPOSURE_PRINCIPAL_BOM,
A.EXPOSURE_PRINCIPAL_BOW,
A.ACCRUED_INTEREST_BOY,
A.ACCRUED_INTEREST_BOQ,
A.ACCRUED_INTEREST_BOM,
A.ACCRUED_INTEREST_BOW
FROM
(SELECT
A.CONTRACT_KEY,
A.CONTRACT_APP_KEY,
A.CLIENT_KEY,
A.StartDate as START_DATE,
A.MaturityDate as MATURITY_DATE,
A.FTPBaseRate as FTP_BASE_RATE,
A.FTPFullRate as FTP_FULL_RATE,
A.ExposurePrincipal as EXPOSURE_PRINCIPAL,
A.AccruedInterest as ACCRUED_INTEREST,
A.OverdueStartDate as OVERDUE_START_DATE,
A.ExposurePrincipalOverdue as EXPOSURE_PRINCIPAL_OVERDUE,
A.AccruedInterestOverdue as ACCRUED_INTEREST_OVERDUE,
A.ExposurePrincipalBOY as EXPOSURE_PRINCIPAL_BOY,
A.AccruedInterestBOY as ACCRUED_INTEREST_BOY,
A.ExposurePrincipalBOQ as EXPOSURE_PRINCIPAL_BOQ,
A.AccruedInterestBOQ as ACCRUED_INTEREST_BOQ,
A.ExposurePrincipalBOM as EXPOSURE_PRINCIPAL_BOM,
A.AccruedInterestBOM as ACCRUED_INTEREST_BOM,
A.ExposurePrincipalBOW as EXPOSURE_PRINCIPAL_BOW,
A.AccruedInterestBOW as ACCRUED_INTEREST_BOW,
A.PrincipalNewTrancheYTD as PRINCIPAL_NEW_TRANCHE_YTD,
A.PrincipalRepaidTrancheYTD as PRINCIPAL_REPAID_TRANCHE_YTD,
A.PrincipalNewTrancheQTD as PRINCIPAL_NEW_TRANCHE_QTD,
A.PrincipalRepaidTrancheQTD as PRINCIPAL_REPAID_TRANCHE_QTD,
A.PrincipalNewTrancheMTD as PRINCIPAL_NEW_TRANCHE_MTD,
A.PrincipalRepaidTrancheMTD as PRINCIPAL_REPAID_TRANCHE_MTD,
A.PrincipalNewTrancheWTD as PRINCIPAL_NEW_TRANCHE_WTD,
A.PrincipalRepaidTrancheWTD as PRINCIPAL_REPAID_TRANCHE_WTD,
A.CONTRACTREPAYMENTY0M1 as CONTRACT_REPAYMENT_Y0M1,
A.CONTRACTREPAYMENTY0M2 as CONTRACT_REPAYMENT_Y0M2,
A.CONTRACTREPAYMENTY0M3 as CONTRACT_REPAYMENT_Y0M3,
A.CONTRACTREPAYMENTY0Q1 as CONTRACT_REPAYMENT_Y0Q1,
A.CONTRACTREPAYMENTY0M4 as CONTRACT_REPAYMENT_Y0M4,
A.CONTRACTREPAYMENTY0M5 as CONTRACT_REPAYMENT_Y0M5,
A.CONTRACTREPAYMENTY0M6 as CONTRACT_REPAYMENT_Y0M6,
A.CONTRACTREPAYMENTY0Q2 as CONTRACT_REPAYMENT_Y0Q2,
A.CONTRACTREPAYMENTY0M7 as CONTRACT_REPAYMENT_Y0M7,
A.CONTRACTREPAYMENTY0M8 as CONTRACT_REPAYMENT_Y0M8,
A.CONTRACTREPAYMENTY0M9 as CONTRACT_REPAYMENT_Y0M9,
A.CONTRACTREPAYMENTY0Q3 as CONTRACT_REPAYMENT_Y0Q3,
A.CONTRACTREPAYMENTY0M10 as CONTRACT_REPAYMENT_Y0M10,
A.CONTRACTREPAYMENTY0M11 as CONTRACT_REPAYMENT_Y0M11,
A.CONTRACTREPAYMENTY0M12 as CONTRACT_REPAYMENT_Y0M12,
A.CONTRACTREPAYMENTY0Q4 as CONTRACT_REPAYMENT_Y0Q4,
A.CONTRACTREPAYMENTY1M1 as CONTRACT_REPAYMENT_Y1M1,
A.CONTRACTREPAYMENTY1M2 as CONTRACT_REPAYMENT_Y1M2,
A.CONTRACTREPAYMENTY1M3 as CONTRACT_REPAYMENT_Y1M3,
A.CONTRACTREPAYMENTY1Q1 as CONTRACT_REPAYMENT_Y1Q1,
A.CONTRACTREPAYMENTY1M4 as CONTRACT_REPAYMENT_Y1M4,
A.CONTRACTREPAYMENTY1M5 as CONTRACT_REPAYMENT_Y1M5,
A.CONTRACTREPAYMENTY1M6 as CONTRACT_REPAYMENT_Y1M6,
A.CONTRACTREPAYMENTY1Q2 as CONTRACT_REPAYMENT_Y1Q2,
A.CONTRACTREPAYMENTY1M7 as CONTRACT_REPAYMENT_Y1M7,
A.CONTRACTREPAYMENTY1M8 as CONTRACT_REPAYMENT_Y1M8,
A.CONTRACTREPAYMENTY1M9 as CONTRACT_REPAYMENT_Y1M9,
A.CONTRACTREPAYMENTY1Q3 as CONTRACT_REPAYMENT_Y1Q3,
A.CONTRACTREPAYMENTY1M10 as CONTRACT_REPAYMENT_Y1M10,
A.CONTRACTREPAYMENTY1M11 as CONTRACT_REPAYMENT_Y1M11,
A.CONTRACTREPAYMENTY1M12 as CONTRACT_REPAYMENT_Y1M12,
A.CONTRACTREPAYMENTY1Q4 as CONTRACT_REPAYMENT_Y1Q4,
A.CONTRACTREPAYMENTY2M1 as CONTRACT_REPAYMENT_Y2M1,
A.CONTRACTREPAYMENTY2M2 as CONTRACT_REPAYMENT_Y2M2,
A.CONTRACTREPAYMENTY2M3 as CONTRACT_REPAYMENT_Y2M3,
A.CONTRACTREPAYMENTY2Q1 as CONTRACT_REPAYMENT_Y2Q1,
A.CONTRACTREPAYMENTY2M4 as CONTRACT_REPAYMENT_Y2M4,
A.CONTRACTREPAYMENTY2M5 as CONTRACT_REPAYMENT_Y2M5,
A.CONTRACTREPAYMENTY2M6 as CONTRACT_REPAYMENT_Y2M6,
A.CONTRACTREPAYMENTY2Q2 as CONTRACT_REPAYMENT_Y2Q2,
A.CONTRACTREPAYMENTY2M7 as CONTRACT_REPAYMENT_Y2M7,
A.CONTRACTREPAYMENTY2M8 as CONTRACT_REPAYMENT_Y2M8,
A.CONTRACTREPAYMENTY2M9 as CONTRACT_REPAYMENT_Y2M9,
A.CONTRACTREPAYMENTY2Q3 as CONTRACT_REPAYMENT_Y2Q3,
A.CONTRACTREPAYMENTY2M10 as CONTRACT_REPAYMENT_Y2M10,
A.CONTRACTREPAYMENTY2M11 as CONTRACT_REPAYMENT_Y2M11,
A.CONTRACTREPAYMENTY2M12 as CONTRACT_REPAYMENT_Y2M12,
A.CONTRACTREPAYMENTY2Q4 as CONTRACT_REPAYMENT_Y2Q4,
A.PRINCIPALASOFY0 as PRINCIPALAS_OF_Y0,
A.PRINCIPALASOFY1 as PRINCIPALAS_OF_Y1,
A.PRINCIPALASOFY2 as PRINCIPALAS_OF_Y2,
A.PRINCIPALASOFY3 as PRINCIPALAS_OF_Y3,
A.PRINCIPALASOFY4 as PRINCIPALAS_OF_Y4,
A.PRINCIPALASOFY5 as PRINCIPALAS_OF_Y5,
A.PRINCIPALASOFY6 as PRINCIPALAS_OF_Y6,
A.PRINCIPALASOFY7 as PRINCIPALAS_OF_Y7,
A.CONTRACTREPAYMENTY0 as CONTRACT_REPAYMENT_Y0,
A.CONTRACTREPAYMENTY1 as CONTRACT_REPAYMENT_Y1,
A.CONTRACTREPAYMENTY2 as CONTRACT_REPAYMENT_Y2,
A.CONTRACTREPAYMENTY3 as CONTRACT_REPAYMENT_Y3,
A.CONTRACTREPAYMENTY4 as CONTRACT_REPAYMENT_Y4,
A.CONTRACTREPAYMENTY5 as CONTRACT_REPAYMENT_Y5,
A.CONTRACTREPAYMENTY6 as CONTRACT_REPAYMENT_Y6,
A.CONTRACTREPAYMENTY7 as CONTRACT_REPAYMENT_Y7,
A.xirr as xirr,
A.contractrepaymentother as contract_repayment_other,
A.ReportingDate AS REPORTINGDATE,
A.valid_to_dttm,
c.CLIENT_CD,
c.SLX_CODE,
c.VTB_CLIENT_GROUP,
c.SHORT_CLIENT_RU_NAM,
cc.branch_key,
orgstr.BASE_CURRENCY_KEY,
cc.CONTRACT_ID_CD,
cc.add_amt,
lapp.PRESENTATION,
lc.SECTOR,
i.rate_en_nam,
mc.COL_MIRCODE,
curr.CURRENCY_LETTER_CD,
lc.currency_key,
lc.auto_flg,
CASE WHEN lc.auto_flg = 1 THEN nvl(COALESCE (ir.RATE, ird.RATE),0) ELSE nvl(COALESCE (ir.RATE, ira.AVG_CORP_RES_RATE, ird.RATE),0) END AS IFRSRATE,
CASE WHEN lc.auto_flg = 1 THEN nvl(COALESCE (ir_iw.RATE, ird_iw.RATE),0) ELSE nvl(COALESCE (ir_iw.RATE, ira.AVG_CORP_RES_RATE, ird_iw.RATE),0) END AS IFRSRATE_IW,
CASE WHEN lc.auto_flg = 1 THEN nvl(COALESCE (ir_mm.RATE, ird_mm.RATE),0) ELSE nvl(COALESCE (ir_mm.RATE, ira.AVG_CORP_RES_RATE, ird_mm.RATE),0) END AS IFRSRATE_MM,
CASE WHEN lc.auto_flg = 1 THEN nvl(COALESCE (ir_qq.RATE, ird_qq.RATE),0) ELSE nvl(COALESCE (ir_qq.RATE, ira.AVG_CORP_RES_RATE, ird_qq.RATE),0) END AS IFRSRATE_QQ,
CASE WHEN lc.auto_flg = 1 THEN nvl(COALESCE (ir_yy.RATE, ird_yy.RATE),0) ELSE nvl(COALESCE (ir_yy.RATE, ira.AVG_CORP_RES_RATE, ird_yy.RATE),0) END AS IFRSRATE_YY,
trunc(ir.from_dttm) AS RATE_START_DT, --08112018 5972
nvl(substr(lprt.file_name,32),'') AS LOANS_NAM --08112018 5972
FROM DWH.REPORTLOANPORTFOLIO A
LEFT JOIN DWH.LEASING_CONTRACTS_APPLS lapp on lapp.contract_key = A.contract_key and lapp.contract_app_key = A.contract_app_key
and lapp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN DWH.LEASING_CONTRACTS lc on lc.contract_key = A.contract_key
and lc.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN (select contract_key, contract_id_cd, add_amt, valid_to_dttm, float_rate_type_key, branch_key, client_key from DWH.CONTRACTS) cc on A.contract_key=cc.contract_key
and cc.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN DWH.INTEREST_RATE_TYPES i ON i.rate_key = cc.float_rate_type_key
and i.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN DWH.MIRCODE mc ON mc.MIRCODE_KEY=lc.mircode_key
and mc.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN DWH.CLIENTS c ON c.client_key=A.CLIENT_KEY
and c.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN DWH.Currencies curr ON curr.currency_key=lc.currency_key
and curr.end_dt = to_date('31.12.2099','dd.mm.yyyy') and curr.valid_to_dttm=to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN DWH.org_structure orgstr on orgstr.branch_key = cc.branch_key and orgstr.VALID_TO_DTTM = to_date('01.01.2400','dd.mm.yyyy')
--====================================================================
LEFT JOIN dwh.ifrs_rate ird on ird.contract_key = 999999999 and ird.contract_app_key = case when lc.auto_flg = 1 then 999999999 else 999999998 end and a.reportingdate between ird.from_dttm and ird.to_dttm and ird.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN dwh.ifrs_rate ir on ir.contract_key = lc.contract_key and ir.contract_app_key = lapp.contract_app_key and a.reportingdate between ir.from_dttm and ir.to_dttm and ir.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN dwh.ifrs_rate ird_iw on ird_iw.contract_key = 999999999 and ird_iw.contract_app_key = case when lc.auto_flg = 1 then 999999999 else 999999998 end and A.reportingdate - 7 between ird_iw.from_dttm and ird_iw.to_dttm and ird_iw.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN dwh.ifrs_rate ir_iw on ir_iw.contract_key = lc.contract_key and ir_iw.contract_app_key = lapp.contract_app_key and A.reportingdate - 7 between ir_iw.from_dttm and ir_iw.to_dttm and ir_iw.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN dwh.ifrs_rate ird_mm on ird_mm.contract_key = 999999999 and ird_mm.contract_app_key = case when lc.auto_flg = 1 then 999999999 else 999999998 end and trunc(A.reportingdate,'MM')-1 between ird_mm.from_dttm and ird_mm.to_dttm and ird_mm.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN dwh.ifrs_rate ir_mm on ir_mm.contract_key = lc.contract_key and ir_mm.contract_app_key = lapp.contract_app_key and trunc(A.reportingdate,'MM')-1 between ir_mm.from_dttm and ir_mm.to_dttm and ir_mm.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN dwh.ifrs_rate ird_qq on ird_qq.contract_key = 999999999 and ird_qq.contract_app_key = case when lc.auto_flg = 1 then 999999999 else 999999998 end and trunc(A.reportingdate,'Q')-1 between ird_qq.from_dttm and ird_qq.to_dttm and ird_qq.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN dwh.ifrs_rate ir_qq on ir_qq.contract_key = lc.contract_key and ir_qq.contract_app_key = lapp.contract_app_key and trunc(A.reportingdate,'Q')-1 between ir_qq.from_dttm and ir_qq.to_dttm and ir_qq.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN dwh.ifrs_rate ird_yy on ird_yy.contract_key = 999999999 and ird_yy.contract_app_key = case when lc.auto_flg = 1 then 999999999 else 999999998 end and trunc(A.reportingdate,'YY')-1 between ird_yy.from_dttm and ird_yy.to_dttm and ird_yy.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN dwh.ifrs_rate ir_yy on ir_yy.contract_key = lc.contract_key and ir_yy.contract_app_key = lapp.contract_app_key and trunc(A.reportingdate,'YY')-1 between ir_yy.from_dttm and ir_yy.to_dttm and ir_yy.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
LEFT JOIN rrate_avg ira on lc.auto_flg = 0 and ira.snapshot_dt = trunc(a.reportingdate,'MM') and ira.client_key = cc.CLIENT_KEY
--====================================================================
LEFT JOIN etl.ctl_input_files lprt on ir.rate is not null and lprt.file_id = ir.file_id
where A.valid_to_dttm=to_date ('01.01.2400', 'dd.mm.yyyy')) A
--=====================================================================================================
LEFT JOIN dwh.exchange_rates exr on exr.currency_key=A.currency_key and exr.ex_rate_dt = A.reportingdate and exr.base_currency_key = 125 and exr.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.exchange_rates b_exr on b_exr.currency_key=A.currency_key and b_exr.ex_rate_dt = A.reportingdate and b_exr.base_currency_key = A.base_currency_key and b_exr.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.exchange_rates exr_mm on exr_mm.currency_key=A.currency_key and exr_mm.ex_rate_dt = trunc(A.reportingdate,'MM')-1 and exr_mm.base_currency_key = 125 and exr_mm.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.exchange_rates b_exr_mm on b_exr_mm.currency_key=A.currency_key and b_exr_mm.ex_rate_dt = trunc(A.reportingdate,'MM')-1 and b_exr_mm.base_currency_key = A.base_currency_key and b_exr_mm.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.exchange_rates exr_yy on exr_yy.currency_key=A.currency_key and exr_yy.ex_rate_dt = trunc(A.reportingdate,'YY')-1 and exr_yy.base_currency_key = 125 and exr_yy.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.exchange_rates b_exr_yy on b_exr_yy.currency_key=A.currency_key and b_exr_yy.ex_rate_dt = trunc(A.reportingdate,'YY')-1 and b_exr_yy.base_currency_key = A.base_currency_key and b_exr_yy.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.exchange_rates exr_qq on exr_qq.currency_key=A.currency_key and exr_qq.ex_rate_dt = trunc(A.reportingdate,'Q')-1 and exr_qq.base_currency_key = 125 and exr_qq.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.exchange_rates b_exr_qq on b_exr_qq.currency_key=A.currency_key and b_exr_qq.ex_rate_dt = trunc(A.reportingdate,'Q')-1 and b_exr_qq.base_currency_key = A.base_currency_key and b_exr_qq.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.exchange_rates exr_iw on exr_iw.currency_key=A.currency_key and exr_iw.ex_rate_dt = A.reportingdate - 7 and exr_iw.base_currency_key = 125 and exr_iw.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.exchange_rates b_exr_iw on b_exr_iw.currency_key=A.currency_key and b_exr_iw.ex_rate_dt = A.reportingdate - 7 and b_exr_iw.base_currency_key = A.base_currency_key and b_exr_iw.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.exchange_rates b_yy on b_yy.ex_rate_dt = trunc(A.reportingdate,'YY')-1 and b_yy.currency_key = A.base_currency_key and b_yy.base_currency_key = 125 and b_yy.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.exchange_rates b_qq on b_qq.ex_rate_dt = trunc(A.reportingdate,'Q')-1 and b_qq.currency_key = A.base_currency_key and b_qq.base_currency_key = 125 and b_qq.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.exchange_rates b_mm on b_mm.ex_rate_dt = trunc(A.reportingdate,'MM')-1 and b_mm.currency_key = A.base_currency_key and b_mm.base_currency_key = 125 and b_mm.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.exchange_rates b_iw on b_iw.ex_rate_dt = A.reportingdate - 7 and b_iw.currency_key = A.base_currency_key and b_iw.base_currency_key = 125 and b_iw.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
LEFT JOIN dwh.exchange_rates b_ on b_.ex_rate_dt = A.reportingdate and b_.currency_key = A.base_currency_key and b_.base_currency_key = 125 and b_.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
--LEFT JOIN dwh.stock_averbal_residval savrb on savrb.contract_key = A.contract_key and savrb.contract_app_key = A.contract_app_key and trunc(savrb.actual_dt,'yy') = trunc(A.reportingdate+1,'YY') --05092018 IN CL PL Stocks used for current year 11092018 No need
left join (select trunc(plcorrs.start_dt,'yy') act_year, plcorrs.contract_key, plcorrs.contract_app_key, sum(plcorrs.corr_val) corr_sum from dwh.cl_pl_corr plcorrs --02102018 added for year beginning provisions
where trunc(plcorrs.start_dt,'yy')=to_date('01.01.2018','dd.mm.yyyy') group by plcorrs.contract_key, plcorrs.contract_app_key, trunc(plcorrs.start_dt,'yy')) plcorr
on plcorr.act_year = trunc(A.reportingdate,'yy') and plcorr.contract_key = a.contract_key and plcorr.contract_app_key = a.contract_app_key
;

