CREATE OR REPLACE PROCEDURE DM.P_DM_RESERVES_REPORT(
p_REPORT_DT date
)
is

BEGIN

  /*
     Процедура расчета витрины RESERVES_STAGES_LOANS полностью.
     В качестве входного параметра подается дата составления отчета
  */
  dm.u_log(p_proc => 'DM.P_DM_RESERVES_REPORT',
           p_step => 'INPUT PARAMS',
           p_info => 'p_REPORT_DT: '||p_REPORT_DT);

 delete from RESERVES_STAGES_LOANS
 where snapshot_dt = p_REPORT_DT;

  dm.u_log(p_proc => 'DM.P_DM_RESERVES_REPORT',
           p_step => 'delete from RESERVES_STAGES_LOANS',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');

  commit;

INSERT /*+ APPEND */ INTO DM.RESERVES_STAGES_LOANS
select
c.stage,--Стадия на отч.дату
c.STAGE_PREV_MNTH,--Изменение стадии
c.snapshot_dt,-- отчетная дата
c.auto_flg,--определение источника данных автолизинг=1, корп=0
E.SCRIPT_NAME,--сценарий отчетной даты Пакет A / Пакет B / Тестовый / Loans_portfolio
sum(cryy.balance_amt) as ead_year_begin,--EAD на начало года, RUB
sum(crqq.balance_amt) as ead_quarter_begin,--EAD на начало квартала, RUB
sum(crmm.balance_amt) as ead_month_begin,--EAD на пред.мес.дату, RUB
sum(crtd.balance_amt) as ead_snapshot_dt,--EAD на отчетную дату (Для сценария "Loans_portfolio": ст."Балансовая стоимость без учёта резерва")???
sum(C.EAD_RUB) AS GBS_BEF_ALLWN,--10 Для сценариев Пакет A / Пакет B / Тестовый: Gross Balance Sheet before allowance, RUB" - берется для корпоратов
--Доля EAD на отч.дату - реализуется в OBIEE
--изм. EAD с начала года, RUB  - реализуется в OBIEE
---изм. EAD с начала квартала, - реализуется в OBIEE
--RUB  изм. EAD с начала месяца, RUB- реализуется в OBIEE
sum(cryy.provisions_amt) as res_year_begin,--Резерв на начало года, RUB
sum(crqq.provisions_amt) as res_quarter_begin,--Резерв на начало квартала, RUB
sum(crmm.provisions_amt) as res_month_begin,--Резерв на пред.мес.дату, RUB
sum(crtd.provisions_amt) as res_snapshot_dt,--Резерв на отч.дату, RUB --14
sum(c.res_rub) as res_snapshot_dt_prf ,--Резервы  Автолизинг на отчетную дату из проформы--15
sum(c.res_rub) as res_snapshort_dt_bal,--Балансовая стоимость без учёта резерва, RUB (для переключателя с EAD_RUB (см. выше)
sum(crtd.provis_add) as pl_year_begin,--PL-эффект изм.резервов с начала  года, RUB--17
sum(crtd.provis_add) - sum(crqq.provis_add) as pl_quarter_begin,--PL-эффект изм.резервов с начала  квартала, RUB
sum(crtd.provis_add) - sum(crmm.provis_add) as pl_month_begin,--PL-эффект изм.резервов с начала  месяца, RUB--19
d.contract_app_key as qty_year_begin,-- С прогнозным NIL на отчетную дату
f.contract_app_key as qty_qrtr_begin,-- для LOANS_Portfolio
g.contract_app_key as qty_mnth_begin,
sum(c.contract_app_key) as qty_year_begin_prf,
sum(c.contract_app_key) as qty_qrtr_begin_prf,--колонки с кол-вом приложений из проформы ( три колонки)
sum(c.contract_app_key) as qty_mnth_begin_prf,
c.vtbl_flg as vtbl_flg,
c.comp_nam as comp_nam,
c.flg_vtb_group as flg_vtb_group,
c.short_nam as short_nam
from
DM.DM_PROFORM_Allowance_CORP c
LEFT JOIN DWH.RISK_IFRS_CGP crtd on crtd.contract_app_key = c.contract_app_key and c.snapshot_dt= crtd.snapshot_dt
LEFT JOIN DWH.RISK_IFRS_CGP cryy on cryy.contract_app_key = c.contract_app_key and trunc(c.snapshot_dt,'yyyy')= cryy.snapshot_dt
LEFT JOIN DWH.RISK_IFRS_CGP crqq on crqq.contract_app_key = c.contract_app_key and trunc(c.snapshot_dt,'q')= crqq.snapshot_dt
LEFT JOIN DWH.RISK_IFRS_CGP crmm on crmm.contract_app_key = c.contract_app_key and trunc(c.snapshot_dt,'mm')= crmm.snapshot_dt
LEFT JOIN (select count(distinct contract_app_key) as contract_app_key from DM.IFRS_BASE_TABLE
where snapshot_dt > to_date(trunc(snapshot_dt,'year'), 'dd.mm.yyyy')and balance_amt is not null ) d  ON d.contract_app_key = c.contract_app_key
LEFT JOIN (select count(distinct contract_app_key) as contract_app_key from DM.IFRS_BASE_TABLE
where snapshot_dt > to_date(trunc(snapshot_dt,'q'), 'dd.mm.yyyy')and balance_amt is not null) g  ON    g.contract_app_key = c.contract_app_key
LEFT JOIN (select count(distinct contract_app_key) as contract_app_key from DM.IFRS_BASE_TABLE
where snapshot_dt > to_date(trunc(snapshot_dt,'mm'), 'dd.mm.yyyy')and balance_amt is not null) f  ON    f.contract_app_key = c.contract_app_key
left join DWH.ifrs_load_script E ON C.SCRIPT_CD = E.SCRIPT_CD
group by c.stage,c.STAGE_PREV_MNTH,c.snapshot_dt,c.auto_flg,E.SCRIPT_NAME,d.contract_app_key
,f.contract_app_key, g.contract_app_key,c.vtbl_flg,
c.comp_nam,
c.flg_vtb_group,
c.short_nam
UNION ALL
--для автолизинга
select
a.stage,
a.STAGE_PREV_MNTH,
a.snapshot_dt,
a.auto_flg,
E.SCRIPT_NAME,
sum(aryy.balance_amt) as ead_year_begin,
sum(arqq.balance_amt) as ead_quarter_begin,
sum(armm.balance_amt) as ead_month_begin,
sum(artd.balance_amt) as ead_snapshot_dt,--Для сценария "Loans_portfolio": ст."Балансовая стоимость без учёта резерва"
sum(A.EAD_RUB) AS GBS_BEF_ALLWN,--Для сценариев Пакет A / Пакет B / Тестовый: Gross Balance Sheet before allowance, RUB"--10
sum(aryy.provisions_amt) as res_year_begin,
sum(arqq.provisions_amt) as res_quarter_begin,
sum(armm.provisions_amt) as res_month_begin,
sum(artd.provisions_amt) as res_snapshot_dt,--14
sum(a.res_rub) as res_snapshot_dt_prf ,--Резервы  Автолизинг на отчетную дату из проформы--15
sum(a.res_rub) as res_snapshort_dt_bal,--Балансовая стоимость без учёта резерва, RUB (для переключателя с EAD_RUB (см. выше)
sum(artd.provis_add) as pl_year_begin,--17
sum(artd.provis_add) - sum(arqq.provis_add) as pl_quarter_begin,
sum(artd.provis_add) - sum(armm.provis_add) as pl_month_begin,
d.contract_app_key as qty_year_begin,-- С прогнозным NIL на отчетную дату
f.contract_app_key as qty_qrtr_begin,-- для LOANS_Portfolio
g.contract_app_key as qty_mnth_begin,
sum(a.contract_app_key) as qty_year_begin_prf,
sum(a.contract_app_key) as qty_qrtr_begin_prf,--колонки с кол-вом приложений из проформы ( три колонки)
sum(a.contract_app_key) as qty_mnth_begin_prf,
a.vtbl_flg as vtbl_flg,
a.comp_nam as comp_nam,
a.flg_vtb_group as flg_vtb_group,
a.short_nam as short_nam
from
DM.DM_PROFORM_Allowance_AUTO a
LEFT JOIN DWH.RISK_IFRS_CGP artd on artd.contract_app_key = a.contract_app_key and a.snapshot_dt= artd.snapshot_dt
LEFT JOIN DWH.RISK_IFRS_CGP aryy on aryy.contract_app_key = a.contract_app_key and trunc(a.snapshot_dt,'yyyy')= aryy.snapshot_dt
LEFT JOIN DWH.RISK_IFRS_CGP arqq on arqq.contract_app_key = a.contract_app_key and trunc(a.snapshot_dt,'q')= arqq.snapshot_dt
LEFT JOIN DWH.RISK_IFRS_CGP armm on armm.contract_app_key = a.contract_app_key and trunc(a.snapshot_dt,'mm')= armm.snapshot_dt
LEFT JOIN (select count(distinct contract_app_key) as contract_app_key from DM.IFRS_BASE_TABLE
where snapshot_dt > to_date(trunc(snapshot_dt,'YEAR'),'dd.mm.yyyy')and balance_amt is not null ) d  ON d.contract_app_key = a.contract_app_key
LEFT JOIN (select count(distinct contract_app_key) as contract_app_key from DM.IFRS_BASE_TABLE
where snapshot_dt > to_date(trunc(snapshot_dt,'q'), 'dd.mm.yyyy')and balance_amt is not null) g  ON    g.contract_app_key = a.contract_app_key
LEFT JOIN (select count(distinct contract_app_key) as contract_app_key from DM.IFRS_BASE_TABLE
where snapshot_dt > to_date(trunc(snapshot_dt,'mm'), 'dd.mm.yyyy')and balance_amt is not null) f  ON    f.contract_app_key = a.contract_app_key
LEFT JOIN dwh.ifrs_load_script E ON    A.SCRIPT_CD = E.SCRIPT_CD
group by a.stage,a.STAGE_PREV_MNTH,a.snapshot_dt,a.auto_flg,E.SCRIPT_NAME,d.contract_app_key
,f.contract_app_key, g.contract_app_key,a.vtbl_flg,a.comp_nam,a.flg_vtb_group,
a.short_nam
;

  dm.u_log(p_proc => 'DM.P_DM_RESERVES_REPORT',
           p_step => 'insert DM.RESERVES_STAGES_LOANS',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');

      commit;

   dm.analyze_table(p_table_name => 'RESERVES_STAGES_LOANS',p_schema => 'DM');

   dm.u_log(p_proc => 'DM.P_DM_RESERVES_REPORT',
           p_step => 'analyze_table DM.RESERVES_STAGES_LOANS',
           p_info => 'analyze_table done');
  etl.P_DM_LOG('RESERVES_STAGES_LOANS');
END;
/

