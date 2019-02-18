CREATE OR REPLACE PROCEDURE DM.p_DM_AVG_OVERDUE_CALC_SINGLE(
    p_contract_key in number,
    p_REPORT_DT in date,
    p_snapshot_cd in varchar
    
)

IS

/* Процедура рассчитывает среднюю просроченную задолженность и заполняет промежуточную витрину DM_AVG_OVERDUE_AMT 
   значениями средней просроченной задолженности AVG_OVERDUE_AMT для каждого контракта с contract_id и даты отчета ODDTM
            
-- В качестве параметра на вход подается дата отчета (p_REPORT_DT).
-- В качестве потока берутся все плановые и фактические платежи по лизингу с датой <= отчетной.
*/

BEGIN
      dm.u_log(p_proc => 'DM.p_DM_AVG_OVERDUE_CALC_SINGLE',
           p_step => 'INPUT PARAMS',
           p_info => 'p_contract_key:'||p_contract_key||'p_REPORT_DT:'||p_REPORT_DT||'p_snapshot_cd:'||p_snapshot_cd); 
    delete from DM_avg_overdue_amt 
    where ODDTM = p_REPORT_DT
    and contract_id = p_contract_key
    and snapshot_cd = p_snapshot_cd;
  dm.u_log(p_proc => 'DM.p_DM_AVG_OVERDUE_CALC_SINGLE',
           p_step => 'delete from DM_avg_overdue_amt',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');        
    insert into dm_avg_overdue_amt (
                                      contract_id, 
                                      avg_overdue_amt, 
                                      avg_overdue_vat_free_amt,
                                      ODDTM,
                                      branch_key,
                                      snapshot_cd)
                                      
                    /* В поток FLOW_CUR попадают плановые и фактические платежи по договорам лизинга (см. процедуру p_DM_OVERDUE_CALC)
                    */                      
        with
            /* Выборка действующих контрактов лизинга и соответствующих им договоров поставок, связанных по полю CONTRACT_LEASING_KEY и следующему условию:
               -- дата начала договора <= дата окончания отчетного периода
               -- дата окончания договора >= дата начала отчетного периода 
            */
            Contr as (
                          SELECT cn1.contract_key L_key,
                                 cn2.contract_key S_key,
                                 cn1.branch_key,
                                 cn1.Currency_Key L_CUR,                                      -- Валюта договора лизинга
                                 cn2.Currency_key S_CUR,                                      -- Валюта договора поставки
                                 OS.base_currency_key base_currency,
                                 cn1.valid_to_dttm
                                 ,cn1.contract_vat_rate -- Add By Zanozin 19/06/2017    
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
                                 and cn1.contract_key = p_contract_key                               
                                 and cn1.open_dt <= p_REPORT_DT
                                 and nvl(cn1.rehiring_flg, 0) != 1
                                 --and cn1.EXClUDE_CGP IS NULL
              ),
              
              Contr_ces as (                                
                        SELECT 
                            cn1.L_key L_key,
                            cn1.S_key S_key,
                            cn3.contract_key L_key_dop,
                            cn4.contract_key S_key_dop,
                            cn1.branch_key,
                            cn1.L_CUR,
                            cn1.S_CUR,
                            cn1.base_currency base_currency
                            ,cn1.contract_vat_rate -- Add By Zanozin 19/06/2017    
                        From Contr cn1
                        join dwh.contracts cn2 
                            ON cn1.l_key = cn2.contract_key
                            and cn2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                            and cn1.branch_key = cn2.branch_key
                        left join dwh.contracts cn3
                            ON cn2.CONTRACT_ID_CD = cn3.CONTRACT_ID_CD        -- привязка по Id транзакции для склейки двух договоров...
                              and cn3.contract_key <> cn2.contract_key 
                              and cn3.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                              and cn3.branch_key = cn2.branch_key
                        Left join dwh.contracts cn4
                              ON cn3.contract_key = cn4.contract_leasing_key  
                              and cn4.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          ),
              
              /* Выборка фактических и плановых платежей по договорам лизинга с кодом КБК (1.1 - 1.10)
              */        
              Flow_plan_fact as
                    (
                     SELECT Contr.L_KEY,
                            branch_key,
                            fact_pp.CBC_DESC,
                            PAY_DT,
                            PAY_AMT, 
                            'LEASING_plan' TP, 
                            Contr.L_CUR CUR1, 
                            fact_pp.CURRENCY_KEY CUR2,
                            Contr.base_currency
                            ,contract_vat_rate -- Add By Zanozin 19/06/2017    
                     from (select distinct 
                                        L_KEY,
                                        branch_key,
                                        L_CUR,
                                        base_currency
                                        ,contract_vat_rate -- Add By Zanozin 19/06/2017    
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
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)))               -- выбор плановых платежей по договорам лизинга с кодом классификации КБК 1.1 - 1.10
                      and fact_pp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                      and p_REPORT_DT between fact_pp.BEGIN_DT and fact_pp.END_DT
                      and PAY_DT <= p_REPORT_DT
                      
                      UNION ALL
                      
                     SELECT Contr.L_KEY,
                            branch_key,
                            fact_pp.CBC_DESC,
                            PAY_DT,
                            PAY_AMT, 
                            'LEASING_plan' TP, 
                            Contr.L_CUR CUR1, 
                            fact_pp.CURRENCY_KEY CUR2,
                            Contr.base_currency
                            ,contract_vat_rate -- Add By Zanozin 19/06/2017    
                     from (select distinct 
                                        L_KEY,
                                        L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        base_currency                                 ,contract_vat_rate -- Add By Zanozin 19/06/2017    
                                        from Contr_ces) Contr
                     inner join dwh.fact_plan_payments fact_pp
                        ON Contr.L_KEY_DOP = fact_pp.contract_key
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
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)))               -- выбор плановых платежей по договорам лизинга с кодом классификации КБК 1.1 - 1.10
                      and fact_pp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                      and p_REPORT_DT between fact_pp.BEGIN_DT and fact_pp.END_DT
                      and PAY_DT <= p_REPORT_DT
                      
                      UNION ALL
                     
                     SELECT Contr.L_KEY,
                            branch_key,
                            fact_pp.CBC_DESC,
                            PAY_DT,
                            PAY_AMT*-1, 
                            'LEASING_fact' TP, 
                            Contr.L_CUR CUR1, 
                            fact_pp.CURRENCY_KEY CUR2,
                            Contr.base_currency                                
                            ,contract_vat_rate -- Add By Zanozin 19/06/2017    
                     from (select distinct 
                                        L_KEY,
                                        branch_key,
                                        L_CUR,
                                        base_currency                                 
                                        ,contract_vat_rate -- Add By Zanozin 19/06/2017    
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
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)))             -- выбор фактических платежей по договорам лизинга с кодом классификации КБК 1.1 - 1.10
                      and fact_pp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                       and PAY_DT <= p_REPORT_DT
                       
                       UNION ALL
                       
                        SELECT Contr.L_KEY,
                            branch_key,
                            fact_pp.CBC_DESC,
                            PAY_DT,
                            PAY_AMT*-1, 
                            'LEASING_fact' TP, 
                            Contr.L_CUR CUR1, 
                            fact_pp.CURRENCY_KEY CUR2,
                            Contr.base_currency                                 ,contract_vat_rate -- Add By Zanozin 19/06/2017    
                     from (select distinct 
                                        L_KEY,
                                        L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        base_currency                                 ,contract_vat_rate -- Add By Zanozin 19/06/2017    
                                        from Contr_ces) Contr
                     inner join dwh.fact_real_payments fact_pp
                        ON Contr.L_KEY_DOP = fact_pp.contract_key
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
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)))             -- выбор фактических платежей по договорам лизинга с кодом классификации КБК 1.1 - 1.10
                      and fact_pp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                       and PAY_DT <= p_REPORT_DT
                      ),
                              
                       Flow_CUR as
                            (
                              select L_KEY,
                                     branch_key,
                                     --CBC_DESC, -- [aapolyakov 04.12.2015]: не нужны эти поля, необходимо схлопывать, иначе накопительная сумма чередует строки.
                                     PAY_DT,
                                     -- [asavgurov 04.12.2015]: добавлено округление
                                     sum (case
                                     when CUR1 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT
                                        then round(PAY_AMT*rt1.EXCHANGE_RATE/rt2.EXCHANGE_RATE,2)
                                     when CUR1 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT > p_REPORT_DT
                                        then round(PAY_AMT*rt_rp1.EXCHANGE_RATE/rt_rp2.EXCHANGE_RATE,2)
                                     when CUR1 = s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT
                                        then round(PAY_AMT*rt1.EXCHANGE_RATE,2)
                                     when CUR1 = s.base_currency and CUR2 <> s.base_currency and PAY_DT > p_REPORT_DT
                                        then round(PAY_AMT*rt_rp1.EXCHANGE_RATE,2)
                                     when CUR2 = s.base_currency and CUR1 <> s.base_currency and PAY_DT <= p_REPORT_DT
                                        then round(PAY_AMT/rt2.EXCHANGE_RATE,2)
                                     when CUR2 = s.base_currency and CUR1 <> s.base_currency and PAY_DT > p_REPORT_DT
                                        then round(PAY_AMT/rt_rp2.EXCHANGE_RATE,2)
                                     else round(PAY_AMT,2)
                                     end) as PAY_AMT_cur -- [aapolyakov 04.12.2015]: добавлена сумма для схлопывания одинаковых дат
                                     --PAY_AMT, -- [aapolyakov 04.12.2015]: не нужны эти поля, необходимо схлопывать, иначе накопительная сумма чередует строки.
                                     --TP, -- [aapolyakov 04.12.2015]: не нужны эти поля, необходимо схлопывать, иначе накопительная сумма чередует строки.
                                     --CUR1, -- [aapolyakov 04.12.2015]: не нужны эти поля, необходимо схлопывать, иначе накопительная сумма чередует строки.
                                     --CUR2 -- [aapolyakov 04.12.2015]: не нужны эти поля, необходимо схлопывать, иначе накопительная сумма чередует строки.
                                      ,contract_vat_rate
                             from Flow_plan_fact s
                             left join dwh.EXCHANGE_RATES rt1 
                                   on s.PAY_DT = rt1.ex_rate_dt 
                                  and s.CUR2= rt1.CURRENCY_KEY 
                                  and rt1.BASE_CURRENCY_KEY = s.base_currency
                                  and rt1.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                                  
                             left join dwh.EXCHANGE_RATES rt2 
                                   on s.PAY_DT = rt2.ex_rate_dt 
                                  and s.CUR1= rt2.CURRENCY_KEY 
                                  and rt2.BASE_CURRENCY_KEY = s.base_currency
                                  and rt2.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                                  
                             left join dwh.EXCHANGE_RATES rt_rp1 
                                   on rt_rp1.ex_rate_dt = p_REPORT_DT 
                                  and s.CUR2= rt_rp1.CURRENCY_KEY 
                                  and rt_rp1.BASE_CURRENCY_KEY = s.base_currency
                                  and rt_rp1.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                                  
                             left join dwh.EXCHANGE_RATES rt_rp2 
                                   on rt_rp2.ex_rate_dt= p_REPORT_DT 
                                  and s.CUR1= rt_rp2.CURRENCY_KEY 
                                  and rt_rp2.BASE_CURRENCY_KEY = s.base_currency
                                  and rt_rp2.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                                  
                             group by L_KEY,
                                     branch_key,
                                     PAY_DT,contract_vat_rate
                            ),
                            
                       /* Вычисление накапливаемой суммы (баланса) платежей для каждого контракта за все время. Если сумма > 0.01, то она является просрочкой (см. процедуру p_DM_CGP)
                       */
                       overdue_prev as      
                            (select L_KEY as contract_id,
                                    f.branch_key,
                                    --vat.vat_rate,
                                    pay_dt dt, 
                                    SUM(PAY_AMT_cur) over (partition by l_KEY order by pay_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) overdue 
                                    ,contract_vat_rate
                             from Flow_CUR f
                            -- inner join dwh.vat vat
                                --on f.branch_key = vat.branch_key
                                --and vat.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                                --and vat.begin_dt <= p_REPORT_DT
                               -- and vat.end_dt >= p_REPORT_DT
                                      ),
                                      
                        overdue_prev_1 as 
                            (select contract_id,
                                    branch_key,
                                    --vat_rate,
                                    dt,
                                    case
                                      when overdue >= 0 
                                          then overdue 
                                      else 0
                                    end AS OVERDUE
                                     ,contract_vat_rate
                             from overdue_prev
                             ),
                                      
                       /* Для расчета количества дней действия просрочки до отчетной даты последнего платежа к полученной 
                          выборке прибавляется строка с датой платежа, равной отчетной и наследующая значение баланса на дату, предшествующую отчетной.
                       */               
                       overdue as (    
                           select contract_id, 
                                  branch_key,
                                  dt, 
                                  overdue 
                                    ,contract_vat_rate -- Add By Zanozin 19/06/2017   
                           from   overdue_prev_1
                           
                           UNION ALL
                           
                           select contract_id, 
                                  branch_key,
                                  p_REPORT_DT + 1 as DT, 
                                  max(overdue) keep (dense_rank last order by dt) overdue
                                    ,contract_vat_rate -- Add By Zanozin 19/06/2017   
                            from overdue_prev_1 where dt < p_REPORT_DT 
                            group by contract_id, branch_key  ,contract_vat_rate
                            
                             UNION ALL
                           
                           select contract_id, 
                                  branch_key,
                                  trunc (p_REPORT_DT, 'mm') - 1 as DT, 
                                  max(overdue) keep (dense_rank last order by dt) overdue
                                    ,contract_vat_rate -- Add By Zanozin 19/06/2017   
                            from overdue_prev_1 where dt <= trunc (p_REPORT_DT, 'mm') - 1 
                            group by contract_id, branch_key ,contract_vat_rate
                          ),
                          
                       overdue_avg as
                        (select contract_id, 
                                branch_key,
                                dt, 
                                overdue*
                                   (nvl (lead (dt) over
                                            (partition by contract_id order by dt), p_REPORT_DT + 1) - dt
                         
                  
                                           )/
                                           (
                                            last_day(dt) - trunc (dt, 'mm') + 2
                                           ) as avg_overdue_amt,
                                p_REPORT_DT as lastday,
                                p_snapshot_cd as snapshot_cd
                                  ,contract_vat_rate -- Add By Zanozin 19/06/2017   
                           from overdue
                             where overdue.dt <= last_day (p_REPORT_DT) 
                              and  overdue.dt >= trunc (p_REPORT_DT, 'mm') - 1
                          )
                          
                          select contract_id, sum (avg_overdue_amt), sum (avg_overdue_amt/(1+contract_vat_rate)),lastday, branch_key, snapshot_cd 
                          from overdue_avg
                         
                          group by contract_id, branch_key, lastday, snapshot_cd,contract_vat_rate;

  dm.u_log(p_proc => 'DM.p_DM_AVG_OVERDUE_CALC_SINGLE',
           p_step => 'insert into dm_avg_overdue_amt',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');           
commit;

end;
/

