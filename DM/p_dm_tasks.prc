CREATE OR REPLACE PROCEDURE DM."P_DM_TASKS"
is

BEGIN 

execute immediate ('truncate table DM.DM_TASKS');

insert into  DM_TASKS (
          TASK_KEY ,
          INQUIRY_KEY ,
          START_DT ,
          START_MONTH ,
          CLOSE_DT ,
          CLOSE_MONTH ,
          CLOSE_FLG ,
          LEASING_DEAL_KEY ,
          CROSYS_DIVISION_NAM ,
          FULL_AMT ,
          CONTROL_AMT ,
          NORM_AMT ,
          TASK_TYPE_NAM ,
          CRM_STATUS ,
          CROSYS_STATUS ,
          REPEAT_FLG ,
          SOURCE_CD ,
          REHIRING_FLG ,
          RISK_RESOLUTION,
          APPROVAL_RESOLUTION,
          APPROVAL_ROUTE_SUBJ,
          OWNER_USER_NAM,
          INSERT_DT,
          DUPLICATE_FLG,
          APPROVAL_RESULT_NAM
)
  with all_inquiries as 
            (select 
                    q.inquiry_cd as inquiry_cd, 
                    q.inquiry_key as inquiry_key, 
                    q.leasing_deal_key as leasing_deal_key, 
                    q.start_dt as start_dt, 
                    q.security_status_key, 
                    q.risk_status_key,
                    q.appraise_status_key, 
                    r.risk_task_key,
                    r.risk_repeat_flg,
                    r.risk_dt,
                    r.risk_agreement_key,
                    r.appraise_task_key,
                    r.appraise_repeat_flg,
                    r.appraise_dt,
                    r.security_task_key,
                    r.security_repeat_flg,
                    r.security_dt, 
                    c.full_risk_amt,
                    c.risk_amt,
                    c.control_risk_amt,
                    c.full_appraise_amt,
                    c.appraise_amt,
                    c.control_appraise_amt 
              from 
                   ( --все запросы со статусами Crosys 
                    select 
                           inquiry_cd, 
                           inquiry_key,
                           leasing_deal_key, 
                           security_status_key, 
                           risk_status_key,
                           appraise_status_key, 
                           start_dt, 
                           risk_amt, 
                           appraise_amt 
                   from dwh.fact_inquiries 
                   where valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY') 
                   ) q 
         
             --резолюции 
              left join
                    (
                     select 
                            inquiry_key,
                            risk_task_key,
                            risk_repeat_flg,
                            risk_dt,
                            risk_agreement_key,
                            appraise_task_key,
                            appraise_repeat_flg,
                            appraise_dt,
                            security_task_key,
                            security_repeat_flg,
                            security_dt 
                     from dwh.fact_resolutions 
                     where valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')
                     ) r 
                  on q.inquiry_key=r.inquiry_key 
           
              --закрытые задачи 
              left join 
                     (
                      select 
                            inquiry_key,
                            full_risk_amt,
                            risk_amt,
                            control_risk_amt,
                            full_appraise_amt,
                            appraise_amt,
                            control_appraise_amt 
                      from dwh.fact_inquiry_times 
                      where valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')
                      ) c 
                  on r.inquiry_key=c.inquiry_key ) 
          

--задачи CRM и Crosys. Выбираются все данные по задачам Crosys, и задачи CRM, не переданные в crosys 
select 
      case when cros.source_cd='Crosys' then cros.task_key else crm.task_key end as task_key, 
      inquiry_key , 
      case when cros.source_cd='Crosys' then cros.start_dt else crm.start_dt end as start_dt, 
      add_months(trunc(case when cros.source_cd='Crosys' then cros.start_dt else crm.start_dt end, 'MM'),1)-1 as start_month, 
      case when cros.source_cd='Crosys' then cros.close_dt else crm.close_dt end as close_dt, 
      add_months(trunc(case when cros.source_cd='Crosys' then cros.close_dt else crm.close_dt end, 'MM'),1)-1 as close_month, 
      case when cros.source_cd='Crosys' then cros.close_flg else crm.close_flg end as close_flg, 
      case when cros.source_cd='Crosys' then cros.leasing_deal_key else crm.leasing_deal_key end as leasing_deal_key, 
      cros.division_nam as crosys_division_nam, 
      case when cros.source_cd='Crosys' then cros.full_amt else crm.full_amt end as full_amt, 
      case when cros.source_cd='Crosys' then cros.control_amt else crm.control_amt end as control_amt, 
      case when cros.source_cd='Crosys' then cros.norm_amt else crm.norm_amt end as norm_amt, 
      case 
          when task_type_nam = 'Одобрение Андеррайтер' and task_subject like 'Андеррайтер.%'
              then 'Андеррайтер (Не Express)'
          when task_type_nam = 'Одобрение Андеррайтер' and task_subject like 'Андеррайтер Express.%'
              then 'Андеррайтер Express'
          else task_type_nam    
      end as task_type_nam, 
      crm.task_status_nam as crm_status, 
      cros.task_status_nam as crosys_status,
      case when cros.source_cd='Crosys' then cros.repeat_flg else to_char(crm.repeat_flg) end as repeat_flg,
      case when cros.source_cd='Crosys' then cros.source_cd else crm.source_cd end as source_cd,
      case when reh.leasing_deal_key is not null then 1 else 0 end as rehiring_flg,
      case
           when task_type_nam in ('Экспертиза (Риск)', 'ПИ Повторная проверка УАКР (Анализ рисков)', 'ПИ Экспертная проверка УАКР (Анализ рисков)')
            and crm.agreement_nam is not null
            and crm.agreement_nam != 'Не требуется'
              then recommendat_desc
          else null
      end as risk_resolution,
      case
           when task_type_nam in ('Одобрение Андеррайтер', 'Одобрение КЛАС', 'Одобрение КУФР', 'Одобрение Уполномоченные лица', 'Оформление решения', 'Верификация')
            and approval_result_nam is not null
              then recommendat_desc
          else null
      end as approval_resolution,
      approval_route_subj,
      case
           when task_type_nam in ('Одобрение Андеррайтер', 'Верификация')
              then owner_user_nam
          else null
      end as owner_user_nam, --[apolyakov 24.02.2016]: фамилия не только  андеррайтера, а любого полозователя
      sysdate as insert_dt,
      case
          when  task_type_nam in ('Одобрение Андеррайтер', 'Одобрение КЛАС', 'Одобрение КУФР', 'Одобрение Уполномоченные лица', 'Оформление решения', 'Верификация')
                then row_number () over (partition by case when cros.source_cd='Crosys' then cros.leasing_deal_key else crm.leasing_deal_key end, approval_route_subj 
                          order by case when cros.source_cd='Crosys' then cros.close_dt else crm.close_dt end)
          else 1
      end duplicate_flg, -- [apolyakov 11.04.2016]: необходимо для удаления дублей
      nvl (approval_result_nam, '-')  -- [apolyakov 11.04.2016]: необходимо решение для фильтрации задач в BI
from (
--задачи Crosys

      select 
            a.inquiry_key as inquiry_key, 
            a.leasing_deal_key as leasing_deal_key, 
            a.task_key as task_key, 
            t.task_status_nam as task_status_nam, 
            a.division_nam as division_nam, 
            a.start_dt as start_dt , 
            a.close_dt,
            ag.agreement_nam,
            case when t.task_status_cd=6 then 1 else 0 end as close_flg,--признак закрытой задачи
            case when t.task_status_cd=6 then a.full_amt else b.full_amt end as full_amt, 
            case when t.task_status_cd=6 then a.division_amt else b.division_amt end as division_amt, 
            case when t.task_status_cd=6 then a.control_amt else b.control_amt end as control_amt, 
            a.norm_amt as norm_amt, 
            nvl(a.repeat_flg,b.repeat_flg) as repeat_flg, 
            'Crosys' as source_cd 
      from 

          ( --открытые задачи 
            select 
                  inquiry_key, 
                  task_key, 
                  start_dt, 
                  leasing_deal_key, 
                  division_key, 
                  full_amt, 
                  division_amt, 
                  control_amt, 
                  SCHEDULED_AMT, 
                  repeat_flg 
            from (
                  select 
                          a.*,
                          row_number() over (partition by inquiry_cd,division_key order by snapshot_dt desc ) rn 
                  from dwh.fact_open_inquiries a where valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY') 
                 ) 
                --выбираем последний срез по открытым задачам
            where  rn = 1
          ) b 

      full outer join
      --закрытые задачи
          (
            select * 
            from (
                  (select --задачи рисков 
                          all_inquiries.inquiry_key, 
                          all_inquiries.leasing_deal_key, 
                          (select division_nam from dwh.divisions where valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY') and division_cd='100000011') as division_nam, 
                          all_inquiries.risk_task_key as task_key, 
                          all_inquiries.risk_status_key as status_key, 
                          all_inquiries.risk_agreement_key agreement_key,
                          all_inquiries.full_risk_amt as full_amt, 
                          all_inquiries.risk_amt as division_amt, 
                          all_inquiries.control_risk_amt as control_amt, 
                          all_inquiries.risk_amt as norm_amt, 
                          all_inquiries.risk_repeat_flg as repeat_flg, 
                          all_inquiries.start_dt as start_dt, 
                          all_inquiries.risk_dt as close_dt ,
                          row_number() over (partition by leasing_deal_key,risk_task_key order by inquiry_cd desc ) rn
                   from all_inquiries
                   where all_inquiries.risk_task_key is not null 

                   union all --задачи оценки 
                   select 
                          all_inquiries.inquiry_key, 
                          all_inquiries.leasing_deal_key, 
                          (select division_nam from dwh.divisions where valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY') and division_cd='100000012') as division_nam, 
                          all_inquiries.appraise_task_key as task_key, 
                          all_inquiries.appraise_status_key as status_key,
                          null as agreement_key,
                          all_inquiries.full_appraise_amt as full_amt, 
                          all_inquiries.appraise_amt as division_amt, 
                          all_inquiries.control_appraise_amt as control_amt, 
                          all_inquiries.appraise_amt as norm_amt,
                          all_inquiries.appraise_repeat_flg as repeat_flg, 
                          all_inquiries.start_dt as start_dt, 
                          all_inquiries.appraise_dt as close_dt, 
                          row_number() over (partition by leasing_deal_key,appraise_task_key order by inquiry_cd desc ) rn
                   from all_inquiries 
                   where all_inquiries.appraise_task_key is not null

                   union all --задачи уоб 
                   select 
                          all_inquiries.inquiry_key, 
                          all_inquiries.leasing_deal_key, 
                          (select division_nam from dwh.divisions where valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY') and division_cd='100000015') as division_nam, 
                          all_inquiries.security_task_key as task_key, 
                          all_inquiries.security_status_key as status_key,
                          null as agreement_key,
                          0 as full_amt, 
                          0 as division_amt, 
                          0 as control_amt, 
                          0 as norm_amt, 
                          all_inquiries.security_repeat_flg as repeat_flg,
                          all_inquiries.start_dt as start_dt, 
                          all_inquiries.security_dt as close_dt,
                          row_number() over (partition by leasing_deal_key,security_task_key order by inquiry_cd desc ) rn
                   from dwh.all_inquiries 
                   where all_inquiries.security_task_key is not null
                  )
                )
--по каждой задаче task_key выбираем последнюю версию запроса (максимальный inquiry_cd)
            where rn=1 
        ) a 

     on a.inquiry_key=b.inquiry_key 
    and a.task_key=b.task_key 

  
    left join dwh.divisions d 
    on b.division_key=d.division_key 
    and d.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY') 
    
    left join dwh.agreements ag
    on a.agreement_key = ag.agreement_key
    and ag.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')
    
    left join dwh.task_status t 
    on a.status_key=t.task_status_key 
    and t.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY') 
    and t.source_cd='CROSYS' ) 
    cros 

--задачи CRM 

full outer join 
          (
            select 
                  fct.task_key, 
                  fct.creation_dt as start_dt, 
                  fct.close_dt as close_dt, 
                  case when s.task_status_nam='Закрыта' then 1 else 0 end as close_flg,--признак закрытой задачи 
                  fct.leasing_deal_key, 
                  fct.full_amt, 
                  fct.scheduled_amt as norm_amt, 
                  fct.control_amt, 
                  s.task_status_nam,
                  t.task_type_nam, 
                  st.task_subtype_nam,
                  fct.repeat_flg as repeat_flg,
                  ar.approval_result_nam,
                  cu.last_nam||' '||cu.first_nam||' '||cu.middle_nam as owner_user_nam,
                  'CRM' as source_cd,
                  fct.recommendat_desc, --[apolyakov 24.02.2016]: резолюция тянется из CRM, а не crosys
                  case
                      when t.task_type_nam = 'Одобрение Андеррайтер'
                          then 'Андеррайтер'
                      when t.task_type_nam like '%КУФР%'
                        or (t.task_type_nam like '%Оформление решения%'
                            and fct.task_subject like '%КУФР%')
                          then 'КУФР'
                      when t.task_type_nam like '%КЛАС%'
                        or (t.task_type_nam like '%Оформление решения%'
                            and fct.task_subject like '%КЛАС%')
                          then 'КЛАС'
                      when t.task_type_nam = 'Верификация'
                       and task_subject like '%Супер Express%'
                          then 'Верификатор'
                      when t.task_type_nam like '%Уполномоченные лица%'
                        or (t.task_type_nam like '%Оформление решения%'
                            and task_subject like '%УЛ%')
                          then 'Уполномоченный орган'
                   end as approval_route_subj, --[apolyakov 29.03.2016]: Уполномоченный орган тянется из поля "Тема" + супер экспресс
                   a.agreement_nam,  --[apolyakov 25.02.2016]: Нужен для определения резолюции риск-менеджера
                   fct.task_subject -- [apolyakov 29.03.2016]: Нужен для определения УО и типа задачи андеррайтера
            from (  
                  select * 
                  from dwh.fact_tasks 
                  where valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY') 
                  and end_dt=to_date('31.12.3999','DD.MM.YYYY') 
                 ) fct 
  
left join dwh.task_status s 
on fct.task_status_key=s.task_status_key 
and s.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY') 

left join dwh.agreements a
on fct.agreement_key = a.agreement_key
and a.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')

left join dwh.crm_users cu
on fct.owner_user_key = cu.crm_user_key
and cu.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')
and cu.end_dt=to_date('31.12.3999','DD.MM.YYYY') 

left join dwh.approval_results ar
on fct.approval_result_key = ar.approval_result_key
and ar.result_source_cd = 'TASK'
and ar.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')

left join dwh.task_types t 
on fct.task_type_key=t.task_type_key 
and t.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY') 

left join dwh.task_subtypes st
on fct.task_subtype_key = st.task_subtype_key 
and st.valid_to_dttm=to_date('01.01.2400','DD.MM.YYYY')

join dwh.object_types ot 
on fct.object_type_key=ot.object_type_key 
and object_type_nam='Opportunity') crm 
on cros.task_key=crm.task_key
left join dwhro.v_uakr_leasing_deal_rehiring reh
    on nvl (crm.leasing_deal_key, cros.leasing_deal_key) = reh.leasing_deal_key;


COMMIT;

etl.P_DM_LOG('DM_TASKS');

END;
/

