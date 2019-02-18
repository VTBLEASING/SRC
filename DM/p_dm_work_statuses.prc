CREATE OR REPLACE PROCEDURE DM."P_DM_WORK_STATUSES" (P_REPORT_DT in date)
IS
BEGIN

/* Процедура расчета витрины "Рабочие  статусы договоров, предметов лизинга, состояний предеметов лизинга"
   
   В качестве входного параметра подается дата составления отчета
*/

delete from DM.DM_WORK_STATUSES where REPORT_DT = p_REPORT_DT;


insert into DM_WORK_STATUSES(REPORT_DT,CONTRACT_KEY,STATUS_1C_DESC,CONTRACT_STATUS_KEY,SUBJECT_STATUS_KEY,STATE_STATUS_KEY,INSERT_DT)
select 
        report_dt, 
        contract_key,
        status_1c_desc,
        contract_status.work_status_key contract_status,
        subject_status.work_status_key subject_status,
        state_status.work_status_key state_status,
        sysdate
from
    (
        --последнее событие по мошенничеству на отчетную дату
    with fraud_cur as
         ( 
          select 
                ffe.contract_key, 
                ffe.risk_kind_key,
                max(ffe.event_nam) keep (dense_rank last order by ffe.event_dt) event_nam
          from 
                dwh.fact_fraud_events ffe
          inner join dwh.risk_kinds rk
            on  ffe.risk_kind_key = rk.risk_kind_key
            and rk.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
            and rk.begin_dt <= p_REPORT_DT 
            and rk.end_dt > p_REPORT_DT
          where ffe.valid_to_dttm = to_date('01.01.2400','DD.MM.YYYY')
            and ffe.delete_flg = 0
            and event_dt <= p_REPORT_DT
            and lower (rk.risk_nam) like '%мошенничество%'
          group by 
                ffe.contract_key,
                ffe.risk_kind_key
        ),


        --последняя стадия по мошенничеству на отчетную дату
       fraud_stage_cur as 
       (
        select
              d.contract_key,
              d.event_nam,
              max(d.stage_key) keep (dense_rank last order by d.stage_dt, d.valid_from_dttm) as stage_key
        from 
            dwh.fact_fraud_stages d, 
            fraud_cur
        where d.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')
          and d.stage_dt <= p_REPORT_DT
          and d.delete_flg = 0
          and fraud_cur.contract_key=d.contract_key
          and fraud_cur.event_nam=d.event_nam
        group by 
              d.contract_key,
              d.event_nam
        ),


        --последнее событие по страховому случаю на отчетную дату
       insure_cur as
       (
        select
              contract_key, 
              max(event_nam) keep(dense_rank last order by event_dt) event_nam
        from 
              dwh.fact_insurance_events
        where valid_to_dttm = to_date('01.01.2400','DD.MM.YYYY')
          and event_dt <= p_REPORT_DT
          and delete_flg = 0
        group by 
              contract_key
        ),

        --последняя стадия по страховым случаям на отчетную дату
       insure_stage_cur as 
       (
        select
              d.contract_key,
              d.event_nam,
              max(d.stage_key) keep(dense_rank last order by d.stage_dt,d.valid_from_dttm) as stage_key,
              -- [apoloyakov 12.04.2016]: дублировалось для случая, когда на одно событие две одинаковые стадии.
              max (d.stage_dt) as stage_dt
        from 
              dwh.fact_insurance_stages d, 
              insure_cur 
        where d.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')
          and d.stage_dt<=p_REPORT_DT
          and d.delete_flg=0
          and insure_cur.contract_key=d.contract_key
          and insure_cur.event_nam=d.event_nam
        group by 
              d.contract_key,
              d.event_nam),

        --последний статус договора по редкому событию
       rare_cur as
       (
        select
              contract_key,
              max(work_status_key) keep(dense_rank last order by event_dt) work_status_key
        from  
              dwh.fact_rare_events
        where valid_to_dttm = to_date('01.01.2400','DD.MM.YYYY')
          and event_dt <= p_REPORT_DT
          and status_kind_nam = 'Договор'
          and delete_flg = 0
        group by 
              contract_key
        ),

        --последний статус имущества по редкому событию
       rare_cur_sub as
       (
        select 
              contract_key,
              status_kind_nam,
              max(work_status_key) keep(dense_rank last order by event_dt) work_status_key
        from 
              dwh.fact_rare_events
        where valid_to_dttm = to_date('01.01.2400','DD.MM.YYYY')
          and event_dt <= p_REPORT_DT
          and status_kind_nam = 'Имущество'
          and delete_flg = 0
        --and contract_key in (21928)
        group by 
              contract_key,
              status_kind_nam
        ),

        --договоры с перенаймом
       reh as 
       (
        select 
              distinct contract_key
        from
              (
                    select 
                          lc.auto_flg, 
                          contr.contract_key,
                          count (*) over(partition by contr.contract_id_cd,contr.contract_num) cnt_contr
                    from dwh.contracts contr
                    inner join dwh.leasing_contracts lc
                        on contr.contract_key = lc.contract_key
                        and lc.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                    where contr.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
              ) contr
        where auto_flg = 1        
          and cnt_contr > 1
        ),

--договоры с выкупом 
       sel as 
       (
        select 
              contract_key, 
              contract_app_key, 
              pay_dt, 
              pay_amt, 
              begin_dt, 
              end_dt, 
              row_number() over (partition by contract_key, contract_app_key order by begin_dt desc) as rn -- тут выбираем последний и предпоследний платежи
        from  (
                    select 
                          contract_key, 
                          contract_app_key, 
                          max(pay_dt) as pay_dt, 
                          pay_amt, 
                          begin_dt, 
                          end_dt -- тут выбираем максимальную дату платежа (если их несколько)
                    from  (
                                  select 
                                        contract_key, 
                                        contract_app_key, 
                                        pay_dt, 
                                        pay_amt, 
                                        min(begin_dt) as begin_dt, 
                                        max(end_dt) as end_dt  -- тут делаем «склейку» одинаковых платежей (т.е. склейку платежей если не менялся плановый платеж по выкупу)
                                  from 
                                        dwh.fact_plan_payments 
                                  where --contract_key = 115520 and
                                        PAYMENT_ITEM_KEY in (
                                                              select 
                                                                    payment_item_key 
                                                              from 
                                                                    DWH.payment_items 
                                                              where code1c_cd = '00239' 
                                                                and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                                                            )
                                    and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                                   group by 
                                        contract_key, 
                                        contract_app_key, 
                                        pay_dt, 
                                        pay_amt
                           )
                     group by 
                           contract_key, 
                           contract_app_key, 
                           pay_amt, 
                           begin_dt, 
                           end_dt
              )
        ),
      
       pl as
       (
        select 
              a.contract_key, 
              a.contract_app_key, 
              a.pay_dt, 
              a.pay_amt, 
              a.begin_dt 
        from 
              sel a, 
              sel b 
        where a.contract_key = b.contract_key 
          and a.contract_app_key = b.contract_app_key -- соединяем последний с предпоследним, чтобы проверить уменьшилась ли дата
          and a.rn = 1 
          and b.rn = 2 
          and a.pay_dt < b.pay_dt
       ),
       
      fct as 
      (
       select 
              contract_key, 
              contract_app_key, 
              max(pay_dt) as pay_dt, 
              sum(pay_amt) as pay_amt -- выбираем фактические платежи
       from 
              dwh.fact_real_payments 
       where --contract_key = 115520 and 
              payment_item_key in (
                                   select 
                                          payment_item_key 
                                   from DWH.payment_items 
                                   where code1c_cd = '00239' 
                                    and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                                  )
          and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
       group by 
              contract_key, 
              contract_app_key
      ),
      
    -- досрочный выкуп
       early_redemption as
       (
       select 
              a.contract_key, 
              a.contract_app_key 
       from 
              pl a, 
              fct b -- соединяем все в единое целое и проверяем условие №3, что «Дата последней оплаты выкупного платежа - Дата изменения последнего графика < 6месяцев»
       where a.contract_key = b.contract_key 
         and a.contract_app_key = b.contract_app_key 
         and a.pay_amt = b.pay_amt 
         and add_months(b.pay_dt, -6) < a.begin_dt
       ),

     --выкуп 
       redemption as
       (
        select 
              fct.contract_key 
        from 
              sel, 
              fct
        where sel.rn=1
          and sel.contract_key=fct.contract_key 
          and sel.contract_app_key = fct.contract_app_key 
          and sel.pay_amt = fct.pay_amt
       )

       select 
              p_REPORT_DT as report_dt,
              c.contract_key as contract_key,
              cs.status_desc as status_1c_desc,
              ws2.work_status_nam as contract_event_nam,
              --определение статуса договора
              case
                  when r.risk_nam='Мошенничество' and cs.status_desc='Расторгнут' then 'Fraud,termination' 
                  when r.risk_nam='Мошенничество' and cs.status_desc<>'Расторгнут' then 'Fraud,not termination' 
                  when i.contract_key is not null and ist.payment_nam='Отказ в выплате' and s.stage_nam<>'Нахождение ТС' and s.stage_nam<>'Аннулирование признания страхового события' then 'Insurance case,  refuse'
                  when i.contract_key is not null and ist.payment_nam='Частичная' and s.stage_nam<>'Нахождение ТС' and s.stage_nam<>'Аннулирование признания страхового события' then 'Insurance case, partial payment'
                  when i.contract_key is not null and ist.payment_nam='Полная' and s.stage_nam<>'Нахождение ТС' and s.stage_nam<>'Аннулирование признания страхового события' then 'Insurance case, consent'
                  when i.contract_key is not null and ist.payment_nam is null and (s.stage_nam<>'Нахождение ТС' or s.stage_nam is null or s.stage_nam<>'Аннулирование признания страхового события')  then 'Insurance event, no decision'
                  when ws2.work_status_nam='Расторжение по согласию сторон без выкупа' and cs.status_desc='Расторгнут'  then 'Termination, agreement'
                  when ws2.work_status_nam in ('Отказ в перенайме, возврат без выкупа','Отказ в перенайме, выкуп поручителем/третьим лицом','Отказ в перенайме,выкуп лизингополучателем' )  and cs.status_desc='Расторгнут'  then 'Termination, failure to rehire without fraud'
                  when ws2.work_status_nam in ('Расторжение прочее','Расторжение договора из-за неисправности ПЛ'  )  and cs.status_desc='Расторгнут'  then 'Termination,other '
                  when t.contract_key is null and cs.status_desc='Расторгнут'  then 'Termination, before leasing'
                  when cs.status_desc='Расторгнут'  then 'Termination, overdue'
                  --when c.contract_key in (select contract_key from early_redemption)  then  'Закрыт досрочно с выкупом ПЛ'
                  when /*c.contract_key in (select contract_key from early_redemption)*/ early_redemption.contract_key is not null  then  'Closed, early redemption'
                  when ws2.work_status_nam='Присвоен высокий потенциальный риск мошенничества'  then 'Fraud, potential risk'
                  when reh.contract_key is not null and nvl(contr.rehiring_flg, 0)=0 and cs.status_desc='Закрыт' then  'Closed, rehiring'
                  when cs.status_desc='Закрыт'  then 'Closed'
                  when ws2.work_status_nam='Возобновление договора лизинга после расторжения' then 'Resumed after termination'
                  when cs.status_desc in ('Подписан (вступил в силу)')  then 'Active'
                  when cs.status_desc in ('Проект (принятие к управленческому учету)','Подписан (НЕ вступил в силу)','Проект (НЕ подписан)')  then 'Not signed'
                  else 'Other, contract'
              end as contract_status_nam,

              --определение статуса ПЛ
              case
                  when fcs.sale_dt<=p_REPORT_DT then 'Sale'
                  when /*c.contract_key in (select contract_key from redemption)*/ redemption.contract_key is not null then 'Redeemed'
                  when (i.contract_key is not null and ist.payment_nam='Полная' and nvl(fc.confiscate_dt,to_date('01.01.2400','DD.MM.YYYY'))>p_REPORT_DT) or (ws1.work_status_nam='Передано страховой компании')  then 'Suggested insurance company'
                  when ws1.work_status_nam='Передача ПЛ в корпоративный блок ВТБЛ'  then 'Transmitted to the park VTBL'
                  when fc.confiscate_dt<=p_REPORT_DT and lower(store_flg)='да' and nvl(fc.store_dt,to_date('01.01.2400','DD.MM.YYYY'))>p_REPORT_DT  then 'Safekeeping VTBL'
                  when s2.stage_nam='ТС найден и находится в органах' then 'Law enforcement agencies'
                  when r2.risk_nam='Хищение' then 'The theft' 
                  when fc.confiscate_dt<=p_REPORT_DT and ws1.work_status_nam='ТС отправлено на СТО (ремонт)' then 'The repairs after leasing / preparation for sale'
                  when ws1.work_status_nam='ПЛ отправлено на замену из-за неисправности' then 'Replacement'
                  when fc.confiscate_dt<=p_REPORT_DT and lower(remarketing_flg)='да' --and nvl(fc.appraise_dt,to_date('01.01.2400','DD.MM.YYYY'))>p_REPORT_DT  
                       then 'Sale, not rated'
                  when fc.confiscate_dt<=p_REPORT_DT and lower(remarketing_flg)='да' --and fc.appraise_dt<=p_REPORT_DT  
                       then 'Sale, rated'
                  when fc.confiscate_dt<=p_REPORT_DT then 'VTBL, other'
                  when t.contract_key is not null then 'Leasing'
                  else 'Other, subject'
              end as subject_status_nam,

              --определение статуса состояния ПЛ
              case
                  when r2.risk_nam='Тотал' then 'Full loss' 
                  when ws2.work_status_nam='Расторжение договора из-за неисправности ПЛ' or ws1.work_status_nam='ПЛ отправлено на замену из-за неисправности'  then 'Faulty' 
                  else 'Other, state'
              end as state_status_nam

      from
 
             (
              select * 
              from dwh.leasing_contracts 
              where valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')
                and auto_flg=1
              --and contract_key=21928
              ) c
      inner join dwh.contracts contr
          on c.contract_key = contr.contract_key
         and contr.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')

      --статус 1С
      left join 
              (
              select
                    contract_key,
                    max(status_desc) keep(dense_rank last order by status_dt) status_desc
              from dwh.fact_leasing_contracts_status
              where valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')
                and status_dt<=p_REPORT_DT
              group by contract_key
              ) cs
        on c.contract_key = cs.contract_key

      --изъятия
      left join
            dwh.fact_confiscations fc
         on c.contract_key=fc.contract_key
        and fc.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')

      --реализация изъятий
      left join
            dwh.fact_confiscation_sales fcs
         on c.contract_key=fcs.contract_key
        and fcs.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')

      --мошенничества
      left join 
            fraud_cur
         on c.contract_key=fraud_cur.contract_key
      
      left join 
            dwh.risk_kinds r
         on fraud_cur.risk_kind_key=r.risk_kind_key
      
      --стадии мошенничества
      left join 
            (
             select s.* 
             from 
                    dwh.fact_fraud_stages s, 
                    fraud_stage_cur 
             where s.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')
               and s.stage_dt<=p_REPORT_DT
               and s.delete_flg=0
               and s.contract_key=fraud_stage_cur.contract_key 
               and s.event_nam=fraud_stage_cur.event_nam
               and s.stage_key=fraud_stage_cur.stage_key
            ) fst
          on c.contract_key=fst.contract_key
      
      left join 
            dwh.stages s2
          on fst.stage_key=s2.stage_key
      
      --страховые случаи
      left join 
            (
             select s.* 
             from 
                    dwh.fact_insurance_events s, 
                    insure_cur 
             where s.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')
               and s.event_dt<=p_REPORT_DT
               and s.delete_flg=0
               and s.contract_key=insure_cur.contract_key 
               and s.event_nam=insure_cur.event_nam
            ) i
          on  c.contract_key =i.contract_key
      
      left join 
            dwh.risk_kinds r2
          on i.risk_kind_key=r2.risk_kind_key
      
      --стадии страховых случаев
      left join 
            (
             select s.* 
             from 
                    dwh.fact_insurance_stages s, 
                    insure_stage_cur 
             where s.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')
               and s.stage_dt<=p_REPORT_DT
               and s.delete_flg=0
               and s.contract_key=insure_stage_cur.contract_key 
               and s.event_nam=insure_stage_cur.event_nam
               and s.stage_key=insure_stage_cur.stage_key
               --[apolyakov 27.04.2016]: по одному событию две одинаковые стадии, нужно брать последнюю
               and s.stage_dt = insure_stage_cur.stage_dt
             ) ist
          on c.contract_key=ist.contract_key
      
      left join 
            dwh.stages s
          on ist.stage_key=s.stage_key
      
      --редкие события
      left join 
            rare_cur_sub
          on c.contract_key=rare_cur_sub.contract_key
      
      left join 
            rare_cur
          on c.contract_key=rare_cur.contract_key
      
      left join 
            dwh.work_statuses ws1
          on rare_cur_sub.work_status_key=ws1.work_status_key
      
      left join 
            dwh.work_statuses ws2
          on rare_cur.work_status_key=ws2.work_status_key
      
      left join 
            reh
          on  c.contract_key=reh.contract_key
      
      left join 
            redemption
          on  c.contract_key=redemption.contract_key
          
      left join
          (
              select distinct  contract_key 
              from early_redemption
          ) early_redemption
          on  c.contract_key=early_redemption.contract_key
          
      --акт передачи в лизинг
      left join 
          (
           select 
                  distinct ap.contract_key 
           from 
                  dwh.leasing_subject_transmit t,  
                  dwh.leasing_contracts_appls ap
           where t.contract_app_key=ap.contract_app_key
             and ap.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')
             and t.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')
             and act_dt<>to_date('01.01.0001','DD.MM.YYYY')
             and act_num is not null 
             and t.contract_app_key is not null
          ) t
          on c.contract_key=t.contract_key
      ) a
left join dwh.work_statuses contract_status
    on trim (a.contract_status_nam) = trim (contract_status.work_status_cd)
   and contract_status.begin_dt <= p_REPORT_DT
   and contract_status.end_dt > p_REPORT_DT
left join dwh.work_statuses subject_status
    on trim (a.subject_status_nam) = trim (subject_status.work_status_cd)
   and subject_status.begin_dt <= p_REPORT_DT
   and subject_status.end_dt > p_REPORT_DT
left join dwh.work_statuses state_status
    on trim (a.state_status_nam) = trim (state_status.work_status_cd)
   and state_status.begin_dt <= p_REPORT_DT
   and state_status.end_dt > p_REPORT_DT
;

commit;

END P_DM_WORK_STATUSES;
/

