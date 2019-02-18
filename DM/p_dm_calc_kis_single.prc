CREATE OR REPLACE PROCEDURE DM.p_DM_CALC_KIS_SINGLE(
      p_contract_key in number,
      p_REPORT_DT IN date,
      p_PAY_DT IN date
)

IS
--v_count number;

/* Процедура, заполняющая промежуточную витрину DM_XIRR вычисленными значениями XIRR для каждого контракта. 
-- В качестве параметров на вход подаются дата отчета (p_REPORT_DT) и номер группы организаций (p_group_key).
-- В процедуре реализован вывод номера договора (contract_id), вычисленного XIRR, даты отчета (ODTTM) и ключа филиала (branch_key) в таблицу DM_XIRR...
-- В качестве потока берутся все плановые платежи по лизингу, фактические платежи до отчетной даты по поставкам и плановые платежи за все время по поставкам.
-- Полученный поток заносится в таблицу DM_XIRR_FLOW, индексируемую IX_DM_XIRR_FLOW по полям L_KEY (номер контракта), REPORT_DT (отчетная дата), EXCPTN_ZERO_DIV (отношение плановых и фактических платежей).
*/
BEGIN
   
-- очистка dm_xirr_flow по договору
   delete from dm_xirr_flow where report_dt = p_report_dt;      -- Очистка таблицы DM_XIRR_FLOW за данный отчетный период
-- получение фин. потока по скорректированному договору.
commit;

insert into dm.dm_xirr_flow (l_key, branch_key, pay_dt, summ, sum_prev, excptn_zero_div, report_dt, flag)
with dnil as (select a.dnil_amt + b.CORRECT_AMT as new_dnil_amt 
              from dm.dm_repayment_schedule a, nil_corrects b 
              where a.contract_key = p_contract_key 
                and a.contract_key = b.contract_key 
                and a.snapshot_dt = p_PAY_DT 
                and a.pay_dt = p_PAY_DT)
select l_key
, branch_key
, pay_dt
, summ
, sum(summ + sum_prev) over (partition by l_key, branch_key, excptn_zero_div, report_dt, flag order by pay_dt, abs(summ) rows between unbounded preceding and current row) as sum_prev
, excptn_zero_div
, report_dt
, flag
from (
select p_contract_key as l_key
, (select branch_key from dwh.contracts where contract_key = p_contract_key and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')) as branch_key
, p_PAY_DT as pay_dt
, -new_dnil_amt as summ
, 0 as sum_prev
, 1 as excptn_zero_div
, p_REPORT_DT as report_dt
, 0 as flag 
from dnil
UNION ALL
SELECT l_key
, branch_key
, pay_dt
, summ
, case when pay_dt = p_PAY_DT and summ = 0 then -new_dnil_amt else 0 end as sum_prev
, excptn_zero_div
, report_dt
, flag
FROM dnil a, 
  (                   /* Авансовый платеж. Если первым осуществлен платеж Л1 по договору лизинга, то производится "размазывание" этого платежа лизинга
                           по платежам поставки. Каждому отрицательному платежу ставится в соответствие такой же положительный платеж до той даты (min_dt), 
                           когда договор поставки по модулю не станет больше накопительной суммы (см. FLOW). 
                        */
                      with   
                      /* Недоплата. Неоплаченные плановые поставки на дату отчетности переносятся на первую дату, следующую за датой 
                     отчетности. Это 1-ое число месяца, следующего за отчетным периодом.
                  */            
                                 
                      --КИС
                            Flow_Underpay as
                                            (
                                            SELECT  fc.L_key,
                                                    fc.branch_key,                                        
                                                    sum(case when cs.PAY_AMT_CuR_supply > 0 and tp='Supply_fact' 
                                                                then fc.PAY_AMT_CuR*-1
                                                              when cs.PAY_AMT_CuR_supply > 0 and tp='Supply_plan'    
                                                                then fc.PAY_AMT_CuR
                                                        else 0 end) PAY_AMT_CuR,
                                                    cs.PAY_AMT_CuR_supply
                                            from 
                                                    dm_xirr_flow_orig fc
                                            join (select l_key, 
                                                      sum (case when tp='Supply_fact' then 
                                                                  PAY_AMT_cur 
                                                                when tp='Supply_plan' then 
                                                                  PAY_AMT_cur*-1 
                                                          end) PAY_AMT_CuR_supply 
                                                  from dm_xirr_flow_orig
                                                  WHERE TP in ('Supply_fact','Supply_plan')
                                                  and snapshot_cd = 'Основной КИС'
                                                  and snapshot_dt = p_REPORT_DT
                                                  and l_key = p_contract_key
                                                  -- and pay_dt <= p_REPORT_DT -- 10/08/2015 MVV
                                                  group by l_key) cs
                                            on cs.l_key = fc.l_key
                                            WHERE fc.TP in ('Supply_fact','Supply_plan')
                                             -- and fc.pay_dt <= p_REPORT_DT -- 10/08/2015 MVV
                                             and snapshot_cd = 'Основной КИС'
                                             and snapshot_dt = p_REPORT_DT
                                             and fc.l_key = p_contract_key
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
                                                from dm_xirr_flow_orig
                                                WHERE TP in ('Supply_fact','Supply_plan')
                                                    and snapshot_cd = 'Основной КИС'
                                                    and snapshot_dt = p_REPORT_DT
                                                    and L_KEY = p_contract_key
                                                    -- and pay_dt <= p_REPORT_DT -- 10/08/2015 MVV
                                                  group by L_KEY
                                               ) SUM_FL                                       
                                        ),                                        
                      
                             /* Объединение потока и недоплаты. Неоплаченные плановые поставки на дату отчетности переносятся на первую дату, следующую за датой 
                     отчетности. Это 1-ое число месяца, следующего за отчетным периодом.
                    */         
                             Flow_prev_1 as
                                            (
                     /*                        SELECT
                                                    L_KEY,
                                                    branch_key,
                                                    p_REPORT_DT + 1 pay_dt ,
                                                    nvl(PAY_AMT_CuR, 0) summ,
                                                    PAY_AMT_CuR PAY_AMT
                                             FROM Flow_Underpay
                                             where PAY_AMT_CuR < 0
                       */
                                            SELECT
                                                    FU.L_KEY,
                                                    FU.branch_key,
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
                                                    PAY_DT, 
                                                    SUM(nvl(PAY_AMT_CUR, 0)) summ, 
                                                    SUM(PAY_AMT) PAY_AMT
                                             FROM dm_xirr_flow_orig
                                             WHERE snapshot_cd = 'Основной КИС'
                                             and snapshot_dt = p_REPORT_DT
                                             and l_key = p_contract_key
                                             and (TP <> 'Supply_plan') -- or  -- 10/08/2015 MVV
                                              -- (TP = 'Supply_plan' and PAY_DT > p_REPORT_DT)) -- 10/08/2015 MVV
                                              and TP <> 'LEASING_FACT'
                                             group by L_KEY, branch_key,  PAY_DT
                                             ),
                              
                              FLOW_prev_v as
                                            (select L_KEY, 
                                                     branch_key, 
                                                     PAY_DT, 
                                                     sum (summ) summ, 
                                                     sum (PAY_AMT) pay_amt 
                                              from  Flow_prev_1
                                              where pay_dt = p_REPORT_DT + 1
                                              group by L_KEY, branch_key, PAY_DT
                                              
                                              union all
                                              
                                              select L_KEY, 
                                                     branch_key, 
                                                     PAY_DT, 
                                                     summ, 
                                                     PAY_AMT 
                                              from  Flow_prev_1
                                              where pay_dt != p_REPORT_DT + 1
                                            ),
            
                    /* Для расчета остатка требуется введение накопительной суммы (sum_prev), которая и будет сравниваться с текущим платежом для "размазывания"
                    */
            
                              FLOW_prev as
                                            (select L_KEY, 
                                                     branch_key, 
                                                     PAY_DT, 
                                                     summ, 
                                                     sum (summ) over (partition by L_KEY order by pay_dt rows between unbounded preceding and current row) sum_prev,
                                                     PAY_AMT 
                                              from  FLOW_prev_v
                                            ),
                              
                              balance as (                                                              -- накопительная сумма
                                       
                                        select L_key,
                                        branch_key,
                                               PAY_DT,
                                               sum(summ) over (partition by l_key order by pay_dt) bal1,
                                               sum(pay_amt) over (partition by l_key order by pay_dt) bal2
                                        from FLOW_prev_v
                                       ),
              
                             min_dt as                                                                -- дата, когда отрицательный платеж по модулю превзошел положительный баланс
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
            
                              FLOW as
                                             (select                                        -- Выбор отрицательных платежей до min_dt 
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
                                            
                                              select                                        -- "Размазывание" положительного платежа по отрицательным, а именно добавление равных платежей,                                
                                                      f.L_KEY,                              -- равных по модулю отрицательным, с обратным знаком до min_dt.
                                                      branch_key, 
                                                      PAY_DT, 
                                                      (case when 
                                                         sum_prev >= 0                      -- Когда нашелся первый отрицательный платеж, превосходящий по модулю остаток (sum_prev), ему сопоставляется положительный остаток.
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
                                            
                                              select                                        -- выбор остальных платежей от min_dt
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
                                            
                                              select                                        -- выбор остальных платежей, у которых нет min_dt
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
                                        (
                                         select 
                                                l_key,
                                                sum (case when summ < 0 then summ else 0 end) as flag,
                                                abs(sum(case when summ >= 0 then summ else 0 end)) / decode (abs(sum(case when summ < 0 then summ else 0 end)), 0, -1, abs(sum(case when summ < 0 then summ else 0 end))) as div 
                                         from flow
                                         group by l_key
                                        ),
                              supply_fact_sum as
                                        (
                                        select 
                                              l_key
                                              from dm.dm_xirr_flow_orig
                                              where TP in ('Supply_fact')
                                                    and snapshot_cd = 'Основной КИС'
                                                    and snapshot_dt = p_REPORT_DT
                                                    and pay_dt <= p_REPORT_DT
                                                    and l_key = p_contract_key
                                              group by l_key having sum(pay_amt_cur) = 0)
            
                              select 
                                    f.l_key,
                                    branch_key,
                                    PAY_DT,
                                    summ,
                                    sum_prev,
                                    case
                                      when
                                          d.div > 1 and s.l_key is null
                                              then 1
                                          else 0
                                      end,
                                    p_report_dt as report_dt,
                                    case 
                                      when
                                        flag = 0
                                          then -99
                                        else 0
                                      end as flag
                              from 
                                   flow f
                              inner join
                                   excptn_zero_div d
                                on f.l_key = d.l_key
                              left join supply_fact_sum s
                                on f.l_key = s.l_key
                              where 
                               (nvl(summ, 0) != 0 or nvl(sum_prev, 0) != 0)                  -- на случай, если ни плановых ни фактических платежей нет, эти договоры мы не выключаем в поток.
                            --  and d.div > 1
               )b where b.pay_dt >= p_PAY_DT );

commit;
   
-- расчет xIRR

delete from dm_xirr where contract_id = p_contract_key and odttm = p_REPORT_DT;
commit;
insert into dm_xirr
select p_contract_key, nvl(f_xirr_calc(p_contract_key, p_REPORT_DT), -1) as xirr, p_REPORT_DT as odttm, branch_key, 'Основной КИС' as snapshot_cd, flag as err_flag 
from dm.dm_xirr_flow where l_key = p_contract_key and report_dt = p_REPORT_DT and pay_dt = p_REPORT_DT;
commit;

-- далее необходимо вызвать процедуру по расчету NIL'а для конкретного контракта
begin 
  p_DM_NIL_CALC_KIS_SINGLE_mv_c (p_contract_key, p_REPORT_DT, p_PAY_DT);
  -- далее необходимо вызвать процедуру по расчет КГП для конкретного контракта
  p_dm_cgp_single (p_contract_key, p_REPORT_DT, 'Основной КИС');
end;

commit;

end;
/

