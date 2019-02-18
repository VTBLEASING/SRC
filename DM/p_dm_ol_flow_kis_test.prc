CREATE OR REPLACE PROCEDURE DM.p_DM_OL_FLOW_KIS_TEST(
      p_REPORT_DT IN date,
      p_group_key in  number,
      p_contract_key in number default null,
      p_snapshot_cd varchar2 default 'Основной КИС'
)

IS
--v_count number;
   v_cnt number;
   v_max_executions number := 120;
   v_cur_ind number := 1;
   v_group_key number;
/* Процедура, заполняющая промежуточную витрину DM_XIRR вычисленными значениями XIRR для каждого контракта. 
-- В качестве параметров на вход подаются дата отчета (p_REPORT_DT) и номер группы организаций (p_group_key).
-- В процедуре реализован вывод номера договора (contract_id), вычисленного XIRR, даты отчета (ODTTM) и ключа филиала (branch_key) в таблицу DM_XIRR...
-- В качестве потока берутся все плановые платежи по лизингу, фактические платежи до отчетной даты по поставкам и плановые платежи за все время по поставкам.
-- Полученный поток заносится в таблицу DM_XIRR_FLOW, индексируемую IX_DM_XIRR_FLOW по полям L_KEY (номер контракта), REPORT_DT (отчетная дата), EXCPTN_ZERO_DIV (отношение плановых и фактических платежей).
*/
BEGIN
    dm.u_log(p_proc => 'p_DM_OL_FLOW_KIS',
           p_step => 'INPUT PARAMS',
           p_info => 'p_group_key:'||p_group_key||'p_REPORT_DT:'||p_REPORT_DT||'p_snapshot_cd:'||p_snapshot_cd||'p_contract_key:'||p_contract_key); 

     v_group_key:=nvl(p_group_key,1);
   delete from dm_ol_flow_orig 
   where SNAPSHOT_dt = p_report_dt
   and snapshot_cd = 'Основной КИС'      -- Очистка таблицы DM_XIRR_FLOW за данный отчетный период
   and (branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = v_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
 );
  dm.u_log(p_proc => 'p_DM_OL_FLOW_KIS',
           p_step => 'delete from dm_ol_flow_orig',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
   insert into dm.dm_ol_flow_orig
     (l_key, branch_key, cbc_desc, pay_dt, pay_amt_cur, pay_amt, tp, cur1, cur2, cur3, pay_amt_cur_supply, snapshot_dt, snapshot_cd, l_key_dop, s_key,OPER_START_DT)
     (
   select * from (
           with
   /* Выборка действующих контрактов лизинга и соответствующих им договоров поставок, связанных по полю CONTRACT_LEASING_KEY и следующему условию:
   -- дата начала договора <= дата окончания отчетного периода
   -- дата окончания договора >= дата начала отчетного периода                  
   */
                  Contr_prev as (
                          SELECT cn1.contract_key L_key,
                                 cn2.contract_key S_key,
                                 cn1.branch_key,
                                 cn1.Currency_Key L_CUR,                                      -- Валюта договора лизинга
                                 cn2.Currency_key S_CUR,                                      -- Валюта договора поставки
                                 OS.base_currency_key base_currency,
                                 cn1.valid_to_dttm,
                                 cn1.CONTRACT_ID_CD,
                                 cn1.client_key , 
                                 cn2.client_key CLIENT_SUPPLY_KEY,
                                 cl.business_category_key,
                                 cl.group_key,
                                 cl.grf_group_key,
                                 cl.member_key,
                                 cl.credit_rating_key
                          from dwh.contracts cn1
                          left join dwh.contracts cn2
                              ON cn1.contract_key = cn2.contract_leasing_key
                              and cn2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                              and cn2.open_dt <= p_REPORT_DT
                          inner join dwh.ORG_STRUCTURE OS                                      -- Для пересчета платежей код базовой валюты тянется из справочника структуры компании
                              ON OS.BRANCH_KEY = cn1.BRANCH_KEY
                          inner join dwh.cgp_group cgp_group                                   -- вяжемся с ручным справочником групп организаций для расчета потока для данной группы организаций
                              ON cn1.branch_key = cgp_group.branch_key
                              and cgp_group.begin_dt <= p_REPORT_DT
                              and cgp_group.end_dt > p_REPORT_DT
                          inner join dwh.clients cl
                              ON cl.client_key = cn1.client_key
                          inner join DWH.LEASING_CONTRACTS LC                                  -- Вяжемся со справчоником лизинговых контрактов для того, чтобы выбрать тип "Финансовый Лизинг"
                              ON cn1.contract_key = LC.contract_key
                          where  cn1.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                                 and cl.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                                 and LC.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                                 and ((LC.contract_fin_kind_desc = 'ОперационнаяАренда' 
                                       and cn1.branch_key in (                                       -- В случае Головного офиса выбирается 'ФинансовыйЛизинг'
                                                              select branch_key 
                                                              from dwh.cgp_group cgp_group 
                                                              where cgp_group.cgp_group_key = 2
                                                              and cgp_group.begin_dt <= p_REPORT_DT
                                                              and cgp_group.end_dt > p_REPORT_DT)
                                      )
                                        or 
                                      (LC.contract_fin_kind_desc is Null                             -- В случае дочерних организаций выбирается Null
                                       and cn1.branch_key in (select branch_key 
                                                              from dwh.cgp_group cgp_group 
                                                              where cgp_group.cgp_group_key not in (2)
                                                              and cgp_group.begin_dt <= p_REPORT_DT
                                                              and cgp_group.end_dt > p_REPORT_DT)
                                       ))
                                -- and cl.cgp_flg = '1'                                                -- Договор КГП
                                 and cgp_group.cgp_group_key = v_group_key                               
                                 and cn1.open_dt <= p_REPORT_DT
                                 and nvl(cn1.rehiring_flg, 0) != 1
                                 --and cn1.EXClUDE_CGP IS NULL
                          ),
                
                /* В случае, когда одному договору лизинга соответствует более одного договора поставки, в потоке платежей лизинга (Flow_L) используется distinct для удаления дублей платежей.
                      Для выделения этого случая используется флаг, который = 1 в этом случае.
                   В случае, когда одному договору лизинга соответствует один договор поставки, в потоке платежей лизинга (Flow_L) берутся все платежи.
                      Для выделения этого случая используется флаг, который = 0.
                  
                */
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
                                  end as flag                     -- флаг, используемый при расчете потока лизинговых платежей (Flow_L)
                                  ,CONTRACT_ID_CD,
                                 client_key , 
                                 CLIENT_SUPPLY_KEY,
                                 business_category_key,
                                 group_key,
                                 grf_group_key,
                                 member_key,
                                 credit_rating_key
                            from contr_prev contr
                            inner join countt countt 
                                on contr.l_key = countt.l_key
                        ),

                /* Дотягиваются договора цессии для сбора полного потока
                */
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
                            cn1.flag,
                                                             cn1.CLIENT_SUPPLY_KEY,
                                 cn1.business_category_key,
                                 cn1.group_key,
                                 cn1.grf_group_key,
                                 cn1.member_key,
                                 cn1.credit_rating_key
                        From Contr cn1
                        /*join dwh.contracts cn2 
                            ON cn1.l_key = cn2.contract_key
                            and cn2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                            and cn1.branch_key = cn2.branch_key*/
                        left join dwh.contracts cn3
                            ON cn1.CONTRACT_ID_CD = cn3.CONTRACT_ID_CD        -- привязка по Id транзакции для склейки двух договоров...
                              and cn3.contract_key <> cn1.L_key --cn2.contract_key 
                              -- and cn3.IS_CLOSED_CONTRACT = 1                  -- уже закрытые договора лизинга для сбора полного потока.
                              and cn3.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                              and cn3.branch_key = cn1.branch_key--cn2.branch_key
                        Left join dwh.contracts cn4
                              ON cn3.contract_key = cn4.contract_leasing_key  
                              and cn4.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          ),
                    Contr_ces_uniq7 as     (select distinct 
                                        L_KEY,
                                        S_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        S_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces),
/* Выборка фактических и плановых платежей по договорам поставки ( с кодом КБК 3.1 - 3.5 и типом КБК = 'Supply'). 
    - Фактические платежи выбираются по следующему условию:
         дата фактического платежа <= дата окончания отчетного периода.

    - Плановые платежи выбираются за все время действия договора
    
   Добавляются платежи по договорам цессии 
 */
              Flow_S as
                        (
                          SELECT Contr.L_KEY,
                                 Contr.branch_key,
                                 fact_rp1.CBC_DESC,
                                 fact_rp1.PAY_DT,
                                 fact_rp1.PAY_AMT,
                                 'Supply_fact' TP,
                                 Contr.L_CUR CUR1,
                                 fact_rp1.CURRENCY_KEY CUR3,
                                 fact_rp1.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag,
                                 Contr.L_KEY L_KEY_DOP,
                                 Contr.L_KEY S_KEY,
                                 abs(fact_rp1.EXCHANGE_RATE) ex_rate
                          from (select distinct 
                                        L_KEY,
                           --             L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                           --             L_CUR S_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces) Contr
                          inner join dwh.fact_real_payments fact_rp1
                              ON Contr.L_Key = fact_rp1.contract_key                                -- связка таблиц договоров и фактических платежей по ключу договора лизинга 
                          where fact_rp1.CBC_DESC in (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Supply'                    -- выбор фактических платежей по договорам поставок с типом КБК 'Supply'
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_rp1.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          and fact_rp1.PAY_DT <= p_REPORT_DT
              
                      UNION ALL
              
                          SELECT Contr.L_KEY,
                                 Contr.branch_key,
                                 fact_rp2.CBC_DESC,
                                 fact_rp2.PAY_DT,
                                 fact_rp2.PAY_AMT,
                                 'Supply_fact' TP,
                                 Contr.L_CUR CUR1,
                                 Contr.S_CUR CUR3,
                                 fact_rp2.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag,
                                 Contr.L_KEY L_KEY_DOP,
                                 Contr.S_KEY S_KEY,
                                 abs(fact_rp2.EXCHANGE_RATE) ex_rate                                    
                          from (select distinct 
                                        L_Key,
                                        S_KEY,
                              --          L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        S_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces) Contr
                          inner join dwh.fact_real_payments fact_rp2
                              ON Contr.S_Key = fact_rp2.contract_key                              -- связка таблиц договоров и фактических платежей по ключу договора поставки 
                          where fact_rp2.CBC_DESC in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply'                   -- выбор фактических платежей по договорам поставок с типом КБК 'Supply'
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_rp2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          and fact_rp2.PAY_DT <= p_REPORT_DT
              
                      UNION ALL
              
                          SELECT /*+ NO_INDEX(fact_pp) */  Contr.L_key,
                                 Contr.branch_key,
                                 fact_pp.CBC_DESC,
                                 fact_pp.PAY_DT,
                                 fact_pp.PAY_AMT*-1,                                              -- Поскольку из EXCEL файла Поставщики.xls платежи загружаются со знаком (+), то меняем знак на (-)
                                 'Supply_plan' TP,
                                 Contr.L_CUR CUR1,
                                 Contr.S_CUR CUR3,
                                 fact_pp.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag,
                                 Contr.L_KEY L_KEY_DOP,
                                 Contr.S_KEY S_KEY,
                                 Null ex_rate                                   
                          from (select distinct 
                                        L_Key,
                                        S_KEY,
                                 --       L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        S_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces) Contr
                          inner join dwh.fact_plan_payments fact_pp
                             ON Contr.S_Key = fact_pp.contract_key
                          where fact_pp.CBC_DESC in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_pp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          and p_REPORT_DT between fact_pp.BEGIN_DT and fact_pp.END_DT
--                          and fact_pp.PAY_DT > p_REPORT_DT
                    
                           
                         UNION ALL  

-- Добавление потока по цессии из старых договоров        
                                  
                          SELECT Contr.L_KEY,
                                 Contr.branch_key,
                                 fact_rp1.CBC_DESC,
                                 fact_rp1.PAY_DT,
                                 fact_rp1.PAY_AMT,
                                 'Supply_fact' TP,
                                 Contr.L_CUR CUR1,
                                 L_DOP_CO.CURRENCY_KEY CUR3,
                                 fact_rp1.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag,
                                 Contr.L_Key_DOP L_KEY_DOP,
                                 Contr.L_Key_DOP S_KEY,
                                 abs(fact_rp1.EXCHANGE_RATE) ex_rate                                   
                          from(select distinct 
                                        L_KEY,
                                        L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces) Contr
                          inner join dwh.fact_real_payments fact_rp1
                              ON Contr.L_Key_DOP = fact_rp1.contract_key
                          inner join dwh.contracts L_DOP_CO
                              on Contr.L_Key_DOP = L_DOP_CO.contract_key
                              and L_DOP_CO.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          where fact_rp1.CBC_DESC  in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_rp1.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          and fact_rp1.PAY_DT <= p_REPORT_DT
              
                      UNION ALL
              
                          SELECT Contr.L_KEY,
                                 Contr.branch_key,
                                 fact_rp2.CBC_DESC,
                                 fact_rp2.PAY_DT,
                                 fact_rp2.PAY_AMT,
                                 'Supply_fact' TP,
                                 Contr.L_CUR CUR1,
                                 Co.CURRENCY_KEY CUR3,
                                 fact_rp2.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag,
                                 Contr.L_Key L_KEY_DOP,
                                 Contr.S_KEY_DOP S_KEY,
                                 abs(fact_rp2.EXCHANGE_RATE) ex_rate                                    
                          from   (select distinct 
                                        L_KEY,
                                        S_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        S_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces) Contr                          

                          inner join dwh.fact_real_payments fact_rp2
                              ON Contr.S_Key_DOP = fact_rp2.contract_key
                          inner join dwh.contracts co 
                              on Contr.S_Key_DOP = co.contract_key
                              and co.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          where fact_rp2.CBC_DESC  in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_rp2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          and fact_rp2.PAY_DT <= p_REPORT_DT
              
                      UNION ALL
              
                          SELECT /*+ NO_INDEX(fact_pp) */ Contr.L_key,
                                 Contr.branch_key,
                                 fact_pp.CBC_DESC,
                                 fact_pp.PAY_DT,
                                 fact_pp.PAY_AMT*-1,
                                 'Supply_plan' TP,
                                 Contr.L_CUR CUR1,
                                 co.CURRENCY_KEY CUR3,
                                 fact_pp.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag,
                                 Contr.L_Key L_KEY_DOP,
                                 Contr.S_KEY_DOP S_KEY, 
                                 Null ex_rate                                  
                          from(select *
                                  from Contr_ces_uniq7) Contr                          
                          inner join dwh.fact_plan_payments fact_pp
                              ON Contr.S_Key_DOP = fact_pp.contract_key
                          inner join dwh.contracts co 
                              on Contr.S_Key_DOP = co.contract_key
                              and co.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          where fact_pp.CBC_DESC  in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_pp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          and p_REPORT_DT between fact_pp.BEGIN_DT and fact_pp.END_DT 
 -- Конец доп. потока                             
                                ),

                                
                Flow_S_CUR as                  
                          (
                            select L_KEY,
                                   branch_key,
                                   CBC_DESC,
                                   PAY_DT,
                                   PAY_AMT,
                                   TP,
                                   CUR1,
                                   CUR3,
                                   CUR2,
                                   base_currency,
                                   flag,
                                   L_KEY_DOP,
                                   S_KEY,                                    
                                   (
                                         case
                                         when CUR1 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT   --Если Д_ВАЛ <> Б_ВАЛ и ФП_ВАЛ <> Б_ВАЛ и ДАТА <= О_ДАТА, 
                                            then PAY_AMT*rt1.EXCHANGE_RATE/rt2.EXCHANGE_RATE                                --то    СУММ = СУММ * ФП_КУРС /  Д_КУРС  
                                        
                                         when CUR1 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT > p_REPORT_DT    --Если Д_ВАЛ <> Б_ВАЛ и ФП_ВАЛ <> Б_ВАЛ и ДАТА > О_ДАТА, 
                                            then PAY_AMT*rt_rp1.EXCHANGE_RATE/rt_rp2.EXCHANGE_RATE                          --то    СУММ = СУММ * ФП_КУРС_О_ДАТА /  Д_КУРС_О_ДАТА 
                                         
                                         when CUR1 = s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT    --Если Д_ВАЛ = Б_ВАЛ и ФП_ВАЛ <> Б_ВАЛ и ДАТА <= О_ДАТА,
                                            then PAY_AMT*rt1.EXCHANGE_RATE                                                   --то    СУММ = СУММ * ФП_КУРС
                                         
                                         when CUR1 = s.base_currency and CUR2 <> s.base_currency and PAY_DT > p_REPORT_DT     --Если Д_ВАЛ = Б_ВАЛ и ФП_ВАЛ <> Б_ВАЛ и ДАТА > О_ДАТА, 
                                            then PAY_AMT*rt_rp1.EXCHANGE_RATE                                                --то    СУММ = СУММ * ФП_КУРС_О_ДАТА
                                         
                                         when CUR2 = s.base_currency and CUR1 <> s.base_currency and PAY_DT <= p_REPORT_DT    --Если Д_ВАЛ <> Б_ВАЛ и ФП_ВАЛ = Б_ВАЛ и ДАТА <= О_ДАТА,
                                            --then PAY_AMT*round(1/rt2.EXCHANGE_RATE,8)                                                   --то    СУММ = СУММ / Д_КУРС
                                            then PAY_AMT/rt2.EXCHANGE_RATE
                                       
                                         when CUR2 = s.base_currency and CUR1 <> s.base_currency and PAY_DT > p_REPORT_DT     --Если Д_ВАЛ <> Б_ВАЛ и ФП_ВАЛ = Б_ВАЛ и ДАТА > О_ДАТА,
                                            --then PAY_AMT*round(1/rt_rp2.EXCHANGE_RATE,8)                                                --то    СУММ = СУММ / Д_КУРС_О_ДАТА
                                            then PAY_AMT/rt_rp2.EXCHANGE_RATE                                               --то    СУММ = СУММ / Д_КУРС_О_ДАТА
                                        
                                         else PAY_AMT                                         --Иначе, СУММ = СУММ.
                                         
                                   end) as PAY_AMT_cur_supply,
                                   ex_rate
                                 
                            from Flow_S s
                               
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
                                  on rt_rp2.ex_rate_dt = p_REPORT_DT 
                                  and s.CUR1= rt_rp2.CURRENCY_KEY 
                                  and rt_rp2.BASE_CURRENCY_KEY = s.base_currency
                                  and rt_rp2.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                                  
                                                                    
                          ),
                          
                FLOW_S_UNDERPAY_1 as (                         
                            select  
                                    f1.L_Key,
                                    f1.branch_key,
                                    f1.CBC_DESC,
                                    (case 
                                        when f1.pay_amt2 >= nvl(f2.pay_amt_sum,0)
                                         and pay_dt > p_REPORT_DT
                                            then p_REPORT_DT 
                                        else pay_dt 
                                    end) pay_dt, 
                                    f1.PAY_AMT,
                                    f1.TP,                                 
                                    f1.CUR1,
                                    f1.CUR3,
                                    f1.CUR2,
                                    f1.base_currency,
                                    f1.flag,                                                                        
                                    f1.L_KEY_DOP,
                                    f1.S_KEY,
                                    f1.PAY_AMT_cur_supply,
                                    f1.ex_rate
                              from 
                                    (select                                 
                                              L_Key, 
                                              branch_key,
                                             CBC_DESC,
                                              pay_dt, 
                                              TP,
                                              PAY_AMT,
                                              PAY_AMT_cur_supply, 
                                              sum(PAY_AMT_cur_supply) over (partition by L_KEY  order by pay_dt rows between unbounded preceding and current row) pay_amt2,
                                              CUR1,
                                              CUR3,
                                              CUR2,
                                              base_currency,
                                              flag,
                                              L_KEY_DOP,
                                              S_KEY,
                                              ex_rate                                                
                                        from flow_s_cur
                                        where TP = 'Supply_plan') f1 
                                  left join
                                        (
                                          select 
                                              L_Key,
                                              CBC_DESC,
                                              sum(PAY_AMT_cur_supply) pay_amt_sum
                                          from flow_s_cur 
                                          where TP = 'Supply_fact' and CBC_DESC ='ОД.3.1'
                                          group by L_Key,CBC_DESC) f2 
                                                                                                    
                                  on f1.L_Key = f2.L_Key and f1.CBC_DESC = f2.CBC_DESC
                      
                        ),

      /*    FLOW_S_UNDERPAY_FACT as (
                                    select                                     
                                    PL.L_Key,
                                    PL.branch_key,
                                    'ОД.3.1' CBC_DESC,
                                    PL.pay_dt, 
                                    s2-s1 PAY_AMT,
                                    'Supply_plan' TP,                                 
                                    PL.CUR1,
                                    PL.CUR1 CUR3,
                                    PL.CUR1 CUR2,
                                    PL.base_currency,
                                    PL.flag,                                                                        
                                    PL.L_KEY_DOP,
                                    PL.S_KEY,
                                    s2-s1 PAY_AMT_cur_supply,
                                    null ex_rate 
                                    from (
                                         select * from  Flow_S_CUR 
                                         where TP = 'Supply_plan' and  pay_dt > p_REPORT_DT) PL
                                         
                                    inner join  (
                                          select sum(PAY_AMT_cur_supply)*-1 s1, TP, L_key from Flow_S_CUR 
                                          where  TP Like 'Supply_plan' and pay_dt<=p_REPORT_DT group by TP,  L_key) SP
                                    on  PL.L_KEY = SP.L_KEY     
                                    inner join  (
                                          select sum(PAY_AMT_cur_supply)*-1 s2, TP, L_key from Flow_S_CUR 
                                          where  TP Like 'Supply_fact' and pay_dt<=p_REPORT_DT group by TP,  L_key) SF  
                                    on  PL.L_KEY = SF.L_KEY 
                                    where s2-s1>0),*/
                          
                Flow_L as             
                          (
                           SELECT /*+ NO_INDEX(fact_pp) */ Contr.L_KEY,                      -- Исключение задваивания в случае, если одному контракту лизинга соответствует несколько договоров поставки (flag = 1)
                                  contr.branch_key,                                                           
                                  fact_pp.CBC_DESC,
                                  PAY_DT,
                                  PAY_AMT, 
                                  'OL_PLAN' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.L_CUR CUR3, 
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag,
                                  Contr.L_Key L_KEY_DOP,
                                  Null S_KEY
                           from (select distinct 
                                        L_KEY,
                                        branch_key,
                                        L_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces) Contr
                           inner join dwh.fact_plan_payments fact_pp
                              ON Contr.L_Key = fact_pp.contract_key
                           where (fact_pp.CBC_DESC in (
                                                        select CBC_DESC 
                                                        from DWH.CLS_CBC_TYPE_CALC 
                                                        where TYPE_CALC = 'Leasing' 
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                                                        or (fact_pp.contract_key in (select contract_key from dwh.leasing_contracts where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') and SUBSIDIZATION_FLG = 1)
                                                        and fact_pp.CBC_DESC in (
                                                        select CBC_DESC 
                                                        from DWH.CLS_CBC_TYPE_CALC 
                                                        where TYPE_CALC = 'Subsidization' 
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)))                 -- выбор плановых платежей по договорам лизинга с типом классификации КБК 'Leasing'
                           and fact_pp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                           and p_REPORT_DT between fact_pp.BEGIN_DT and fact_pp.END_DT
                           
                           UNION ALL
       
                          -- Дополнительный поток по цессии 
       
                           SELECT /*+ NO_INDEX(fact_pp) */ Contr.L_KEY,                          -- Исключение задваивания в случае, если одному контракту лизинга соответствует несколько договоров поставки (flag = 1)
                                  contr.branch_key,
                                  fact_pp.CBC_DESC,
                                 PAY_DT,
                                  PAY_AMT, 
                                  'OL_PLAN' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.L_CUR CUR3, 
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag,
                                  Contr.L_KEY_DOP L_KEY_DOP,
                                  Null S_KEY                                  
                           from dwh.fact_plan_payments fact_pp
                           INNER join (select distinct 
                                        L_KEY,
                                        L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        base_currency,
                                        flag
                                        from Contr_ces) Contr
                              ON Contr.L_Key_dop = fact_pp.contract_key
                           where (fact_pp.CBC_DESC in (
                                                        select CBC_DESC 
                                                        from DWH.CLS_CBC_TYPE_CALC 
                                                        where TYPE_CALC = 'Leasing' 
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                                                        or (fact_pp.contract_key in (select contract_key from dwh.leasing_contracts where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') and SUBSIDIZATION_FLG = 1)
                                                        and fact_pp.CBC_DESC in (
                                                        select CBC_DESC 
                                                        from DWH.CLS_CBC_TYPE_CALC 
                                                        where TYPE_CALC = 'Subsidization' 
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)))                -- выбор плановых платежей по договорам лизинга с типом классификации КБК 'Leasing'
                           and fact_pp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                           and p_REPORT_DT between fact_pp.BEGIN_DT and fact_pp.END_DT
                           
                           UNION ALL
                           
                           SELECT Contr.L_KEY,                      -- Исключение задваивания в случае, если одному контракту лизинга соответствует несколько договоров поставки (flag = 1)
                                  contr.branch_key,                                                           
                                  fact_pp.CBC_DESC,
                                  PAY_DT,
                                  PAY_AMT, 
                                  'OL_FACT' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.L_CUR CUR3, 
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag,
                                  Contr.L_KEY L_KEY_DOP,
                                  Null S_KEY                                    
                           from (select distinct 
                                        L_KEY,
                                        branch_key,
                                        L_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces) Contr
                           inner join dwh.fact_real_payments fact_pp
                              ON Contr.L_Key = fact_pp.contract_key
                           where (fact_pp.CBC_DESC in (
                                                        select CBC_DESC 
                                                        from DWH.CLS_CBC_TYPE_CALC 
                                                        where TYPE_CALC = 'Leasing' 
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                                                        or (fact_pp.contract_key in (select contract_key from dwh.leasing_contracts where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') and SUBSIDIZATION_FLG = 1)
                                                        and fact_pp.CBC_DESC in (
                                                        select CBC_DESC 
                                                        from DWH.CLS_CBC_TYPE_CALC 
                                                        where TYPE_CALC = 'Subsidization' 
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)))                 -- выбор плановых платежей по договорам лизинга с типом классификации КБК 'Leasing'
                           and fact_pp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                           
                           UNION ALL
       
                          -- Дополнительный поток по цессии 
       
                           SELECT Contr.L_KEY,                          -- Исключение задваивания в случае, если одному контракту лизинга соответствует несколько договоров поставки (flag = 1)
                                  contr.branch_key,
                                  fact_pp.CBC_DESC,
                                 PAY_DT,
                                  PAY_AMT, 
                                  'OL_FACT' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.L_CUR CUR3, 
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag,
                                  Contr.L_KEY_DOP L_KEY_DOP,
                                  Null S_KEY                                    
                           from dwh.fact_real_payments fact_pp
                           INNER join (select distinct 
                                        L_KEY,
                                        L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        base_currency,
                                        flag
                                        from Contr_ces) Contr
                              ON Contr.L_Key_dop = fact_pp.contract_key
                           where (fact_pp.CBC_DESC in (
                                                        select CBC_DESC 
                                                        from DWH.CLS_CBC_TYPE_CALC 
                                                        where TYPE_CALC = 'Leasing' 
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                                                        or (fact_pp.contract_key in (select contract_key from dwh.leasing_contracts where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') and SUBSIDIZATION_FLG = 1)
                                                        and fact_pp.CBC_DESC in (
                                                        select CBC_DESC 
                                                        from DWH.CLS_CBC_TYPE_CALC 
                                                        where TYPE_CALC = 'Subsidization' 
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)))                -- выбор плановых платежей по договорам лизинга с типом классификации КБК 'Leasing'
                           and fact_pp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')                         
                           
                           ),
           
          /* Объединение платежей по договорам лизинга, поставок и добавление строки с отчетной датой 
             с суммой 0 для расчета количества дней от последнего платежа до отчетной даты.
          */
                 Flow_Cur as(                   
                              select 
                                    fl.*, 
                                    0 PAY_AMT_cur_supply,                                  
                                    Null  ex_rate
                              from Flow_L fl
                            UNION ALL
                              select * 
                              from Flow_S_cur 
                              where TP = 'Supply_fact'
                            UNION ALL 
                              select * 
                              from FLOW_S_UNDERPAY_1 
                              where TP = 'Supply_plan' 
                                and CBC_DESC = 'ОД.3.1'
                            UNION ALL
                              select * 
                              from Flow_S_cur 
                              where TP = 'Supply_plan' 
                                and CBC_DESC <> 'ОД.3.1'
                /*            UNION ALL
                               select * 
                              from Flow_S_cur 
                              where TP = 'Supply_plan' 
                                and CBC_DESC = 'ОД.3.1' and pay_dt > p_REPORT_DT   */                             
                            UNION ALL
                              select 
                                    L_key as L_key, 
                                    branch_key, 
                                    'ОД.1.1' as CBC_DESC, 
                                    p_REPORT_DT as PAY_DT, 
                                    0 as PAY_AMT, 
                                    'TEH'  as TP,
                                    Contr.L_CUR as CUR1, 
                                    Contr.L_CUR as CUR3, 
                                    Contr.L_CUR as CUR2, 
                                    Contr.base_currency, 
                                    0 flag, 
                                    0 Flow_S_cur,
                                    L_key as L_KEY_DOP,
                                    S_KEY,
                                    null ex_rate 
                              from Contr
              /*              UNION ALL
                              select * 
                              from FLOW_S_UNDERPAY_FACT  */                            
                 ) ,                  
              
          /* Алгоритм приведения валют в планах/фактах к валюте договора лизинга путем пересчета по курсам 
             валют из справочника "Курсы валют" в зависимости от организации, по которой выполняется расчет xIRR. 
             Расчет производится в зависимости от базовой ставки и даты платежа: до отчетной даты или после отчетной даты...
          */
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
                                  
                                   WHEN ex_rate is not Null and ex_rate = 0 and cur1 != cur2 
                                      then 0
                                   WHEN ex_rate is not Null and ex_rate <> 0 and cur1 != cur2   
                                      then PAY_AMT/ex_rate/rt2.EXCHANGE_RATE 
                                      
                                   else
                                         case
                                         when CUR1 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT   --Если Д_ВАЛ <> Б_ВАЛ и ФП_ВАЛ <> Б_ВАЛ и ДАТА <= О_ДАТА, 
                                            then PAY_AMT*rt1.EXCHANGE_RATE/rt2.EXCHANGE_RATE                                --то    СУММ = СУММ * ФП_КУРС /  Д_КУРС  
                                        
                                         when CUR1 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT > p_REPORT_DT    --Если Д_ВАЛ <> Б_ВАЛ и ФП_ВАЛ <> Б_ВАЛ и ДАТА > О_ДАТА, 
                                            then PAY_AMT*rt_rp1.EXCHANGE_RATE/rt_rp2.EXCHANGE_RATE                          --то    СУММ = СУММ * ФП_КУРС_О_ДАТА /  Д_КУРС_О_ДАТА 
                                         
                                         when CUR1 = s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT    --Если Д_ВАЛ = Б_ВАЛ и ФП_ВАЛ <> Б_ВАЛ и ДАТА <= О_ДАТА,
                                            then PAY_AMT*rt1.EXCHANGE_RATE                                                   --то    СУММ = СУММ * ФП_КУРС
                                         
                                         when CUR1 = s.base_currency and CUR2 <> s.base_currency and PAY_DT > p_REPORT_DT     --Если Д_ВАЛ = Б_ВАЛ и ФП_ВАЛ <> Б_ВАЛ и ДАТА > О_ДАТА, 
                                            then PAY_AMT*rt_rp1.EXCHANGE_RATE                                                --то    СУММ = СУММ * ФП_КУРС_О_ДАТА
                                         
                                         when CUR2 = s.base_currency and CUR1 <> s.base_currency and PAY_DT <= p_REPORT_DT    --Если Д_ВАЛ <> Б_ВАЛ и ФП_ВАЛ = Б_ВАЛ и ДАТА <= О_ДАТА,
                                            --then PAY_AMT*round(1/rt2.EXCHANGE_RATE,8)                                                   --то    СУММ = СУММ / Д_КУРС
                                            then PAY_AMT/rt2.EXCHANGE_RATE
                                       
                                         when CUR2 = s.base_currency and CUR1 <> s.base_currency and PAY_DT > p_REPORT_DT     --Если Д_ВАЛ <> Б_ВАЛ и ФП_ВАЛ = Б_ВАЛ и ДАТА > О_ДАТА,
                                            --then PAY_AMT*round(1/rt_rp2.EXCHANGE_RATE,8)                                                --то    СУММ = СУММ / Д_КУРС_О_ДАТА
                                            then PAY_AMT/rt_rp2.EXCHANGE_RATE  
                                        
                                         else PAY_AMT                                                                        --Иначе, СУММ = СУММ.
                                         end
                                   end) as PAY_AMT_cur,
                                   PAY_AMT,
                                   TP,
                                   CUR1,
                                   CUR2, 
                                   CUR3,
                                   PAY_AMT_cur_supply,
                                   L_KEY_DOP,
                                   S_KEY                                    
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
                                  on rt_rp1.ex_rate_dt  = p_REPORT_DT 
                                  and s.CUR2= rt_rp1.CURRENCY_KEY 
                                  and rt_rp1.BASE_CURRENCY_KEY = s.base_currency
                                  and rt_rp1.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                               
                               left join dwh.EXCHANGE_RATES rt_rp2             -- привязка к курсам валют по равенству даты курса отчетной дате и по валюте договора
                                  on rt_rp2.ex_rate_dt  = p_REPORT_DT 
                                  and s.CUR1= rt_rp2.CURRENCY_KEY 
                                  and rt_rp2.BASE_CURRENCY_KEY = s.base_currency
                                  and rt_rp2.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')

                          )
         select 
                L_KEY,
                branch_key,
                CBC_DESC,
                PAY_DT, 
                PAY_AMT_cur,
                PAY_AMT,
                TP,
                CUR1,
                CUR2, 
                CUR3,
                PAY_AMT_cur_supply,                 
                p_REPORT_DT as snapshot_dt, 
                'Основной КИС' as snapshot_cd,
                L_KEY_DOP,
                S_KEY,
               Case when BRANCH_key <> 1 then sysdate  else (Select min (ACT_DT) from dwh.LEASING_SUBJECT_TRANSMIT
Where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
And contract_app_key in (select contract_app_key from dwh.leasing_contracts_appls where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') and contract_key= L_KEY
) ) end ACT_DT
         from flow_L_CUR l
         ));
  dm.u_log(p_proc => 'p_DM_OL_FLOW_KIS',
           p_step => 'insert into dm_ol_flow_orig',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');

   commit;
   delete from DM_OL_FLOW_SUPPLY 
   where SNAPSHOT_dt = p_report_dt
   and snapshot_cd = 'Основной КИС'      -- Очистка таблицы DM_OL_FLOW_SUPPLY за данный отчетный период
   ;
   --and (branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = v_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT));
  dm.u_log(p_proc => 'p_DM_OL_FLOW_KIS',
           p_step => 'delete from DM_OL_FLOW_SUPPLY',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
INSERT INTO DM_OL_FLOW_SUPPLY
  (
    CONTRACT_KEY,
    S_KEY,
    SNAPSHOT_CD,
    SNAPSHOT_DT,
    S_AMT,
    S_AMT_F,
    S_AMT_F_R
  )
SELECT --REP_DT,
  CONTRACT_KEY,
  S_KEY,
  --CUR,
 -- BRANCH_KEY,
  SNAPSHOT_CD,
  SNAPSHOT_DT,
  S_AMT,
  S_AMT_F,
  S_AMT_F_R
 -- S_EX_RATE
FROM V$DM_OL_FLOW_SUPPLY where SNAPSHOT_DT=p_report_dt;
  dm.u_log(p_proc => 'p_DM_OL_FLOW_KIS',
           p_step => 'insert into DM_OL_FLOW_SUPPLY',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');
   delete from DM_OL_FLOW 
   where SNAPSHOT_dt = p_report_dt
   and snapshot_cd = 'Основной КИС'      -- Очистка таблицы DM_OL_FLOW за данный отчетный период
   ;
   --and (branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = v_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT));
  dm.u_log(p_proc => 'p_DM_OL_FLOW',
           p_step => 'delete from DM_OL_FLOW_SUPPLY',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');


insert into dm.dm_ol_flow
select * from DM.V$DM_OL_METRIC t  ;         
  dm.u_log(p_proc => 'p_DM_OL_FLOW_KIS',
           p_step => 'insert into DM_OL_FLOW',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');
   commit;

END;
/

