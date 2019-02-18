CREATE OR REPLACE PROCEDURE DM.p_DM_NOTA (
    p_REPORT_DT date
)
is

BEGIN
    /*
     02102018 Процедура пересчета основе DM.V$NOTA_PL, OPTIMAZED .
     В качестве входного параметра подается дата составления отчета
    */
    dm.u_log(p_proc => 'DM.p_DM_NOTA',
           p_step => 'INPUT PARAMS',
           p_info => 'p_REPORT_DT: '||p_REPORT_DT);
	delete from DM.DM_NOTA where snapshot_dt = p_REPORT_DT;

	dm.u_log(p_proc => 'DM.p_DM_NOTA',
           p_step => 'delete from DM.DM_NOTA',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');

	commit;

INSERT /*+ APPEND */ INTO DM.DM_NOTA
with
qclp as (select lp.provisions, lp.contract_app_key, lp.snapshot_dt, lp.exposure_principal, lp.accrued, row_number() over (partition by lp.contract_app_key order by lp.snapshot_dt) as snapshot_cnt
from DM.V$NOTA_PL lp where lp.snapshot_dt between trunc(p_REPORT_DT, 'YY') and p_REPORT_DT),
qcrd as (select apc.contract_app_key, apc.snapshot_dt, apc.EXPOSURE_PRINCIPAL_BOY, apc.EXPOSURE_PRINCIPAL_BOQ, apc.EXPOSURE_PRINCIPAL_BOM, apc.EXPOSURE_PRINCIPAL_BOW,
apc.ACCRUED_INTEREST_BOY, apc.ACCRUED_INTEREST_BOQ, apc.ACCRUED_INTEREST_BOM, apc.ACCRUED_INTEREST_BOW, apc.IFRSRATE_IW, apc.IFRSRATE_MM, apc.IFRSRATE_QQ, apc.IFRSRATE_YY, apc.PROVISIONS_EXPOSURE_BOY, apc.PROVISIONS_EXPOSURE_BOY_IND
from DM.V$NOTA_PL apc where apc.snapshot_dt = p_REPORT_DT),
q as  (select ap.contract_app_key, ap.snapshot_dt, ap.original_loan_currency, ap.branch_key,
--BS Dynamics, RUR; FX Revaluation 12092018 was exposure_principal+accrued
sum(nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= p_REPORT_DT-7 then apc.EXPOSURE_PRINCIPAL_BOW else lp.exposure_principal end,0)*(case when ap.branch_key = '14' then (nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) - nvl(b_exr_iw.EXCHANGE_RATE,0)*nvl(b_iw.EXCHANGE_RATE,0)) else (nvl(ap.exchange_rate,0) - nvl(exr_iw.EXCHANGE_RATE,0)) end)) over(partition by trunc(ap.snapshot_dt + (7 - to_char(p_REPORT_DT,'d')), 'Day'), ap.contract_app_key order by ap.snapshot_dt) as revaluation_wtd,
sum(nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'MM')-1 then apc.EXPOSURE_PRINCIPAL_BOM else lp.exposure_principal end,0)*(case when ap.branch_key = '14' then (nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) - nvl(b_exr_mm.EXCHANGE_RATE,0)*nvl(b_mm.EXCHANGE_RATE,0)) else (nvl(ap.exchange_rate,0) - nvl(exr_mm.EXCHANGE_RATE,0)) end)) over(partition by trunc(ap.snapshot_dt,'MM'), ap.contract_app_key order by ap.snapshot_dt) as revaluation_mtd,
sum(nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt, 'Q')-1 then apc.EXPOSURE_PRINCIPAL_BOQ else lp.exposure_principal end,0)*(case when ap.branch_key = '14' then (nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) - nvl(b_exr_qq.EXCHANGE_RATE,0)*nvl(b_qq.EXCHANGE_RATE,0)) else (nvl(ap.exchange_rate,0) - nvl(exr_qq.EXCHANGE_RATE,0)) end)) over(partition by trunc(ap.snapshot_dt, 'Q'), ap.contract_app_key order by ap.snapshot_dt) as revaluation_qtd,
sum(nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'YY')-1 then apc.EXPOSURE_PRINCIPAL_BOY else lp.exposure_principal end,0)*(case when ap.branch_key = '14' then (nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) - nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0)) else (nvl(ap.exchange_rate,0) - nvl(exr.EXCHANGE_RATE,0)) end)) over(partition by trunc(ap.snapshot_dt,'YY'), ap.contract_app_key order by ap.snapshot_dt) as revaluation_ytd,
--LLP BS Dynamisc, RUR; FX Revaluation
sum((case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= p_REPORT_DT-7 then (nvl(apc.EXPOSURE_PRINCIPAL_BOW,0) + nvl(apc.ACCRUED_INTEREST_BOW,0))*nvl(apc.IFRSRATE_IW,0)*(-1) else nvl(lp.provisions,0) end)*(case when ap.branch_key = '14' then (nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) - nvl(b_exr_iw.EXCHANGE_RATE,0)*nvl(b_iw.EXCHANGE_RATE,0)) else (nvl(ap.exchange_rate,0) - nvl(exr_iw.EXCHANGE_RATE,0)) end)) over(partition by trunc(ap.snapshot_dt + (7 - to_char(p_REPORT_DT,'d')), 'Day'), ap.contract_app_key order by ap.snapshot_dt) as fx_revaluation_wtd,
sum((case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'MM')-1 then (nvl(apc.EXPOSURE_PRINCIPAL_BOM,0) + nvl(apc.ACCRUED_INTEREST_BOM,0))*nvl(apc.IFRSRATE_MM,0)*(-1) else nvl(lp.provisions,0) end)*(case when ap.branch_key = '14' then (nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) - nvl(b_exr_mm.EXCHANGE_RATE,0)*nvl(b_mm.EXCHANGE_RATE,0)) else (nvl(ap.exchange_rate,0) - nvl(exr_mm.EXCHANGE_RATE,0)) end)) over(partition by trunc(ap.snapshot_dt,'MM'), ap.contract_app_key order by ap.snapshot_dt) as fx_revaluation_mtd,
sum((case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt, 'Q')-1 then (nvl(apc.EXPOSURE_PRINCIPAL_BOQ,0) + nvl(apc.ACCRUED_INTEREST_BOQ,0))*nvl(apc.IFRSRATE_QQ,0)*(-1) else nvl(lp.provisions,0) end)*(case when ap.branch_key = '14' then (nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) - nvl(b_exr_qq.EXCHANGE_RATE,0)*nvl(b_qq.EXCHANGE_RATE,0)) else (nvl(ap.exchange_rate,0) - nvl(exr_qq.EXCHANGE_RATE,0)) end)) over(partition by trunc(ap.snapshot_dt, 'Q'), ap.contract_app_key order by ap.snapshot_dt) as fx_revaluation_qtd,
--sum((case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'YY')-1 then (nvl(apc.EXPOSURE_PRINCIPAL_BOY,0) + nvl(apc.ACCRUED_INTEREST_BOY,0))*nvl(apc.IFRSRATE_YY,0)*(-1) else nvl(lp.provisions,0) end)*(case when ap.branch_key = '14' then (nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) - nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0)) else (nvl(ap.exchange_rate,0) - nvl(exr.EXCHANGE_RATE,0)) end)) over(partition by trunc(ap.snapshot_dt,'YY'), ap.contract_app_key order by ap.snapshot_dt) as fx_revaluation_ytd,
sum((case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'YY')-1 then (nvl(apc.PROVISIONS_EXPOSURE_BOY_IND,0)) else nvl(lp.provisions,0) end)*(case when ap.branch_key = '14' then (nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) - nvl(b_exr.EXCHANGE_RATE,0)*nvl(b_.EXCHANGE_RATE,0)) else (nvl(ap.exchange_rate,0) - nvl(exr.EXCHANGE_RATE,0)) end)) over(partition by trunc(ap.snapshot_dt,'YY'), ap.contract_app_key order by ap.snapshot_dt) as fx_revaluation_ytd,
--LLP BS Dynamisc, RUR; LLP accrual/LLP write-off
sum((case when ap.branch_key = '14' then nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) else nvl(ap.EXCHANGE_RATE,0) end)*(nvl(ap.provisions,0)-(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= p_REPORT_DT-7 then (nvl(apc.EXPOSURE_PRINCIPAL_BOW,0) + nvl(apc.ACCRUED_INTEREST_BOW,0))*nvl(apc.IFRSRATE_IW,0)*(-1) else nvl(lp.provisions,0) end))) over (partition by trunc(ap.snapshot_dt + (7 - to_char(p_REPORT_DT,'d')), 'Day'), ap.contract_app_key order by ap.snapshot_dt) AS LLP_ACCRUAL_WTD,
sum((case when ap.branch_key = '14' then nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) else nvl(ap.EXCHANGE_RATE,0) end)*(nvl(ap.provisions,0)-(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'MM')-1 then (nvl(apc.EXPOSURE_PRINCIPAL_BOM,0) + nvl(apc.ACCRUED_INTEREST_BOM,0))*nvl(apc.IFRSRATE_MM,0)*(-1) else nvl(lp.provisions,0) end))) over (partition by trunc(ap.snapshot_dt,'MM'), ap.contract_app_key order by ap.snapshot_dt) AS LLP_ACCRUAL_MTD,
sum((case when ap.branch_key = '14' then nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) else nvl(ap.EXCHANGE_RATE,0) end)*(nvl(ap.provisions,0)-(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt, 'Q')-1 then (nvl(apc.EXPOSURE_PRINCIPAL_BOQ,0) + nvl(apc.ACCRUED_INTEREST_BOQ,0))*nvl(apc.IFRSRATE_QQ,0)*(-1) else nvl(lp.provisions,0) end))) over (partition by trunc(ap.snapshot_dt, 'Q'), ap.contract_app_key order by ap.snapshot_dt) AS LLP_ACCRUAL_QTD,
--sum((case when ap.branch_key = '14' then nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) else nvl(ap.EXCHANGE_RATE,0) end)*(nvl(ap.provisions,0)-(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'YY')-1 then (nvl(apc.EXPOSURE_PRINCIPAL_BOY,0) + nvl(apc.ACCRUED_INTEREST_BOY,0))*nvl(apc.IFRSRATE_YY,0)*(-1) else nvl(lp.provisions,0) end))) over (partition by trunc(ap.snapshot_dt,'YY'), ap.contract_app_key order by ap.snapshot_dt) AS LLP_ACCRUAL_YTD,
sum((case when ap.branch_key = '14' then nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) else nvl(ap.EXCHANGE_RATE,0) end)*(nvl(ap.provisions,0)-(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'YY')-1 then (nvl(apc.PROVISIONS_EXPOSURE_BOY_IND,0)) else nvl(lp.provisions,0) end))) over (partition by trunc(ap.snapshot_dt,'YY'), ap.contract_app_key order by ap.snapshot_dt) AS LLP_ACCRUAL_YTD,
--======================================
--BS Dynamics, RUR;  New tranche/Repaid tranche
--12092018 Trying to expect: BS Exposure, Begin-of-Year + New tranche + Repaid tranche + FX Revaluation = BS Exposure, Reporting date
sum(case when (nvl(ap.exposure_principal,0) - nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= p_REPORT_DT-7 then apc.EXPOSURE_PRINCIPAL_BOW else lp.exposure_principal end,0)) > 0 then (case when ap.branch_key = '14' then nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) else nvl(ap.EXCHANGE_RATE,0) end)*(nvl(ap.exposure_principal,0) - nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= p_REPORT_DT-7 then apc.EXPOSURE_PRINCIPAL_BOW else lp.exposure_principal end,0)) else 0 end) over (partition by trunc(ap.snapshot_dt + (7 - to_char(p_REPORT_DT,'d')), 'Day'), ap.contract_app_key order by ap.snapshot_dt) AS new_tranche_wtd,
sum(case when (nvl(ap.exposure_principal,0) - nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= p_REPORT_DT-7 then apc.EXPOSURE_PRINCIPAL_BOW else lp.exposure_principal end,0)) < 0 then (case when ap.branch_key = '14' then nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) else nvl(ap.EXCHANGE_RATE,0) end)*(nvl(ap.exposure_principal,0) - nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= p_REPORT_DT-7 then apc.EXPOSURE_PRINCIPAL_BOW else lp.exposure_principal end,0)) else 0 end) over (partition by trunc(ap.snapshot_dt + (7 - to_char(p_REPORT_DT,'d')), 'Day'), ap.contract_app_key order by ap.snapshot_dt) AS repaid_tranche_wtd,
sum(case when (nvl(ap.exposure_principal,0) - nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'MM')-1 then apc.EXPOSURE_PRINCIPAL_BOM else lp.exposure_principal end,0)) > 0 then (case when ap.branch_key = '14' then nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) else nvl(ap.EXCHANGE_RATE,0) end)*(nvl(ap.exposure_principal,0) - nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'MM')-1 then apc.EXPOSURE_PRINCIPAL_BOM else lp.exposure_principal end,0)) else 0 end) over (partition by trunc(ap.snapshot_dt, 'MM'), ap.contract_app_key order by ap.snapshot_dt) AS new_tranche_mtd,
sum(case when (nvl(ap.exposure_principal,0) - nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'MM')-1 then apc.EXPOSURE_PRINCIPAL_BOM else lp.exposure_principal end,0)) < 0 then (case when ap.branch_key = '14' then nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) else nvl(ap.EXCHANGE_RATE,0) end)*(nvl(ap.exposure_principal,0) - nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'MM')-1 then apc.EXPOSURE_PRINCIPAL_BOM else lp.exposure_principal end,0)) else 0 end) over (partition by trunc(ap.snapshot_dt, 'MM'), ap.contract_app_key order by ap.snapshot_dt) AS repaid_tranche_mtd,
sum(case when (nvl(ap.exposure_principal,0) - nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt, 'Q')-1 then apc.EXPOSURE_PRINCIPAL_BOQ else lp.exposure_principal end,0)) > 0 then (case when ap.branch_key = '14' then nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) else nvl(ap.EXCHANGE_RATE,0) end)*(nvl(ap.exposure_principal,0) - nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt, 'Q')-1 then apc.EXPOSURE_PRINCIPAL_BOQ else lp.exposure_principal end,0)) else 0 end) over (partition by trunc(ap.snapshot_dt, 'Q'), ap.contract_app_key order by ap.snapshot_dt) AS new_tranche_qtd,
sum(case when (nvl(ap.exposure_principal,0) - nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt, 'Q')-1 then apc.EXPOSURE_PRINCIPAL_BOQ else lp.exposure_principal end,0)) < 0 then (case when ap.branch_key = '14' then nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) else nvl(ap.EXCHANGE_RATE,0) end)*(nvl(ap.exposure_principal,0) - nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt, 'Q')-1 then apc.EXPOSURE_PRINCIPAL_BOQ else lp.exposure_principal end,0)) else 0 end) over (partition by trunc(ap.snapshot_dt, 'Q'), ap.contract_app_key order by ap.snapshot_dt) AS repaid_tranche_qtd,
sum(case when (nvl(ap.exposure_principal,0) - nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'YY')-1 then apc.EXPOSURE_PRINCIPAL_BOY else lp.exposure_principal end,0)) > 0 then (case when ap.branch_key = '14' then nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) else nvl(ap.EXCHANGE_RATE,0) end)*(nvl(ap.exposure_principal,0) - nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'YY')-1 then apc.EXPOSURE_PRINCIPAL_BOY else lp.exposure_principal end,0)) else 0 end) over (partition by trunc(ap.snapshot_dt, 'YY'), ap.contract_app_key order by ap.snapshot_dt) AS new_tranche_ytd,
sum(case when (nvl(ap.exposure_principal,0) - nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'YY')-1 then apc.EXPOSURE_PRINCIPAL_BOY else lp.exposure_principal end,0)) < 0 then (case when ap.branch_key = '14' then nvl(b_exr_a.EXCHANGE_RATE,0)*nvl(b_a.EXCHANGE_RATE,0) else nvl(ap.EXCHANGE_RATE,0) end)*(nvl(ap.exposure_principal,0) - nvl(case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'YY')-1 then apc.EXPOSURE_PRINCIPAL_BOY else lp.exposure_principal end,0)) else 0 end) over (partition by trunc(ap.snapshot_dt, 'YY'), ap.contract_app_key order by ap.snapshot_dt) AS repaid_tranche_ytd
--======================================
   from DM.V$NOTA_PL ap
  --left join (select lp.provisions, lp.contract_app_key, lp.snapshot_dt, lp.exposure_principal, lp.accrued from DM.V$NOTA_PL lp) lp
  --   on lp.snapshot_dt = lpd.snapshot_dtlp and lp.contract_app_key = ap.contract_app_key
  left join qclp lpdqc on lpdqc.snapshot_dt = ap.snapshot_dt and lpdqc.contract_app_key = ap.contract_app_key
  left join qclp lp on lp.snapshot_cnt = lpdqc.snapshot_cnt-1 and lp.contract_app_key = lpdqc.contract_app_key
  --======================================================================================================
  --left join (select apc.contract_app_key, apc.snapshot_dt, apc.EXPOSURE_PRINCIPAL_BOY, apc.EXPOSURE_PRINCIPAL_BOQ, apc.EXPOSURE_PRINCIPAL_BOM, apc.EXPOSURE_PRINCIPAL_BOW,
	--apc.ACCRUED_INTEREST_BOY, apc.ACCRUED_INTEREST_BOQ, apc.ACCRUED_INTEREST_BOM, apc.ACCRUED_INTEREST_BOW, apc.IFRSRATE_IW, apc.IFRSRATE_MM, apc.IFRSRATE_QQ, apc.IFRSRATE_YY from DM.V$NOTA_PL apc) apc
     --on apc.snapshot_dt = p_REPORT_DT and apc.contract_app_key = ap.contract_app_key
  left join qcrd apc on apc.contract_app_key = ap.contract_app_key
  --======================================================================================================
  left join dwh.exchange_rates b_exr_a on b_exr_a.currency_key=ap.currency_key and b_exr_a.ex_rate_dt = ap.snapshot_dt and b_exr_a.base_currency_key = ap.base_currency_key and b_exr_a.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
  left join dwh.exchange_rates b_a on b_a.ex_rate_dt = ap.snapshot_dt and b_a.currency_key = ap.base_currency_key and b_a.base_currency_key = 125 and b_a.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
  --======================================================================================================
  left join dwh.exchange_rates b_exr on b_exr.ex_rate_dt = nvl(lp.snapshot_dt, trunc(ap.snapshot_dt,'YY')-1) and b_exr.currency_key=ap.currency_key and b_exr.base_currency_key = ap.base_currency_key and b_exr.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
  left join dwh.exchange_rates b_ on b_.ex_rate_dt = nvl(lp.snapshot_dt, trunc(ap.snapshot_dt,'YY')-1) and b_.currency_key = ap.base_currency_key and b_.base_currency_key = 125 and b_.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
  left join dwh.exchange_rates exr on exr.ex_rate_dt = nvl(lp.snapshot_dt, trunc(ap.snapshot_dt,'YY')-1) and exr.currency_key = ap.currency_key and exr.base_currency_key = 125 and exr.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
  --=========================
  left join dwh.exchange_rates exr_mm on exr_mm.ex_rate_dt = case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'MM')-1 then trunc(ap.snapshot_dt,'MM')-1 else lp.snapshot_dt end
	and exr_mm.currency_key = ap.currency_key and exr_mm.base_currency_key = 125 and exr_mm.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
  left join dwh.exchange_rates exr_qq on exr_qq.ex_rate_dt = case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt, 'Q')-1 then trunc(ap.snapshot_dt, 'Q')-1 else lp.snapshot_dt end
	and exr_qq.currency_key = ap.currency_key and exr_qq.base_currency_key = 125 and exr_qq.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
  left join dwh.exchange_rates exr_iw on exr_iw.ex_rate_dt = case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= p_REPORT_DT-7 then p_REPORT_DT-7 else lp.snapshot_dt end
	and exr_iw.currency_key = ap.currency_key and exr_iw.base_currency_key = 125 and exr_iw.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
  left join dwh.exchange_rates b_exr_mm on b_exr_mm.ex_rate_dt = case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'MM')-1 then trunc(ap.snapshot_dt,'MM')-1 else lp.snapshot_dt end
	and b_exr_mm.currency_key=ap.currency_key and b_exr_mm.base_currency_key = ap.base_currency_key and b_exr_mm.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
  left join dwh.exchange_rates b_exr_qq on b_exr_qq.ex_rate_dt = case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt, 'Q')-1 then trunc(ap.snapshot_dt, 'Q')-1 else lp.snapshot_dt end
	and b_exr_qq.currency_key=ap.currency_key and b_exr_qq.base_currency_key = ap.base_currency_key and b_exr_qq.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
  left join dwh.exchange_rates b_exr_iw on b_exr_iw.ex_rate_dt = case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= p_REPORT_DT-7 then p_REPORT_DT-7 else lp.snapshot_dt end
	and b_exr_iw.currency_key=ap.currency_key and b_exr_iw.base_currency_key = ap.base_currency_key and b_exr_iw.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
  left join dwh.exchange_rates b_mm on b_mm.ex_rate_dt = case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt,'MM')-1 then trunc(ap.snapshot_dt,'MM')-1 else lp.snapshot_dt end
	and b_mm.currency_key = ap.base_currency_key and b_mm.base_currency_key = 125 and b_mm.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
  left join dwh.exchange_rates b_qq on b_qq.ex_rate_dt = case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= trunc(ap.snapshot_dt, 'Q')-1 then trunc(ap.snapshot_dt, 'Q')-1 else lp.snapshot_dt end
	and b_qq.currency_key = ap.base_currency_key and b_qq.base_currency_key = 125 and b_qq.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
  left join dwh.exchange_rates b_iw on b_iw.ex_rate_dt = case when lp.snapshot_dt IS NULL OR lp.snapshot_dt <= p_REPORT_DT-7 then p_REPORT_DT-7 else lp.snapshot_dt end
	and b_iw.currency_key = ap.base_currency_key and b_iw.base_currency_key = 125 and b_iw.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
--=========================
  where ap.snapshot_dt between trunc(p_REPORT_DT, 'YY') and p_REPORT_DT /*27082018 Cutting approximation period for optimization*/
  )
select a.exchange_rate,
       a.contract_app_key,
       a.snapshot_dt,
       a.mircode,
       a.desk,
       a.lnd,
       a.npl,
       a.sector,
       a.current_account_number,
       a.local_client_id,
       a.vtb_group,
       a.borrower,
       a.booking_entity,
       a.funding_bank,
       a.vtb_nwrc,
       a.clfi,
       a.sharing_desc,
       a.original_loan_currency,
       a.deal_type,
       a.start_date,
       a.maturity_date,
       a.initial_wal,
       a.fixed_floating_rate_base,
       a.base_interest_rate,
       a.full_interest_rate,
       a.upfront_fee,
       a.ftp_base_rate,
       a.ftp_full_rate,
       a.net_running_margin,
       a.upfront_running_margin,
       a.exposure_principal,
        a.accrued,
        a.provisions,
        a.exposure_principal_rur,
        a.accrued_rur,
        a.provisions_rur,
        a.overdue_start_date,
        a.exposure_principal_overdue_rur,
        a.overdue_accrued_start_date,
        a.accrued_interest_overdue,
        a.overdue_penalty_fee,
        a.overdue_penalty_fee_start_date,
        a.overdue_penalty_fee_rur,
        a.bs_exposure_boy,
        a.accrued_boy,
        a.provisions_exposure_boy,
        a.bs_exposure_boq,
        a.accrued_boq,
        a.provisions_exposure_boq,
        a.bs_exposure_bom,
        a.accrued_bom,
        a.provisions_exposure_bom,
        a.bs_exposure_bow,
        a.accrued_bow,
        a.provisions_exposure_bow,
        a.bs_exposure_snapshotdt,
        a.accrued_snapshotdt,
        a.provisions_snapshotdt,
        q.new_tranche_ytd, --07092018
        q.repaid_tranche_ytd,
        q.new_tranche_qtd,
        q.repaid_tranche_qtd,
        q.new_tranche_mtd,
        q.repaid_tranche_mtd,
        q.new_tranche_wtd,
        q.repaid_tranche_wtd, --07092018
        a.revolving,
        a.unrevolving,
        a.total_limit,
        a.blank_1,
        a.contract_repayment_y0m1,
        a.contract_repayment_y0m2,
        a.contract_repayment_y0m3,
        a.contract_repayment_y0q1,
        a.contract_repayment_y0m4,
        a.contract_repayment_y0m5,
        a.contract_repayment_y0m6,
        a.contract_repayment_y0q2,
        a.contract_repayment_y0m7,
        a.contract_repayment_y0m8,
        a.contract_repayment_y0m9,
        a.contract_repayment_y0q3,
        a.contract_repayment_y0m10,
        a.contract_repayment_y0m11,
        a.contract_repayment_y0m12,
        a.contract_repayment_y0q4,
        a.contract_repayment_y0,
        a.principalas_of_y0,
        a.contract_repayment_y1m1,
        a.contract_repayment_y1m2,
        a.contract_repayment_y1m3,
        a.contract_repayment_y1q1,
        a.contract_repayment_y1m4,
        a.contract_repayment_y1m5,
        a.contract_repayment_y1m6,
        a.contract_repayment_y1q2,
        a.contract_repayment_y1m7,
        a.contract_repayment_y1m8,
        a.contract_repayment_y1m9,
        a.contract_repayment_y1q3,
        a.contract_repayment_y1m10,
        a.contract_repayment_y1m11,
        a.contract_repayment_y1m12,
        a.contract_repayment_y1q4,
        a.contract_repayment_y1,
        a.principalas_of_y1,
        a.contract_repayment_y2m1,
        a.contract_repayment_y2m2,
        a.contract_repayment_y2m3,
        a.contract_repayment_y2q1,
        a.contract_repayment_y2m4,
        a.contract_repayment_y2m5,
        a.contract_repayment_y2m6,
        a.contract_repayment_y2q2,
        a.contract_repayment_y2m7,
        a.contract_repayment_y2m8,
        a.contract_repayment_y2m9,
        a.contract_repayment_y2q3,
        a.contract_repayment_y2m10,
        a.contract_repayment_y2m11,
        a.contract_repayment_y2m12,
        a.contract_repayment_y2q4,
        a.contract_repayment_y2,
        a.principalas_of_y2,
        a.contract_repayment_y3,
        a.principalas_of_y3,
        a.contract_repayment_y4,
        a.principalas_of_y4,
        a.contract_repayment_y5,
        a.principalas_of_y5,
        a.contract_repayment_y6,
        a.principalas_of_y6,
        a.contract_repayment_y7,
        a.principalas_of_y7,
        a.contract_repayment_after,
        a.final_maturity_date_pass_due,
        a.payment_lockout_period,
        a.column_209,
        CASE WHEN q.original_loan_currency = 'RUB' and q.branch_key <> '14' THEN 0 ELSE q.revaluation_wtd END AS revaluation_wtd,
        CASE WHEN q.original_loan_currency = 'RUB' and q.branch_key <> '14' THEN 0 ELSE q.revaluation_mtd END AS revaluation_mtd,
        CASE WHEN q.original_loan_currency = 'RUB' and q.branch_key <> '14' THEN 0 ELSE q.revaluation_qtd END AS revaluation_qtd,
        CASE WHEN q.original_loan_currency = 'RUB' and q.branch_key <> '14' THEN 0 ELSE q.revaluation_ytd END AS revaluation_ytd,
        CASE WHEN q.original_loan_currency = 'RUB' and q.branch_key <> '14' THEN 0 ELSE q.fx_revaluation_wtd END AS fx_revaluation_wtd,
        CASE WHEN q.original_loan_currency = 'RUB' and q.branch_key <> '14' THEN 0 ELSE q.fx_revaluation_mtd END AS fx_revaluation_mtd,
        CASE WHEN q.original_loan_currency = 'RUB' and q.branch_key <> '14' THEN 0 ELSE q.fx_revaluation_qtd END AS fx_revaluation_qtd,
        CASE WHEN q.original_loan_currency = 'RUB' and q.branch_key <> '14' THEN 0 ELSE q.fx_revaluation_ytd END AS fx_revaluation_ytd,
        CASE WHEN q.llp_accrual_ytd < 0 THEN q.llp_accrual_ytd ELSE 0 END AS LLP_ACCRUAL_YTD, --06092018
        CASE WHEN q.llp_accrual_ytd > 0 THEN q.llp_accrual_ytd ELSE 0 END AS LLP_WRITE_OFF_YTD,
        CASE WHEN q.llp_accrual_qtd < 0 THEN q.llp_accrual_qtd ELSE 0 END AS LLP_ACCRUAL_QTD,
        CASE WHEN q.llp_accrual_qtd > 0 THEN q.llp_accrual_qtd ELSE 0 END AS LLP_WRITE_OFF_QTD,
        CASE WHEN q.llp_accrual_mtd < 0 THEN q.llp_accrual_mtd ELSE 0 END AS LLP_ACCRUAL_MTD,
        CASE WHEN q.llp_accrual_mtd > 0 THEN q.llp_accrual_mtd ELSE 0 END AS LLP_WRITE_OFF_MTD,
        CASE WHEN q.llp_accrual_wtd < 0 THEN q.llp_accrual_wtd ELSE 0 END AS LLP_ACCRUAL_WTD,
        CASE WHEN q.llp_accrual_wtd > 0 THEN q.llp_accrual_wtd else 0 END AS LLP_WRITE_OFF_WTD,
	    a.rate_start_dt, --08112018 5972
	    a.loans_nam --08112018 5972
        from DM.V$NOTA_PL a
left join q on q.contract_app_key = a.contract_app_key and q.snapshot_dt = a.snapshot_dt
where a.snapshot_dt = p_REPORT_DT;

      dm.u_log(p_proc => 'DM.p_DM_NOTA',
           p_step => 'insert DM.p_DM_NOTA',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');

      commit;

   dm.analyze_table(p_table_name => 'DM_NOTA',p_schema => 'DM');
   dm.u_log(p_proc => 'DM.p_DM_NOTA',
           p_step => 'analyze_table DM.DM_NOTA',
           p_info => 'analyze_table done');
  etl.P_DM_LOG('DM_NOTA');
END;
/

