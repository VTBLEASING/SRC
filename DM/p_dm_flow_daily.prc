CREATE OR REPLACE PROCEDURE DM."P_DM_FLOW_DAILY" (
    p_REPORT_DT in date
)

is

BEGIN

/*
    Процедура загрузки витрины DM_FLOW_DAYLY

*/
 delete from DM_FLOW_DAILY
 where REPORT_DT = p_REPORT_DT;


insert into  DM_FLOW_DAILY(
SNAPSHOT_DT,
REPORT_DT,
CONTRACT_KEY,
CBC_DESC,
PAYMENT_ITEM_NAM,
PLAN_PAY_DT,
PLAN_PAY_DT_ORIG,
FACT_PAY_DT_ORIG,
CURRENCY_KEY,
PLAN_AMT,
FACT_AMT,
PAY_AMT,
OVERDUE_AMT_DAILY,
PEN_DAYS,
PENALTY_AMT,
OVERDUE_DAYS_ORIG,
OVERDUE_PAYMENT,
OVERDUE_PAYMENT_TOTAL,
CUR_CONTRACT_FIN_AMT,
CUR_FIN_AMT,
INSERT_DT
)
with hol AS
  (SELECT calendar_dt
  FROM dwh.production_calendars
  WHERE date_type != 'Рабочий'
  AND valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')
  ),
  wrk AS
  (SELECT calendar_dt
  FROM dwh.production_calendars
  WHERE date_type  = 'Рабочий'
  AND valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')
  ),
  days AS
  (SELECT a.calendar_dt AS hol_dt,
    MIN(b.calendar_dt)  AS wrk_dt
  FROM hol a,
    wrk b
  WHERE a.calendar_dt    < b.calendar_dt
  AND a.calendar_dt + 30 > b.calendar_dt
  GROUP BY a.calendar_dt
  ),
  pen AS
  (SELECT contract_key,
    penalty_rate
  FROM dwh.leasing_contracts
  WHERE valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
  AND auto_flg        =1
  -------------------------------------------------------------------------------- 
--and 1=0
  ),
  details AS
  (SELECT a.contract_key,
    cbc_desc,
    p.payment_item_nam,
    payment_num,
    plan_pay_dt,
    pay_dt,
    pay_dt_orig,
    currency_key,
    ABS(plan_pay_amt) AS plan_amt,
    case 
        when pay_amt > 0 
        and fact_pay_amt <> 0
            then -fact_pay_amt
        else ABS(fact_pay_amt) end AS fact_amt,
    pay_amt,
    overdue_amt,
    CASE
      WHEN overdue_amt > 0
      AND overdue_days >= 0
      THEN overdue_days
      WHEN overdue_amt   > 0
      AND (overdue_days IS NULL
      OR overdue_days   <= 0)
      THEN p_REPORT_DT - pay_dt
      ELSE NULL
    END pen_days,
    /*CASE
    WHEN overdue_amt > 0 and overdue_days_orig > 0
    THEN overdue_days_orig
    WHEN overdue_amt > 0 and (overdue_days_orig is null or overdue_days_orig <= 0)
    THEN to_date('15.04.2015', 'dd.mm.yyyy') - pay_dt_orig
    ELSE NULL
    END pen_days_orig,*/
    CASE
      WHEN overdue_amt > 0
      AND p.code1c_cd  ='00238'
      THEN b.penalty_rate * overdue_amt * (
        CASE
          WHEN overdue_days < 0
          OR overdue_days   IS NULL
          THEN p_REPORT_DT - pay_dt
          ELSE overdue_days
        END)            / 100
      WHEN p.code1c_cd IN ('00007','00209','00219')
      THEN fact_pay_amt
      ELSE 0
    END AS penalty_amt ,
    MAX(
    CASE
      WHEN ABS(plan_pay_amt)<>0
      THEN pay_dt_orig
      ELSE NULL
    END) over (partition BY a.contract_key, cbc_desc, payment_item_nam, plan_pay_dt, currency_key ) plan_pay_dt_orig ,
    MIN(
    CASE
      WHEN ABS(fact_pay_amt)<>0
      THEN pay_dt_orig
      ELSE NULL
    END) over (partition BY a.contract_key, cbc_desc, payment_item_nam, plan_pay_dt, currency_key ) fact_pay_dt_orig
  FROM
    (SELECT contract_key,
      cbc_desc,
      pay_dt_orig,
      pay_dt,
      plan_pay_dt,
      currency_key,
      plan_pay_amt,
      fact_pay_amt,
      pay_amt,
      payment_item_key,
      dense_rank () OVER (partition by contract_key, cbc_desc, currency_key, payment_item_key order by plan_pay_dt) payment_num,
      SUM(pay_amt) over (partition BY contract_key, cbc_desc, currency_key, payment_item_key, plan_pay_dt order by plan_pay_dt, pay_dt_orig rows BETWEEN unbounded PRECEDING AND CURRENT row)                           AS overdue_amt,
      ROUND(NVL(lead(pay_dt) over (partition BY contract_key, cbc_desc, currency_key, payment_item_key, plan_pay_dt order by plan_pay_dt asc, pay_dt_orig asc, plan_pay_amt asc), p_REPORT_DT) - pay_dt) AS overdue_days
      --,ROUND(NVL(lead(pay_dt_orig) over (partition BY contract_key, cbc_desc, currency_key, payment_item_key, plan_pay_dt order by plan_pay_dt, pay_dt_orig), to_date('15.04.2015', 'dd.mm.yyyy')) - pay_dt_orig) AS overdue_days_orig
    FROM
      (SELECT contract_key,
        cbc_desc,
        pay_dt_orig,
        pay_dt,
        plan_pay_dt,
        currency_key,
        payment_item_key,
        SUM(plan_pay_amt)                AS plan_pay_amt,
        SUM(fact_pay_amt)                AS fact_pay_amt,
        SUM(plan_pay_amt + fact_pay_amt) AS pay_amt
      FROM
        (SELECT contract_key,
          cbc_desc,
          pay_dt                   AS pay_dt_orig,
          NVL(days.wrk_dt, pay_dt) AS pay_dt,
          NVL(days.wrk_dt, pay_dt) AS plan_pay_dt,
          pay_amt*er1.exchange_rate plan_pay_amt,
          0 AS fact_pay_amt,
          p.currency_key,
          payment_item_key
        FROM dwh.fact_plan_payments p
        LEFT JOIN days
        ON p.pay_dt =days.hol_dt
        LEFT JOIN dwh.exchange_rates er1
        ON p.currency_key          =er1.currency_key
        AND er1.valid_to_dttm      =to_date('01.01.2400','DD.MM.YYYY')
        AND er1.ex_rate_dt         =p.pay_dt
        AND er1.base_currency_key IN
          (SELECT currency_key
          FROM dwh.currencies
          WHERE valid_to_dttm     =to_date('01.01.2400','dd.mm.yyyy')
          AND begin_dt           <=p.pay_dt
          AND end_dt              >p.pay_dt
          AND currency_letter_cd IN ('RUB')
          )
        WHERE 
         p.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
        --AND begin_dt      <=  p_REPORT_DT
        --AND end_dt  =  p_REPORT_DT
        AND end_dt  =  to_date('31.12.3999','DD.MM.YYYY')
        AND pay_dt <= p_REPORT_DT
        --AND contract_key  = 5336
        UNION ALL
        SELECT contract_key,
          cbc_desc,
          pay_dt AS pay_dt_orig,
          pay_dt,
          NVL(days.wrk_dt, plan_pay_dt) AS plan_pay_dt,
          0                             AS plan_pay_amt,
          -pay_amt*er2.exchange_rate    AS fact_pay_amt,
          f.currency_key,
          payment_item_key
        FROM dwh.fact_real_payments f
        LEFT JOIN days
        ON f.plan_pay_dt =days.hol_dt
        LEFT JOIN dwh.exchange_rates er2
        ON f.currency_key          =er2.currency_key
        AND er2.valid_to_dttm      =to_date('01.01.2400','DD.MM.YYYY')
        AND er2.ex_rate_dt         =f.pay_dt
        AND er2.base_currency_key IN
          (SELECT currency_key
          FROM dwh.currencies
          WHERE valid_to_dttm     =to_date('01.01.2400','dd.mm.yyyy')
          AND begin_dt           <=f.pay_dt
          AND end_dt              >f.pay_dt
          AND currency_letter_cd IN ('RUB')
          )
        WHERE 
         f.pay_dt        <= p_REPORT_DT
        AND f.valid_to_dttm  = to_date('01.01.2400', 'dd.mm.yyyy')
        
        )
      GROUP BY contract_key,
        cbc_desc,
        pay_dt_orig,
        pay_dt,
        plan_pay_dt,
        currency_key,
        payment_item_key
      )
    ORDER BY cbc_desc,
      plan_pay_dt,
      pay_dt
    ) a,
    pen b ,
    DWH.payment_items p
  WHERE a.contract_key  = b.contract_key
  AND a.payment_item_key=p.payment_item_key
  ),
final_data as
(  
SELECT 
d.contract_key,
  cbc_desc,
  payment_item_nam,
  plan_pay_dt,
  payment_num,
  plan_pay_dt_orig AS plan_pay_dt_orig,
  (
  CASE
    WHEN fact_amt<>0
    THEN pay_dt_orig
    ELSE fact_pay_dt_orig
  END) AS fact_pay_dt_orig,
  
  currency_key,
  plan_amt,
  fact_amt,
  pay_amt,
CASE
    WHEN overdue_amt<0
    THEN 0
    ELSE overdue_amt
  END AS overdue_amt,
  pen_days,
  penalty_amt,

  CASE
    WHEN overdue_amt > 0
    THEN ROUND(NVL(lead((CASE   WHEN fact_amt<>0
        THEN pay_dt_orig
        ELSE fact_pay_dt_orig
      END)) over (partition BY d.contract_key, cbc_desc, currency_key, payment_item_nam, plan_pay_dt order by plan_pay_dt, pay_dt_orig),p_REPORT_DT) - plan_pay_dt_orig)
  END AS overdue_days_orig,
  sum(plan_amt-fact_amt) over (partition BY d.contract_key, cbc_desc, payment_item_nam, plan_pay_dt order by plan_pay_dt,(CASE   WHEN fact_amt<>0
        THEN pay_dt_orig
        ELSE fact_pay_dt_orig
      END)) overdue_payment,
  sum(plan_amt-fact_amt) over (partition BY d.contract_key, cbc_desc, payment_item_nam, plan_pay_dt order by plan_pay_dt) overdue_payment_total,
--Совокупная сумма финансирования по договору со стороны ВТБЛ, руб., текущая
case when cbc_desc in (select cbc_desc from dwh.cls_cbc_type_calc where type_calc='Leasing' and begin_dt<=p_REPORT_DT and end_dt>p_REPORT_DT ) then
sum (plan_amt-fact_amt) over (partition BY d.contract_key ) end as cur_contract_fin_amt,
--Совокупная сумма финансирования со стороны ВТБЛ, руб., текущая
case when cbc_desc in (select cbc_desc from dwh.cls_cbc_type_calc where type_calc='Leasing' and begin_dt<=p_REPORT_DT and end_dt>p_REPORT_DT ) then
sum (plan_amt-fact_amt) over (partition BY crm_cl.crm_client_key, crm_cl.account_group_key) end as CUR_FIN_AMT
FROM details D
LEFT JOIN dwh.v_mapping_contracts v
    ON D.contract_key = v.contract_key
 LEFT JOIN DWH.crm_clients crm_cl
    ON v.crm_client_key     =crm_cl.crm_client_key
    AND crm_cl.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')
)
select
TRUNC (p_REPORT_DT,'MM')-1 AS SNAPSHOT_DT,--месяц расчета. Добавлен, чтобы в отчетах соединяться с v_uakr_cgp
p_REPORT_DT REPORT_DT,    
fd.contract_key,
fd.cbc_desc,
fd.payment_item_nam,
fd.plan_pay_dt,
fd.plan_pay_dt_orig,
fd.fact_pay_dt_orig,
fd.currency_key,
fd.plan_amt,
fd.fact_amt,
fd.pay_amt,
fd.overdue_amt,
fd.pen_days,
fd.penalty_amt,
fd.overdue_days_orig,
fd.overdue_payment,
fd.overdue_payment_total,
max(cur_contract_fin_amt) over (partition by  fd.contract_key) cur_contract_fin_amt,
max(cur_fin_amt) over (partition by  fd.contract_key) cur_fin_amt,
sysdate
from final_data fd
;    
  
commit;

end;
/

