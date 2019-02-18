CREATE OR REPLACE FORCE VIEW DM.V$DM_OL_FLOW AS
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
        --sum(case when tp = 'Supply_plan'  then pay_amt end ) SUPPLY_PLAN_RUR_PAY_AMT_ORIG,
        sum(case when tp = 'Supply_fact' AND pay_dt <= og.snapshot_dt then pay_amt_cur end ) SUPPLY_FACT_PAY_AMT,
        sum(case when tp = 'Supply_plan' AND pay_dt <= og.snapshot_dt then pay_amt_cur end ) DT_SUPPLY_PLAN_PAY_AMT--,

        --Sum (sum (case when DM_OL_FLOW_ORIG.TP = 'Supply_plan' then DM_OL_FLOW_ORIG.PAY_AMT_CUR end) - sum (case when DM_OL_FLOW_ORIG.TP = 'Supply _Fact' then DM_OL_FLOW_ORIG.PAY_AMT_CUR end))

        --для значений > 0
   FROM dm.dm_ol_flow_orig og
        LEFT JOIN dwh.EXCHANGE_RATES  rt1_SUPPLY_PLAN_RUR
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
;

