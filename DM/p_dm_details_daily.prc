CREATE OR REPLACE PROCEDURE DM.P_DM_DETAILS_DAILY (P_REPORT_DT in date)
IS
BEGIN

/* Процедура для автоматического расчета витрины "График плановых и фактических платежей" для УАКР АЛ

   В качестве входного параметра подается дата составления отчета
*/
  dm.u_log(p_proc => 'DM.P_DM_DETAILS_DAILY',
           p_step => 'INPUT PARAMS',
           p_info => 'p_REPORT_DT:'||p_REPORT_DT);

--execute immediate ('truncate table DM.DM_DETAILS_DAILY');
  dm.u_log(p_proc => 'DM.P_DM_DETAILS_DAILY',
           p_step => 'truncate table DM.DM_DETAILS_DAILY',
           p_info => 'table truncated');
  delete from dm.dm_DETAILS_DAILY where snapshot_dt=P_REPORT_DT;
  dm.u_log(p_proc => 'DM.P_DM_DETAILS_DAILY',
           p_step => 'delete from DM.DM_DETAILS_DAILY',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');

insert All into  DM.DM_DETAILS_DAILY (
                                CONTRACT_KEY,
                                CBC_DESC,
                                PAYMENT_NUM,
                                PLAN_PAY_DT_ORIG,
                                PAY_DT_ORIG,
                                PLAN_AMT,
                                FACT_PAY_AMT,
                                PRE_PAY,
                                AFTER_PAY,
                                OVERDUE_DAYS,
                                PAYMENT_ITEM_KEY,
                                CURRENCY_KEY,
                                PAY_FLG,
                                off_schedule,
                                SNAPSHOT_DT,
                                INSERT_DT,
                                --LOAD_DT,
                                rown
                              )
 /*into  DM.DM_DD (
                                CONTRACT_KEY,
                                CBC_DESC,
                                PAYMENT_NUM,
                                PLAN_PAY_DT_ORIG,
                                PAY_DT_ORIG,
                                PLAN_AMT,
                                FACT_PAY_AMT,
                                PRE_PAY,
                                AFTER_PAY,
                                OVERDUE_DAYS,
                                PAYMENT_ITEM_KEY,
                                CURRENCY_KEY,
                                PAY_FLG,
                                off_schedule,
                                SNAPSHOT_DT,
                                INSERT_DT,
                                LOAD_DT,
                                rown
                              ) */
with
  -- [apolyakov 04.04.2017]: Договоры лизинга
  leas_contr AS
  (
    SELECT contract_key
    FROM dwh.leasing_contracts
    WHERE valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
    AND auto_flg        =1
  ),
  -- [apolyakov 04.04.2017]: оригинальные графики платежей
  orig_payments as
  (
    -- [apolyakov 04.04.2017]: набор плановых платежей
    SELECT leas_contr.contract_key,
           cbc_desc,
           pay_dt                   AS pay_dt_orig,
           pay_dt                   AS plan_pay_dt_orig,
           pay_amt * er1.exchange_rate plan_pay_amt,
           0 AS fact_pay_amt,
           p.currency_key,
           payment_item_key,
           'PLAN' as TP
           ,nvl(p.off_schedule,'N') off_schedule
           ,p.valid_from_dttm
    FROM
           dwh.fact_plan_payments p
    INNER JOIN leas_contr leas_contr
        ON leas_contr.contract_key = p.contract_key
    LEFT JOIN dwh.exchange_rates er1
        ON p.currency_key          =er1.currency_key
       AND er1.valid_to_dttm      =to_date('01.01.2400','DD.MM.YYYY')
       AND er1.ex_rate_dt         =p.pay_dt
       AND er1.base_currency_key IN
          (
            SELECT
                    currency_key
            FROM dwh.currencies
            WHERE valid_to_dttm     = to_date('01.01.2400','dd.mm.yyyy')
              AND begin_dt           <=p.pay_dt
              AND end_dt              >p.pay_dt
              AND currency_letter_cd IN ('RUB')
          )
    WHERE p.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      AND end_dt  =  to_date('31.12.3999','DD.MM.YYYY')
      --AND p.contract_key  = 1836

    UNION ALL
    -- [apolyakov 04.04.2017]: набор фактических платежей
    SELECT leas_contr.contract_key,
           cbc_desc,
           nvl (real_pay_dt, pay_dt) AS pay_dt_orig,
           plan_pay_dt as plan_pay_dt_orig,
           0                             AS plan_pay_amt,
           pay_amt * er2.exchange_rate    AS fact_pay_amt,
           f.currency_key,
           payment_item_key,
           'FACT' as TP
           ,coalesce(f.off_schedule,'N') off_schedule
           ,f.valid_from_dttm
    FROM
           dwh.fact_real_payments f
    INNER JOIN leas_contr leas_contr
        ON leas_contr.contract_key = f.contract_key
    LEFT JOIN dwh.exchange_rates er2
        ON f.currency_key          =er2.currency_key
       AND er2.valid_to_dttm      =to_date('01.01.2400','DD.MM.YYYY')
       AND er2.ex_rate_dt         =f.pay_dt
       AND er2.base_currency_key IN
          (
            SELECT
                    currency_key
            FROM dwh.currencies
            WHERE valid_to_dttm     =to_date('01.01.2400','dd.mm.yyyy')
              AND begin_dt           <=f.pay_dt
              AND end_dt              >f.pay_dt
              AND currency_letter_cd IN ('RUB')
          )
    WHERE f.valid_to_dttm  = to_date('01.01.2400', 'dd.mm.yyyy')
    --AND f.contract_key  = 1836
    ),

  -- [apolyakov 04.04.2017]: агрегирование фактических платежей в разрезе лизингового платежа и даты фактического платежа
  orig_payments_agr  as
    (
      (select * from (
         SELECT contract_key,
                cbc_desc,
                plan_pay_dt_orig,
                pay_dt_orig,
                currency_key,
                payment_item_key,
                TP,
                SUM(plan_pay_amt)                AS plan_pay_amt,
                SUM(fact_pay_amt)                AS fact_pay_amt
            ,off_schedule
            ,max(valid_from_dttm) valid_from_dttm
         FROM
                orig_payments
         GROUP BY
                contract_key,
                cbc_desc,
                plan_pay_dt_orig,
                pay_dt_orig,
                currency_key,
                payment_item_key,
                TP,
            	off_schedule
     ) where   plan_pay_amt<>0 or fact_pay_amt<>0)) ,

  -- [apolyakov 04.04.2017]: расчет сумм к оплате, планового платежа и суммы остатка, расчет количества дней просрочки
  details as
    (
     SELECT
            contract_key,
            cbc_desc,
            plan_pay_dt_orig,
            pay_dt_orig,
            currency_key,
            payment_item_key,
            TP,
            plan_pay_amt,
            fact_pay_amt,
            -- [apolyakov 04.04.2017]: Остаток после оплаты ("Сумма остаток")
            SUM(plan_pay_amt)
                  over (partition BY contract_key, cbc_desc, currency_key, payment_item_key, plan_pay_dt_orig,off_schedule)
            -
            sum (fact_pay_amt)
                  over (partition by contract_key, cbc_desc, currency_key, payment_item_key, plan_pay_dt_orig,off_schedule
                              order by case when plan_pay_amt = 0 then 1 else 0 end asc, plan_pay_dt_orig, pay_dt_orig
                        ) as after_pay,
            -- [apolyakov 04.04.2017]: Остаток до оплаты ("Сумма к оплате")
            SUM(plan_pay_amt)
                  over (partition BY contract_key, cbc_desc, currency_key, payment_item_key, plan_pay_dt_orig,off_schedule)
            -
            sum (fact_pay_amt)
                  over (partition by contract_key, cbc_desc, currency_key, payment_item_key, plan_pay_dt_orig,off_schedule
                              order by case when plan_pay_amt = 0 then 1 else 0 end asc, plan_pay_dt_orig, pay_dt_orig  rows BETWEEN unbounded PRECEDING AND 1 PRECEDING
                        ) as pre_pay,
            -- [apolyakov 04.04.2017]: Сумма планогового платежа
            SUM(plan_pay_amt)
                  over (partition BY contract_key, cbc_desc, currency_key, payment_item_key, plan_pay_dt_orig,off_schedule
                        ) as PLAN_AMT,
            -- [apolyakov 04.04.2017]: Номер платежа
            dense_rank ()
                  OVER (partition by contract_key, cbc_desc, currency_key, payment_item_key,off_schedule order by plan_pay_dt_orig
                       ) payment_num,
                  /*      case when ziro_flg=0 then dense_rank ()
                  OVER (partition by contract_key, cbc_desc, currency_key, payment_item_key,ziro_flg order by plan_pay_dt_orig)
                        else dense_rank ()
                  OVER (partition by contract_key, cbc_desc, currency_key, payment_item_key,ziro_flg order by plan_pay_dt_orig) -1
                       end payment_num,*/
            -- [apolyakov 04.04.2017]: Количество дней просрочки
            case
                  when ROUND(nvl (pay_dt_orig, p_REPORT_DT) - plan_pay_dt_orig) < 0
                      then 0
                  when ROUND(nvl (pay_dt_orig, p_REPORT_DT) - plan_pay_dt_orig) >= 0 --ovilkova 18.12.2017
                       and (SUM(plan_pay_amt) over (partition BY contract_key, cbc_desc, currency_key, payment_item_key, plan_pay_dt_orig)) = 0--ovilkova 18.12.2017
                      then 0      --ovilkova 18.12.2017
                  else ROUND(nvl (pay_dt_orig, p_REPORT_DT) - plan_pay_dt_orig)
            end AS overdue_days
            ,off_schedule
            ,valid_from_dttm
      FROM  orig_payments_agr
           -- (select a.*,sum(case when nvl(plan_pay_amt,0)=0 and nvl(fact_pay_amt,0)=0 then 1 else 0 end) over(partition by contract_key, cbc_desc, currency_key, payment_item_key order by plan_pay_dt_orig ) ziro_flg from orig_payments_agr a)
      ORDER BY
            cbc_desc,
            plan_pay_dt_orig,
            pay_dt_orig
    ),

  -- [apolyakov 04.04.2017]: Определение общей суммы остатка для определения непогашенных платежей
  non_paid as
      (
      select
            contract_key,
            cbc_desc,
            payment_num,
            plan_pay_dt_orig,
            currency_key,
            payment_item_key,
            plan_amt,
            max(after_pay) keep (dense_rank last order by case when TP = 'FACT' then 1 else 0 end, pay_dt_orig) total_afterpay,
            max(pay_dt_orig) keep (dense_rank last order by case when TP = 'FACT' then 1 else 0 end, pay_dt_orig) max_pay_dt_orig
            ,off_schedule
            ,max(valid_from_dttm) valid_from_dttm
       from details
       group by
            contract_key,
            cbc_desc,
            payment_num,
            plan_pay_dt_orig,
            currency_key,
            plan_amt,
            payment_item_key,off_schedule
      ),
  final_data as
      (
        select  contract_key,
                cbc_desc,
                payment_num,
                plan_pay_dt_orig,
                pay_dt_orig,
                PLAN_AMT,
                fact_pay_amt,
                pre_pay,
                after_pay,
                case when overdue_days < 0 then 0 else overdue_days end overdue_days,
                payment_item_key,
                currency_key,
                '1' as pay_flg,
                p_REPORT_DT as snapshot_dt,
                sysdate as insert_dt
                ,off_schedule
                ,valid_from_dttm
                ,rank() over(order by contract_key) rown
        from details
        --where plan_pay_amt = 0
        where TP = 'FACT'


        union all

        select
              contract_key,
              cbc_desc,
              payment_num,
              plan_pay_dt_orig,
              null,
              PLAN_AMT,
              null,
              total_afterpay,
              total_afterpay,
              p_REPORT_DT - plan_pay_dt_orig,
              payment_item_key,
              currency_key,
              '0' as pay_flg,
              p_REPORT_DT as snapshot_dt,
              sysdate as insert_dt
              ,off_schedule
              ,valid_from_dttm
              ,0 rown
         from non_paid
         where total_afterpay != 0

        order by payment_num, plan_pay_dt_orig, pay_dt_orig
      )
select
        contract_key,
        cbc_desc,
--case when ziro_flg=0 then dense_rank ()
 --                 OVER (partition by contract_key, cbc_desc, currency_key, payment_item_key,ziro_flg order by plan_pay_dt_orig)
    --                    else
    dense_rank ()
                  OVER (partition by contract_key, cbc_desc, currency_key, payment_item_key,ziro_flg order by plan_pay_dt_orig) -case when /*(nvl(PLAN_AMT,0)=0 and nvl(fact_pay_amt,0)=0 and nvl(pre_pay,0)=0  and nvl(after_pay,0)=0) or */ ziro_flg=0  then 0 else 1 end
                       --end
                        payment_num ,
                               plan_pay_dt_orig,
        pay_dt_orig,
        PLAN_AMT,
        fact_pay_amt,
        pre_pay,
        after_pay,
        overdue_days,
        payment_item_key,
        currency_key,
        pay_flg,
        off_schedule, --5509 Add by Zanozin 13/05/2018
        snapshot_dt,
        insert_dt
        --,valid_from_dttm
        ,rown from (
select
        contract_key,
        cbc_desc,
        sum(case when nvl(PLAN_AMT,0)=0 and nvl(fact_pay_amt,0)=0 and nvl(pre_pay,0)=0  and nvl(after_pay,0)=0 then 1 else 0 end)
                           over(partition by contract_key, cbc_desc, currency_key, payment_item_key order by plan_pay_dt_orig ) ziro_flg,
        plan_pay_dt_orig,
        pay_dt_orig,
        PLAN_AMT,
        fact_pay_amt,
        pre_pay,
        after_pay,
        overdue_days,
        payment_item_key,
        currency_key,
        pay_flg,
        off_schedule,
        snapshot_dt,
        insert_dt,
        valid_from_dttm,
        rown
from final_data
where --plan_amt<>0 and fact_pay_amt <>0 --Shishlyanikov 03.10.2017
--nvl(plan_amt,1)<>0 and nvl(fact_pay_amt,1)<>0 --Shishlyanikov 03.10.2017
( nvl(plan_amt,1)<>0 or nvl(fact_pay_amt,1)<>0)
order by plan_pay_dt_orig
);

   dm.u_log(p_proc => 'DM.P_DM_DETAILS_DAILY',
           p_step => 'insert into  DM.DM_DETAILS_DAILY',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');
commit;

etl.P_DM_LOG('DM_DETAILS_DAILY');

END;
/

