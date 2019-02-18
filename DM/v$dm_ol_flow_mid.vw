CREATE OR REPLACE FORCE VIEW DM.V$DM_OL_FLOW_MID AS
SELECT flow."CONTRACT_KEY",flow."S_KEY",flow."SNAPSHOT_CD",flow."SNAPSHOT_DT",flow."CURRENCY_KEY",flow."CURRENCY_KEY_SUPPLY",flow."BRANCH_KEY",flow."PLAN_PAY_AMT",flow."FACT_PAY_AMT",flow."DT_PLAN_PAY_AMT",flow."SUPPLY_PLAN_PAY_AMT",flow."SUPPLY_PLAN_PAY_AMT_ORIG",flow."SUPPLY_PLAN_RUR_PAY_AMT_RUR",flow."SUPPLY_FACT_PAY_AMT",flow."DT_SUPPLY_PLAN_PAY_AMT",SUPPLY_PLAN_pay_amt_orig/PLAN_PAY_AMT K1 FROM (
SELECT
        og.l_key CONTRACT_KEY,
        min(og.s_key) s_key,
        og.snapshot_cd,
        og.snapshot_dt,
        og.CUR1 currency_key,
        min(og.Cur2) currency_key_supply,
        min(og.branch_key) branch_key,
        sum(case when tp = 'OL_PLAN' then pay_amt_cur end ) PLAN_PAY_AMT,
        sum(case when tp = 'OL_FACT' AND pay_dt <= og.snapshot_dt then pay_amt_cur end ) FACT_PAY_AMT,
        sum(case when tp = 'OL_PLAN' AND pay_dt <= og.snapshot_dt then pay_amt_cur end ) DT_PLAN_PAY_AMT,
        sum(case when tp = 'Supply_plan'  then pay_amt_cur end ) SUPPLY_PLAN_PAY_AMT,
        sum(case when tp = 'Supply_plan'  then pay_amt end ) SUPPLY_PLAN_pay_amt_orig,
        sum(case when tp = 'Supply_plan'  then pay_amt * rt1_SUPPLY_PLAN_RUR.EXCHANGE_RATE end ) SUPPLY_PLAN_RUR_PAY_AMT_RUR,
        --sum(case when tp = 'Supply_plan'  then pay_amt end ) SUPPLY_PLAN_RUR_PAY_AMT_ORIG,
        sum(case when tp = 'Supply_fact' AND pay_dt <= og.snapshot_dt then pay_amt_cur end ) SUPPLY_FACT_PAY_AMT,
        sum(case when tp = 'Supply_plan' AND pay_dt <= og.snapshot_dt then pay_amt_cur end ) DT_SUPPLY_PLAN_PAY_AMT
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
        og.CUR1) flow
;

