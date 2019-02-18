CREATE OR REPLACE PROCEDURE DM."P_DM_VINTAGE" (p_report_dt date)
as
begin
    delete from DM_VINTAGE
    where REPORT_DT = p_report_dt+1;

/*в витрине отражены договоры автолизинга. 
Если по договору был перенайм, то отражается key последнего, действующего договора. 
При этом, показатели сохраняются в рамках ID сделки (всех договоров перенайма). Например, если рассчитываем максимальную просрочку, то выбираем просрочку среди всех договоров в рамках одного id сделки*/


insert into DM_VINTAGE_tmp
(report_dt, snapshot_dt, contract_key, term_amt,
term_amt_tax, overdue_amt, overdue_amt_tax, term_amt_risk, 
overdue_dt, overdue_cnt, max_overdue_cnt, region, act_dt, 
lease_month, transmit_subject_nam, advance_pay_dt, advance_rub, 
cost_rub, finance_amt, status_1c_desc, contract_status_key, 
subject_status_key, state_status_key, age, confiscate_flg, insure_flg, insert_dt)
with contr as
  (select c.contract_key,
    c.close_dt,
    c.oper_start_dt,
    c.rehiring_flg,
    c.contract_id_cd
  from dwh.leasing_contracts lc
  join dwh.contracts c
  on c.contract_key    = lc.contract_key
  and c.valid_to_dttm  = to_date ('01.01.2400', 'DD.MM.YYYY')
  and lc.valid_to_dttm = to_date ('01.01.2400', 'DD.MM.YYYY')
  and lc.auto_flg      = 1
  )
select 
  cgp.report_dt,
  cgp.snapshot_dt,
  cgp.contract_key,
  cgp.term_amt,
  cgp.term_amt_tax,
  cgpd.overdue_amt,
  cgp.overdue_amt_tax,
  cgp.term_amt_risk,
  cgpd.overdue_dt,
  cgpd.overdue_CNT,
  cgpd.max_overdue_cnt,
  tr.region,
  tr.act_dt,
  tr.lease_month,--месяц передачи в лизинг (поколение)
  tr.transmit_subject_nam,
  tr.pay_dt advance_pay_dt,
  tr.advance_rub,
  tr.cost_rub,
  tr.finance_amt,
  ws.status_1c_desc,
  ws.contract_status_key,
  ws.subject_status_key,
  ws.state_status_key,
  months_between(cgp.snapshot_dt ,add_months(tr.lease_month,1)) as age, --возраст ПЛ,
  case when conf.confiscate_dt is not null then 1 else 0 end as confiscate_flg,--признак изъятия
  case when ins.event_dt is not null then 1 else 0 end as insure_flg,--признак изъятия
  sysdate
from

  --данные по задолжности КГП договоров автолизинга. dwhro.v_uakr_cgp содержит все договоры (простые и перенайма)
(select * from   (
  select 
  to_char(p_report_dt + 1) as report_dt,--отчетная дата, 1 число месяца
    snapshot_dt,
    contract_key,
    term_amt,
    term_amt_tax,
    term_amt_risk,
    term_amt_tax_risk,
    overdue_amt,
    overdue_amt_tax,
    overdue_dt,
    (snapshot_dt+1-overdue_dt)  as overdue_cnt, --количество дней просрочки, текущее в отчетном периоде
    max (case when snapshot_dt<=p_report_dt then (snapshot_dt+1-overdue_dt)end) OVER (PARTITION BY contract_key)  max_overdue_cnt--максимальное количество дней просрочки по договору
  from ( SELECT b.snapshot_dt AS snapshot_dt,
          b.contract_key,
          b.xirr_rate,                           --ставка доходности по сделке
          b.overdue_dt,        --дата возникновения просроченной задолженности
          b.term_amt,       -- Задолженность по NIL без НДС, c учетом списаний
          b.term_amt_tax,      --Задолженность по NIL с НДС, c учетом списаний
          b.overdue_amt,       --Просроченная задолженность, c НДС, на 1 число
          b.overdue_amt_tax, --Просроченная задолженность, без НДС, на 1 число
          CASE
             WHEN NOT (    b.status_desc = 'Расторгнут'
                       AND b.term_amt = 0)
             THEN
                b.term_amt
             ELSE
                FIRST_VALUE (b.term_amt)
                   OVER (PARTITION BY sm_gr ORDER BY snapshot_dt ASC)
          END
             term_amt_risk, -- Задолженность по NIL без НДС, ,без учета списаний
          CASE
             WHEN NOT (    b.status_desc = 'Расторгнут'
                       AND b.term_amt = 0)
             THEN
                b.term_amt_tax
             ELSE
                FIRST_VALUE (b.term_amt_tax)
                   OVER (PARTITION BY sm_gr ORDER BY snapshot_dt ASC)
          END
             term_amt_tax_risk -- Задолженность по NIL без НДС, ,без учета списаний
     FROM (SELECT a.*,
                  SUM (
                     gr)
                  OVER (PARTITION BY contract_key
                        ORDER BY snapshot_dt
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) sm_gr
                  ,count(distinct contract_key) over (PARTITION BY contract_id_cd) cnt
                  ,row_number() over (PARTITION BY contract_id_cd,snapshot_dt order by decode(REHIRING_FLG, null, 99, 0 , 99,1,1) asc, OPEN_DT desc ) rn                              
             FROM (SELECT a.snapshot_dt,
                          contr_ces.contract_key,
                          a.overdue_dt AS overdue_dt,
                          a.xirr_rate,
                          a.term_amt,
                          ROUND (a.term_amt * (1 + v.vat_rate), 2)
                             AS term_amt_tax,
                          ROUND (
                             a.overdue_amt * (100 / (100 + v.vat_rate * 100)),
                             2)
                             AS overdue_amt,
                          a.overdue_amt AS overdue_amt_tax,
                          cs.status_desc,
                          CASE
                             WHEN     cs.status_desc = 'Расторгнут'
                                  AND a.term_amt = 0
                             THEN
                                0
                             ELSE
                                1
                          END
                             gr,
                          contr_ces.OPEN_DT,
                          contr_ces.REHIRING_FLG, 
                          contr_ces.contract_id_cd 
                     FROM dwh.contracts contr_main
                          INNER JOIN dwh.leasing_contracts lc
                             ON     lc.contract_key = contr_main.contract_key
                                AND lc.valid_to_dttm =
                                       TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                          INNER JOIN dm.dm_cgp a
                             ON lc.contract_key = a.contract_key
                          LEFT JOIN dwh.contracts contr_ces
                             ON     contr_main.contract_id_cd =
                                       contr_ces.contract_id_cd
                                AND contr_ces.valid_to_dttm =
                                       TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                          LEFT JOIN
                          (SELECT contract_key,
                                  status_dt start_status_dt,
                                  NVL (
                                     LEAD (
                                        status_dt)
                                     OVER (PARTITION BY contract_key
                                           ORDER BY status_dt),
                                     TO_DATE ('31.12.3999', 'dd.mm.yyyy'))
                                     end_status_dt,
                                  status_desc
                             FROM dwh.fact_leasing_contracts_status
                            WHERE valid_to_dttm =
                                     TO_DATE ('01.01.2400', 'DD.MM.YYYY')) cs
                             ON     a.contract_key = cs.contract_key
                                AND a.snapshot_dt >= cs.start_status_dt
                                AND a.snapshot_dt < cs.end_status_dt
                          INNER JOIN dwh.vat v
                             ON     a.branch_key = v.branch_key
                                AND v.valid_to_dttm =
                                       TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                                AND v.begin_dt <= a.snapshot_dt
                                AND v.end_dt >= a.snapshot_dt
                    WHERE     contr_main.valid_to_dttm =
                                 TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                          AND lc.auto_flg = 1
                          AND snapshot_dt=p_report_dt
                          AND a.snapshot_cd = 'Основной КИС'
                          --and nvl (contr_ces.rehiring_flg, 0)!= 1
                          AND NVL (contr_ces.exclude_cgp, 0) != 1) a
                          ) b
where cnt = 1 or (cnt > 1 and rn = 1))
 -- where contract_key in (28241)
  ) 
   ) cgp
  --акты передачи в лизинг
left join
  --по договору выбирается минимальная дата акта передачи (т.е. первая передача ПЛ в лизинг. Если по договору был перенайм, то нужно брать дату первой передачи (по первому договору)
  (
  select contract_key,
  act_dt,
  lease_month,
  leasing_subject_key,
  leasing_deal_key,
  region,
    transmit_subject_nam,
    pay_dt,
    advance,
    advance_currency,
    advance_rub,
    advance_exchange_rate,
    cost_amt,
    cost_currency,
    cost_rub,
    cost_exchange_rate,
    finance_amt  -- "Сумма финансирования, первоначальная",
  from dwhro.v_uakr_transmit_subjects
  ) tr
on cgp.contract_key=tr.contract_key

left join 
(select t.snapshot_dt, t.contract_key, t.overdue_dt, t.overdue_amt, t.snapshot_dt+1-t.overdue_dt as overdue_cnt,
max (t.snapshot_dt+1-t.overdue_dt) OVER (PARTITION BY t.contract_key) as max_overdue_cnt
from dm.dm_cgp_daily t) cgpd 
on cgpd.contract_key=cgp.contract_key
and cgpd.snapshot_dt=cgp.snapshot_dt


left join
--статусы 1С и рабочие статусы
dm.dm_work_statuses ws
on cgp.contract_key=ws.contract_key
and cgp.snapshot_dt=ws.report_dt

--изъятия на отчетную дату. Если есть дата изъятия, то в отчете признак изъятия=1
left join
DWH.fact_confiscations conf
on cgp.contract_key=conf.contract_key
and valid_to_dttm =to_date('01.01.2400','DD.MM.YYYY')
and confiscate_dt<=p_report_dt
and lower(confiscate_flg)='да'

--признак страхового случая на отчетную дату. Если есть дата страхового случая, то в отчете признак =1
left join
(select contract_key, max(event_dt) as event_dt from
dwh.fact_insurance_events 
where valid_to_dttm =to_date('01.01.2400','DD.MM.YYYY')
and event_dt<=p_report_dt
and delete_flg=0
group by contract_key) ins
on cgp.contract_key=ins.contract_key;

commit;

end;
/

