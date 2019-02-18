CREATE OR REPLACE PROCEDURE DM.p_DM_TRANSMIT_SUBJECTS
is

BEGIN 

execute immediate ('truncate table DM.DM_TRANSMIT_SUBJECTS');

insert into  DM.DM_TRANSMIT_SUBJECTS (
          LEASE_MONTH,
          contract_id_cd,
          ACT_DT,
          TRANSMIT_SUBJECT_NAM,
          CONTRACT_KEY,
          CONTRACT_CURRENCY,
          LEASING_DEAL_KEY,
          LEASING_SUBJECT_KEY,
          REGION,
          SROK,
          PAY_DT,
          ADVANCE,
          ADVANCE_CURRENCY,
          ADVANCE_RUB,
          ADVANCE_EXCHANGE_RATE,
          COST_AMT,
          COST_CURRENCY,
          COST_RUB,
          COST_EXCHANGE_RATE,
          FINANCE_AMT,
          FIRST_FIN_AMT,
          INSERT_DT,
          SUPPLY_AMT,
          SUPPLY_RUB,
          INSURANCE_AMT,
          INSURANCE_RUB,
          FIRST_FIN_AMT_CLIENTS
)
  WITH contr
        AS (SELECT c.contract_key,
                   sup.contract_key S_KEY,
                   c.close_dt,
                   c.open_dt,
                   c.rehiring_flg,
                   c.contract_id_cd
              FROM dwh.leasing_contracts lc
                   JOIN dwh.contracts c
                      ON     c.contract_key = lc.contract_key
                         AND c.valid_to_dttm =
                                TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                         AND lc.valid_to_dttm =
                                TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                         AND lc.auto_flg = 1
              -- aapolyakov [22.09.2015]: Для договоров лизинга определяем договор поставки
              LEFT JOIN dwh.contracts sup
                      ON     lc.contract_key = sup.contract_leasing_key
                         AND sup.valid_to_dttm =
                                TO_DATE ('01.01.2400', 'DD.MM.YYYY')),
    -- aapolyakov [22.09.2015]: Для договоров поставки берем фактические платежи со знаком (+) и для каждого платежа определяем курс на дату платежа
    fct_supply_cur
        AS (select contr.contract_key,
                   contr.S_KEY,
                   contr.close_dt,
                   contr.open_dt,
                   contr.rehiring_flg,
                   contr.contract_id_cd,
                   fact_rp.pay_dt,
                   fact_rp.cbc_desc,
                   fact_rp.pay_amt * (-1) as pay_amt,
                   fact_rp.currency_key,
                   -- [apolyakov 18.02.2016]: расчет по курсу бух учета, как в КИС
                   case
                        when fact_rp.EXCHANGE_RATE is not null
                         and fact_rp.EXCHANGE_RATE <> 0
                            then fact_rp.pay_amt * (-1) / abs (fact_rp.EXCHANGE_RATE)
                        else fact_rp.pay_amt * (-1) * er1.exchange_rate
                   end as supply_rub
            from contr contr
            left join dwh.fact_real_payments fact_rp
                ON contr.s_key = fact_rp.contract_key
               AND fact_rp.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
            LEFT JOIN dwh.exchange_rates er1
                          ON     fact_rp.currency_key = er1.currency_key
                             AND er1.valid_to_dttm =
                                    TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                             AND er1.ex_rate_dt = fact_rp.pay_dt
                             AND er1.base_currency_key IN (SELECT currency_key
                                                             FROM dwh.currencies
                                                            WHERE     valid_to_dttm =
                                                                         TO_DATE (
                                                                            '01.01.2400',
                                                                            'dd.mm.yyyy')
                                                                  AND begin_dt <=
                                                                         fact_rp.pay_dt
                                                                  AND end_dt >
                                                                         fact_rp.pay_dt
                                                                  AND currency_letter_cd IN ('RUB')
                                                          )
            ),
    -- aapolyakov [22.09.2015]: Суммируем платежи в рамках id сделки, получая стоимость по ДКП и стоимость по ДКП в рублях.
    fct_supply
        AS (
            select 
                   
                   contract_id_cd,
                   sum (pay_amt) as supply_amt,
                   sum (supply_rub) supply_rub
            from fct_supply_cur
            group by 
                   
                   contract_id_cd
           ),
    
    -- [apolyakov 28.03.2016]: добавление расчета суммы по страховым случаям       
    fct_insurance
        AS (
            select contr.contract_id_cd,
                   sum (pay_amt) as insurance_amt,
                   sum (pay_rub_amt) as insurance_rub
            from contr contr
            left join dwh.fact_insurance_payments fact_ip
                ON contr.s_key = fact_ip.contract_key
               AND fact_ip.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
            group by contract_id_cd
            ),
            
    contr_transmit
        AS (
            SELECT act_dt,
                   contract_key,
                   open_dt,
                   cost_amt,
                   rehiring_flg,
                   contract_id_cd,
                   currency_key,
                   close_dt,
                   transmit_subject_nam
            FROM  (
            
                          SELECT act_dt,
                                 contract_key,
                                 open_dt,
                                 cost_amt,
                                 rehiring_flg,
                                 contract_id_cd,
                                 currency_key,
                                 close_dt,
                                 transmit_subject_nam,
                                 ROW_NUMBER ()
                                                         OVER (PARTITION BY CONTRACT_ID_CD
                                                               ORDER BY act_dt asc)
                                                            rn1
                            FROM (SELECT /*+  use_hash(lc c v) cardinality(v 100000) */
                                        t.act_dt,
                                         c.contract_key,
                                         c.open_dt AS open_dt,
                                         t.cost_amt AS cost_amt,
                                         c.rehiring_flg,
                                         c.contract_id_cd,
                                         t.currency_key,
                                         c.close_dt,
                                         t.transmit_subject_nam,
                                         ROW_NUMBER ()
                                         OVER (PARTITION BY c.CONTRACT_ID_CD
                                               ORDER BY t.snapshot_dt desc)
                                            rn
                                    FROM dwh.leasing_subject_transmit t
                                         JOIN dwh.leasing_contracts_appls ap
                                            ON     t.contract_app_key = ap.contract_app_key
                                               AND ap.valid_to_dttm =
                                                      TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                                         JOIN contr c ON c.contract_key = ap.contract_key
                                   WHERE     1 = 1
                                         AND t.valid_to_dttm =
                                                TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                                         AND t.act_dt <>
                                                TO_DATE ('01.01.0001', 'DD.MM.YYYY')
                                         AND t.act_num IS NOT NULL
                                         AND t.contract_app_key IS NOT NULL
                                  )
                           WHERE rn = 1
                  )
            WHERE rn1 = 1
    ),
    fct
        AS (SELECT *
              FROM (SELECT c.contract_id_cd,
                           fct.currency_key,
                           fct.pay_dt,
                           fct.pay_amt,
                           ROW_NUMBER ()
                           OVER (PARTITION BY contract_id_cd
                                 ORDER BY pay_dt DESC)
                              rn
                      FROM (  SELECT contract_key,
                                     currency_key,
                                     MAX (pay_dt) AS pay_dt,
                                     SUM (pay_amt) AS pay_amt
                                FROM dwh.fact_real_payments fct
                               WHERE     fct.valid_to_dttm =
                                            TO_DATE ('01.01.2400',
                                                     'DD.MM.YYYY')
                                     AND fct.payment_item_key IN (SELECT payment_item_key
                                                                    FROM dwh.payment_items
                                                                   WHERE     payment_item_nam =
                                                                                'Аванс (с НДС)'
                                                                         AND valid_to_dttm =
                                                                                TO_DATE (
                                                                                   '01.01.2400',
                                                                                   'DD.MM.YYYY'))
                            GROUP BY contract_key, currency_key) fct
                           JOIN (select  
                                      contract_key,
                                      contract_id_cd
                                 from contr) c ON fct.contract_key = c.contract_key)
             WHERE rn = 1),
        mapping_contracts as
        (
            select /*+ materialize */
            * from dwh.v_mapping_contracts
        )             
        ,tt
        AS (SELECT /*+ INLINE   */
                  lease_month,                     --Месяц передачи в лизинг
                   act_dt,                         -- Дата передачи в лизинг
                   contract_key,                       --   Договор лизинга,
                   contract_id_cd,
                   TRANSMIT_SUBJECT_NAM,
                   contract_currency,             --  Валюта договор лизинга
                   leasing_deal_key,                             --   Сделка
                   leasing_subject_key,                    --Предмет лизинга
                   region,                                         -- Регион
                   srok,                                    --  Срок лизинга
                   DECODE (
                      pay_dt,
                      NULL, LAG (
                               pay_dt)
                            OVER (PARTITION BY contract_id_cd
                                  ORDER BY NVL (rehiring_flg, 0)),
                      pay_dt)
                      pay_dt,                             --дата оплаты аванса
                   DECODE (
                      advance,
                      NULL, LAG (
                               advance)
                            OVER (PARTITION BY contract_id_cd
                                  ORDER BY NVL (rehiring_flg, 0)),
                      advance)
                      advance,                           -- Аванс,исх.валюта
                   DECODE (
                      advance_currency,
                      NULL, LAG (
                               advance_currency)
                            OVER (PARTITION BY contract_id_cd
                                  ORDER BY NVL (rehiring_flg, 0)),
                      advance_currency)
                      advance_currency,                      --Валюта аванса
                   DECODE (
                      advance_rub,
                      NULL, LAG (
                               advance_rub)
                            OVER (PARTITION BY contract_id_cd
                                  ORDER BY NVL (rehiring_flg, 0)),
                      advance_rub)
                      advance_rub,                             -- Аванс,руб.
                   DECODE (
                      advance_exchange_rate,
                      NULL, LAG (
                               advance_exchange_rate)
                            OVER (PARTITION BY contract_id_cd
                                  ORDER BY NVL (rehiring_flg, 0)),
                      advance_exchange_rate)
                      advance_exchange_rate,                --Курс ЦБ, аванс
                   cost_amt,                      --Стоимость ПЛ, исх.валюта
                   cost_currency,                      --Валюта стоимости ПЛ
                   cost_rub,                             --Стоимость ПЛ,руб.
                   cost_exchange_rate,                   --Курс ЦБ, поставка
                   DECODE (
                      supply_amt,
                      NULL, LAG (
                               supply_amt)
                            OVER (PARTITION BY contract_id_cd
                                  ORDER BY NVL (rehiring_flg, 0)),
                      supply_amt)
                      supply_amt,                  -- Стоимость ПЛ в исх валюте по совершенным платежам поставки
                    DECODE (
                      supply_rub,
                      NULL, LAG (
                               supply_rub)
                            OVER (PARTITION BY contract_id_cd
                                  ORDER BY NVL (rehiring_flg, 0)),
                      supply_rub)
                      supply_rub,                  -- Стоимость ПЛ в рублях по совершенным платежам поставки
                   DECODE (
                      insurance_amt,
                      NULL, LAG (
                               insurance_amt)
                            OVER (PARTITION BY contract_id_cd
                                  ORDER BY NVL (rehiring_flg, 0)),
                      insurance_amt)
                      insurance_amt,                  -- Сумма страховых выплат в исходной валюте
                    DECODE (
                      insurance_rub,
                      NULL, LAG (
                               insurance_rub)
                            OVER (PARTITION BY contract_id_cd
                                  ORDER BY NVL (rehiring_flg, 0)),
                      insurance_rub)
                      insurance_rub,                  -- Сумма страховых выплат в рублях
                   DECODE (
                      finance_amt,
                      NULL, LAG (
                               finance_amt)
                            OVER (PARTITION BY contract_id_cd
                                  ORDER BY NVL (rehiring_flg, 0)),
                      finance_amt)
                      finance_amt,  -- Сумма финансирования, первоначальная,
                   DECODE (
                      first_fin_amt,
                      NULL, LAG (
                               first_fin_amt)
                            OVER (PARTITION BY contract_id_cd
                                  ORDER BY NVL (rehiring_flg, 0)),
                      first_fin_amt)
                      first_fin_amt, -- Совокупная сумма финансирования, первоначальная,
                   DECODE (
                      first_fin_amt_clients,
                      NULL, LAG (
                               first_fin_amt_clients)
                            OVER (PARTITION BY contract_id_cd
                                  ORDER BY NVL (rehiring_flg, 0)),
                      first_fin_amt_clients)
                      first_fin_amt_clients, -- Совокупная сумма финансирования по клиенту, первоначальная,
                   ROW_NUMBER ()
                   OVER (PARTITION BY contract_id_cd
                         ORDER BY NVL (rehiring_flg, 0) DESC)
                      f_rn
              FROM (SELECT ADD_MONTHS (TRUNC (c.act_dt, 'MM'), 1) - 1
                              AS lease_month,   -- месяц передачи в лизинг
                           c.act_dt AS act_dt,  -- дата акта передачи в лизинг
                           fct.pay_dt AS pay_dt, -- дата аванса
                           c.contract_key AS contract_key,  -- 
                           c.transmit_subject_nam,   -- наименование переданного ПЛ
                           cur1.currency_letter_cd AS contract_currency,    -- Валюта договора
                           v.leasing_deal_key AS leasing_deal_key,
                           v.leasing_subject_key AS leasing_subject_key,
                           t.town_nam AS region,
                           trunc (months_between (c.close_dt, c.open_dt)) AS srok,
                           fct.pay_amt AS advance,     -- аванс в исходной валюте
                           cur2.currency_letter_cd AS advance_currency,    -- валюта аванса
                           fct.pay_amt * er2.exchange_rate AS advance_rub,   -- аванс в рублях
                           er2.exchange_rate AS advance_exchange_rate,  -- курс пересчета аванса
                           c.cost_amt AS cost_amt,                      -- стоимость ПЛ выставленная в валюте
                           cur3.currency_letter_cd AS cost_currency,    -- валюта выставленной стоимости ПЛ
                           c.cost_amt * er1.exchange_rate AS cost_rub,  -- стоимость ПЛ по курсу на дату поставки
                           fct_supply.supply_amt,                       -- aapolyakov [22.09.2015]: стоимость ПЛ в валюте, рассчитанная по совершенным платежам
                           fct_supply.supply_rub,                       -- aapolyakov [22.09.2015]: стоимость ПЛ в рублях, рассчитанная по совершенным платежам
                           fct_insurance.insurance_amt,                 -- aapolyakov [28.03.2015]: Сумма страховых выплат в исходной валюте
                           fct_insurance.insurance_rub,                 -- aapolyakov [28.03.2015]: Сумма страховых выплат в рублях
                           er1.exchange_rate AS cost_exchange_rate,     -- курс пересчета выставленной стоимости ПЛ
                             nvl (fct_supply.supply_rub, 0)
                           - nvl (fct.pay_amt * er2.exchange_rate, 0)
                              AS finance_amt,
                           --Совокупная сумма финансирования со стороны ВТБЛ, руб., первоначальная
                           SUM (
                                nvl (fct_supply.supply_rub, 0)
                              - nvl (fct.pay_amt * er2.exchange_rate, 0))
                           OVER (
                              PARTITION BY nvl (crm_cl.account_group_key, c.contract_key))
                              AS first_fin_amt,
                           -- [apolyakov 11.04.2017]: Совокупная сумма финансирования по клиенту со стороны ВТБЛ, руб., первоначальная
                           SUM (
                                nvl (fct_supply.supply_rub, 0)
                              - nvl (fct.pay_amt * er2.exchange_rate, 0))
                           OVER (
                              PARTITION BY crm_cl.crm_client_key)
                              AS first_fin_amt_clients,
                           c.rehiring_flg,
                           c.contract_id_cd
                      FROM contr_transmit c
                           --aapolyakov [22.09.2015]: + данные по стоимости ПЛ
                           LEFT JOIN fct_supply 
                              ON c.contract_id_cd = fct_supply.contract_id_cd
                           --aapolyakov [28.03.2016]: + данные по страховым выплатам
                           LEFT JOIN fct_insurance
                              ON c.contract_id_cd = fct_insurance.contract_id_cd
                           LEFT JOIN fct
                              ON c.contract_id_cd = fct.contract_id_cd
                           LEFT JOIN mapping_contracts v
                              ON c.contract_key = v.contract_key
                           LEFT JOIN dwh.leasing_deals ld
                              ON     v.leasing_deal_key = ld.leasing_deal_key
                                 AND ld.valid_to_dttm =
                                        TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                                 AND ld.end_dt =
                                        TO_DATE ('31.12.3999', 'DD.MM.YYYY')
                           --курс по поставке
                           LEFT JOIN dwh.exchange_rates er1
                              ON     c.currency_key = er1.currency_key
                                 AND er1.valid_to_dttm =
                                        TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                                 AND er1.ex_rate_dt = c.act_dt
                                 AND er1.base_currency_key IN (SELECT currency_key
                                                                 FROM dwh.currencies
                                                                WHERE     valid_to_dttm =
                                                                             TO_DATE (
                                                                                '01.01.2400',
                                                                                'dd.mm.yyyy')
                                                                      AND begin_dt <=
                                                                             c.act_dt
                                                                      AND end_dt >
                                                                             c.act_dt
                                                                      AND currency_letter_cd IN ('RUB'))
                           --курс по авансу
                           LEFT JOIN dwh.exchange_rates er2
                              ON     fct.currency_key = er2.currency_key
                                 AND er2.valid_to_dttm =
                                        TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                                 AND er2.ex_rate_dt = fct.pay_dt
                                 AND er2.base_currency_key IN (SELECT currency_key
                                                                 FROM dwh.currencies
                                                                WHERE     valid_to_dttm =
                                                                             TO_DATE (
                                                                                '01.01.2400',
                                                                                'dd.mm.yyyy')
                                                                      AND begin_dt <=
                                                                             fct.pay_dt
                                                                      AND end_dt >
                                                                             fct.pay_dt
                                                                      AND currency_letter_cd IN ('RUB'))
                           LEFT JOIN dwh.crm_users u
                              ON     ld.core_manager_key = u.crm_user_key
                                 AND u.valid_to_dttm =
                                        TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                                 AND u.end_dt =
                                        TO_DATE ('31.12.3999', 'DD.MM.YYYY')
                           LEFT JOIN dwh.business_units bu
                              ON     u.business_unit_key =
                                        bu.business_unit_key
                                 AND bu.valid_to_dttm =
                                        TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                           LEFT JOIN dwh.towns t
                              ON     bu.town_key = t.town_key
                                 AND t.valid_to_dttm =
                                        TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                           LEFT JOIN dwh.currencies cur1
                              ON     c.currency_key = cur1.currency_key
                                 AND cur1.valid_to_dttm =
                                        TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                                 AND cur1.begin_dt <= c.act_dt
                                 AND cur1.end_dt > c.act_dt
                           LEFT JOIN dwh.currencies cur2
                              ON     fct.currency_key = cur2.currency_key
                                 AND cur2.valid_to_dttm =
                                        TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                                 AND cur2.begin_dt <= c.act_dt
                                 AND cur2.end_dt > c.act_dt
                           LEFT JOIN dwh.currencies cur3
                              ON     c.currency_key = cur3.currency_key
                                 AND cur3.valid_to_dttm =
                                        TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                                 AND cur3.begin_dt <= c.act_dt
                                 AND cur3.end_dt > c.act_dt
                           LEFT JOIN DWH.crm_clients crm_cl
                              ON     v.crm_client_key = crm_cl.crm_client_key
                                 AND crm_cl.valid_to_dttm =
                                        TO_DATE ('01.01.2400', 'DD.MM.YYYY')))
   SELECT LEASE_MONTH,
          contract_id_cd,
          ACT_DT,
          TRANSMIT_SUBJECT_NAM,
          CONTRACT_KEY,
          CONTRACT_CURRENCY,
          LEASING_DEAL_KEY,
          LEASING_SUBJECT_KEY,
          REGION,
          SROK,
          PAY_DT,
          ADVANCE,
          ADVANCE_CURRENCY,
          ADVANCE_RUB,
          ADVANCE_EXCHANGE_RATE,
          COST_AMT,
          COST_CURRENCY,
          COST_RUB,
          COST_EXCHANGE_RATE,
          FINANCE_AMT,
          FIRST_FIN_AMT,
          sysdate as insert_dt,
          SUPPLY_AMT,
          SUPPLY_RUB,
          INSURANCE_AMT,
          INSURANCE_RUB,
          -- [apolyakov 11.04.2017]: добавление поля для расчета в КГП Ежедневном
          FIRST_FIN_AMT_CLIENTS
     FROM tt
    WHERE f_rn = 1;

COMMIT;

etl.P_DM_LOG('DM_TRANSMIT_SUBJECTS ');

END;
/

