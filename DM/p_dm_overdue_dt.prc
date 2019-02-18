CREATE OR REPLACE PROCEDURE DM.p_DM_OVERDUE_DT(
    p_REPORT_DT in date,
    p_group_key in number,
    p_snapshot_cd in varchar
)

IS

/* Процедура пересчитывает дату возникновения просроченной задолженности в витрине p_DM_CGP,
   заполняя промежуточную витрину DM_OVERDUE_DT записью для contract_id, даты возникновения
   просрочки overdue_dt и даты отчета ODDTM. 
   
   На вход в качестве параметра подается отчетная дата p_REPORT_DT.
*/


BEGIN
   
delete from DM_overdue_dt 
where ODDTM = p_REPORT_DT
and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
and snapshot_cd = p_snapshot_cd; 
  dm.u_log(p_proc => 'p_DM_OVERDUE_DT',
           p_step => 'delete from DM_overdue_dt',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted'); 
insert into dm_overdue_dt (
                            contract_id,
                            ODDTM,
                            branch_key,
                            overdue_dt,
                            snapshot_cd)
                
                    with
                    
                      /* В качестве потока берутся плановые и фактические платежи по договорам лизинга
                         (см. процедуру p_DM_OVERDUE_CALC).
                      */
                      Contr as (
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
                                                              where cgp_group.cgp_group_key not in (2)
                                                              and cgp_group.begin_dt <= p_REPORT_DT
                                                              and cgp_group.end_dt > p_REPORT_DT)
                                       ))
                                 and cl.cgp_flg = '1'                                                -- Договор КГП
                                 and cgp_group.cgp_group_key = p_group_key                               
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
                     from (select distinct 
                                        L_KEY,
                                        branch_key,
                                        L_CUR,
                                        base_currency
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
                     from (select distinct 
                                        L_KEY,
                                        L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        base_currency
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
                     from (select distinct 
                                        L_KEY,
                                        branch_key,
                                        L_CUR,
                                        base_currency
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
                            Contr.base_currency
                     from (select distinct 
                                        L_KEY,
                                        L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        base_currency
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
                                select L_KEY contract_id,
                                       branch_key,
                                       PAY_DT dt,
                                       SUM(case
                                       when CUR1 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT
                                          then round(PAY_AMT*rt1.EXCHANGE_RATE/rt2.EXCHANGE_RATE, 2)
                                       when CUR1 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT > p_REPORT_DT
                                          then round(PAY_AMT*rt_rp1.EXCHANGE_RATE/rt_rp2.EXCHANGE_RATE, 2)
                                       when CUR1 = s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT
                                          then round(PAY_AMT*rt1.EXCHANGE_RATE, 2)
                                       when CUR1 = s.base_currency and CUR2 <> s.base_currency and PAY_DT > p_REPORT_DT
                                          then round(PAY_AMT*rt_rp1.EXCHANGE_RATE, 2)
                                       when CUR2 = s.base_currency and CUR1 <> s.base_currency and PAY_DT <= p_REPORT_DT
                                          then round(PAY_AMT/rt2.EXCHANGE_RATE, 2)
                                       when CUR2 = s.base_currency and CUR1 <> s.base_currency and PAY_DT > p_REPORT_DT
                                          then round(PAY_AMT/rt_rp2.EXCHANGE_RATE, 2)
                                       else PAY_AMT
                                       end) as PAY_AMT_cur,
                                       TP
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
                                       PAY_DT,
                                       TP
                              ),
            overdue_go as (    
                             select fc.contract_id,
                                    fc.branch_key,
                                    fc.dt, 
                                    sum(fc.pay_amt_cur) over (partition by fc.contract_id order by fc.dt rows between unbounded preceding and current row) sum_plan,
                                    nvl(S_FACT.sum_fact,0) sum_fact
                             from   flow_cur fc
                             left join (select contract_id, sum(pay_amt_cur) sum_fact from flow_cur 
                                            where TP='LEASING_fact' 
                                            group by contract_id) S_FACT
                                     on fc.contract_id=S_FACT.contract_id
                             inner join dwh.cgp_group cgp_group                                   -- вяжемся с ручным справочником групп организаций для расчета потока для данной группы организаций
                                    ON fc.branch_key = cgp_group.branch_key
                                    and cgp_group.begin_dt <= p_REPORT_DT
                                    and cgp_group.end_dt > p_REPORT_DT
                             where fc.TP = 'LEASING_plan' and cgp_group.cgp_group_key = 2),
           overdue_do as (    
                             select fc.contract_id,
                                    fc.branch_key,
                                    fc.dt, 
                                    sum(fc.pay_amt_cur) over (partition by fc.contract_id order by fc.dt rows between unbounded preceding and current row) sum_plan,
                                    nvl(S_FACT.sum_fact,0) sum_fact
                             from   flow_cur fc
                             left join (select contract_id, sum(pay_amt_cur) sum_fact from flow_cur 
                                            where TP='LEASING_fact' 
                                            group by contract_id) S_FACT
                                     on fc.contract_id=S_FACT.contract_id
                             inner join dwh.cgp_group cgp_group                                   -- вяжемся с ручным справочником групп организаций для расчета потока для данной группы организаций
                                    ON fc.branch_key = cgp_group.branch_key
                                    and cgp_group.begin_dt <= p_REPORT_DT
                                    and cgp_group.end_dt > p_REPORT_DT
                             where fc.TP = 'LEASING_plan' and cgp_group.cgp_group_key not in (1,2)),                                     
           balance_go as(
                            select contract_id,
                                    branch_key,
                                    dt, 
                                    sum_plan,
                                    nvl(sum_fact, 0) sum_fact,
                                    (sum_plan + nvl(sum_fact, 0)) d_diff,
                                    'Основной КИС' as snapshot_cd
                             from   overdue_go
                              ),
           balance_do as(
                            select contract_id,
                                    branch_key,
                                    dt, 
                                    sum_plan,
                                    nvl(sum_fact, 0) sum_fact,
                                    (sum_plan + nvl(sum_fact, 0)) d_diff,
                                    'Основной КИС' as snapshot_cd
                             from   overdue_do
                              ),                              
                     
          OVERDUE_DT_GO as (             
                              select b1.contract_id,
                                     p_REPORT_DT as ODDTM,
                                     b1.branch_key,
                                     min(b1.dt) as overdue_dt,
                                     b1.snapshot_cd
                               from balance_go b1
                               left join ( 
                                    select contract_id,
                                          p_REPORT_DT as ODDTM,
                                          branch_key,
                                           max(case
                                              when
                                                d_diff <= 0 
                                                then dt
                                              else to_date('01.01.1900', 'dd.mm.yyyy')
                                            end
                                           ) as max_dt,
                                           snapshot_cd
                                    from balance_GO b1
                                    group by contract_id, p_REPORT_DT, branch_key, snapshot_cd
                                    ) b2
                                    on b1.contract_id = b2.contract_id
                                    and b1.dt > b2.max_dt
                                    where max_dt is not Null
                             group by b1.contract_id, p_REPORT_DT, b1.branch_key, b1.snapshot_cd),
          OVERDUE_DT_DO as (             
                              select b1.contract_id,
                                     p_REPORT_DT as ODDTM,
                                     b1.branch_key,
                                     min(b1.dt) as overdue_dt,
                                     b1.snapshot_cd
                               from balance_do b1
                               left join ( 
                                    select contract_id,
                                          p_REPORT_DT as ODDTM,
                                          branch_key,
                                           max(case
                                              when
                                                d_diff <= 0 
                                                then dt
                                              else to_date('01.01.1900', 'dd.mm.yyyy')
                                            end
                                           ) as max_dt,
                                           snapshot_cd
                                    from balance_DO b1
                                    group by contract_id, p_REPORT_DT, branch_key, snapshot_cd
                                    ) b2
                                    on b1.contract_id = b2.contract_id
                                    and b1.dt > b2.max_dt
                                    where max_dt is not Null
                             group by b1.contract_id, p_REPORT_DT, b1.branch_key, b1.snapshot_cd)
                select *
                from OVERDUE_DT_GO
                UNION ALL
                select *
                from OVERDUE_DT_DO;                        
                         
                          /* В качестве баланса берем поток и добавляем к нему строку с датой отчета, наследующей
                             значение баланса на последнюю дату платежа.
                          */
 /*                        overdue as (    
                             select fc.contract_id,
                                    fc.branch_key,
                                    fc.dt, 
                                    sum(fc.pay_amt_cur) over (partition by fc.contract_id order by fc.dt rows between unbounded preceding and current row) sum_plan,
                                    S_FACT.sum_fact
                             from   flow_cur fc
                             left join (select contract_id, sum(pay_amt_cur) sum_fact from flow_cur 
                                            where TP='LEASING_fact' 
                                            group by contract_id) S_FACT
                                     on fc.contract_id=S_FACT.contract_id
                                     where fc.TP = 'LEASING_plan'),
                         
                         balance as(
                            select contract_id,
                                    branch_key,
                                    dt, 
                                    sum_plan,
                                    nvl(sum_fact, 0),
                                    (sum_plan + nvl(sum_fact, 0)) d_diff,
                                    p_snapshot_cd as snapshot_cd
                             from   overdue
                              )
                            
 */                           
                            /* Поскольку датой возникновения просрочки мы считаем дату, когда баланс стал > 0, а баланс на предыдущую
                               дату был < 0, то выбираем значение баланса на предыдущую дату. nvl на случай, когда нынешний платеж - первый для
                               данного договора.
                            */
                           
                             
                             /* Выбираем максимальную дату платежа, когда баланс поменял знак с - на +, считая ее датой возникновения просрочки...
                             */
/*                               select b1.contract_id,
                                     p_REPORT_DT as ODDTM,
                                     b1.branch_key,
                                     min(b1.dt) as overdue_dt,
                                     b1.snapshot_cd
                               from balance b1
                               left join ( 
                                    select contract_id,
                                          p_REPORT_DT as ODDTM,
                                          branch_key,
                                           max(case
                                              when
                                                d_diff <= 0 
                                                then dt
                                              else to_date('01.01.1900', 'dd.mm.yyyy')
                                            end
                                           ) as max_dt,
                                           snapshot_cd
                                    from balance b1
                                    group by contract_id, p_REPORT_DT, branch_key, snapshot_cd
                                    ) b2
                                    on b1.contract_id = b2.contract_id
                                    and b1.dt > b2.max_dt
                                    where max_dt is not Null
                             group by b1.contract_id, p_REPORT_DT, b1.branch_key, b1.snapshot_cd;*/

  dm.u_log(p_proc => 'p_DM_OVERDUE_DT',
           p_step => 'insert into dm_overdue_dt',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted'); 
commit;

end;
/

