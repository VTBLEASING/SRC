CREATE OR REPLACE PROCEDURE DM.p_DM_RPL (
    p_REPORT_DT date)
is

BEGIN

  /* Процедура расчета витрины DM_CL_PL полностью.
     В качестве входного параметра подается дата составления отчета
  */
    dm.u_log(p_proc => 'DM.p_DM_RPL',
           p_step => 'INPUT PARAMS',
           p_info => 'p_REPORT_DT: '||p_REPORT_DT);
  delete from DM.DM_RPL where snapshot_dt = p_REPORT_DT;

  dm.u_log(p_proc => 'DM.p_DM_RPL',
           p_step => 'delete from DM.DM_RPL',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');

  commit;

INSERT /*+ APPEND */ INTO DM.DM_RPL
with
/*with dcnt as (select rpldc.contract_key, rpldc.contract_app_key, rpldc.PRODUCT_NONUNI, sum(rpldc.total_nil_ovd) as sm, count(rpldc.snapshot_dt) as cc
from DM.DM_RPL rpldc where rpldc.snapshot_dt between trunc(p_REPORT_DT,'yy')-1 and p_REPORT_DT and rpldc.product_nonuni = '80' group by rpldc.contract_key, rpldc.contract_app_key, rpldc.PRODUCT_NONUNI), --ov*/
dcntod as (select vclply.contract_key, vclply.contract_app_key, vclply.PRODUCT_NONUNI, sum(nvl(vclply.ExposurePrincipal,0)) as sm,
sum(nvl(vclply.funding_rate * vclply.reserv_bal_residval_effdate * vclply.exchange_rate_avg,0)) as fund_npl, sum(nvl(vclply.AccruedInterest,0)) as smperc, count(vclply.snapshot_dt) as cc
from DM.V$CL_PL vclply where vclply.snapshot_dt between trunc(p_REPORT_DT,'yy')-1 and p_REPORT_DT and vclply.product_nonuni = '80'
group by vclply.contract_key, vclply.contract_app_key, vclply.PRODUCT_NONUNI) --132018 CHR-402
select a.deal_id,
       a.id_dfk,
       a.dfk,
       a.dealtype_id,
       a.ressyst_id,
       a.ressyst_name,
       a.recordtype_id,
       a.date_correnforce,
       a.oneday_corr,
       a.corr_status,
       nvl(a.slx_code,0),
       a.client_name,
       a.portfolio_nonuni_id,
       a.portfolio_name,
       a.clientuni_id,
       a.clientuni_name,
       a.clientgroup_id,
       a.clientgroup_name,
       a.portfoliouni_id,
       a.portfoliouni_name,
       a.client_type,
       a.intportfolio_deal,
       a.subdivisionuni_id,
       a.subdivisionuni_name,
       a.subdivision,
       a.salesman_id,
       a.salesman_name,
       a.busncateg_id,
       a.busncateg,
       a.product_nonuni,
       a.productuni_id,
       a.product_name,
       a.industry_id,
       a.industry_name,
       a.date_dealbegin,
       a.date_1tranche,
       a.date_2tranche,
       a.currency_titlenom,
       a.currency_2titlenom,
       a.fincomp_currency,
       a.dealcateg_id,
       a.dealcateguni_id,
       a.dealcateg,
       a.optiontype_id,
       a.optiontypeuni_id,
       a.option_type,
       a.securities_id,
       a.deal_exchrate,
       a.precmet_gram,
       a.precmet_gramattr,
       a.nondel_forwardattr,
       a.deal_intrate,
       a.deal_amtcurr1,
       a.deal_amtcurr2,
       a.exchrate_2,
       a.deal_amtcurr1leg2,
       a.deal_amtcurr2leg2,
       a.date_dealaccomp,
       a.deal_status,
       a.date_change,
       a.date_correction,
       a.date_recordchng,
       a.date_recvalidfrom,
       a.date_recvalidupto,
       a.flag_toreport,
       a.reporting_year,
       a.flag_tocorrect,
       a.flag_recchangaccnt,
       a.date_77,
       a.slxuni_id,
       a.salescredit_effdate,
       a.salescredit_corrdate,
       a.salescredit_curr,
       a.salescreditstrt_effdate,
       a.salescreditstrt_corrdate,
       a.salescreditstrt_curr,
       a.perc_earncost_effdate,
       a.perc_earncost_corrdate,
       a.perc_earncost_curr,
       a.tran_earncost_effdate,
       a.tran_earncost_corrdate,
       a.tran_earncurr,
       a.commissions_effdate,
       a.commissions_corrdate,
       a.commissions_curr,
       a.commissions_exp_effdate,
       a.commissions_exp_corrdate,
       a.commissions_exp_curr,
     --CASE WHEN a.PRODUCT_NONUNI = '80' THEN (-nvl(rplcy.reserv_bal_residval_effdate,0) + nvl(a.reserv_bal_residval_effdate,0) - nvl(plifrscorr.ifrs_corr_sum,0) + nvl(plcorr.corr_sum,0))*a.reserves_cva_effdate ELSE NULL END AS reserves_cva_effdate, /*24072018*/
    CASE WHEN a.PRODUCT_NONUNI = '80'
         THEN
             case when extract (year from p_report_dt) = 2018
                  then (nvl(a.reserv_bal_residval_effdate,0) - nvl(plifrscorr.ifrs_corr_sum,0) + nvl(plcorr.corr_sum,0))*a.exchange_rate_avg
                    else (-nvl(ay.reserv_bal_residval_effdate,0) + nvl(a.reserv_bal_residval_effdate,0))*a.exchange_rate_avg
                      end
    ELSE 0 END AS reserves_cva_effdate,
       a.reserves_cva_corrdate,
       a.reserves_curr,
       a.real_reval_effdate,
       a.real_reval_corrdate,
       a.real_reval_curr,
       a.nonreal_reval_curr_effdate,
       a.nonreal_reval_curr_corrdate,
       a.nonreal_reval_curr_curr,
       a.nonreal_reval_past_effdate,
       a.nonreal_reval_past_corrdate,
       a.nonreal_reval_past_curr,
       a.oci_deval_effdate,
       a.oci_deval_corrdate,
       a.oci_deval_curr,
       a.pl_deval_effdate,
       a.pl_deval_corrdate,
       a.pl_deval_curr,
       a.allocation_effdate,
       a.allocation_corrdate,
       a.allocation_curr,
     --CASE WHEN a.PRODUCT_NONUNI = '80' THEN nvl((dcntodt.fund_npl - (a.reserv_bal_residval_effdate * a.funding_rate * a.exchange_rate_avg)) * ((dcntodt.cc-1)/365),0) ELSE 0 END AS funding_npl_effdate, --27112018 CHR-402 26072018 was nvl(rpl.reserv_bal_residval_effdate*a.funding_rate*(1/365),0)
   0 AS funding_npl_effdate, --27112018
     a.funding_npl_corrdate,
     a.funding_npl_curr,
       a.bal_residval_effdate,
       a.bal_residval_corrdate,
     --CASE WHEN a.PRODUCT_NONUNI = '80' THEN (nvl(rplly.total_nil_ovd,0)/2 + nvl(savrb.averbal_residval,0) + nvl(rpl.total_nil_ovd,0) + nvl(a.averbal_residval_effdate,0)/2)/(p_REPORT_DT-trunc(p_REPORT_DT,'yy')) ELSE 0 END AS averbal_residval_effdate, --23072018
     --CASE WHEN a.PRODUCT_NONUNI = '80' THEN (nvl(rplly.total_nil_ovd,0)/2 + nvl(savrb.averbal_residval,0) + nvl(rpl.total_nil_ovd,0) + nvl(a.averbal_residval_effdate,0)/2)/dcntt.dayc ELSE 0 END AS averbal_residval_effdate, --20092018
     --CASE WHEN a.PRODUCT_NONUNI = '80' THEN /*dcntt.dayc*/ (dcntt.sm + a.TOTAL_NIL_OVD) / (dcntt.cc + 1) ELSE 0 END AS averbal_residval_effdate, --ov
     CASE WHEN a.PRODUCT_NONUNI = '80' THEN dcntodt.sm / dcntodt.cc ELSE 0 END AS averbal_residval_effdate, --13112018 CHR-420
       a.averbal_residval_corrdate,
       a.bal_residval_curr,
       a.overd_residval_effdate,
       a.overd_residval_corrdate,
       a.overd_residval_curr,
       a.offbal_item_effdate,
       a.offbal_item_corrdate,
       a.averoffbal_residval_effdate,
       a.averoffbal_residval_corrdate,
       a.offbal_item_curr,
       a.perc_bal_residval_effdate,
       a.perc_bal_residval_corrdate,
       a.perc_bal_residval_curr,
       CASE WHEN a.PRODUCT_NONUNI = '80' THEN dcntodt.smperc / dcntodt.cc ELSE 0 END AS perc_aver_acc_effdate, --13112018 CHR-402
     a.perc_aver_acc_corrdate,
     a.perc_aver_acc_curr,
       a.comm_bal_residval_effdate,
       a.comm_bal_residval_corrdate,
       a.comm_bal_residval_curr,
       a.reserv_bal_residval_effdate,
       a.reserv_bal_residval_corrdate,
       a.reserv_bal_residval_curr,
       a.actbal_nonreal_resval_effdate,
       a.actbal_nonreal_resval_corrdate,
       a.actbal_nonreal_resval_curr,
       a.pbal_nonreal_resval_effdate,
       a.psbal_nonreal_resval_corrdate,
       a.psbal_nonreal_resval_curr,
     a.opex_effdate,
       a.opex_corrdate,
       a.opex_curr,
       a.facility_num,
       a.date_facil_agrmnt,
       a.tenor,
       a.wal,
       a.wal0,
       a.effective_nim,
       a.running_nim,
       a.base_rate,
       a.total_disbursements_ltd,
       a.total_repaid_ltd,
       a.interrate_margin_floattype,
       a.funding_rate_floattype,
       a.npl_status,
       a.rating_internal,
       a.rating_external,
       a.rating_expert,
       a.pd,
       a.lgd,
       a.el,
       a.ead,
       a.rwa_weight,
       a.h1_weight,
       a.ifrs_basel_rwa,
       a.ras_rwa,
       a.sales_director,
       a.trading_director,
       a.structuring_director,
       a.coverage_director,
       a.committed_mark,
       a.number_of_restruct,
       a.restruct_rolled_refin,
       a.date_restruct_rolled_refin,
       a.initial_volume,
       a.funding_rate,
       a.tp_charge,
       a.date_tp_charge,
       a.risk_cost,
       a.commitment_volume,
       a.limit_mark,
       a.limit_ccy,
       a.collateral_type,
       a.collateral_amount,
       a.collateral_quality,
       a.col_amt_provis_ras,
       a.trading_result,
       a.llp,
       a.illp_pllp_classif,
       a.accrual_basis_mtm,
       a.bank_agent,
       a.id_fin_purp,
       a.fin_purp,
       a.cession,
       a.subordinated_loan,
       a.syndicated_loan,
       a.normal_problem_type,
       a.loan_type,
       a.repmnt_freq_basic_debt,
       a.repmnt_freq_perc,
       a.availability_period,
       a.comp_spread_early_repmnt,
       a.comp_spread_fix_rate,
       a.comments,
       a.account_number,
     CASE WHEN a.PRODUCT_NONUNI = '80' THEN nvl(a.total_nil_ovd,0)/* + nvl(rpl.total_nil_ovd,0)*/ ELSE 0 END AS total_nil_ovd, --03072018 SUMM (NIL+OVD) FOR THE CURRENT PERIOD FOR CALCULATION averbal_residval_effdate
     a.contract_key,
     a.contract_app_key,
       a.snapshot_dt,
       sysdate,
       0,
     a.rate_start_dt, --08112018 5972
     a.loans_nam, --08112018 5972
	 a.allocation_category --22012019 CHR-1088
  from DM.V$CL_PL a
  /*left join DM.DM_RPL rpl
    on rpl.snapshot_dt = case when p_report_dt = trunc(p_report_dt,'yy') then null else p_REPORT_DT - 1 end --EVERY NEW YEAR TOTAL NIL+OVD STARTING FROM FIRST 010120XX YEAR VALUE
  and rpl.contract_key = a.contract_key and rpl.contract_app_key = a.contract_app_key and rpl.PRODUCT_NONUNI = a.PRODUCT_NONUNI and a.PRODUCT_NONUNI = '80' --03072018 Added to view also
  left join DM.DM_RPL rplly
    on rplly.snapshot_dt = trunc(p_report_dt,'yy') - 1 --FOR PREVIOUS YEAR PARAMETERS
  and rplly.contract_key = a.contract_key and rplly.contract_app_key = a.contract_app_key and rplly.PRODUCT_NONUNI = a.PRODUCT_NONUNI and a.PRODUCT_NONUNI = '80'
  left join DM.DM_RPL rplcy
    on rplcy.snapshot_dt = trunc(p_report_dt,'yy') --FOR CURRENT YEAR PARAMETERS
  and rplcy.contract_key = a.contract_key and rplcy.contract_app_key = a.contract_app_key and rplcy.PRODUCT_NONUNI = a.PRODUCT_NONUNI and a.PRODUCT_NONUNI = '80'*/ --14112018 CHR-402 Commented all 3 dm's
  left join DM.V$CL_PL ay on ay.snapshot_dt = trunc(p_report_dt,'yy') - 1 --FOR CURRENT YEAR PARAMETERS
  and ay.contract_key = a.contract_key and ay.contract_app_key = a.contract_app_key and ay.PRODUCT_NONUNI = a.PRODUCT_NONUNI and a.PRODUCT_NONUNI = '80'
  left join (select plifrscorrs.contract_key, plifrscorrs.contract_app_key, sum(plifrscorrs.ifrs_corr_val) ifrs_corr_sum from dwh.cl_pl_ifrs_corr plifrscorrs --24072018 IFRS CORRECTIVES - ONLY FOR 2018 YEAR
  where trunc(plifrscorrs.start_dt,'yy')=to_date('01.01.2018','dd.mm.yyyy') group by plifrscorrs.contract_key, plifrscorrs.contract_app_key) plifrscorr
  on plifrscorr.contract_key = a.contract_key and plifrscorr.contract_app_key = a.contract_app_key and a.PRODUCT_NONUNI = '80'
  left join (select trunc(plcorrs.start_dt,'yy') act_year, plcorrs.contract_key, plcorrs.contract_app_key, sum(plcorrs.corr_val) corr_sum from dwh.cl_pl_corr plcorrs --24072018 CORRECTIVES - FOR YEAR
  group by plcorrs.contract_key, plcorrs.contract_app_key, trunc(plcorrs.start_dt,'yy')) plcorr
  on plcorr.act_year = trunc(p_report_dt,'yy') and plcorr.contract_key = a.contract_key and plcorr.contract_app_key = a.contract_app_key and a.PRODUCT_NONUNI = '80'
  /*left join dwh.stock_averbal_residval savrb on trunc(savrb.actual_dt,'yy') = trunc(p_report_dt,'yy') --23072017 IT's OLD FOR AVERBAL_RESIDVAL_EFFDATE
  and savrb.contract_key = a.contract_key and savrb.contract_app_key = a.contract_app_key and a.PRODUCT_NONUNI = '80'*/
  --left join dcnt dcntt on dcntt.contract_key = a.contract_key and dcntt.contract_app_key = a.contract_app_key and a.PRODUCT_NONUNI = dcntt.PRODUCT_NONUNI
  left join dcntod dcntodt on dcntodt.contract_key = a.contract_key and dcntodt.contract_app_key = a.contract_app_key and a.PRODUCT_NONUNI = '80' and a.PRODUCT_NONUNI = dcntodt.PRODUCT_NONUNI
where a.snapshot_dt = p_REPORT_DT;

   dm.u_log(p_proc => 'DM.p_DM_RPL',
           p_step => 'insert DM.p_DM_RPL',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');

      commit;

   dm.analyze_table(p_table_name => 'DM_RPL',p_schema => 'DM');

   dm.u_log(p_proc => 'DM.p_DM_RPL',
           p_step => 'analyze_table DM.DM_RPL',
           p_info => 'analyze_table done');
  etl.P_DM_LOG('DM_RPL');
END;
/

