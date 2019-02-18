CREATE OR REPLACE PROCEDURE DM.p_DM_CORRECT_CALC_NIL (
      p_CORRECTION_NUMBER number,
      p_REPORT_DT in date
----------------------------------------------------[asavgurov 03.11.2015]: p_DELETE_DT_2 передается дата '01.01.1900' только для одной единственной корректировки по договору
)
IS
v_id_prev pls_integer;
pers number;
nill number;
diff number;
prev_dt date;
p_xirr number;
v_count number;
diff_prev number;
diff_prev2 number;
ka number;
nil_ka number;
ka_prev number;
ka_prev2 number;

/* Процедура рассчитывает показатели NIL на основе xIRR и заполняет витрины:
      -- промежуточную витрину DM_NIL значениями:
          а) процентной составляющей платежа срочной задолженности на дату NIL_PERS,
          б) основного долга платежа срочной задолженности на дату NIL
          в) срочной задолженности основного долга на дату NIL_DIFF
          г) фактических/плановых платежей, платежей лизинга/поставок из потока (см. процедуру p_dm_xirr_calc) и даты платежа
          д) коэффициентов ka и kb
          е) NIL*ka*kb за вычетом НДС
          ж) отчетной даты
      -- витрину по плановым погашениям DM_REPAYMENT_SCHEDULE значениями:
          а) фактических/плановых платежей, платежей лизинга/поставок из потока (см. процедуру p_dm_xirr_calc) и даты платежа
          б) процентной составляющей платежа срочной задолженности на дату INTEREST_AMT
          в) основного долга платежа срочной задолженности на дату PRINCIPAL_AMT
          г) срочной задолженности основного долга на дату DNIL_AMT
          д) NIL*ka*kb за вычетом НДС NIL_AMT.
          
-- В качестве параметров на вход подаются дата отчета (p_REPORT_DT) и номер группы организаций (p_group_key).
-- В качестве потока берутся все плановые платежи по лизингу, фактические платежи до отчетной даты по поставкам и плановые платежи за все время по поставкам.
*/

BEGIN
     dm.u_log(p_proc => 'DM.p_DM_CORRECT_CALC_NIL',
           p_step => 'INPUT PARAMS',
           p_info => 'p_CORRECTION_NUMBER:'||p_CORRECTION_NUMBER||'p_REPORT_DT:'||p_REPORT_DT/*||'p_snapshot_cd:'||p_snapshot_cd*/); 


   delete from DM.DM_NIL 
   where rowid in  
   (
       select
       a.rowid 
       from DM.DM_NIL  a
            inner join DM_CORRECT_DNIL dcd 
                on a.contract_id = dcd.contract_key
                and contract_date >= dcd.DELETE_DT_1
                and dcd.CORRECTION_NUMBER = p_CORRECTION_NUMBER  
       and ODTTM = p_REPORT_DT
       and snapshot_cd = 'Основной КИС'
    );
  dm.u_log(p_proc => 'DM.p_DM_CORRECT_CALC_NIL',
           p_step => 'delete from DM.DM_NIL',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');           
   delete from DM.DM_NIL_SINGLE;
  dm.u_log(p_proc => 'DM.p_DM_CORRECT_CALC_NIL',
           p_step => 'delete from DM.DM_NIL_SINGLE',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');        
   --if (v_count = 0)then
            v_id_prev:=null;
            for rec in (
                        /* Берется поток по договорам лизинга и поставок (см. процедуру p_dm_xirr_calc)
                        */ 
                        with
                Contr_prev as (
                          SELECT cn1.contract_key L_key,
                                 cn2.contract_key S_key,
                                 cn1.branch_key,
                                 cn1.Currency_Key L_CUR,                                      -- Валюта договора лизинга
                                 cn2.Currency_key S_CUR,                                      -- Валюта договора поставки
                                 OS.base_currency_key base_currency,
                                 cn1.valid_to_dttm
                          from dwh.contracts cn1
                          left join dwh.contracts cn2
                              ON cn1.contract_key = cn2.contract_leasing_key
                              and cn2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                              and cn2.open_dt <= p_REPORT_DT
                          inner join dwh.ORG_STRUCTURE OS                                      -- Для пересчета платежей код базовой валюты тянется из справочника структуры компании
                              ON OS.BRANCH_KEY = cn1.BRANCH_KEY
                          inner join dwh.clients cl
                              ON cl.client_key = cn1.client_key
                          inner join DWH.LEASING_CONTRACTS LC                                  -- Вяжемся со справчоником лизинговых контрактов для того, чтобы выбрать тип "Финансовый Лизинг"
                              ON cn1.contract_key = LC.contract_key
                          inner join DM_CORRECT_DNIL dnc
                              on cn1.contract_key = dnc.contract_key 
                              and dnc.CORRECTION_NUMBER = p_CORRECTION_NUMBER                               
                          where  cn1.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                                 and cl.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                                 and LC.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                                 and ((LC.contract_fin_kind_desc <> 'ОперационнаяАренда' 
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
                                                              where cgp_group.cgp_group_key not in (1, 2)
                                                              and cgp_group.begin_dt <= p_REPORT_DT
                                                              and cgp_group.end_dt > p_REPORT_DT)
                                       ))
                                 and cl.cgp_flg = '1'                                                -- Договор КГП
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
                            cn1.flag
                        From Contr cn1
                        join dwh.contracts cn2 
                            ON cn1.l_key = cn2.contract_key
                            and cn2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                            and cn1.branch_key = cn2.branch_key
                        left join dwh.contracts cn3
                            ON cn2.CONTRACT_ID_CD = cn3.CONTRACT_ID_CD        -- привязка по Id транзакции для склейки двух договоров...
                              and cn3.contract_key <> cn2.contract_key
                              and cn3.branch_key = cn2.branch_key
                              and cn3.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                        Left join dwh.contracts cn4
                              ON cn3.contract_key = cn4.contract_leasing_key  
                              and cn4.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          ),

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
                                 abs(fact_rp1.EXCHANGE_RATE) ex_rate
                          from (select distinct 
                                        L_KEY,
                                        branch_key,
                                        L_CUR,
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
                                 abs(fact_rp2.EXCHANGE_RATE) ex_rate 
                          from (select distinct 
                                        L_Key,
                                        S_KEY,
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
              
                          SELECT Contr.L_key,
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
                                 Null ex_rate
                          from (select distinct 
                                        L_Key,
                                        S_KEY,
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
              
                          SELECT Contr.L_key,
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
                                 Null ex_rate
                          from(select distinct 
                                        L_KEY,
                                        S_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        S_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces) Contr                          
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
                                  on rt_rp2.ex_rate_dt= p_REPORT_DT 
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
                        
    /*       FLOW_S_UNDERPAY_FACT as (
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
                                    where s2-s1>0),      */                  
                          
                Flow_L as             
                          (
                           SELECT Contr.L_KEY,                      -- Исключение задваивания в случае, если одному контракту лизинга соответствует несколько договоров поставки (flag = 1)
                                  contr.branch_key,                                                           
                                  fact_pp.CBC_DESC,
                                  PAY_DT,
                                  PAY_AMT, 
                                  'LEASING' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.L_CUR CUR3, 
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag
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
       
                           SELECT Contr.L_KEY,                          -- Исключение задваивания в случае, если одному контракту лизинга соответствует несколько договоров поставки (flag = 1)
                                  contr.branch_key,
                                  fact_pp.CBC_DESC,
                                 PAY_DT,
                                  PAY_AMT, 
                                  'LEASING' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.L_CUR CUR3, 
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag
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
                              where pay_amt != 0
                            UNION ALL
                              select * 
                              from Flow_S_cur 
                              where TP = 'Supply_fact'
                              and pay_amt != 0
                            UNION ALL 
                              select * 
                              from FLOW_S_UNDERPAY_1 
                              where TP = 'Supply_plan' 
                                and CBC_DESC = 'ОД.3.1'
                                and pay_amt != 0
                            UNION ALL
                              select * 
                              from Flow_S_cur 
                              where TP = 'Supply_plan' 
                                and CBC_DESC <> 'ОД.3.1'
                                and pay_amt != 0
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
                                    null ex_rate 
                              from Contr 
                 /*           UNION ALL
                              select * 
                              from FLOW_S_UNDERPAY_FACT     */                         
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
                                         end
                                   end) as PAY_AMT_cur,
                                   PAY_AMT,
                                   TP,
                                   CUR1,
                                   CUR2, 
                                   CUR3,
                                   PAY_AMT_cur_supply
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
                                
                                                     
                         --КИС
                            Flow_Underpay as
                                            (
                                            SELECT  fc.L_key,
                                                    fc.branch_key,
                                                    'ОД.3.1' as cbc_desc,
                                                    sum(case when cs.PAY_AMT_CuR_supply > 0 and tp='Supply_fact' 
                                                                then fc.PAY_AMT_CuR*-1
                                                              when cs.PAY_AMT_CuR_supply > 0 and tp='Supply_plan'    
                                                                then fc.PAY_AMT_CuR
                                                        else 0 end) PAY_AMT_CuR,
                                                    cs.PAY_AMT_CuR_supply
                                            from 
                                                    Flow_L_Cur fc
                                            join (select l_key, 
                                                      sum (case when tp='Supply_fact' then 
                                                                  PAY_AMT_cur 
                                                                when tp='Supply_plan' then 
                                                                  PAY_AMT_cur*-1 
                                                          end) PAY_AMT_CuR_supply 
                                                  from Flow_L_Cur
                                                  WHERE TP in ('Supply_fact','Supply_plan')
                                                   and pay_dt <= p_REPORT_DT
                                                  group by l_key) cs
                                            on cs.l_key = fc.l_key
                                            WHERE fc.TP in ('Supply_fact','Supply_plan')
                                             and fc.pay_dt <= p_REPORT_DT
                                            group by  fc.L_key, fc.branch_key, cs.PAY_AMT_CuR_supply
                              
                                
                          ),

                  Flow_Underpay_FLG as                                                                              -- Проверка необходимости добавлять переплату (Исключения курсовой разницы)
                                    ( 
                                      Select  
                                            SUM_FL.L_KEY,  
                                            (case when SUM_FL.PAY_AMT_FACT =  SUM_FL.PAY_AMT_PLAN 
                                                then 'N'
                                             else 'Y'
                                             end) FLG_UNDERPAY
                                      from (select l_key, 
                                                      sum (case when tp='Supply_fact' then 
                                                                  PAY_AMT
                                                                else 0
                                                           end) PAY_AMT_FACT,
                                                       sum (case when tp='Supply_plan' then 
                                                                  PAY_AMT 
                                                          end) PAY_AMT_PLAN
                                                from Flow_L_Cur
                                                WHERE TP in ('Supply_fact','Supply_plan')
                                       --             and snapshot_cd = 'Основной КИС'
                                       --             and snapshot_dt = p_REPORT_DT                                                    
                                                    and pay_dt <= p_REPORT_DT
                                                  group by L_KEY
                                               ) SUM_FL                                       
                                        ),                          
                                
                        Supply_eq as (select l_key as unpaid_l_key from flow_l_cur   ----- 26102015 Составление списка контрактов с оплаченной поставкой
                                              where upper(tp) in ('SUPPLY_PLAN', 'SUPPLY_FACT') group by l_key
                                              having sum(case when upper(tp) = 'SUPPLY_PLAN' then pay_amt else -pay_amt end) = 0),                 
                                
                        Flow_prev as
                                (
             /*                    SELECT
                                        L_KEY,
                                        branch_key,
                                        CBC_DESC,
                                        p_REPORT_DT + 1 pay_dt ,
                                        PAY_AMT_CuR summ,
                                        PAY_AMT_CuR PAY_AMT
                                 FROM Flow_Underpay
                                 where PAY_AMT_CuR < 0
               */                  
                                 SELECT
                                        FU.L_KEY,
                                        FU.branch_key,
                                        FU.CBC_DESC,
                                        p_REPORT_DT + 1 pay_dt ,
                                        nvl(PAY_AMT_CuR, 0) summ,
                                        PAY_AMT_CuR PAY_AMT
                                 FROM Flow_Underpay FU
                                      join Flow_Underpay_FLG FUF
                                      on FU.L_KEY=FUF.L_KEY 
                                 where PAY_AMT_CuR < 0
                                   and FUF.FLG_UNDERPAY='Y'                                 
                      
                                UNION ALL
                      
                      
                                  SELECT 
                                         L_KEY, 
                                         branch_key, 
                                         CBC_DESC, 
                                         PAY_DT, 
                                         SUM(PAY_AMT_CUR) summ, 
                                         SUM(PAY_AMT) PAY_AMT
                                  FROM FLOW_L_CUR
                                  WHERE TP <> 'Supply_plan' or 
                                  (TP = 'Supply_plan' and PAY_DT > p_REPORT_DT)
                                  group by L_KEY, branch_key, CBC_DESC, PAY_DT
                                  
                                                                  UNION ALL
                    
                    
                                SELECT ----- 26102015 Выбор только тех будущих плановых платежей по поставке, которые еще не оплачены
                                       L_KEY, 
                                       branch_key, 
                                       CBC_DESC, 
                                       PAY_DT, 
                                       SUM(PAY_AMT_CUR) summ, 
                                       SUM(PAY_AMT) PAY_AMT
                                FROM FLOW_L_CUR a, Supply_eq b
                                  WHERE TP = 'Supply_plan' and PAY_DT > p_REPORT_DT and unpaid_l_key is null
                                  and a.l_key = b.unpaid_l_key (+)               
                                  group by L_KEY, branch_key, CBC_DESC, PAY_DT
                                 ),
                                 
                          balance as (
             
                                  select L_key,
                                  branch_key,
                                         PAY_DT,
                                         sum(summ) over (partition by l_key order by pay_dt) bal1,
                                         sum(pay_amt) over (partition by l_key order by pay_dt) bal2,
                                         first_value (pay_dt) over (partition by l_key order by pay_dt) fv -- для того, чтобы исключить "размазывание контрактов, где дата первого платежа равна минимальной дате
                                  from Flow_prev
                                 ),
  
                       min_dt as
                                  (
                                  select 
                                        L_KEY,
                                        fv, -- для того, чтобы исключить размазывание контрактов, где дата первого платежа равна минимальной дате
                                        min(case 
                                                when bal1 < 0
                                                  then pay_dt
                                                else null
                                            end) min_dt
                                  from balance 
                                  group by L_KEY, fv
                                  ),        
                                 
                          Flow_prev_1 as 
                                (
                                  Select L_KEY,
                                         branch_key,
                                         PAY_DT,
                                         sum(case
                                            when (CBC_DESC in (
                                                        select CBC_DESC 
                                                        from DWH.CLS_CBC_TYPE_CALC 
                                                        where TYPE_CALC = 'Leasing' 
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                                                        or (L_KEY in (select contract_key from dwh.leasing_contracts where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') and SUBSIDIZATION_FLG = 1)
                                                        and CBC_DESC in (
                                                        select CBC_DESC 
                                                        from DWH.CLS_CBC_TYPE_CALC 
                                                        where TYPE_CALC = 'Subsidization' 
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT))) 
                                              then summ 
                                              else 0
                                              end
                                         ) LEASING_PAY,
                                         sum(case
                                          when cbc_desc in (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Supply'                    -- выбор фактических платежей по договорам поставок с типом КБК 'Supply'
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT) 
                                            then summ 
                                            else 0
                                          end
                                        ) SUPPLY_PAY,
                                        sum (summ) summ,
                                        sum (pay_amt) pay_amt
                                        from FLOW_prev
                                        group by L_KEY, branch_key, PAY_DT
                                ),
                            
                          FLOW_prev_2 as
                                    (select L_KEY, 
                                       branch_key,
                                       PAY_DT, 
                                       summ ,
                                       sum(summ) over (partition by L_KEY order by pay_dt rows between unbounded preceding and current row) sum_prev, 
                                       LEASING_PAY,
                                       SUPPLY_PAY,
                                       PAY_AMT
                                    from  Flow_prev_1 
                                    ),
                        
                          FLOW as
                                    (select f.L_KEY, 
                                             branch_key,
                                             PAY_DT, 
                                             summ, 
                                             sum_prev,
                                             LEASING_PAY,
                                             SUPPLY_PAY,
                                             PAY_AMT
                                    from  FLOW_prev_2 f
                                    inner join min_dt min_dt
                                        on min_dt.l_key = f.l_key
                                    where summ <= 0
                                    and pay_dt <= min_dt
                                   
                                   union all
                                    
                                   select f.L_KEY, 
                                             branch_key,
                                             PAY_DT, 
                                             0 summ, 
                                             sum_prev,
                                             LEASING_PAY - sum_prev,
                                             SUPPLY_PAY,
                                             LEASING_PAY - sum_prev + SUPPLY_PAY PAY_AMT
                                    from  FLOW_prev_2 f
                                    inner join min_dt min_dt
                                        on min_dt.l_key = f.l_key
                                    where summ > 0
                                    and pay_dt <= min_dt 
                                    and (LEASING_PAY - sum_prev) <> 0 
                                    and  SUPPLY_PAY<>0  
                
 /*                                   union all
               
                                    select f.L_KEY, 
                                             branch_key,
                                             PAY_DT, 
                                             summ, 
                                             sum_prev,
                                             LEASING_PAY - sum_prev,
                                             SUPPLY_PAY,
                                             PAY_AMT
                                    from  FLOW_prev_2 f
                                    inner join min_dt min_dt
                                        on min_dt.l_key = f.l_key
                                    where summ > 0
                                    and pay_dt <= min_dt       */          
                                
                
                                  union all
                
                                    select   f.L_KEY, 
                                             branch_key,
                                             
                                             PAY_DT, 
                                             (case when 
                                                sum_prev >= 0
                                                   then abs (summ)
                                               else sum_prev - summ
                                             end) as summ,
                                             sum_prev,
                                             (case when 
                                                sum_prev >= 0
                                                   then abs (supply_pay)
                                               else sum_prev - supply_pay
                                             end) LEASING_PAY,
                                             0 as SUPPLY_PAY,
                                             (case when 
                                                  sum_prev >= 0 or pay_dt <= min_dt
                                                     then abs (PAY_AMT)
                                                 else PAY_AMT
                                               end) PAY_AMT
                        
                                             from 
                                             FLOW_prev_2 f
                                             inner join min_dt min_dt
                                        on min_dt.l_key = f.l_key
                                            where summ < 0
                                           -- and pay_dt != p_REPORT_DT -- для того, чтобы не задубливал уже заведомо существующую запись
                                            and pay_dt <= min_dt
                                            and min_dt != fv -- для того, чтобы исключить размазывание контрактов, где дата первого платежа равна минимальной дате
                                            
                                     
                                            
                                    union all
                                    
                                    select   f.L_KEY, 
                                             branch_key, 
                                             
                                             PAY_DT, 
                                             summ,
                                             sum_prev,
                                             LEASING_PAY,
                                             SUPPLY_PAY,
                                             PAY_AMT
                                             from 
                                             FLOW_prev_2 f
                                             inner join min_dt min_dt
                                              on min_dt.l_key = f.l_key 
                                            where pay_dt > min_dt
                                    
                                    union all
                                    
                                    select   f.L_KEY, 
                                             branch_key,
                                             
                                             PAY_DT, 
                                             summ,
                                             sum_prev,
                                             LEASING_PAY,
                                             SUPPLY_PAY, 
                                             PAY_AMT
                                             from 
                                             FLOW_prev_2 f
                                             left join min_dt min_dt
                                              on min_dt.l_key = f.l_key 
                                            where min_dt is null
                                            ),
                     UNDERPAY_L as (
                                  select L_fact.L_key CONTRACT_KEY, 
                                         (CASE  ----- 26102015 Изменен case для учета всех переплат
                                              WHEN (L_fact.summ_f-nvl(L_plan.summ_p,0))>0 
                                                THEN (L_fact.summ_f-nvl(L_plan.summ_p,0)) 
                                              ELSE 0
                                             END) pay_amt ,
                                          min_DT_L.min_DT plan_pay_dt
                                        from 
                                              (select L_key, sum(pay_amt_cur) summ_p 
                                              from dm.dm_xirr_flow_orig a
                                                inner join DM_CORRECT_DNIL dcd
                                                    on  a.L_key =  dcd.contract_key 
                                                    and dcd.CORRECTION_NUMBER = p_CORRECTION_NUMBER 
                                                where tp = 'LEASING' 
                                                  and snapshot_cd = 'Основной КИС' 
                                                  and snapshot_dt = p_REPORT_DT
                                                  and pay_dt <=p_REPORT_DT
--                                                  and L_key = p_contract_key
                                                group by L_key) L_plan,
                                                
                                              (select L_key, sum(pay_amt_cur) summ_f 
                                              from dm.dm_xirr_flow_orig  a
                                                inner join DM_CORRECT_DNIL dcd
                                                    on  a.L_key =  dcd.contract_key 
                                                    and dcd.CORRECTION_NUMBER = p_CORRECTION_NUMBER 
                                                where tp = 'LEASING_FACT' 
                                                  and snapshot_cd = 'Основной КИС' 
                                                  and snapshot_dt = p_REPORT_DT
                                                  and pay_dt <=p_REPORT_DT
--                                                  and L_key = p_contract_key
                                                group by L_key) L_fact, 
                                                
                                                (select L_key, min(pay_dt) min_DT 
                                                from FLOW a
                                                inner join DM_CORRECT_DNIL dcd
                                                    on  a.L_key =  dcd.contract_key  
                                                    and dcd.CORRECTION_NUMBER = p_CORRECTION_NUMBER 
                                                  where pay_dt > p_REPORT_DT
--                                                  and L_key = p_contract_key
                                                  and LEASING_PAY>0
                                                  group by L_key) min_DT_L
                                                  
                                            where L_fact.L_key=L_plan.L_key (+)
                                            and L_fact.L_key=min_DT_L.L_key
                                  )
                                              select l_key, branch_key, pay_dt, summ, sum(summ + sum_prev) 
                                                    over (partition by l_key, branch_key order by pay_dt, abs(summ) 
                                                    rows between unbounded preceding and current row) as sum_prev, leasing_pay, supply_pay, pay_amt, under_l_pay 
                                              from 
                                              (
                                              
                                                  select cont.contract_key as l_key 
                                                  ,cont.branch_key 
                                                  ,CORRECT_DT as pay_dt
                                                  , -dnil as summ
                                                  , 0 as sum_prev
                                                  , 0 as leasing_pay
                                                  , -dnil as supply_pay
                                                  , -dnil as pay_amt
                                                  , 0 as under_l_pay 
                                                  from DM_CORRECT_DNIL dcd
                                                    inner join dwh.contracts cont 
                                                        on dcd.contract_key = cont.contract_key
                                                        and cont.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') 
                                                where dcd.CORRECTION_NUMBER = p_CORRECTION_NUMBER
                                                  union all
                                                  select l_key, branch_key, pay_dt, summ, 0 as sum_prev, leasing_pay, supply_pay, pay_amt, under_l_pay
                                                   from 
                                                  (Select f.L_KEY, 
                                                         f.branch_key,
                                                         f.PAY_DT, 
                                                         dcd.CORRECT_DT,
                                                         sum (f.summ) summ,
                                                         sum (f.sum_prev) sum_prev,
                                                         sum (f.LEASING_PAY) LEASING_PAY,
                                                         sum (f.SUPPLY_PAY) SUPPLY_PAY, 
                                                         sum (f.PAY_AMT) PAY_AMT,
                                                         NVL(UNDER_L.pay_amt, 0) UNDER_L_PAY
                                                  from FLOW f
                                                  inner join dm_xirr x
                                                      on f.l_key = x.contract_id
                                                  inner join DM_CORRECT_DNIL dcd
                                                      on f.l_key = dcd.contract_key
                                                      and dcd.CORRECTION_NUMBER = p_CORRECTION_NUMBER
                                                  left join UNDERPAY_L UNDER_L                                                        
                                                    on UNDER_L.CONTRACT_KEY = f.L_KEY and UNDER_L.plan_pay_dt = f.pay_dt
                                                  where x.odttm = p_REPORT_DT
                                                  and x.snapshot_cd = 'Основной КИС'
                                                  group by f.l_key, f.branch_key, f.pay_dt, UNDER_L.pay_amt, dcd.CORRECT_DT) 
                                                  where pay_dt > CORRECT_DT
                                              )  -- склейка --[asavgurov:06.04.2016] Удалил = , падало при задубливании в DM_NIL_SINGLE
                                              order by l_key, PAY_DT
                          --where L_KEY in (32, 33, 41, 52)
    )
loop
              if rec.L_KEY != v_id_prev or v_id_prev is null                      -- после сортировки при первом появлении договора в потоке
                then
                  pers := null;
                  nill := null;
                  diff := round(rec.SUMM,2)*(-1);
                  v_id_prev := rec.L_KEY;
                  prev_dt := rec.pay_dt;
                  select XIRR into p_XIRR from DM_XIRR where
                  contract_id = rec.L_KEY
                  and ODTTM= p_REPORT_DT
                  and snapshot_cd = 'Основной КИС';
                  p_xirr := p_xirr/100;
                  diff_prev2 := diff_prev;
                  diff_prev := diff;
                  ka_prev2 := ka_prev;
                  ka_prev := ka;
                          if rec.pay_dt > p_REPORT_DT and diff_prev2 is null then ka := 1;
                          elsif rec.pay_dt <= p_REPORT_DT then ka := 1;
                          elsif diff_prev = 0 then ka := nvl(ka_prev, 1);
                          elsif ka_prev = 0 then ka := diff_prev2 * ka_prev2 / diff_prev; -- падало на нуле
                          elsif nill > 0 then ka := ka_prev;
                          else ka := 0;
                          end if;
                  nil_ka := round(ka * nill, 2);
                  if nil_ka < 0 and rec.pay_dt > p_REPORT_DT then nil_ka := 0;
                  end if;
                  insert into DM_NIL_SINGLE (contract_id,contract_date, fact_amt, plan_amt, leasing_amt, supply_amt,nil_pers,nil,nil_diff,ODTTM,ka, nil_ka, PAY_AMT, branch_key, snapshot_cd, UNDERPAY_LEAS)
                  values(rec.L_KEY,rec.pay_dt,(case when rec.summ < 0 then rec.summ else 0 end), (case when rec.summ > 0 then rec.summ else 0 end), rec.leasing_pay, rec.supply_pay, pers,nill,diff,p_REPORT_DT,round(ka, 2), nil_ka, rec.summ, rec.branch_key, 'Основной КИС', rec.UNDER_L_PAY);
                
                else                                                                              -- после сортировки при повторном появлении договора в потоке
                  pers := round(diff*power((1+p_XIRR),(rec.pay_dt-prev_dt)/365)-diff,2);
                  nill := round(rec.summ-pers,2);
                  diff_prev2 := diff_prev;
                  diff_prev := diff;
                  diff := round(diff-nill,2);
                  ka_prev2 := ka_prev;
                  ka_prev := ka;
                          if rec.pay_dt > p_REPORT_DT and diff_prev2 is null then ka := 1;
                          elsif rec.pay_dt <= p_REPORT_DT then ka := 1;
                          elsif diff_prev = 0 then ka := nvl(ka_prev, 1);
                          elsif ka_prev = 0 then ka := diff_prev2 * ka_prev2 / diff_prev; -- падало на нуле                          
                          elsif nill > 0 then ka := ka_prev;
                          else ka := 0;
                          end if;
                  v_id_prev := rec.L_KEY;
                  prev_dt := rec.pay_dt;
                  nil_ka := round(ka * nill, 2);
                  if nil_ka < 0 and rec.pay_dt > p_REPORT_DT then nil_ka := 0;
                  end if;
                  insert into DM_NIL_SINGLE (contract_id,contract_date, fact_amt, plan_amt, leasing_amt, supply_amt, nil_pers,nil,nil_diff,ODTTM, ka, nil_ka, PAY_AMT, branch_key, snapshot_cd, UNDERPAY_LEAS)
                  values(rec.L_KEY,rec.pay_dt,(case when rec.summ < 0 then rec.summ else 0 end), (case when rec.summ > 0 then rec.summ else 0 end), rec.leasing_pay, rec.supply_pay, pers,nill,diff,p_REPORT_DT,round(ka, 2), nil_ka, rec.PAY_AMT, rec.branch_key, 'Основной КИС', rec.UNDER_L_PAY);
                  commit;
              end if;
            end loop;
           -- end if;
commit;

   delete from DM_repayment_schedule 
   where rowid in
   (
        select a.rowid
        from DM_repayment_schedule a
            inner join DM_CORRECT_DNIL b
                on a.contract_key = b.contract_key
                and a.pay_dt >= b.DELETE_DT_1 
                and b.CORRECTION_NUMBER = p_CORRECTION_NUMBER
        where a.snapshot_dt = p_REPORT_DT  
        and snapshot_cd = 'Основной КИС'           
   ); 
  dm.u_log(p_proc => 'DM.p_DM_CORRECT_CALC_NIL',
           p_step => 'delete from DM_repayment_schedule',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');   
   
-- [apolyakov 14.09.2016]: Доработка по обратному КГП
--delete from DM_repayment_schedule_hist 
--   where snapshot_dt = p_REPORT_DT 
--   and contract_key = p_contract_key
--   and pay_dt >= p_DELETE_DT_1
--   and snapshot_cd = 'Основной КИС';

   delete from DM_repayment_schedule_hist 
   where rowid in
   (
        select a.rowid
        from DM_repayment_schedule_hist a
            inner join DM_CORRECT_DNIL b
                on a.contract_key = b.contract_key
                and a.pay_dt >= b.DELETE_DT_1 
                and b.CORRECTION_NUMBER = p_CORRECTION_NUMBER 
        where a.snapshot_dt = p_REPORT_DT  
        and snapshot_cd = 'Основной КИС'               
   );
  dm.u_log(p_proc => 'DM.p_DM_CORRECT_CALC_NIL',
           p_step => 'delete from DM_repayment_schedule_hist',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');   

/*delete dm_stg_kb;
commit;
insert into dm_stg_kb (contract_id, kb)
with t as
(select contract_id, sum(nil_ka) sum_nil
    from DM_NIL_SINGLE
   where contract_date > p_REPORT_DT
     and contract_id = p_contract_key
     and odttm = p_REPORT_DT
     and snapshot_cd = 'Основной КИС'
   group by contract_id),
t2 as
(select contract_id, nil_diff
    from DM_NIL_SINGLE
   where contract_date = p_REPORT_DT
     and contract_id = p_contract_key
     and odttm = p_REPORT_DT
     and snapshot_cd = 'Основной КИС'),
t3 as 
(select t.contract_id, decode(t.sum_nil, 0, -1, t2.nil_diff / t.sum_nil) as kb from t, t2
where t.contract_id = t2.contract_id)
select contract_id, kb from t3;
commit;
update DM_NIL_SINGLE a set a.kb = (select b.kb from dm_stg_kb b where b.contract_id = a.contract_id),
nil_ka_kb = round(nil_ka  * (select b.kb from dm_stg_kb b where b.contract_id = a.contract_id), 2)
where a.contract_date > p_REPORT_DT 
and odttm = p_REPORT_DT
and a.contract_id = p_contract_key;
commit;
update DM_NIL_SINGLE set kb = 0, nil_ka_kb = 0 where kb is null or nil_ka_kb is null;
commit;

insert into DM_NIL
select * from DM_NIL_SINGLE;
*/

    delete from DM_NIL_SINGLE_KB;
  dm.u_log(p_proc => 'DM.p_DM_CORRECT_CALC_NIL',
           p_step => 'delete from DM_NIL_SINGLE_KB',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');   
insert all
    into DM_NIL(CONTRACT_ID, CONTRACT_DATE, FACT_AMT, PLAN_AMT, LEASING_AMT, 
    SUPPLY_AMT, NIL_PERS, NIL, NIL_DIFF, ODTTM, KA, NIL_KA, KB  ,NIL_KA_KB,PAY_AMT, BRANCH_KEY, SNAPSHOT_CD, UNDERPAY_LEAS)
    -------------------------------------------------------------------------------------- 
    into DM_NIL_SINGLE_KB(CONTRACT_ID, CONTRACT_DATE, FACT_AMT, PLAN_AMT, LEASING_AMT, 
    SUPPLY_AMT, NIL_PERS, NIL, NIL_DIFF, ODTTM, KA, NIL_KA, KB  ,NIL_KA_KB,PAY_AMT, BRANCH_KEY, SNAPSHOT_CD, UNDERPAY_LEAS)
select 
    CONTRACT_ID, CONTRACT_DATE, FACT_AMT, PLAN_AMT, LEASING_AMT, 
    SUPPLY_AMT, NIL_PERS, NIL, NIL_DIFF, ODTTM, KA, NIL_KA, 
    nvl(case when contract_date > p_REPORT_DT --to_date('29.02.2016', 'dd.mm.yyyy') 
            and nil_diff_dt is not null
                then decode(t.sum_nil, 0, -1, t.nil_diff_dt / t.sum_nil) 
        else kb 
    end,0) kb, 
    nvl(case when contract_date > p_REPORT_DT --to_date('29.02.2016', 'dd.mm.yyyy') 
        and nil_diff_dt is not null
            then round(nil_ka  * decode(t.sum_nil, 0, -1, t.nil_diff_dt / t.sum_nil), 2) 
        else NIL_KA_KB
    end,0) NIL_KA_KB,
    PAY_AMT, BRANCH_KEY, SNAPSHOT_CD, UNDERPAY_LEAS
from 
(
    select 
    CONTRACT_ID, CONTRACT_DATE, FACT_AMT, PLAN_AMT, LEASING_AMT, 
    SUPPLY_AMT, NIL_PERS, NIL, NIL_DIFF, ODTTM, KA, NIL_KA, 
    KB, NIL_KA_KB, PAY_AMT, BRANCH_KEY, SNAPSHOT_CD, UNDERPAY_LEAS,
    sum(
            case when   contract_date > p_REPORT_DT-- to_date('29.02.2016', 'dd.mm.yyyy')
                    and odttm = p_REPORT_DT-- to_date('29.02.2016', 'dd.mm.yyyy')
                    and snapshot_cd = 'Основной КИС'
            then nil_ka
            else null end ) over (partition by CONTRACT_ID) sum_nil,
    max(        
            case when   contract_date = p_REPORT_DT-- to_date('29.02.2016', 'dd.mm.yyyy')
                    and odttm = p_REPORT_DT-- to_date('29.02.2016', 'dd.mm.yyyy')
                    and snapshot_cd = 'Основной КИС'
            then nil_diff
            else null end ) over (partition by CONTRACT_ID) nil_diff_dt
    from DM_NIL_SINGLE dn
) t;
  dm.u_log(p_proc => 'DM.p_DM_CORRECT_CALC_NIL',
           p_step => 'insert all into DM_NIL;into DM_NIL_SINGLE_KB',
           p_info => SQL%ROWCOUNT|| ' row(s) inserteded');    
commit;


insert all
into dm_repayment_schedule
    ( SNAPSHOT_DT,
      SNAPSHOT_CD,
      SNAPSHOT_MONTH,
      CONTRACT_KEY,
      TRANCHE_NUM,
      PAY_DT,
      CURRENCY_KEY,
      FACT_PAY_AMT,
      PLAN_PAY_AMT,
      LEASING_PAY_AMT,
      SUPPLY_PAY_AMT,
      PAY_AMT,
      NIL_AMT,
      INTEREST_AMT,
      PRINCIPAL_AMT,
      DNIL_AMT,
      KA,
      KB,
      PROCESS_KEY,
      INSERT_DT,
      BRANCH_KEY,
      NIL_ORIG_AMT,
      UNDERPAY_LEAS,
      CUSTOM_FLG
)

values

    ( SNAPSHOT_DT,
      SNAPSHOT_CD,
      SNAPSHOT_MONTH,
      CONTRACT_KEY,
      TRANCHE_NUM,
      PAY_DT,
      CURRENCY_KEY,
      FACT_PAY_AMT,
      PLAN_PAY_AMT,
      LEASING_PAY_AMT,
      SUPPLY_PAY_AMT,
      PAY_AMT,
      NIL_AMT,
      INTEREST_AMT,
      PRINCIPAL_AMT,
      DNIL_AMT,
      KA,
      KB,
      PROCESS_KEY,
      INSERT_DT,
      BRANCH_KEY,
      NIL_ORIG_AMT,
      UNDERPAY_LEAS,
      CUSTOM_FLG
)

into dm_repayment_schedule_hist
    ( SNAPSHOT_DT,
      SNAPSHOT_CD,
      SNAPSHOT_MONTH,
      CONTRACT_KEY,
      TRANCHE_NUM,
      PAY_DT,
      CURRENCY_KEY,
      FACT_PAY_AMT,
      PLAN_PAY_AMT,
      LEASING_PAY_AMT,
      SUPPLY_PAY_AMT,
      PAY_AMT,
      NIL_AMT,
      INTEREST_AMT,
      PRINCIPAL_AMT,
      DNIL_AMT,
      KA,
      KB,
      PROCESS_KEY,
      INSERT_DT,
      BRANCH_KEY,
      NIL_ORIG_AMT,
      UNDERPAY_LEAS,
      FILE_ID,
      VALID_FROM_DTTM,
      VALID_TO_DTTM,
      CUSTOM_FLG,
      CLOSED_ROW_FILE_ID
)

select 
      SNAPSHOT_DT,
      SNAPSHOT_CD,
      SNAPSHOT_MONTH,
      CONTRACT_KEY,
      TRANCHE_NUM,
      PAY_DT,
      CURRENCY_KEY,
      FACT_PAY_AMT,
      PLAN_PAY_AMT,
      LEASING_PAY_AMT,
      SUPPLY_PAY_AMT,
      PAY_AMT,
      NIL_AMT,
      INTEREST_AMT,
      PRINCIPAL_AMT,
      DNIL_AMT,
      KA,
      KB,
      PROCESS_KEY,
      INSERT_DT,
      BRANCH_KEY,
      NIL_ORIG_AMT,
      UNDERPAY_LEAS,
      FILE_ID,
      VALID_FROM_DTTM,
      VALID_TO_DTTM,
      CUSTOM_FLG,
      CLOSED_ROW_FILE_ID
from (
with 
   SUM_UNDERPAY_LEAS as                    
                    (
                    select a.contract_id,
                           a.contract_date,
                           round (a.NIL_KA_KB * (100 / (100 + v.contract_vat_rate*100)), 2) Nil_ka_kb_2, 
                           sum(round (a.NIL_KA_KB * (100 / (100 + v.contract_vat_rate*100)), 2)) over (partition by a.contract_id  order by a.CONTRACT_DATE rows between unbounded preceding and current row) sum_nil_ka_kb_2,
                           sum(round (a.LEASING_AMT * (100 / (100 + v.contract_vat_rate*100)), 2)) over (partition by a.contract_id  order by a.CONTRACT_DATE rows between unbounded preceding and current row) sum_leasing,
                           b.SUM_UNDERPAY * (100 / (100 + v.contract_vat_rate*100)) SUM_UNDERPAY,
                           b.min_DT_U,
                           c.min_DT_L
                    from dm.DM_NIL_SINGLE_KB a, 
                          (select sum(UNDERPAY_LEAS) SUM_UNDERPAY, contract_id, min(contract_date) min_DT_U from dm.DM_NIL_SINGLE
                            where snapshot_cd = 'Основной КИС'
                                  and odttm = p_REPORT_DT
                                  and UNDERPAY_LEAS > 0
                            group by contract_id) b,
                           (select min(contract_date) min_DT_L, contract_id from dm.DM_NIL_SINGLE
                            where snapshot_cd = 'Основной КИС'
                                  and odttm = p_REPORT_DT
                                  and LEASING_AMT > 0
                           group by contract_id) c, 
                          --dwh.vat v
                          dwh.contracts v
                    where a.CONTRACT_DATE > p_REPORT_DT
                        and a.contract_id=b.contract_id 
                        and a.contract_id=c.contract_id 
                        and a.snapshot_cd = 'Основной КИС'
                        and a.odttm = p_REPORT_DT
                       /* and a.branch_key = v.branch_key
                        and v.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                        and v.begin_dt <= p_REPORT_DT
                        and v.end_dt >= p_REPORT_DT*/
                        --
                        and v.contract_key = a.contract_id
                         --and v.valid_to_dttm=to_date('01.01.2400','dd.mm.yyyy')
                        and p_REPORT_DT between v.valid_from_dttm and v.valid_to_dttm                                      
                    ) 
--[apolyakov 14.09.2016]: добавление алисасов для обратного КГП 
select p_REPORT_DT SNAPSHOT_DT, 
'Основной КИС'as SNAPSHOT_CD,  
to_char(p_REPORT_DT, 'MM') as SNAPSHOT_MONTH,
a.contract_id as CONTRACT_KEY, 
null as TRANCHE_NUM, 
a.contract_date as PAY_DT, 
b.currency_key as CURRENCY_KEY,
a.fact_amt as FACT_PAY_AMT,  
a.plan_amt as PLAN_PAY_AMT,
a.leasing_amt as LEASING_PAY_AMT,
a.supply_amt as SUPPLY_PAY_AMT,
a.PAY_AMT as PAY_AMT, 
CASE
  WHEN su.min_dt_u>min_dt_l and su.SUM_UNDERPAY - su.sum_nil_ka_kb_2 >=0       
      THEN 0
  WHEN
       su.min_dt_u>min_dt_l and su.SUM_UNDERPAY - su.sum_nil_ka_kb_2 < 0 and abs(su.SUM_UNDERPAY - su.sum_nil_ka_kb_2) < su.Nil_ka_kb_2
      THEN abs(su.SUM_UNDERPAY - su.sum_nil_ka_kb_2)

  WHEN su.min_dt_u <= min_dt_l and round(su.SUM_UNDERPAY - su.sum_leasing,0) >=0      
      THEN 0
      
--  WHEN su.min_dt_u <= min_dt_l and (round (a.NIL_KA_KB * (100 / (100 + v.vat_rate*100)), 2) - ROUND (a.UNDERPAY_LEAS * (100 / (100 + v.vat_rate*100)), 2)) < 0       
--      THEN 0

  ELSE (round (a.NIL_KA_KB * (100 / (100 + v.contract_vat_rate*100)), 2) - ROUND (a.UNDERPAY_LEAS * (100 / (100 + v.contract_vat_rate*100)), 2))

END NIL_AMT,                                     -- учет НДС
a.NIL_PERS as INTEREST_AMT, 
a.NIL as PRINCIPAL_AMT, 
a.NIL_DIFF as DNIL_AMT, 
a.KA as KA, 
a.KB as KB, 
77 as PROCESS_KEY, 
sysdate  as INSERT_DT,
a.branch_key as BRANCH_KEY,
a.NIL_KA_KB as NIL_ORIG_AMT,
a.UNDERPAY_LEAS   as UNDERPAY_LEAS,
0 as CUSTOM_FLG,
0 as FILE_ID,
sysdate as VALID_FROM_DTTM,
to_date ('01.01.2400', 'dd.mm.yyyy') as  VALID_TO_DTTM,
null as CLOSED_ROW_FILE_ID
from DM_NIL_SINGLE_KB a 
inner join dwh.contracts b
    on a.contract_id = b.contract_key
    and b.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
    --and a.contract_id = p_contract_key
/*inner join dwh.vat v 
    on a.branch_key = v.branch_key
    and v.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
    and v.begin_dt <= p_REPORT_DT
    and v.end_dt >= p_REPORT_DT*/
    
 join dwh.contracts v on v.contract_key = a.contract_id
  --and v.valid_to_dttm=to_date('01.01.2400','dd.mm.yyyy')
  and p_REPORT_DT between v.valid_from_dttm and v.valid_to_dttm 
      
left join SUM_UNDERPAY_LEAS su 
    on a.contract_id = su.contract_id
    and a.contract_date = su.contract_date
inner join DM_CORRECT_DNIL dcd
    on a.contract_id = dcd.contract_key 
    and dcd.CORRECTION_NUMBER = p_CORRECTION_NUMBER    
where a.odttm = p_REPORT_DT
and a.snapshot_cd = 'Основной КИС'
and a.contract_date >= dcd.DELETE_DT_2     -------------------------------------------------------[asavgurov 03.11.2015]: p_DELETE_DT_2 используется только тут
);
  dm.u_log(p_proc => 'DM.p_DM_CORRECT_CALC_NIL',
           p_step => 'insert all into dm_repayment_schedule;into dm_repayment_schedule_hist',
           p_info => SQL%ROWCOUNT|| ' row(s) inserteded');     
commit;

end;
/

