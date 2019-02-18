CREATE OR REPLACE PROCEDURE DM.p_DM_CGP (
    p_REPORT_DT date,
    p_group_key in number,
    p_snapshot_cd in varchar
)
is


BEGIN

  /* Процедура расчета витрины DM_CGP полностью.
     В качестве входного параметра подается дата составления отчета 
  */
    dm.u_log(p_proc => 'DM.p_DM_CGP',
           p_step => 'INPUT PARAMS',
           p_info => 'p_group_key:'||p_group_key||'p_REPORT_DT:'||p_REPORT_DT||'p_snapshot_cd:'||p_snapshot_cd); 
 delete from DM_cgp 
 where snapshot_dt = p_REPORT_DT
 and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
 and snapshot_cd = p_snapshot_cd;
  dm.u_log(p_proc => 'DM.p_DM_CGP',
           p_step => 'delete from DM_cgp',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');  
 -- [apolyakov 05.09.2016]: Доработка по обратному КГП
 delete from DM_CGP_HIST 
 where snapshot_dt = p_REPORT_DT
 and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
 and snapshot_cd = p_snapshot_cd
 and valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy');
  dm.u_log(p_proc => 'DM.p_DM_CGP',
           p_step => 'delete from DM_CGP_HIST',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted'); 
    insert ALL
    into DM_CGP
    (      snapshot_cd,
           snapshot_dt,
           snapshot_month,
           contract_key,
           branch_key,
           client_key,
           business_category_key,
           client_nam,
           credit_rating_key,
           rating_agency_key,
           activity_type_key,
           reg_country_key,
           risk_country_key,
           loan_type_key,
           lending_purpose_key,
           risk_trans_flg,
           contract_num,
           start_dt,
           end_dt,
           currency_key,
           assets_transfer_flg,
           xirr_rate,
           term_amt,
           avg_term_amt,
           overdue_amt,
           avg_overdue_amt,
           overdue_dt,
           float_base_flg,
           float_base_type_key,
           float_base_amt,
           add_amt,
           ias3_term_key,
           ias3_overdue_key,
           contract_status_key,
           process_key,
           insert_dt,
           fact_close_dt,
           status,
           -- [apolyakov 05.09.2016]: Доработка по обратному КГП
           CONTRACT_ID_CD,
           CLIENT_ID,
           CLIENT_1C_CD,
           CUSTOM_FLG
           , OVERDUE_VAT_FREE_AMT,
       AVG_OVERDUE_VAT_FREE_AMT,
       VAT_OVERDUE_AMT,
       VAT_TERM_AMT
    )
    
    values (snapshot_cd,
           snapshot_dt,
           snapshot_month,
           contract_key,
           branch_key,
           client_key,
           business_category_key,
           short_client_ru_nam, 
           credit_rating_key,
           agency_key,
           activity_type_key,
           reg_country_key,
           risk_country_key,           
           loan_type_key,          
           lending_purpose_key, 
           risk_trans_flag,
           contract_num,
           open_dt,
           close_dt,
           currency_key,
           assets_transfer_flg,
           xirr_rate,
           term_amt,
           avg_term_amt,  
           overdue_amt,           
           avg_overdue_amt,             
           overdue_dt,           
           float_base_flg,
           float_base_type_key,
           float_base_amt,
           add_amt,
           ias3_term_key,
           ias3_overdue_key,
           contract_status_key,
           process_key,
           insert_dt,
           fact_close_dt,
           status,
           -- [apolyakov 05.09.2016]: Доработка по обратному КГП
           CONTRACT_ID_CD,
           CLIENT_ID,
           CLIENT_1C_CD,
           CUSTOM_FLG      , OVERDUE_VAT_FREE_AMT,
       AVG_OVERDUE_VAT_FREE_AMT,
       VAT_OVERDUE_AMT,
       VAT_TERM_AMT)
     
     -- [apolyakov 05.09.2016]: Доработка по обратному КГП
     into DM_CGP_HIST
        (
            SNAPSHOT_CD,
            SNAPSHOT_DT,
            SNAPSHOT_MONTH,
            CONTRACT_KEY,
            BRANCH_KEY,
            CLIENT_KEY,
            BUSINESS_CATEGORY_KEY,
            CLIENT_NAM,
            CREDIT_RATING_KEY,
            RATING_AGENCY_KEY,
            ACTIVITY_TYPE_KEY,
            REG_COUNTRY_KEY,
            RISK_COUNTRY_KEY,
            LOAN_TYPE_KEY,
            LENDING_PURPOSE_KEY,
            RISK_TRANS_FLG,
            CONTRACT_NUM,
            START_DT,
            END_DT,
            CURRENCY_KEY,
            ASSETS_TRANSFER_FLG,
            XIRR_RATE,
            TERM_AMT,
            AVG_TERM_AMT,
            OVERDUE_AMT,
            AVG_OVERDUE_AMT,
            OVERDUE_DT,
            FLOAT_BASE_FLG,
            FLOAT_BASE_TYPE_KEY,
            FLOAT_BASE_AMT,
            ADD_AMT,
            IAS3_TERM_KEY,
            IAS3_OVERDUE_KEY,
            STATUS,
            FACT_CLOSE_DT,
            CONTRACT_STATUS_KEY,
            INSERT_DT,
            VALID_FROM_DTTM,
            VALID_TO_DTTM,
            PROCESS_KEY,
            FILE_ID,
            CONTRACT_ID_CD,
            CLIENT_ID,
            CLIENT_1C_CD,
            CUSTOM_FLG,
            CLOSED_ROW_FILE_ID      , OVERDUE_VAT_FREE_AMT,
       AVG_OVERDUE_VAT_FREE_AMT,
       VAT_OVERDUE_AMT,
       VAT_TERM_AMT
        )
        
    values (SNAPSHOT_CD,
            SNAPSHOT_DT,
            SNAPSHOT_MONTH,
            CONTRACT_KEY,
            BRANCH_KEY,
            CLIENT_KEY,
            BUSINESS_CATEGORY_KEY,
            SHORT_CLIENT_RU_NAM,
            CREDIT_RATING_KEY,
            AGENCY_KEY,
            ACTIVITY_TYPE_KEY,
            REG_COUNTRY_KEY,
            RISK_COUNTRY_KEY,
            LOAN_TYPE_KEY,
            LENDING_PURPOSE_KEY,
            RISK_TRANS_FLAG,
            CONTRACT_NUM,
            OPEN_DT,
            CLOSE_DT,
            CURRENCY_KEY,
            ASSETS_TRANSFER_FLG,
            XIRR_RATE,
            TERM_AMT,
            AVG_TERM_AMT,
            OVERDUE_AMT,
            AVG_OVERDUE_AMT,
            OVERDUE_DT,
            FLOAT_BASE_FLG,
            FLOAT_BASE_TYPE_KEY,
            FLOAT_BASE_AMT,
            ADD_AMT,
            IAS3_TERM_KEY,
            IAS3_OVERDUE_KEY,
            STATUS,
            FACT_CLOSE_DT,
            CONTRACT_STATUS_KEY,
            INSERT_DT,
            VALID_FROM_DTTM,
            VALID_TO_DTTM,
            PROCESS_KEY,
            FILE_ID,
            CONTRACT_ID_CD,
            CLIENT_ID,
            CLIENT_1C_CD,
            CUSTOM_FLG,
            CLOSED_ROW_FILE_ID      , OVERDUE_VAT_FREE_AMT,
       AVG_OVERDUE_VAT_FREE_AMT,
       VAT_OVERDUE_AMT,
       VAT_TERM_AMT)
    /* Расчет признака передачи основных средств. 
       Если сумма плановых платежей больше суммы фактических, то ставится признак 'V'.
    */
    WITH contr_cess AS
          (SELECT contract_id_cd,
            branch_key,
            contract_key,
            MAX(cgp_contract_key) over (partition BY contract_id_cd, branch_key) AS cgp_contract_key
          FROM
            (SELECT contract_id_cd,
              branch_key,
              CASE
                WHEN (NVL(rehiring_flg, '0') = '0')
                THEN contract_key
                ELSE NULL
              END AS cgp_contract_key,
              contract_key
            FROM dwh.contracts
            WHERE valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            AND branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
            )
          ),
    assets_transfer_flg as (
          SELECT c.cgp_contract_key AS CONTRACT_KEY, 'V' as asset_flg
                FROM dwh.leasing_contracts_appls a,
                  dwh.leasing_subject_transmit b,
                  contr_cess c
                WHERE c.contract_key       = a.contract_key
                AND a.contract_app_key     = b.contract_app_key (+)
                AND a.valid_to_dttm        = to_date('01.01.2400', 'dd.mm.yyyy')
                AND b.valid_to_dttm (+)    = to_date('01.01.2400', 'dd.mm.yyyy')
                AND b.act_dt        (+)    > to_date('01.01.1900', 'dd.mm.yyyy')
                AND b.act_dt        (+)    <= p_REPORT_DT
                AND c.cgp_contract_key IN
                  (SELECT d.contract_key
                  FROM DWH.LEASING_CONTRACTS d
                  WHERE d.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                  AND d.AUTO_FLG        = '1'
                  )
                GROUP BY c.cgp_contract_key having max(b.act_dt) is null),
    START_DT as
        (select L_KEY as CONTRACT_KEY, min(PAY_DT) as START_DT 
        from DM.DM_XIRR_FLOW_ORIG 
          where 
            ((TP = 'Supply_fact' and branch_key<>6) or (TP = 'Supply_plan' and branch_key=6)) 
            and snapshot_dt = p_REPORT_DT and SNAPSHOT_CD = p_snapshot_cd and PAY_DT<=p_REPORT_DT
          group by L_KEY),             
            /* При расчете даты закрытия договора необходимо учитывать цессию. Для этого выполняется связка "старых" и "новых контрактов"*/
    max_pay_dt as (select l_key_dop as l_key, max(pay_dt) as l_pay_dt from dm_xirr_flow_orig where tp = 'LEASING' and snapshot_dt = p_REPORT_DT and pay_amt != 0 group by l_key_dop),
    old_c as (select contract_key, contract_id_cd, branch_key, close_dt, b.l_pay_dt, client_key, float_flg, float_rate_type_key, float_base_amt, add_amt from dwh.contracts a, max_pay_dt b 
                where a.contract_key = b.l_key and nvl(rehiring_flg, 0) != 1 and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')),
    new_c as (select contract_key, contract_id_cd, branch_key, close_dt, b.l_pay_dt, client_key, float_flg, float_rate_type_key, float_base_amt, add_amt from dwh.contracts a, max_pay_dt b 
                where a.contract_key = b.l_key and rehiring_flg = 1 and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')),
    cess_c as (select a.contract_key as old_contract_key, max(greatest(a.close_dt, b.close_dt)) as last_close_dt from old_c a, new_c b where a.contract_id_cd = b.contract_id_cd 
               and a.branch_key = b.branch_key group by a.contract_key),
    cess_contracts as (select a.contract_key, a.client_key old_client_key, a.l_pay_dt old_close_dt, b.client_key new_client_key, b.l_pay_dt new_close_dt,
                       a.float_flg as old_float_flg, a.float_rate_type_key as old_float_rate_type_key, a.float_base_amt as old_float_base_amt, a.add_amt as old_add_amt, 
                       b.float_flg as new_float_flg, b.float_rate_type_key as new_float_rate_type_key, b.float_base_amt as new_float_base_amt, b.add_amt as new_add_amt from old_c a, new_c b 
                        where a.contract_id_cd = b.contract_id_cd),
    cess_clients as (select contract_key, max(cl_key) keep (dense_rank last order by cl_dt) as client_key 
                       from (select contract_key, old_client_key as cl_key, old_close_dt as cl_dt from cess_contracts
                       union all
                       select contract_key, new_client_key, new_close_dt from cess_contracts) group by contract_key),
    cess_rates as (select contract_key, 
                          max(float_flg) keep (dense_rank last order by cl_dt) as float_flg, 
                          max(float_rate_type_key) keep (dense_rank last order by cl_dt) as float_rate_type_key, 
                          max(float_base_amt) keep (dense_rank last order by cl_dt) as float_base_amt, 
                          max(add_amt) keep (dense_rank last order by cl_dt) as add_amt from 
                          (select contract_key, old_float_flg as float_flg, old_float_rate_type_key as float_rate_type_key, old_float_base_amt as float_base_amt, 
                                  old_add_amt as add_amt, old_close_dt as cl_dt from cess_contracts
                           union all
                           select contract_key, new_float_flg as float_flg, new_float_rate_type_key as float_rate_type_key, new_float_base_amt as float_base_amt, 
                                  new_add_amt as add_amt, new_close_dt from cess_contracts) group by contract_key),
    
     /* Расчет средневзвешенной срочной задолженности.
        1) Из промежуточной витрины DM_NIL берется срочная задолженность на предыдущий отчетный период (NIL_DIFF)
           при первом платеже для данного номера контракта. Затем берется следующее значение NIL_DIFF и т.д. по цепочке, 
           пока не дойдет до отчетной даты текущего периода.
        2) Считается количество дней действия этой задолженности до следующего платежа Д1
        3) Считается количество дней в отчетном месяце Д_СУММ
        4) Текущий платеж * Д1 / Д_СУММ
        5) средние суммируются в рамках одного договора, получается средняя срочная задолженность.
     */
     Term_amt as (
            select            
                  (case 
                    when xirr = -1
                      or nvl (term.term_amt, 0) <= 0
                      then 0
                    when xirr != -1
                      and max_dt.max_dt <= p_REPORT_DT
                    then round (nvl (term.term_amt, 0))
                     else round (nvl (term.term_amt, 0), 2)  
                  end
                 ) term_amt,
                round (nvl (term.term_amt, 0), 2) term_amt_sub,
                term.contract_key,
                max_dt.oddtm,
           case when term.contract_key in (Select contract_key
                                            from DWH.LEASING_CONTRACTS
                                            where VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
                                            and SUBSIDIZATION_FLG = 1) and xirr = -1
           then round (nvl (term.term_amt, 0), 2) else 
                             (case 
                    when xirr = -1
                      or nvl (term.term_amt, 0) <= 0
                      then 0
                    when xirr != -1
                      and max_dt.max_dt <= p_REPORT_DT
                    then round (nvl (term.term_amt, 0))
                     else round (nvl (term.term_amt, 0), 2)  
                  end
                 ) end term_amt_AVG
           from DM_XIRR xirr 
           left join 
                    (select contract_key,
                            sum (nil_amt) term_amt
                     from 
                            dm_repayment_schedule rs
                     where rs.snapshot_cd = p_snapshot_cd
                     and rs.nil_amt > 0
                     and rs.snapshot_dt = p_REPORT_DT
                     group by contract_key) term  
                on term.contract_key = xirr.contract_id
                and xirr.snapshot_cd = p_snapshot_cd                 
            left JOIN DM_MAX_DT max_dt
                on term.contract_key = max_dt.contract_id
                and max_dt.oddtm = xirr.odttm
            where xirr.odttm = p_REPORT_DT 
            ),
avg_term_amt as
     (   
      select contract_key as contract_id, sum(term_amt) as term_amt, lastday from 
        (select contract_key , term_amt , lastday, k_DAY
        from (
              select 
                  contract_key,
                  -- [apolyakov 05.12.2016]: добавление decode на случай, когда первый платеж = ОД.
                  decode ((nvl (lead(calc_pay_dt) over               -- nvl на случай, если следующего платежа нет, проставляется отчетная дата.
                              -- [apolyakov 27.06.2016]: добавление сортировки на ОД, чтоб не прыгали значения на пограничных первых числах месяца
                              (partition by contract_key order by calc_pay_dt asc, snapshot_dt desc), p_REPORT_DT) -
                              pay_dt
                              ), 0, 1, nvl (lead(calc_pay_dt) over               -- nvl на случай, если следующего платежа нет, проставляется отчетная дата.
                              -- [apolyakov 27.06.2016]: добавление сортировки на ОД, чтоб не прыгали значения на пограничных первых числах месяца
                              (partition by contract_key order by calc_pay_dt asc, snapshot_dt desc), p_REPORT_DT) -
                              pay_dt) K_DAY,
                  dnil_amt * (
                              -- [apolyakov 05.12.2016]: добавление decode на случай, когда первый платеж = ОД.
                              decode ((nvl (lead(calc_pay_dt) over               -- nvl на случай, если следующего платежа нет, проставляется отчетная дата.
                              -- [apolyakov 27.06.2016]: добавление сортировки на ОД, чтоб не прыгали значения на пограничных первых числах месяца
                              (partition by contract_key order by calc_pay_dt asc, snapshot_dt desc), p_REPORT_DT) -
                              pay_dt
                              ), 0, 1, nvl (lead(calc_pay_dt) over               -- nvl на случай, если следующего платежа нет, проставляется отчетная дата.
                              -- [apolyakov 27.06.2016]: добавление сортировки на ОД, чтоб не прыгали значения на пограничных первых числах месяца
                              (partition by contract_key order by calc_pay_dt asc, snapshot_dt desc), p_REPORT_DT) -
                              pay_dt)
                              )/
                              (
                              p_REPORT_DT - trunc (p_REPORT_DT, 'mm') + 1   -- число дней отчетного периода
                              ) as term_amt,
                  p_REPORT_DT+1 as lastday
                  
                  
               from
               -- [apolyakov 02.06.2016]: добавление доп агрегации, чтоб не скакали значения.
                    (select 
                            snapshot_dt,
                            snapshot_cd,
                            contract_key,
                            pay_dt,
                            pay_dt calc_pay_dt,
                            sum (dnil_amt)as dnil_amt
                      from
                              (select snapshot_dt,
                                     snapshot_cd,
                                     rs.contract_key,
                                     pay_dt,
                                     pay_dt calc_pay_dt,
                                     dnil_amt * (100/(100 + vat.contract_vat_rate*100)) dnil_amt
                              from dm_repayment_schedule rs
                              --inner join dwh.vat vat
                              inner join dwh.contracts vat on vat.contract_key=rs.contract_key
                               -- on rs.branch_key = vat.branch_key
                                --and vat.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                                --and vat.begin_dt <= p_REPORT_DT
                                --and vat.end_dt >= p_REPORT_DT
                                and vat.valid_from_dttm <= p_REPORT_DT
                                and vat.valid_to_dttm >= p_REPORT_DT
                              where snapshot_cd = P_SNAPSHOT_CD
                              and snapshot_dt = p_REPORT_DT
                              and pay_dt != trunc (p_REPORT_DT, 'mm') - 1
                              -- [apolyakov 27.06.2016]: добавление фильтра, чтоб не прыгали значения на пограничных первых числах месяца 
                              --and pay_dt != trunc (p_REPORT_DT, 'mm')
                              and pay_dt != p_REPORT_DT
                              
                              union all 
                              
                              select p_REPORT_DT snapshot_dt,
                                     P_SNAPSHOT_CD snapshot_cd,
                                     contract_key,
                                     p_REPORT_DT pay_dt,
                                     p_REPORT_DT calc_pay_dt,
                                     term_amt_AVG dnil_amt        ----02.12.2015
                              from Term_amt 
                              
                              union all 
                              
                             select p_REPORT_DT snapshot_dt,
                                     P_SNAPSHOT_CD snapshot_cd,
                                     contract_key,
                                     p_REPORT_DT+1 pay_dt,
                                     p_REPORT_DT+1 calc_pay_dt,
                                     0 dnil_amt
                              from Term_amt                     
                              
                   /*           select snapshot_dt,
                                     snapshot_cd,
                                     contract_key,
                                     P_SNAPSHOT_DT as pay_dt,
                                     term_amt
                              from dm_cgp 
                              where snapshot_cd = P_SNAPSHOT_CD
                              and snapshot_dt = P_SNAPSHOT_DT*/
          
                              
                              union all 
                              
                              select snapshot_dt,
                                     snapshot_cd,
                                     contract_key,
                                     trunc (p_REPORT_DT, 'mm')  pay_dt,
                                     trunc (p_REPORT_DT, 'mm')  CALC_pay_dt,
                                     term_amt
                              from dm_cgp
                              where snapshot_cd = P_SNAPSHOT_CD
                              and snapshot_dt = trunc (p_REPORT_DT, 'mm') - 1
                    )
                     group by 
                            snapshot_dt,
                            snapshot_cd,
                            contract_key,
                            pay_dt,
                            calc_pay_dt
                    
                    )
              where pay_dt >= trunc (p_REPORT_DT, 'mm') - 1
              and pay_dt <= p_REPORT_DT+1
              and dnil_amt >= 0              
              and snapshot_cd = P_SNAPSHOT_CD  
              ) where K_DAY>=0)
        group by contract_key, lastday),
 
    V_PAY as (
            select L_KEY contract_key from dm.dm_xirr_flow_orig 
            where snapshot_cd = P_SNAPSHOT_CD
            and snapshot_dt = p_REPORT_DT
            and tp in ('LEASING_FACT', 'LEASING')
            and CBC_DESC = 'ОД.1.4'
            group by L_KEY
            having count(distinct(tp)) > 1
            union
            select contract_key from dwh.contracts
            where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            and force_close_date >= trunc(p_REPORT_DT, 'MM')
            and trunc(force_close_date) <= p_REPORT_DT
             ),
    SUPPLY_PAY_AMT as (
            select 
                l_key
                from dm.dm_xirr_flow_orig
                where TP in ('Supply_fact')
                      and snapshot_cd = P_SNAPSHOT_CD
                      and snapshot_dt = p_REPORT_DT
                      and pay_dt <= p_REPORT_DT
                group by l_key having sum(pay_amt_cur) = 0
             ),
    
    DM_CGP_PREV as
    (  
    select /*+ cardinality(xirr, 150000) cardinality(contr, 150000) use_hash(contr, xirr) */
           p_snapshot_cd as snapshot_cd,
           p_REPORT_DT as snapshot_dt,
           extract (month from p_REPORT_DT) as snapshot_month,
           contr.contract_key,
           contr.branch_key,
           nvl(cess_clients.client_key, contr.client_key) as client_key,
           dm_cl.business_category_key,
     --      cl.short_client_ru_nam,
           dm_cl.short_client_ru_nam, 
           dm_cl.credit_rating_key,
           cred_rat.agency_key,
           dm_cl.activity_type_key,
           /*case
              when cl.reg_country_key is null
                  then (select min(country_key) from dwh.countries where country_cd = '643' and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy'))
              else cl.reg_country_key
            end */
           dm_cl.reg_country_key reg_country_key,
           case
              when cl.risk_country_key is null
                  then (select min(country_key) from dwh.countries where country_cd = '643' and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy'))
              else cl.risk_country_key
            end risk_country_key,           
           (select loan_type_key
            from dwh.loan_types 
            where loan_type_cd = '29' 
            and valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
            and p_REPORT_DT between begin_dt and end_dt) loan_type_key,          
           (select lending_purpose_key
            from dwh.lending_purposes 
            where lending_purpose_cd = '21' 
            and valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
            and p_REPORT_DT between begin_dt and end_dt) lending_purpose_key, 
           '0' as risk_trans_flag,
           contr.contract_num,
           contr.open_dt,
           nvl(cess_c.last_close_dt, contr.close_dt) as close_dt,
           contr.currency_key,
           assets_transfer_flg.asset_flg assets_transfer_flg,
           (case 
              when xirr = -1 
                 then 0
               else round(xirr.xirr/100, 14)
            end    
           ) xirr_rate,
      /*     (case 
              when xirr = -1
                or nvl (term.term_amt, 0) <= 0
                then 0
              when xirr != -1
                and max_dt.max_dt <= p_REPORT_DT
              then round (nvl (term.term_amt, 0))
               else round (nvl (term.term_amt, 0), 2)  
            end
           ) term_amt,*/ /*Учет НДС*/
           case when contr.contract_key in (Select contract_key
                                            from DWH.LEASING_CONTRACTS
                                            where VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
                                            and SUBSIDIZATION_FLG = 1) and xirr = -1
           then nvl(term.term_amt_sub,0) else (case when trunc(contr.force_close_date) <= p_REPORT_DT and contr.force_close_date >= trunc(p_REPORT_DT, 'MM') then 0 else nvl(term.term_amt,0) end) end term_amt,

           case when contr.contract_key in (Select contract_key
                                            from DWH.LEASING_CONTRACTS
                                            where VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
                                            and SUBSIDIZATION_FLG = 1) and xirr = -1
                then round (nvl (avg_term_amt.term_amt, 0), 2)
           else
           (case 
              when xirr = -1
                or nvl (term.term_amt, 0) <= 0
                then 0
              when xirr != -1
                and max_dt.max_dt <= p_REPORT_DT
              then round (nvl (avg_term_amt.term_amt, 0)) 
              else round (nvl (avg_term_amt.term_amt, 0), 2) 
            end
           ) end avg_term_amt,  
  /*         (case 
             when round(overdue.overdue_amt) > 0 and nvl(assets_transfer_flg.asset_flg,0)<>'V' 
                then round (overdue.overdue_amt, 2)
               else 0
            end
           ) overdue_amt,*/
           case when sup.l_key is null then 
           (nvl(case when trunc(contr.force_close_date) <= p_REPORT_DT and contr.force_close_date >= trunc(p_REPORT_DT, 'MM') then 0 else (case 
             when round(overdue.overdue_amt,2) <= 0 
                then 0
             when round(overdue.overdue_amt,2) > 0 and nvl(assets_transfer_flg.asset_flg,0) = 'V' and nvl(term.term_amt,0) = 0 
                then 0 
               else round (overdue.overdue_amt, 2)
            end
           ) end, 0)) else 0 end overdue_amt,           
  /*         (case
             when round (overdue.overdue_amt) > 0 and nvl(assets_transfer_flg.asset_flg,0)<>'V' 
                then round (avg_overdue.avg_overdue_amt, 2)
             when round (overdue.overdue_amt) <= 0
              then 0
            end
           )  avg_overdue_amt, */
           case when sup.l_key is null then 
           (nvl(case when trunc(contr.force_close_date) <= p_REPORT_DT and contr.force_close_date >= trunc(p_REPORT_DT, 'MM') then 0 else (case 
             when nvl(round(overdue.overdue_amt, 2), 0) <= 0 
                then 0
             when round(overdue.overdue_amt,2) > 0 and nvl(assets_transfer_flg.asset_flg,0) = 'V' and nvl(term.term_amt,0) = 0 
                then 0 
               else round (avg_overdue.avg_overdue_amt, 4)
            end
           ) end, 0)) else 0 end avg_overdue_amt,             
  /*         (case
              when round (overdue.overdue_amt) > 0 and nvl(assets_transfer_flg.asset_flg,0)<>'V' 
                 then overdue_dt.overdue_dt
              else null
            end) overdue_dt,*/
            case when sup.l_key is null then 
           (case when trunc(contr.force_close_date) <= p_REPORT_DT and contr.force_close_date >= trunc(p_REPORT_DT, 'MM') then null else (case 
             when nvl(round(overdue.overdue_amt, 2), 0) <= 0 
                then Null
             when round(overdue.overdue_amt,2) > 0 and nvl(assets_transfer_flg.asset_flg,0) = 'V' and nvl(term.term_amt,0) = 0 
                then Null 
               else overdue_dt.overdue_dt
            end) end) else null end overdue_dt,           
           nvl(cess_rates.float_flg, contr.float_flg) float_base_flg,
           nvl(cess_rates.float_rate_type_key, contr.float_rate_type_key) float_base_type_key,
           nvl(cess_rates.float_base_amt, contr.float_base_amt) float_base_amt,
           nvl(cess_rates.add_amt, contr.add_amt) add_amt,
           (select IAS3_KEY
            from dwh.IAS3 
            where IAS3_CD = '10610' 
            and valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
            and p_REPORT_DT between begin_dt and end_dt) as ias3_term_key,
           case when trunc(contr.force_close_date) <= p_REPORT_DT and contr.force_close_date >= trunc(p_REPORT_DT, 'MM') then null else (case 
             when nvl(round(overdue.overdue_amt, 2), 0) <= 0 -- изменено для загрузки в КИС
                then null
             when round(overdue.overdue_amt,2) > 0 and nvl(assets_transfer_flg.asset_flg,0) = 'V' and nvl(term.term_amt,0) = 0 
                then null 
               else (select IAS3_KEY
                      from dwh.IAS3 
                      where IAS3_CD = '10610' 
                      and valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                      and p_REPORT_DT between begin_dt and end_dt)
            end
           ) end ias3_overdue_key,
           '90' as contract_status_key,
           777 as process_key,
           sysdate insert_dt,
           nvl(case when trunc(contr.force_close_date) <= p_REPORT_DT and contr.force_close_date >= trunc(p_REPORT_DT, 'MM') then contr.force_close_date else null end, nvl(max_dt.max_dt, case when (nvl(term.term_amt,0) = 0 and (case 
             when nvl(round(overdue.overdue_amt), 0) <= 0 
                then 0
             when round(overdue.overdue_amt) > 0 and nvl(assets_transfer_flg.asset_flg,0) = 'V' and nvl(term.term_amt,0) = 0 
                then 0 
               else round (overdue.overdue_amt, 2)
            end
           ) = 0) then p_REPORT_DT end))  fact_close_dt,
           -- [apolyakov 05.09.2016]: доработка по обратному КГП
           sysdate valid_from_dttm,
           to_date ('01.01.2400', 'dd.mm.yyyy') as valid_to_dttm,
           0 file_id,
           contr.contract_id_cd,
           dm_cl.client_id as client_id,
           dm_cl.client_cd as CLIENT_1C_CD,
           0 as custom_flg,
           null as closed_row_file_id 
           ,case when sup.l_key is null then 
           (nvl(case when trunc(contr.force_close_date) <= p_REPORT_DT and contr.force_close_date >= trunc(p_REPORT_DT, 'MM') then 0 else (case 
             when round(overdue.overdue_vat_free_amt,2) <= 0 
                then 0
             when round(overdue.overdue_vat_free_amt,2) > 0 and nvl(assets_transfer_flg.asset_flg,0) = 'V' and nvl(term.term_amt,0) = 0 
                then 0 
               else round (overdue.OVERDUE_VAT_FREE_AMT, 2)
            end
           ) end, 0)) else 0 end OVERDUE_VAT_FREE_AMT,     
           
           case when sup.l_key is null then 
           (nvl(case when trunc(contr.force_close_date) <= p_REPORT_DT and contr.force_close_date >= trunc(p_REPORT_DT, 'MM') then 0 else (case 
             when nvl(round(overdue.overdue_vat_free_amt, 2), 0) <= 0 
                then 0
             when round(overdue.overdue_vat_free_amt,2) > 0 and nvl(assets_transfer_flg.asset_flg,0) = 'V' and nvl(term.term_amt,0) = 0 
                then 0 
               else round (avg_overdue.avg_overdue_vat_free_amt, 4)
            end
           ) end, 0)) else 0 end AVG_OVERDUE_VAT_FREE_AMT,   

           case when sup.l_key is null then 
           (nvl(case when trunc(contr.force_close_date) <= p_REPORT_DT and contr.force_close_date >= trunc(p_REPORT_DT, 'MM') then 0 else (case 
             when nvl(round(overdue.overdue_vat_free_amt, 2), 0) <= 0 
                then 0
             when round(overdue.overdue_vat_free_amt,2) > 0 and nvl(assets_transfer_flg.asset_flg,0) = 'V' and nvl(term.term_amt,0) = 0 
                then 0 
               else round (overdue.VAT_OVERDUE_AMT, 4)
            end
           ) end, 0)) else 0 end VAT_OVERDUE_AMT,   
                      
           -----    Add by Zanozin ------------------
           case when contr.contract_key in (Select contract_key
                                            from DWH.LEASING_CONTRACTS
                                            where VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
                                            and SUBSIDIZATION_FLG = 1) and xirr = -1
           then nvl(term.term_amt_sub,0) else (case when trunc(contr.force_close_date) <= p_REPORT_DT and contr.force_close_date >= trunc(p_REPORT_DT, 'MM') then 0 else nvl(term.term_amt,0)*contr.contract_vat_rate end) end vat_term_amt
            -------- End ADD        ---------------------
          -- 4 VAT_TERM_AMT
from
                dwh.contracts contr
         left JOIN dwh.clients cl
            on contr.client_key = cl.client_key
         left JOIN cess_clients
            on contr.contract_key = cess_clients.contract_key
         left JOIN cess_rates
            on contr.contract_key = cess_rates.contract_key
         left JOIN dm.DM_CLIENTS dm_cl
            on dm_cl.client_key = nvl(cess_clients.client_key, contr.client_key)
          and dm_cl.snapshot_dt = p_REPORT_DT
           and dm_cl.snapshot_cd = p_snapshot_cd
         left JOIN assets_transfer_flg assets_transfer_flg 
            on assets_transfer_flg.contract_key = contr.contract_key
         left JOIN dwh.credit_ratings cred_rat
            on dm_cl.credit_rating_key = cred_rat.credit_rating_key
            and p_REPORT_DT between cred_rat.BEGIN_DT and cred_rat.END_DT
         left JOIN dwh.business_categories bus_cat
            on dm_cl.business_category_key = bus_cat.business_category_key
            and p_REPORT_DT between bus_cat.BEGIN_DT and bus_cat.END_DT
         left JOIN DM_MAX_DT max_dt
            on contr.contract_key = max_dt.contract_id
            and max_dt.oddtm = p_REPORT_DT
         left join SUPPLY_PAY_AMT sup
            on contr.contract_key = sup.l_key
         inner JOIN DM_XIRR xirr
            on contr.contract_key = xirr.contract_id
            and xirr.snapshot_cd = p_snapshot_cd
            and xirr.odttm = p_REPORT_DT
         INNER JOIN START_DT SDT
            ON contr.contract_key = SDT.contract_key             
  /*       left join 
                (select contract_key,
                        sum (nil_amt) term_amt
                 from 
                        dm_repayment_schedule rs
                 where rs.snapshot_cd = p_snapshot_cd
                 and rs.nil_amt > 0
                 and rs.snapshot_dt = p_REPORT_DT
                 group by contract_key) term
             on contr.contract_key = term.contract_key*/
         left join Term_amt term
            on contr.contract_key = term.contract_key
         left JOIN avg_term_amt
            on contr.contract_key = avg_term_amt.contract_id
         left JOIN dm_avg_overdue_amt avg_overdue
            on contr.contract_key = avg_overdue.contract_id
            and avg_overdue.oddtm = p_REPORT_DT
            and avg_overdue.snapshot_cd = p_snapshot_cd
         left JOIN dm_overdue_amt overdue
            on contr.contract_key = overdue.contract_id
            and overdue.oddtm = p_REPORT_DT
            and overdue.snapshot_cd = p_snapshot_cd
         left JOIN dm_overdue_dt overdue_dt
            on contr.contract_key = overdue_dt.contract_id
            and overdue_dt.oddtm = p_REPORT_DT
            and overdue_dt.snapshot_cd = p_snapshot_cd
         left JOIN cess_c
            on contr.contract_key = cess_c.old_contract_key
       /*  inner join dwh.vat vat
            on contr.branch_key = vat.branch_key
            and vat.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
            and vat.begin_dt <= p_REPORT_DT
            and vat.end_dt >= p_REPORT_DT*/
   
      where 
      nvl (contr.exclude_cgp, 0) != 1 and
      nvl(contr.force_close_date, to_date('31.12.2999', 'dd.mm.yyyy')) >= trunc(p_REPORT_DT, 'MM') and -- исключение ранее закрытых (принудительно контрактов)
      contr.branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
      and contr.VALID_TO_DTTM = to_date ('01.01.2400', 'dd.mm.yyyy')
      and xirr.odttm = p_REPORT_DT
      and (xirr.err_flag != -99 or (xirr.err_flag = -99 and round(overdue.overdue_amt) > 0 and nvl(assets_transfer_flg.asset_flg,0)<>'V' and contr.branch_key = 6))
      and cl.VALID_TO_DTTM = to_date ('01.01.2400', 'dd.mm.yyyy')
      )
      select cgp.*,
      case 
         when fact_close_dt <= p_REPORT_DT
                and nvl(term_amt, 0) = 0
                and nvl(round (overdue_amt), 0) = 0
                and (VP.contract_key is not null or (br.branch_key not in (select branch_key 
                      from dwh.cgp_group cgp_group 
                      where cgp_group.cgp_group_key = 2
                      and cgp_group.begin_dt <= p_REPORT_DT
                      and cgp_group.end_dt > p_REPORT_DT)))
                and cgp.contract_key not in ( 
                                      select contract_key 
                                      from dm_cgp_contracts_include cci
                                      where cci.begin_dt <= p_REPORT_DT 
                                            and cci.end_dt > p_REPORT_DT
                                      )
                  then 'Closed'
               else 'Open'
           end status
      
      from dm_cgp_prev cgp
      left join ( select contract_key from DM.DM_CGP
                                where  SNAPSHOT_CD = 'Основной КИС' 
                                and SNAPSHOT_DT = trunc (p_REPORT_DT, 'mm') - 1
                                and STATUS = 'Open'                               
                                group by contract_key 
                                ) cgp_1
          on cgp.contract_key = cgp_1.contract_key 
      left join V_PAY VP
          on VP.CONTRACT_KEY = cgp.CONTRACT_KEY
      left join dwh.org_structure br
          on br.branch_key = cgp.branch_key
          and br.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      where
      (fact_close_dt >= trunc (p_REPORT_DT, 'mm') 
      or 
      (fact_close_dt < trunc (p_REPORT_DT, 'mm') and (nvl(TERM_AMT,0) <> 0 or nvl(round (OVERDUE_AMT),0)<>0))  
      )
      and 
      cgp.contract_key not in (  
                                select contract_key from DM.DM_REPAYMENT_SCHEDULE 
                                where  SNAPSHOT_CD = 'Основной КИС' 
                                and SNAPSHOT_DT = p_REPORT_DT
                                group by contract_key 
                                having min(pay_dt)>p_REPORT_DT
                                )
      and
      cgp.contract_key not in (  
                                select contract_key from DM.DM_CGP
                                where  SNAPSHOT_CD = 'Основной КИС' 
                                and SNAPSHOT_DT < p_REPORT_DT
                                and STATUS = 'Closed'
                                group by contract_key 
                                )
      
      and cgp_1.contract_key is null  
      
       UNION ALL
     
     select cgp.*,
      case 
         when fact_close_dt <= p_REPORT_DT
                and nvl(term_amt, 0) = 0
                and nvl(round (overdue_amt), 0) = 0
                and (VP.contract_key is not null or (br.branch_key not in (select branch_key 
                      from dwh.cgp_group cgp_group 
                      where cgp_group.cgp_group_key = 2
                      and cgp_group.begin_dt <= p_REPORT_DT
                      and cgp_group.end_dt > p_REPORT_DT)) or lp.exclude_contract_key is not null)
                and cgp.contract_key not in ( 
                                      select contract_key 
                                      from dm_cgp_contracts_include cci
                                      where cci.begin_dt <= p_REPORT_DT 
                                            and cci.end_dt > p_REPORT_DT
                                      )
                  then 'Closed'
               else 'Open'
           end status

      from dm_cgp_prev cgp
      left join ( select contract_key from DM.DM_CGP
                                where  SNAPSHOT_CD = 'Основной КИС' 
                                and SNAPSHOT_DT =trunc (p_REPORT_DT, 'mm') - 1
                                and STATUS = 'Open'                               
                                group by contract_key 
                                ) cgp_1
          on cgp.contract_key = cgp_1.contract_key
      left join (select l_key as exclude_contract_key from dm.dm_xirr_flow_orig where snapshot_dt = p_REPORT_DT and snapshot_cd = 'Основной КИС'
                                and upper(tp) in ('LEASING', 'LEASING_FACT') group by l_key having nvl(sum(case when tp = 'LEASING' then PAY_AMT else 0 end), 0) = 0 
                                and nvl(sum(case when tp = 'LEASING_FACT' then PAY_AMT else 0 end), 0) = 0) lp
          on cgp.contract_key = lp.exclude_contract_key
      left join V_PAY VP
          on VP.CONTRACT_KEY = cgp.CONTRACT_KEY
      left join dwh.org_structure br
          on br.branch_key = cgp.branch_key
          and br.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      where 
      cgp_1.contract_key is not null
    ;
   dm.u_log(p_proc => 'DM.p_DM_CGP',
           p_step => 'insert ALL  into DM_CGP, DM_CGP_HIST',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');       
      
      commit;
   analyze_table(p_table_name => 'DM_CGP',p_schema => 'DM'); 
   analyze_table(p_table_name => 'DM_CGP_HIST',p_schema => 'DM'); 
   dm.u_log(p_proc => 'DM.p_DM_CGP',
           p_step => 'analyze_table DM_CGP,DM_CGP_HIST',
           p_info => SQL%ROWCOUNT|| 'analyze_table done');     

END;
/

