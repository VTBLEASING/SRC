CREATE OR REPLACE FORCE VIEW DM.V$DM_OL_METRIC AS
with tt as
(
        SELECT
        og.l_key CONTRACT_KEY,
        og.snapshot_cd,
        og.snapshot_dt,
        og.CUR1,
--        og.branch_key,
        sum(case when tp = 'OL_PLAN' then pay_amt_cur end ) LEASING_PLAN_PAY_AMT,
        sum(case when tp = 'OL_FACT' AND pay_dt <= og.snapshot_dt then pay_amt_cur end ) LEASING_FACT_PAY_AMT,
        sum(case when tp = 'OL_PLAN' AND pay_dt <= og.snapshot_dt then pay_amt_cur end ) DT_LEASING_PLAN_PAY_AMT,
        sum(case when tp = 'Supply_plan'  then pay_amt_cur end ) SUPPLY_PLAN_PAY_AMT,
        sum(case when tp = 'Supply_plan'  then pay_amt end ) SUPPLY_PLAN_pay_amt_orig,
        sum(case when tp = 'Supply_plan'  then pay_amt * rt1_SUPPLY_PLAN_RUR.EXCHANGE_RATE end ) SUPPLY_PLAN_RUR_PAY_AMT_RUR,
        sum(case when tp = 'Supply_plan'  then pay_amt end ) SUPPLY_PLAN_RUR_PAY_AMT_ORIG,
        sum(case when tp = 'Supply_fact' AND pay_dt <= og.snapshot_dt then pay_amt_cur end ) SUPPLY_FACT_PAY_AMT,
        sum(case when tp = 'Supply_plan' AND pay_dt <= og.snapshot_dt then pay_amt_cur end ) DT_SUPPLY_PLAN_PAY_AMT,
        min(og.oper_start_dt) oper_start_dt
   FROM dm.dm_ol_flow_orig og
        LEFT JOIN dwh.EXCHANGE_RATES  rt1_SUPPLY_PLAN_RUR -- привязка к курсам валют по равенству даты курса  дате платежа и по валюте факта/плана
           ON     rt1_SUPPLY_PLAN_RUR.ex_rate_dt = og.snapshot_dt
              AND og.CUR2 = rt1_SUPPLY_PLAN_RUR.CURRENCY_KEY
              AND rt1_SUPPLY_PLAN_RUR.BASE_CURRENCY_KEY = 125
              AND rt1_SUPPLY_PLAN_RUR.valid_to_dttm =
                     TO_DATE ('01.01.2400', 'dd.mm.yyyy')
   WHERE tp <> 'TEH'
group by      og.l_key ,
        og.snapshot_cd,
        og.snapshot_dt,
        og.CUR1
)
select
  CONTR.CONTRACT_KEY,
  CO.BRANCH_KEY,
  CO.CURRENCY_KEY,
  CO.CURRENCY_KEY CURRENCY_KEY_SUPPLY,
--  cgp.insert_dt,
  CONTR.snapshot_dt,
  CONTR.snapshot_cd,
 -- CONTR.SNAPSHOT_DT + 1 AS REP_DT,
  sysdate insert_dt,
  cl.activity_type_key activity_type_key,
  cl.business_category_key,
  cl.client_key,
  cl.Credit_Rating_Key,
  cl.grf_group_key,
  CL.GROUP_KEY,
  CL.MEMBER_KEY,
  cred_rat.agency_key rating_agency_key,
  trunc(CO.CLOSE_DT, 'MM') CLOSE_DT_MONTH,
  trunc(CO.CLOSE_DT, 'YY') CLOSE_DT_YEAR,
  --SUPPLY_RUR_AMT.OPER_START_DT
  --Case when co.BRANCH_CD <> 'VTB_LEASING' then co.OPER_START_DT else sysdate end OPER_START_DT
 -- ,(select min(lst.act_dt) from dwh.leasing_subject_transmit lst where lst.valid_to_dttm=date'2400-01-01'
  --and lst.contract_app_key=lca.contract_app_key)
  case when co.branch_key=1  and glst.OPER_START_DT is not null then glst.OPER_START_DT else co.oper_start_dt end OPER_START_DT,

--  CO.CONTRACT_NUM,
--  CO.OPEN_DT START_DT,
--  CO.CLOSE_DT END_DT,


 -- cur.exchange_rate,
 --- vat.vat_rate,
 -- co.contract_vat_rate vat_rate, -- STUB


  --co.float_rate_type_key RATE_KEY,

  NVL (CONTR.LEASING_PLAN_pay_amt, 0) L_PLAN,
  NVL (CONTR.LEASING_FACT_pay_amt, 0) L_FACT,
 -- NVL (CONTR.DT_LEASING_PLAN_pay_amt, 0) DT_L_PLAN,
  (CASE
      WHEN NVL (CONTR.LEASING_PLAN_pay_amt, 0) = 0 THEN 0
      ELSE NVL (CONTR.SUPPLY_PLAN_pay_amt / CONTR.LEASING_PLAN_pay_amt, 0) * -1
   END)
     K1,
  --     nvl(SUPPLY_PLAN.pay_amt/LEASING_PLAN.pay_amt,0)*-1 K1,
  NVL (CONTR.SUPPLY_PLAN_pay_amt, 0) * -1 S_PLAN,
  NVL (CONTR.SUPPLY_FACT_pay_amt, 0) * -1 S_FACT,
  NVL (CONTR.SUPPLY_PLAN_RUR_pay_amt_rur, 0) * -1 S_PLAN_RUR,
  SUPPLY_RUR_AMT.SUPPLY_RUR_AMT_S_AMT_F,
  SUPPLY_RUR_AMT.SUPPLY_RUR_AMT_S_AMT_F_R,
  (CASE
      WHEN (CONTR.LEASING_PLAN_pay_amt - CONTR.LEASING_FACT_pay_amt) > 0
      THEN
         (CONTR.LEASING_PLAN_pay_amt - CONTR.LEASING_FACT_pay_amt)
      ELSE
         0
   END)
     OST_AMNT,
  (CASE
      WHEN (CONTR.LEASING_PLAN_pay_amt - LEASING_FACT_pay_amt) < 0
      THEN
         (CONTR.LEASING_PLAN_pay_amt - LEASING_FACT_pay_amt)
      ELSE
         0
   END)
     OST_UNDER,
     0 overdue_amt,
  /*(CASE
      WHEN (CONTR.DT_LEASING_PLAN_pay_amt - CONTR.LEASING_FACT_pay_amt) > 0
      THEN
         (CONTR.DT_LEASING_PLAN_pay_amt - CONTR.LEASING_FACT_pay_amt)
      ELSE
         0
   END)
     OST_OVER,
   (CASE
      WHEN (CONTR.DT_LEASING_PLAN_pay_amt - CONTR.LEASING_FACT_pay_amt) < 0
      THEN
         (CONTR.DT_LEASING_PLAN_pay_amt - CONTR.LEASING_FACT_pay_amt)
      ELSE
         0
   END)
     OST_EXTRA,*/
  ---------------------------------------------------
  (CASE
      WHEN (CONTR.SUPPLY_PLAN_pay_amt - CONTR.SUPPLY_FACT_pay_amt) > 0
      THEN
         (CONTR.SUPPLY_PLAN_pay_amt - CONTR.SUPPLY_FACT_pay_amt)
      ELSE
         0
   END)
     OST_SUP_AMNT/*,
  (CASE
      WHEN (CONTR.SUPPLY_PLAN_pay_amt - CONTR.SUPPLY_FACT_pay_amt) < 0
      THEN
         (CONTR.SUPPLY_PLAN_pay_amt - CONTR.SUPPLY_FACT_pay_amt)
      ELSE
         0
   END)
     OST_SUP_UNDER,
  (CASE
      WHEN (CONTR.DT_SUPPLY_PLAN_pay_amt - CONTR.SUPPLY_FACT_pay_amt) > 0
      THEN
         (CONTR.DT_SUPPLY_PLAN_pay_amt - CONTR.SUPPLY_FACT_pay_amt)
      ELSE
         0
   END)
     OST_SUP_OVER*/
  ----------------------------------------------------
 -- ROUND (MONTHS_BETWEEN (CO.CLOSE_DT, CO.OPEN_DT), 2) K_MONTH,
 -- ROUND (MONTHS_BETWEEN (CO.CLOSE_DT, CO.OPEN_DT) / 12, 2) K_YEAR,


--  (CASE WHEN CGP.STATUS IS NULL THEN 'N' ELSE 'Y' END) FLG_CGP,
 from tt CONTR
    INNER JOIN dwh.contracts co
        ON    CONTR.CONTRACT_KEY = CO.CONTRACT_KEY
          AND CO.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
    LEFT JOIN dwh.clients cl
        ON    co.client_key = cl.client_key
          AND cl.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')

    /*LEFT JOIN DM.DM_CLIENTS dm_CL
        ON    co.CLIENT_KEY = dm_CL.CLIENT_KEY
           AND CONTR.SNAPSHOT_DT = dm_CL.SNAPSHOT_DT
           AND CONTR.SNAPSHOT_CD = dm_CL.SNAPSHOT_CD*/
         left JOIN dwh.credit_ratings cred_rat
            on cl.credit_rating_key = cred_rat.credit_rating_key
            --and dm_cl.SNAPSHOT_DT between cred_rat.BEGIN_DT and cred_rat.END_DT
         left JOIN dwh.business_categories bus_cat
            on cl.business_category_key = bus_cat.business_category_key
            and contr.SNAPSHOT_DT between bus_cat.BEGIN_DT and bus_cat.END_DT
       --  left join dwh.activity_types act on act.activity_type_key
         left join dwh.leasing_contracts lc
           on co.contract_key = lc.contract_key
           and lc.valid_to_dttm = date '2400-01-01'
         left join dwh.leasing_contracts_appls lca
             on lca.contract_key=co.contract_key
             and lca.valid_to_dttm = date '2400-01-01'
         left join (select contract_app_key,min(lst.act_dt) oper_start_dt from dwh.leasing_subject_transmit lst where lst.valid_to_dttm=date'2400-01-01'
         group by contract_app_key ) glst on glst.contract_app_key=lca.contract_app_key
 /*   LEFT JOIN DM.DM_CGP CGP
        ON    CONTR.CONTRACT_KEY = CGP.CONTRACT_KEY
          AND CONTR.snapshot_cd = CGP.snapshot_cd
          AND CONTR.snapshot_dt = CGP.snapshot_dt
    LEFT JOIN DM.DM_CGP CGP_LAST
        ON
              CGP.CONTRACT_KEY = CGP_LAST.CONTRACT_KEY
          AND CGP.snapshot_cd = CGP_LAST.snapshot_cd
          AND CGP_LAST.snapshot_dt = TRUNC (CGP.snapshot_dt, 'mm') - 1
    LEFT JOIN DM.DM_CLIENTS CL
        ON    CGP.CLIENT_KEY = CL.CLIENT_KEY
          AND CGP.SNAPSHOT_DT = CL.SNAPSHOT_DT
          AND CGP.SNAPSHOT_CD = CL.SNAPSHOT_CD
    LEFT JOIN
          (SELECT e.currency_key, e.Ex_rate_DT, e.exchange_rate
             FROM dwh.EXCHANGE_RATES e
                  JOIN dwh.currencies c
                     ON     c.currency_key = e.base_currency_key
                        AND c.currency_letter_cd = 'RUB'
                        AND c.valid_to_dttm > SYSDATE + 100
                        AND c.end_dt > SYSDATE + 100
                        AND e.valid_to_dttm > SYSDATE + 100) cur
        ON  CONTR.CUR1 = cur.currency_key
            AND CONTR.SNAPSHOT_DT = cur.Ex_rate_DT */
 /*   LEFT JOIN
         (SELECT branch_key,
                  vat_rate,
                  begin_dt,
                  end_dt
             FROM dwh.VAT
            WHERE valid_to_dttm > SYSDATE + 100) vat
        ON  CGP.branch_key = vat.branch_key
            AND CGP.snapshot_dt BETWEEN vat.begin_dt AND vat.end_dt */
          LEFT JOIN  (  SELECT l_key CONTRACT_KEY,
                    snapshot_cd,
                    snapshot_dt,
                    SUM (
                       CASE
                          WHEN tp = 'Supply_fact'
                          THEN
                               S.PAY_AMT
                             * rt2.EXCHANGE_RATE
                             / rt1.EXCHANGE_RATE
                             * -1
                             * rt3.EXCHANGE_RATE
                          ELSE
                             0
                       END)
                       AS SUPPLY_RUR_AMT_S_AMT_F,
                    SUM (
                       CASE
                          WHEN tp = 'Supply_fact' AND S.PAY_AMT > 0
                          THEN
                             S.PAY_AMT_CUR * -1
                          ELSE
                             CASE
                                WHEN tp = 'Supply_fact'
                                THEN
                                   S.PAY_AMT * rt2.EXCHANGE_RATE * -1
                                ELSE
                                   0
                             END
                       END)
                       AS SUPPLY_RUR_AMT_S_AMT_F_R
                      -- ,min(S.Oper_Start_Dt) Oper_Start_Dt
               FROM dm.dm_ol_flow_orig S
                    left JOIN dwh.contracts co
                       ON     s.s_key = co.CONTRACT_KEY
                          AND co.valid_to_dttm =
                                 TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                    LEFT JOIN dwh.EXCHANGE_RATES rt1
                       ON     co.CURRENCY_KEY = rt1.CURRENCY_KEY
                          AND S.pay_dt = rt1.ex_rate_dt
                          AND rt1.BASE_CURRENCY_KEY = 125
                          AND rt1.valid_to_dttm =
                                 TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                    LEFT JOIN dwh.EXCHANGE_RATES rt2
                       ON     S.CUR2 = rt2.CURRENCY_KEY
                          AND S.pay_dt = rt2.ex_rate_dt
                          AND rt2.BASE_CURRENCY_KEY = 125
                          AND rt2.valid_to_dttm =
                                 TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                    LEFT JOIN dwh.EXCHANGE_RATES rt3
                       ON     co.CURRENCY_KEY = rt3.CURRENCY_KEY
                          AND S.snapshot_dt = rt3.ex_rate_dt
                          AND rt3.BASE_CURRENCY_KEY = 125
                          AND rt3.valid_to_dttm =
                                 TO_DATE ('01.01.2400', 'dd.mm.yyyy')
              WHERE tp = 'Supply_fact'
           GROUP BY l_key, snapshot_cd, snapshot_dt) SUPPLY_RUR_AMT
        on  SUPPLY_RUR_AMT.CONTRACT_KEY =  CONTR.CONTRACT_KEY
            AND SUPPLY_RUR_AMT.snapshot_cd = CONTR.snapshot_cd
            AND SUPPLY_RUR_AMT.snapshot_dt = CONTR.snapshot_dt
;

