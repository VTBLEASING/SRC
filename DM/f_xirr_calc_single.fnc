CREATE OR REPLACE FUNCTION DM."F_XIRR_CALC_SINGLE" (
      p_contract_key number, 
      p_REPORT_DT date)
RETURN NUMBER IS
xIRR_res NUMBER;

/* Функция рассчитывает XIRR для одного контракта. 
-- В качестве параметров на вход подаются номер контракта (p_contract_key) и дата отчета (p_REPORT_DT).
-- На выходе вычисленный XIRR в переменной xIRR_RES для определенного контракта на определенную отчетную дату...
-- В качестве потока берутся все плановые платежи по лизингу, фактические платежи до отчетной даты по поставкам и плановые платежи за все время по поставкам. (см. процедуру p_DM_XIRR_CALC)
*/

BEGIN
  select xIRR INTO xIRR_res FROM
  (
  with
                Contr_prev as (
                          SELECT cn1.contract_key L_key,
                                 cn2.contract_key S_key,
                                 cn1.branch_key,
                                 cn1.Currency_Key L_CUR,
                                 cn2.Currency_key S_CUR,
                                 OS.base_currency_key base_currency
                          from dwh.contracts cn1
                          left join dwh.contracts cn2
                              ON cn1.contract_key = cn2.contract_leasing_key
                              and cn2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                              and cn2.open_dt <= p_REPORT_DT
                          inner join dwh.ORG_STRUCTURE OS
                              ON OS.BRANCH_KEY = cn1.BRANCH_KEY
                          inner join dwh.clients cl
                              ON cl.client_key = cn1.client_key
                          inner join DWH.LEASING_CONTRACTS LC
                              ON cn1.contract_key = LC.contract_key
                          where  cn1.contract_key = p_contract_key
                                 and cn1.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                                 and cl.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                                 and LC.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                                 and ((LC.contract_fin_kind_desc <> 'ОперационнаяАренда' 
                                       and cn1.branch_key in (
                                                              select branch_key 
                                                              from dwh.cgp_group cgp_group 
                                                              where cgp_group.cgp_group_key = 1)
                                      )
                                        or 
                                      (LC.contract_fin_kind_desc is Null 
                                       and cn1.branch_key in (select branch_key 
                                                              from dwh.cgp_group cgp_group 
                                                              where cgp_group.cgp_group_key not in (1, 4))
                                       ))
                                 and cl.cgp_flg = '1'                     
                                 and cn1.open_dt <= p_REPORT_DT
                                -- and cn1.close_dt >= trunc (p_REPORT_DT, 'mm')
                                 and ( (cn1.IS_CLOSED_CONTRACT = 0 
                                        and cn1.branch_key in (
                                                              select branch_key 
                                                              from dwh.cgp_group cgp_group 
                                                              where cgp_group.cgp_group_key = 1))
                                        or (cn1.IS_CLOSED_CONTRACT is null) 
                                           and cn1.branch_key in (select branch_key 
                                                              from dwh.cgp_group cgp_group 
                                                              where cgp_group.cgp_group_key not in (1, 4))
                             )

                                 
                          ),
                          
                countt as (
                            select l_key, 
                                   count (L_KEY) countt
                            from contr_prev
                            group by l_KEY
                            ),
                            
                 Contr as (                           
                            select 
                                  contr.l_key l_key,
                                  s_key,
                                  branch_key,
                                  l_cur,
                                  s_cur,
                                  base_currency,
                                  case
                                    when countt.countt > 1
                                       then 1
                                    else 0
                                  end as flag
                            from contr_prev contr
                            inner join countt countt 
                                on contr.l_key = countt.l_key
                        ),

  -- Дотягиваются договора цессии для сбора полного потока 
                Contr_ces as (                                
                        SELECT 
                            cn1.L_key L_key,
                            cn1.S_key S_key,
                            cn3.contract_key L_key_dop,
                            cn4.contract_key S_key_dop,
                            cn1.branch_key,
                            cn1.L_CUR,
                            cn1.S_CUR,
                            cn1.base_currency base_currency,
                            cn1.flag
                        From Contr cn1
                        join dwh.contracts cn2 
                            ON cn1.l_key = cn2.contract_key
                            and cn2.valid_to_dttm = '01.01.2400'
                        left join dwh.contracts cn3
                            ON cn2.CONTRACT_ID_CD = cn3.CONTRACT_ID_CD 
                              and cn3.IS_CLOSED_CONTRACT = 1
                              and cn3.valid_to_dttm = '01.01.2400'
                        Left join dwh.contracts cn4
                              ON cn3.contract_key = cn4.contract_leasing_key  
                              and cn4.valid_to_dttm = '01.01.2400'
                          ),

               Flow_S as
                        (
                          SELECT Contr.L_KEY,
                                 Contr.branch_key,
                                 fact_rp1.CBC_DESC,
                                 fact_rp1.PAY_DT,
                                 fact_rp1.PAY_AMT,
                                 'Supply' TP,
                                 Contr.L_CUR CUR1,
                                 Contr.S_CUR CUR3,
                                 fact_rp1.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag
                          from Contr Contr
                          inner join dwh.fact_real_payments fact_rp1
                              ON Contr.L_Key = fact_rp1.contract_key
                          where fact_rp1.CBC_DESC in (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Supply' 
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_rp1.valid_to_dttm = '01.01.2400'
                          and fact_rp1.PAY_DT <= p_REPORT_DT
              
                      UNION ALL
              
                          SELECT Contr.L_KEY,
                                 Contr.branch_key,
                                 fact_rp2.CBC_DESC,
                                 fact_rp2.PAY_DT,
                                 fact_rp2.PAY_AMT,
                                 'Supply' TP,
                                 Contr.L_CUR CUR1,
                                 Contr.S_CUR CUR3,
                                 fact_rp2.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag
                          from Contr Contr
                          inner join dwh.fact_real_payments fact_rp2
                              ON Contr.S_Key = fact_rp2.contract_key
                          where fact_rp2.CBC_DESC in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_rp2.valid_to_dttm = '01.01.2400'
                          and fact_rp2.PAY_DT <= p_REPORT_DT
              
                      UNION ALL
              
                          SELECT Contr.L_key,
                                 Contr.branch_key,
                                 fact_pp.CBC_DESC,
                                 fact_pp.PAY_DT,
                                 fact_pp.PAY_AMT*-1,
                                 'Supply' TP,
                                 Contr.L_CUR CUR1,
                                 Contr.S_CUR CUR3,
                                 fact_pp.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag
                          from Contr Contr
                          inner join dwh.fact_plan_payments fact_pp
                              ON Contr.S_Key = fact_pp.contract_key
                          where fact_pp.CBC_DESC in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_pp.valid_to_dttm = '01.01.2400'
                          and fact_pp.PAY_DT > p_REPORT_DT
              
                       UNION ALL
              
                         SELECT Contr.L_key,
                               Contr.branch_key,
                               fact_pp.CBC_DESC,
                               fact_pp.PAY_DT,
                               fact_pp.PAY_AMT PAY_AMT,
                               'Supply_PLAN' TP,
                               Contr.L_CUR CUR1,
                               Contr.S_CUR CUR3,
                               fact_pp.CURRENCY_KEY CUR2,
                               Contr.base_currency,
                               Contr.flag
                           from Contr Contr
                                  inner join dwh.fact_plan_payments fact_pp
                          ON Contr.S_Key = fact_pp.contract_key
                          and fact_pp.valid_to_dttm = '01.01.2400'
                                  where fact_pp.CBC_DESC in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                                  and fact_pp.PAY_DT <= p_REPORT_DT
                           
                           
                         UNION ALL  
-- Добавление потока по цессии из старых договоров        
                                  
                          SELECT Contr.L_KEY,
                                 Contr.branch_key,
                                 fact_rp1.CBC_DESC,
                                 fact_rp1.PAY_DT,
                                 fact_rp1.PAY_AMT,
                                 'Supply' TP,
                                 Contr.L_CUR CUR1,
                                 Contr.S_CUR CUR3,
                                 fact_rp1.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag
                          from Contr_ces Contr
                          inner join dwh.fact_real_payments fact_rp1
                              ON Contr.L_Key_DOP = fact_rp1.contract_key
                          where fact_rp1.CBC_DESC  in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_rp1.valid_to_dttm = '01.01.2400'
                          and fact_rp1.PAY_DT <= p_REPORT_DT
              
                      UNION ALL
              
                          SELECT Contr.L_KEY,
                                 Contr.branch_key,
                                 fact_rp2.CBC_DESC,
                                 fact_rp2.PAY_DT,
                                 fact_rp2.PAY_AMT,
                                 'Supply' TP,
                                 Contr.L_CUR CUR1,
                                 Contr.S_CUR CUR3,
                                 fact_rp2.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag
                          from Contr_ces Contr
                          inner join dwh.fact_real_payments fact_rp2
                              ON Contr.S_Key_DOP = fact_rp2.contract_key
                          where fact_rp2.CBC_DESC  in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_rp2.valid_to_dttm = '01.01.2400'
                          and fact_rp2.PAY_DT <= p_REPORT_DT
              
                      UNION ALL
              
                          SELECT Contr.L_key,
                                 Contr.branch_key,
                                 fact_pp.CBC_DESC,
                                 fact_pp.PAY_DT,
                                 fact_pp.PAY_AMT*-1,
                                 'Supply' TP,
                                 Contr.L_CUR CUR1,
                                 Contr.S_CUR CUR3,
                                 fact_pp.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag
                          from Contr_ces Contr
                          inner join dwh.fact_plan_payments fact_pp
                              ON Contr.S_Key_DOP = fact_pp.contract_key
                          where fact_pp.CBC_DESC  in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_pp.valid_to_dttm = '01.01.2400'
                          and fact_pp.PAY_DT > p_REPORT_DT
              
                       UNION ALL
              
                         SELECT Contr.L_key,
                           Contr.branch_key,
                           fact_pp.CBC_DESC,
                           fact_pp.PAY_DT,
                           fact_pp.PAY_AMT PAY_AMT,
                           'Supply_PLAN' TP,
                           Contr.L_CUR CUR1,
                           Contr.S_CUR CUR3,
                           fact_pp.CURRENCY_KEY CUR2,
                           Contr.base_currency,
                           Contr.flag
                           from Contr_ces Contr
                                  inner join dwh.fact_plan_payments fact_pp
                          ON Contr.S_Key_DOP = fact_pp.contract_key
                          and fact_pp.valid_to_dttm = '01.01.2400'
                                  where fact_pp.CBC_DESC  in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                                  and fact_pp.PAY_DT <= p_REPORT_DT                              
 -- Конец доп. потока                             
                                ),
                Flow_L as             
                          (
                           SELECT distinct Contr.L_KEY,                      -- Исключение задваивания в случае, если одному контракту лизинга соответствует несколько договоров поставки (flag = 1)
                                  contr.branch_key,                                                           
                                  fact_pp.CBC_DESC,
                                  PAY_DT,
                                  PAY_AMT, 
                                  'LEASING' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.S_CUR CUR3, 
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag
                           from Contr Contr
                           inner join dwh.fact_plan_payments fact_pp
                              ON Contr.L_Key = fact_pp.contract_key
                          -- inner join mindt m on Contr.L_Key = m.L_key
                           where fact_pp.CBC_DESC in  (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Leasing' 
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)                 -- выбор плановых платежей по договорам лизинга с типом классификации КБК 'Leasing'
                           and fact_pp.valid_to_dttm = '01.01.2400'
                           and contr.flag = 1
                           
                           UNION ALL
                           
                           SELECT Contr.L_KEY,
                                  contr.branch_key,
                                  fact_pp.CBC_DESC,
                                  PAY_DT,
                                  PAY_AMT, 
                                  'LEASING' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.S_CUR CUR3,
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag
                           from Contr Contr
                           inner join dwh.fact_plan_payments fact_pp
                              ON Contr.L_Key = fact_pp.contract_key
                          -- inner join mindt m on Contr.L_Key = m.L_key
                           where fact_pp.CBC_DESC in  (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Leasing' 
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)                 -- выбор плановых платежей по договорам лизинга с типом классификации КБК 'Leasing'
                           and fact_pp.valid_to_dttm = '01.01.2400'
                           and contr.flag = 0                                                         -- В случае соответствия одному договору лизинга одного договора поставки, берется все как есть.  
                           
                           UNION ALL
       
                          -- Дополнительный поток по цессии 
       
                           SELECT distinct Contr.L_KEY,                          -- Исключение задваивания в случае, если одному контракту лизинга соответствует несколько договоров поставки (flag = 1)
                                  contr.branch_key,
                                  fact_pp.CBC_DESC,
                                 PAY_DT,
                                  PAY_AMT, 
                                  'LEASING' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.S_CUR CUR3, 
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag
                           from dwh.fact_plan_payments fact_pp
                           INNER join (select distinct 
                                        L_KEY,
                                        L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        S_CUR,
                                        base_currency,
                                        flag
                                        from Contr_ces) Contr
                              ON Contr.L_Key_dop = fact_pp.contract_key
                          -- inner join mindt m on Contr.L_Key = m.L_key
                           where fact_pp.CBC_DESC in  (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Leasing' 
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)                -- выбор плановых платежей по договорам лизинга с типом классификации КБК 'Leasing'
                           and fact_pp.valid_to_dttm = '01.01.2400'
                           and contr.flag = 1
                           
                           UNION ALL
                           
                           SELECT Contr.L_KEY,
                                  contr.branch_key,
                                  fact_pp.CBC_DESC,
                                 PAY_DT,
                                  PAY_AMT, 
                                  'LEASING' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.S_CUR CUR3, 
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag
                           from dwh.fact_plan_payments fact_pp
                           INNER join (select distinct 
                                        L_KEY,
                                        L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        S_CUR,
                                        base_currency,
                                        flag
                                        from Contr_ces) Contr 
                              ON Contr.L_Key_dop = fact_pp.contract_key
                          -- inner join mindt m on Contr.L_Key = m.L_key
                           where fact_pp.CBC_DESC in  (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Leasing' 
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)                -- выбор плановых платежей по договорам лизинга с типом классификации КБК 'Leasing'
                           and fact_pp.valid_to_dttm = '01.01.2400'
                           and contr.flag = 0                                                             -- В случае соответствия одному договору лизинга одного договора поставки, берется все как есть. 
                        
                           ),
           
                 Flow_Cur as(                   
                           select * from Flow_L
                           UNION ALL
                           select * from Flow_S
                           UNION ALL
                           select L_key as L_key, branch_key, 'ОД.1.1' as CBC_DESC, p_REPORT_DT as PAY_DT, 0 as PAY_AMT, 'TEH'  as TP,
                                  Contr.L_CUR as CUR1, Contr.L_CUR as CUR3, Contr.L_CUR as CUR2, Contr.base_currency, 0 flag
                            from Contr Contr
                    ),                  
              
            /*Объединение платежей по договорам лизинга, поставок и добавление строки с отчетной датой 
              с суммой 0 для расчета количества дней от последнего платежа до отчетной даты.*/
                 Flow_L_CUR as                  
                          (
                            select L_KEY,
                            branch_key,
                                   CBC_DESC,
                                   PAY_DT,
                                  /* в случае, если 
                                             -- валюта плана-факта/договора равна/не равна базовой валюте;
                                             -- дата платежа до/после даты отчета,
                                     сумма платежа умножается/не умножается на курс валюты факта/плана и делится/не делится на курс валюты договора
                                  
                                  Условные обозначения: -- Д_ВАЛ - Валюта договора 
                                                        -- Б_ВАЛ - Базовая валюта организации 
                                                        -- ФП_ВАЛ - валюта факта/плана,
                                                        -- ДАТА - дата платежа 
                                                        -- О_ДАТА - отчетная дата
                                                        -- СУММ - сумма платежа
                                                        -- ФП_КУРС - курс валюты факта/плана до отчетной даты 
                                                        -- Д_КУРС - курс валюты договора до отчетной даты
                                                        -- ФП_КУРС_О_ДАТА - курс валюты факта/плана на отчетную дату
                                                        -- Д_КУРС_О_ДАТА - курс валюты договора на отчетную дату
                                  */
                                   (case
                                   when CUR1 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT  --Если Д_ВАЛ <> Б_ВАЛ и ФП_ВАЛ <> Б_ВАЛ и ДАТА <= О_ДАТА, 
                                      then PAY_AMT*rt1.EXCHANGE_RATE/rt2.EXCHANGE_RATE                                 --то    СУММ = СУММ * ФП_КУРС /  Д_КУРС  
                                  
                                   when CUR1 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT > p_REPORT_DT   --Если Д_ВАЛ <> Б_ВАЛ и ФП_ВАЛ <> Б_ВАЛ и ДАТА > О_ДАТА, 
                                      then PAY_AMT*rt_rp1.EXCHANGE_RATE/rt_rp2.EXCHANGE_RATE                           --то    СУММ = СУММ * ФП_КУРС_О_ДАТА /  Д_КУРС_О_ДАТА 
                                   
                                   when CUR1 = s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT   --Если Д_ВАЛ = Б_ВАЛ и ФП_ВАЛ <> Б_ВАЛ и ДАТА <= О_ДАТА,
                                      then PAY_AMT*rt1.EXCHANGE_RATE                                                   --то    СУММ = СУММ * ФП_КУРС
                                   
                                   when CUR1 = s.base_currency and CUR2 <> s.base_currency and PAY_DT > p_REPORT_DT    --Если Д_ВАЛ = Б_ВАЛ и ФП_ВАЛ <> Б_ВАЛ и ДАТА > О_ДАТА, 
                                      then PAY_AMT*rt_rp1.EXCHANGE_RATE                                                --то    СУММ = СУММ * ФП_КУРС_О_ДАТА
                                   
                                   when CUR2 = s.base_currency and CUR1 <> s.base_currency and PAY_DT <= p_REPORT_DT   --Если Д_ВАЛ <> Б_ВАЛ и ФП_ВАЛ = Б_ВАЛ и ДАТА <= О_ДАТА,
                                      then PAY_AMT/rt2.EXCHANGE_RATE                                                   --то    СУММ = СУММ / Д_КУРС
                                 
                                   when CUR2 = s.base_currency and CUR1 <> s.base_currency and PAY_DT > p_REPORT_DT    --Если Д_ВАЛ <> Б_ВАЛ и ФП_ВАЛ = Б_ВАЛ и ДАТА > О_ДАТА,
                                      then PAY_AMT/rt_rp2.EXCHANGE_RATE                                                --то    СУММ = СУММ / Д_КУРС_О_ДАТА
                                  
                                   else PAY_AMT                                                                        --Иначе, СУММ = СУММ.
                                   end) as PAY_AMT_cur,
                                   PAY_AMT,
                                   TP,
                                   CUR1,
                                   CUR2
                            from Flow_CUR s
                               
                               left join dwh.EXCHANGE_RATES rt1               -- привязка к курсам валют по равенству даты курса  дате платежа и по валюте факта/плана
                                  on s.PAY_DT = rt1.ex_rate_dt 
                                  and s.CUR2= rt1.CURRENCY_KEY 
                                  and rt1.BASE_CURRENCY_KEY = s.base_currency
                                  and rt1.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                               
                               left join dwh.EXCHANGE_RATES rt2                -- привязка к курсам валют по равенству даты курса дате платежа и по валюте договора
                                  on s.PAY_DT = rt2.ex_rate_dt 
                                  and s.CUR1= rt2.CURRENCY_KEY 
                                  and rt2.BASE_CURRENCY_KEY = s.base_currency
                                  and rt2.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                               
                               left join dwh.EXCHANGE_RATES rt_rp1             -- привязка к курсам валют по равенству даты курса отчетной дате и по валюте факта/плана
                                  on rt_rp1.ex_rate_dt = p_REPORT_DT 
                                  and s.CUR2= rt_rp1.CURRENCY_KEY 
                                  and rt_rp1.BASE_CURRENCY_KEY = s.base_currency
                                  and rt_rp1.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                               
                               left join dwh.EXCHANGE_RATES rt_rp2             -- привязка к курсам валют по равенству даты курса отчетной дате и по валюте договора
                                  on rt_rp2.ex_rate_dt= p_REPORT_DT 
                                  and s.CUR1= rt_rp2.CURRENCY_KEY 
                                  and rt_rp2.BASE_CURRENCY_KEY = s.base_currency
                                  and rt_rp2.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                          ),
                          
                Flow_S_CUR as                  
                          (
                            select L_KEY,
                            branch_key,
                                   CBC_DESC,
                                   PAY_DT,
                                  /* в случае, если 
                                             -- валюта плана-факта/договора равна/не равна базовой валюте;
                                             -- дата платежа до/после даты отчета,
                                     сумма платежа умножается/не умножается на курс валюты факта/плана и делится/не делится на курс валюты договора
                                  
                                  Условные обозначения: -- Д_ВАЛ - Валюта договора 
                                                        -- Б_ВАЛ - Базовая валюта организации 
                                                        -- ФП_ВАЛ - валюта факта/плана,
                                                        -- ДАТА - дата платежа 
                                                        -- О_ДАТА - отчетная дата
                                                        -- СУММ - сумма платежа
                                                        -- ФП_КУРС - курс валюты факта/плана до отчетной даты 
                                                        -- Д_КУРС - курс валюты договора до отчетной даты
                                                        -- ФП_КУРС_О_ДАТА - курс валюты факта/плана на отчетную дату
                                                        -- Д_КУРС_О_ДАТА - курс валюты договора на отчетную дату
                                  */
                                   (case
                                   when CUR3 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT <= TO_DATE ('30.06.2014', 'DD.MM.YYYY')  --Если Д_ВАЛ <> Б_ВАЛ и ФП_ВАЛ <> Б_ВАЛ и ДАТА <= О_ДАТА, 
                                      then PAY_AMT*rt1.EXCHANGE_RATE/rt2.EXCHANGE_RATE                                 --то    СУММ = СУММ * ФП_КУРС /  Д_КУРС  
                                  
                                                                      
                                   when CUR3 = s.base_currency and CUR2 <> s.base_currency and PAY_DT <= TO_DATE ('30.06.2014', 'DD.MM.YYYY')   --Если Д_ВАЛ = Б_ВАЛ и ФП_ВАЛ <> Б_ВАЛ и ДАТА <= О_ДАТА,
                                      then PAY_AMT*rt1.EXCHANGE_RATE                                                   --то    СУММ = СУММ * ФП_КУРС
                                   
                                   
                                   when CUR2 = s.base_currency and CUR3 <> s.base_currency and PAY_DT <= TO_DATE ('30.06.2014', 'DD.MM.YYYY')   --Если Д_ВАЛ <> Б_ВАЛ и ФП_ВАЛ = Б_ВАЛ и ДАТА <= О_ДАТА,
                                     then PAY_AMT/rt2.EXCHANGE_RATE                                                   --то    СУММ = СУММ / Д_КУРС
                                 
                                  
                                   else PAY_AMT                                                                        --Иначе, СУММ = СУММ.
                                   end) as PAY_AMT_cur,
                                   PAY_AMT,
                                   TP,
                                   CUR3,
                                   CUR2
                            from Flow_CUR s
                               
                               left join dwh.EXCHANGE_RATES rt1               -- привязка к курсам валют по равенству даты курса  дате платежа и по валюте факта/плана
                                  on s.PAY_DT = rt1.ex_rate_dt 
                                  and s.CUR2= rt1.CURRENCY_KEY 
                                  and rt1.BASE_CURRENCY_KEY = s.base_currency
                                  and rt1.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                               
                               left join dwh.EXCHANGE_RATES rt2                -- привязка к курсам валют по равенству даты курса дате платежа и по валюте договора
                                  on s.PAY_DT = rt2.ex_rate_dt 
                                  and s.CUR3= rt2.CURRENCY_KEY 
                                  and rt2.BASE_CURRENCY_KEY = s.base_currency
                                  and rt2.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                               
                               left join dwh.EXCHANGE_RATES rt_rp1             -- привязка к курсам валют по равенству даты курса отчетной дате и по валюте факта/плана
                                  on rt_rp1.ex_rate_dt = TO_DATE ('30.06.2014', 'DD.MM.YYYY') 
                                  and s.CUR2= rt_rp1.CURRENCY_KEY 
                                  and rt_rp1.BASE_CURRENCY_KEY = s.base_currency
                                  and rt_rp1.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                               
                               left join dwh.EXCHANGE_RATES rt_rp2             -- привязка к курсам валют по равенству даты курса отчетной дате и по валюте договора
                                  on rt_rp2.ex_rate_dt= TO_DATE ('30.06.2014', 'DD.MM.YYYY') 
                                  and s.CUR3= rt_rp2.CURRENCY_KEY 
                                  and rt_rp2.BASE_CURRENCY_KEY = s.base_currency
                                  and rt_rp2.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                          ),
  
                balance as (
                           
                            select L_key,
                            branch_key,
                                   PAY_DT,
                                   sum(pay_amt_cur) over (partition by l_key order by pay_dt) bal1,
                                   sum(pay_amt) over (partition by l_key order by pay_dt) bal2
                            from flow_L_cur
                            where TP <> 'Supply_PLAN'
                           ),
  
                 min_dt as
                            (
                                select 
                                      L_KEY,
                                      
                                      min(case 
                                              when bal1 < 0
                                                then pay_dt
                                              else null
                                          end) min_dt
                                from balance 
                                group by L_KEY
                                ),
                  
                 Flow_Underpay as
                                (
                                SELECT  L_key,
                                        branch_key,
                                        sum(PAY_AMT_CuR)*-1 PAY_AMT_CuR
                                from 
                                        Flow_S_CUR
                                WHERE TP in ('Supply','Supply_PLAN')
                                 and pay_dt <= p_REPORT_DT
                                group by  L_key, branch_key
                      ),
                
                 Flow_prev_1 as
                                (
                                 SELECT
                                        L_KEY,
                                        branch_key,
                                        p_REPORT_DT + 1 pay_dt ,
                                        nvl(PAY_AMT_CuR, 0) summ,
                                        PAY_AMT_CuR PAY_AMT
                                 FROM Flow_Underpay
                                 where PAY_AMT_CuR < 0
                      
                                 UNION ALL
                      
                      
                                 SELECT 
                                        L_KEY, 
                                        branch_key,  
                                        PAY_DT, 
                                        SUM(nvl(PAY_AMT_CUR, 0)) summ, 
                                        SUM(PAY_AMT) PAY_AMT
                                 FROM FLOW_L_CUR
                                 WHERE TP <> 'Supply_PLAN'
                                 group by L_KEY, branch_key,  PAY_DT
                                 ),


                  FLOW_prev as
                                (select L_KEY, 
                                         branch_key, 
                                         PAY_DT, 
                                         summ, 
                                         sum (summ) over (partition by L_KEY order by pay_dt rows between unbounded preceding and current row) sum_prev,
                                         PAY_AMT 
                                  from  Flow_prev_1
                                ),

                  FLOW as
                                 (select 
                                         f.L_KEY, 
                                         branch_key, 
                                         PAY_DT, 
                                         summ, 
                                         sum_prev
                                  from  
                                         FLOW_prev f
                                  inner join min_dt min_dt
                                     on min_dt.l_key = f.l_key
                                  where summ < 0
                                    and pay_dt <= min_dt
                                                
                                
                                 union all
                                
                                  select   
                                          f.L_KEY, 
                                          branch_key, 
                                          PAY_DT, 
                                          (case when 
                                             sum_prev >= 0
                                               then abs (summ)
                                             else sum_prev - summ
                                          end) as summ,
                                          sum_prev    
                                  from 
                                         FLOW_prev f
                                  inner join min_dt min_dt
                                    on min_dt.l_key = f.l_key
                                  where summ < 0
                                    and pay_dt <= min_dt
                                        
                                union all
                                
                                  select   
                                          f.L_KEY, 
                                          branch_key, 
                                          PAY_DT, 
                                          summ,
                                          sum_prev
                                  from 
                                          FLOW_prev f
                                  inner join min_dt min_dt
                                     on min_dt.l_key = f.l_key 
                                  where pay_dt > min_dt
                                
                                union all
                                
                                  select   
                                          f.L_KEY, 
                                          branch_key, 
                                          PAY_DT, 
                                          summ,
                                          sum_prev
                                  from 
                                          FLOW_prev f
                                  left join min_dt min_dt
                                     on min_dt.l_key = f.l_key 
                                  where min_dt is null
                          ),
  /* Если сумма фактических платежей больше суммы плановых (div < 1), то xirr не считаем, проставляя -1...
  */
  excptn_zero_div as   
  (select abs(sum(case when summ >= 0 then summ else 0 end)) / decode (abs(sum(case when summ < 0 then summ else 0 end)), 0, -1, abs(sum(case when summ < 0 then summ else 0 end))) as div from flow)

   select

                 nvl(irr*100, -1) XIRR
                 from
                    (
                    select * from flow, excptn_zero_div d where d.div > 1
                    /* Итерационный метод Ньютона для расчета xIRR с точностью до 10 знака после запятой...
                    */
                     model
                      dimension by (row_number() over (order by PAY_DT) rn)
                      measures(PAY_DT-first_value(PAY_DT) over (order by PAY_DT) dt, summ s, 0 ss, 1 disc_summ, 0 irr, 1 interv/*100%*/, 0 iter)
                      rules iterate(100) until (abs(interv[1])<power(10,-10))
                            (ss[any]=s[CV()]/power(1+IRR[1],dt[CV()]/365),
                            irr[1] = decode(sign(disc_summ[1]),sign(sum(ss)[any]),irr[1]+sign(disc_summ[1])*interv[1],irr[1]-sign(disc_summ[1])*interv[1]/2),
                            interv[1]= decode(sign(disc_summ[1]),sign(sum(ss)[any]),interv[1],interv[1]/2),
                            disc_summ[1]=sum(ss)[any],
                            iter[1]=iteration_number+1
                             )
                    )
      where rn=1
      );
      return xIRR_res;
END;
/

