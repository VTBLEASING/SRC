CREATE OR REPLACE PROCEDURE DM.P_DM_REG_KS (p_REPORT_DT in DATE, p_reg_group_key in number default 1)
IS

BEGIN
    dm.u_log(p_proc => 'DM.P_DM_REG_KS',
           p_step => 'INPUT PARAMS',
           p_info => 'p_REPORT_DT:'||p_REPORT_DT||' reg_group_key: '||p_reg_group_key);

DELETE FROM DM.DM_REG_KS WHERE snapshot_DT = p_REPORT_DT and branch_key in (select branch_key from dwh.reg_group where reg_group_key = p_reg_group_key);
   dm.u_log(p_proc => 'DM.P_DM_REG_KS',
           p_step => 'delete from dm.DM_REG',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');

insert into DM.DM_REG_KS(
                  SNAPSHOT_CD,
                  SNAPSHOT_DT,
                  SNAPSHOT_MONTH,
                  SNAPSHOT_YEAR,
                  BRANCH_KEY,
                  ACСOUNT_KEY,
                  CONTRACT_KEY,
                  CLIENT_KEY,
                  BANK_KEY,
                  MEMBER_KEY,
                  VTB_MEMBER_FLG,
                  INSTRUMENT_KEY,
                  INSTRUMENT_KIND_CD,
                  SRC_CURRENCY_KEY,
                  CIS_CURRENCY_KEY,
                  TERM_CNT,
                  PERIOD1_TYPE_KEY,
                  PERIOD2_TYPE_KEY,
                  PERIOD3_TYPE_KEY,
                  SRC_AMT,
                  RUR_AMT,
                  CIS_AMT,
                  RATE_W_AMT,
                  TERM_W_AMT,
                  SRC_LIQ_AMT,
                  CIS_LIQ_AMT,
                  SRC_MR_AMT,
                  RUR_MR_AMT,
                  RATE_W_MR_AMT,
                  PAY_DT,
                  EX_RATE,
                  FLOAT_RATE_FLG,
                  RATE_AMT,
                  PURPOSE_DESC,
                  ART_CD,
                  PROCESS_KEY,
                  INSERT_DT
                  )

with ks_flow as
(          select
                  contract_key,
                  currency_key,
                  pay_dt,
                  group_cd,
                  client_key,
                  row_number () over (partition by contract_key
                                order by pay_dt ) as rn,
                  case when rate > 1 then rate/100 else rate end as rate,
                  sum(pay_term_amt) as pay_term_amt,
                  sum(pay_int_amt) as pay_int_amt,
                  sum(comission_amt) as comission_amt
            from
                  (
                    select
                          contract_key,
                          currency_key,
                          pay_dt,
                          group_cd,
                          client_key,
                          rate,
                          pay_term_amt,
                          pay_int_amt,
                          comission_amt

                    from
                          dwh.fact_ks_flow
                    where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                      and pay_dt>p_REPORT_DT
                      and report_dt=p_REPORT_DT
                      and (pay_term_amt is not null or pay_int_amt is not null --or comission_amt is not null
                      )
                      and upper(group_cd) not like '%ОБЛИГАЦ%'

                    union all

                    select
                          a.contract_key,
                          a.currency_key,
                          a.pay_dt,
                          'другие' as group_cd,
                          b.client_key,
                          nvl(a.rate, b.contract_rate) rate,
                          case
                              when cbc_desc = 'ФД.22.1'
                                  then pay_amt
                              else 0
                          end as pay_term_amt,
                          case
                              when cbc_desc = 'ФД.22.2'
                                  then pay_amt
                              else 0
                          end as pay_int_amt,
                          case
                              when cbc_desc in ('ФД.22.31', 'ФД.22.33', 'ФД.22.34', 'ФД.22.35', 'ФД.22.36')
                                  then pay_amt
                              else 0
                          end as comission_amt


                    from
                          dwh.fact_plan_payments a,
                          dwh.contracts b,
                          dwh.contract_kinds c
                    where a.contract_key = b.contract_key
                      and a.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                      and b.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                      --and c.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                      and b.contract_kind_key = c.contract_kind_key
                      and b.open_dt <= p_REPORT_DT
                      --and b.close_dt >= p_REPORT_DT
                      and a.begin_dt <= p_REPORT_DT
                      and a.end_dt > p_REPORT_DT
                      and a.pay_dt > p_REPORT_DT
                      and c.contract_kind_ru_nam = 'Кредиты'
                      and a.CBC_DESC in ('ФД.22.1', 'ФД.22.2', 'ФД.22.31', 'ФД.22.33', 'ФД.22.34', 'ФД.22.35', 'ФД.22.36')
                 ) where pay_term_amt<>0 or   pay_int_amt<>0
                    group by contract_key, currency_key, pay_dt, group_cd, client_key, rate),

--потоки для расчета НКД. Рассчитывается дата последнего погашения процентов
ks_flow_prev as
(          select
                  contract_key,
                  max(pay_dt) keep(dense_rank last order by pay_dt) prev_pay_dt

           from
                 dwh.fact_ks_flow
           where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and upper(group_cd) not like '%ОБЛИГАЦ%'
             and pay_dt<=p_REPORT_DT
             and report_dt=p_REPORT_DT
             and pay_int_amt is not null
           group by contract_key

           union all

           select
                  contract_key,
                  max(pay_dt) keep(dense_rank last order by pay_dt) prev_pay_dt

           from
                 dwh.fact_plan_payments
           where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and pay_dt<=p_REPORT_DT
             and begin_dt <= p_REPORT_DT
             and end_dt > p_REPORT_DT
             and CBC_DESC in ('ФД.22.2')
           group by contract_key),

-- [aapolyakov 31.12.2015]: Добавление в алгоритм расчета НКД условия, что если даты погашения нет, то берем дату предоставления кредита по ресурсу "Предоставление"
ks_flow_prev_in as
(          select
                  contract_key,
                  max(pay_dt) keep(dense_rank last order by pay_dt) prev_pay_dt_in

           from
                 dwh.fact_ks_flow
           where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and upper(group_cd) not like '%ОБЛИГАЦ%'
             and pay_dt<=p_REPORT_DT
             and report_dt=p_REPORT_DT
             and pay_in_amt is not null
           group by contract_key),

--рассчитывается плановая сумма платежей и ставка
ks_flow_cur as
(          select
                  contract_key,
                  sum(nvl(pay_term_amt,0)) as sum_flow ,
                  max(rate) keep(dense_rank first order by pay_dt) as   rate
           from
                dwh.fact_ks_flow
           where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and upper(group_cd) not like '%ОБЛИГАЦ%'
             and pay_dt>p_REPORT_DT
             and report_dt=p_REPORT_DT

           group by contract_key),


--расчет НКД
ks_ncd as
(          select contract_key,
                  sum(calc_ncd_amt) as calc_ncd_amt
           from
                  (
                    select
                          ks_flow_cur.contract_key as contract_key,
                          ks_flow_cur.sum_flow* ( case when  ks_flow_cur.rate > 1 then  ks_flow_cur.rate/100 else  ks_flow_cur.rate end)*(p_REPORT_DT -
                    case
                              when prev_pay_dt is null
                                  then prev_pay_dt_in
                              else prev_pay_dt
                          end)/365 as calc_ncd_amt
                    from
                          ks_flow_cur,ks_flow_prev, ks_flow_prev_in
                    where ks_flow_cur.contract_key=ks_flow_prev.contract_key(+)
                    and ks_flow_cur.contract_key=ks_flow_prev_in.contract_key(+)

           union all

                    select
                        fct.contract_key,
                        nvl(fct.pay_amt,0) as calc_ncd_amt
                    from
                        dwh.fact_plan_payments fct ,ks_flow_prev
                    where fct.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                      and fct.pay_dt>nvl(prev_pay_dt, to_date('01.01.1900','dd.mm.yyyy') )
                      and fct.pay_dt<=p_REPORT_DT
                      and fct.contract_key=ks_flow_prev.contract_key(+)
                      and fct.begin_dt <= p_REPORT_DT
                      and fct.end_dt > p_REPORT_DT
                      and fct.CBC_DESC in ('ФД.22.4')

             )
             group by contract_key)
select
          'Основной КИС' as snapshot_cd,
          p_REPORT_DT as snapshot_dt,
          to_char(p_REPORT_DT, 'MM') as snapshot_month,
          to_char(p_REPORT_DT, 'YYYY') as snapshot_year,
          cs.branch_key as branch_key,
          null as acсount_key,
          ks.contract_key as contract_key,
          cl.client_key as client_key,
          null as bank_key,
          cl.member_key as member_key,
          case
                    when gr.member_cd <> 0
                      then 'Y'
                    else 'N'
                  end as VTB_MEMBER_FLG,
          case
              when ks.group_cd = 'заем'
              and ats.activity_type_ru_desc = 'Банк'
                  then (
                        select
                              INSTRUMENT_KEY
                        from dwh.INSTRUMENT_TYPES it
                        where INSTRUMENT_RU_NAM = 'МБК - актив'
                          and it.begin_dt <= p_REPORT_DT
                          and it.end_dt > p_REPORT_DT
                       )
              when ks.group_cd = 'заем'
              and (ats.activity_type_ru_desc != 'Банк'
               or ats.activity_type_ru_desc is null)
                  then (
                        select
                              instrument_key
                        from dwh.INSTRUMENT_TYPES
                        where INSTRUMENT_RU_NAM = 'Прочие процентные активы'
                          and begin_dt <= p_REPORT_DT
                          and end_dt > p_REPORT_DT
                       )
              when ks.group_cd = 'ВТБ'
                  then (
                        select
                              INSTRUMENT_KEY
                        from dwh.INSTRUMENT_TYPES it
                        where INSTRUMENT_RU_NAM = 'МБК - пассив'
                          and it.begin_dt <= p_REPORT_DT
                          and it.end_dt > p_REPORT_DT
                       )
              when ks.group_cd = 'другие'
              and ats.activity_type_ru_desc = 'Банк'
                  then (
                        select
                              INSTRUMENT_KEY
                        from dwh.INSTRUMENT_TYPES it
                        where INSTRUMENT_RU_NAM = 'МБК - пассив'
                          and it.begin_dt <= p_REPORT_DT
                          and it.end_dt > p_REPORT_DT
                       )
/*              when ks.group_cd = 'другие'
              and (ats.activity_type_ru_desc != 'Банк'
              or ats.activity_type_ru_desc is null)
                  then (
                        select INSTRUMENT_KEY
                        from dwh.INSTRUMENT_TYPES it
                        where INSTRUMENT_RU_NAM = 'Прочие процентные пассивы'
                        and it.begin_dt <= p_REPORT_DT
                        and it.end_dt > p_REPORT_DT
                       ) */
              when ks.group_cd = 'другие'
              and (ats.activity_type_ru_desc != 'Банк'
              or ats.activity_type_ru_desc is null)
              and bc.business_cat_ru_nam='малый'
                  then (
                        select INSTRUMENT_KEY
                        from dwh.INSTRUMENT_TYPES it
                        where INSTRUMENT_RU_NAM = 'Депозиты малого бизнеса'
                        and it.begin_dt <= p_REPORT_DT
                        and it.end_dt > p_REPORT_DT
                       )
              when ks.group_cd = 'другие'
              and (ats.activity_type_ru_desc != 'Банк'
              or ats.activity_type_ru_desc is null)
              and bc.business_cat_ru_nam='средний'
                  then (
                        select INSTRUMENT_KEY
                        from dwh.INSTRUMENT_TYPES it
                        where INSTRUMENT_RU_NAM = 'Депозиты среднего бизнеса'
                        and it.begin_dt <= p_REPORT_DT
                        and it.end_dt > p_REPORT_DT
                       )
              when ks.group_cd = 'другие'
              and (ats.activity_type_ru_desc != 'Банк'
              or ats.activity_type_ru_desc is null)
              and bc.business_cat_ru_nam='крупный'
                  then (
                        select INSTRUMENT_KEY
                        from dwh.INSTRUMENT_TYPES it
                        where INSTRUMENT_RU_NAM = 'Депозиты крупного бизнеса'
                        and it.begin_dt <= p_REPORT_DT
                        and it.end_dt > p_REPORT_DT
                       )
          end as instrument_key,
          case
              when ks.group_cd = 'заем'
                  then 'Активы'
              else 'Пассивы'
          end as instrument_kind_cd,
          ks.currency_key as SRC_CURRENCY_KEY,
          case
              when cr.currency_letter_cd in ('USD', 'EUR', 'RUB')
                  then ks.currency_key
              else (
                    select
                          currency_key
                    from dwh.currencies
                    where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                      and currency_letter_cd = 'OTH'
          ) end as cis_currency_key,
--СРОК, срок должен быть больше 1. Если срок=1, то кладем на срок =2.
          (CASE WHEN cs.FLOAT_RATE_TYPE_KEY = 2 then decode(ks.PAY_DT - p_REPORT_DT, 1, 2, ks.PAY_DT - p_REPORT_DT)
                 WHEN cs.FLOAT_RATE_TYPE_KEY = 92 then 30
                      ELSE least(decode(ks.PAY_DT - p_REPORT_DT,1,2, ks.PAY_DT - p_REPORT_DT), irt.UNFIXED_TERM_CNT) end) AS TERM_CNT, -- changed by okrupko CHR-448 14/11/2018 prev:decode(ks.PAY_DT - p_REPORT_DT, 1, 2, ks.PAY_DT - p_REPORT_DT)
          p1.period_key as PERIOD1_TYPE_KEY,
          p2.period_key as PERIOD2_TYPE_KEY,
          p3.period_key as PERIOD3_TYPE_KEY,
          (case when ks.group_cd = 'заем' then 1 else -1 end) * ks.pay_term_amt as src_amt,
          (case when ks.group_cd = 'заем' then 1 else -1 end) * case
              when cr.currency_letter_cd = 'RUB'
                  then ks.pay_term_amt
              else ks.pay_term_amt * er.exchange_rate
          end as RUR_AMT,
          (case when ks.group_cd = 'заем' then 1 else -1 end) * case
              when cr.currency_letter_cd in ('USD', 'EUR', 'RUB')
                  then ks.pay_term_amt
              else ks.pay_term_amt * er.exchange_rate
          end as CIS_AMT,
          (case when ks.group_cd = 'заем' then 1 else -1 end) * ks.rate * (case
                        when cr.currency_letter_cd  in ('USD', 'EUR', 'RUB')
                            then ks.pay_term_amt
                        else ks.pay_term_amt* er.exchange_rate
                     end) as RATE_W_AMT,
              /*      vklavsut - переводим в CIS ,чтобы потом на отчете ОПР для расчета показателя - Средневзвешенный срок до пересмотра процентной ставки (дни)
           все типы инструментов разделить на sum(CIS_amt)*/
--   OLD: (case when ks.group_cd = 'заем' then 1 else -1 end) * ks.pay_term_amt * decode(ks.PAY_DT - p_REPORT_DT, 1, 2,ks.PAY_DT - p_REPORT_DT) as TERM_W_AMT,
          (case when ks.group_cd = 'заем' then 1 else -1 end) * (case
              when cr.currency_letter_cd in ('USD', 'EUR', 'RUB')
                  then ks.pay_term_amt
              else ks.pay_term_amt * er.exchange_rate end)*
           (CASE WHEN cs.FLOAT_RATE_TYPE_KEY = 2 then decode(ks.PAY_DT - p_REPORT_DT, 1, 2, ks.PAY_DT - p_REPORT_DT)
                 WHEN cs.FLOAT_RATE_TYPE_KEY = 92 then 30
                      ELSE least(decode(ks.PAY_DT - p_REPORT_DT, 1, 2, ks.PAY_DT - p_REPORT_DT), irt.UNFIXED_TERM_CNT) end) as TERM_W_AMT, -- changed by okrupko for CHR-448 prev: decode(ks.PAY_DT - p_REPORT_DT, 1, 2,ks.PAY_DT - p_REPORT_DT)

          (case when ks.group_cd = 'заем' then 1 else -1 end) * case
              when ks.group_cd = 'заем'
                  then nvl(ks.pay_term_amt, 0) + nvl(ks.pay_int_amt, 0)
              else nvl(ks.pay_term_amt, 0) + nvl(ks.pay_int_amt, 0) --+ nvl(ks.COMISSION_AMT, 0)
          end as SRC_LIQ_AMT,
          (case when ks.group_cd = 'заем' then 1 else -1 end) * (case
                when ks.group_cd = 'заем'
                    then nvl(ks.pay_term_amt, 0) + nvl(ks.pay_int_amt, 0)
                else nvl(ks.pay_term_amt, 0) + nvl(ks.pay_int_amt, 0) --+ nvl(ks.COMISSION_AMT, 0)
          end) *
          (case
                when cr.currency_letter_cd in ('USD', 'EUR', 'RUB')
                    then 1
                else er.exchange_rate end) as CIS_LIQ_AMT,

          (case when ks.group_cd = 'заем' then 1 else -1 end) *
            (case
             when ks.rn=1 then nvl(ks.pay_term_amt, 0)+nvl(ncd.calc_ncd_amt,0)
             else nvl(ks.pay_term_amt, 0) end )   as SRC_MR_AMT,

          (case when ks.group_cd = 'заем' then 1 else -1 end) * case
              when cr.currency_letter_cd = 'RUB'
                  then    (case
                           when ks.rn=1 then nvl(ks.pay_term_amt, 0)+nvl(ncd.calc_ncd_amt,0)
                           else ks.pay_term_amt end )
              else (case
                           when ks.rn=1 then nvl(ks.pay_term_amt, 0)+nvl(ncd.calc_ncd_amt,0)
                           else nvl(ks.pay_term_amt, 0) end )  * er.exchange_rate
          end as RUR_MR_AMT,
          (case when ks.group_cd = 'заем' then 1 else -1 end) * ks.rate * (case
                         when cr.currency_letter_cd = 'RUB'
                            then (case
                                  when ks.rn=1 then nvl(ks.pay_term_amt, 0)+nvl(ncd.calc_ncd_amt,0)
                                  else nvl(ks.pay_term_amt, 0) end )
                         else (case
                               when ks.rn=1 then nvl(ks.pay_term_amt, 0)+nvl(ncd.calc_ncd_amt,0)
                               else nvl(ks.pay_term_amt, 0) end ) * er.exchange_rate end) as RATE_W_MR_AMT,
          KS.PAY_DT as PAY_DT,
          case
              when cr.currency_letter_cd = 'RUB'
                  then 1
              else er.exchange_rate
          end as EX_RATE,
          '0' as FLOAT_RATE_FLG,
          ks.rate as RATE_AMT,
          case
              when ks.group_cd = 'заем'
          then
             (select PURPOSE_DESC
              from dwh.OPERATION_PURPOSES
              where INSTRUMENT_RU_NAM = 'МБК - актив'
              And Upper(INSTRUMENT_SOURCE_NAM)LIKE '%ЗАЕМ%'
              And BEGIN_DT<=p_REPORT_DT
              AND END_DT>p_REPORT_DT)
         else
             (select PURPOSE_DESC
              from dwh.OPERATION_PURPOSES
              where INSTRUMENT_RU_NAM = 'МБК - пассив'
              And Upper(INSTRUMENT_SOURCE_NAM)LIKE '%КРЕДИТЫ%ДО%'
              And BEGIN_DT<=p_REPORT_DT
              AND END_DT>p_REPORT_DT)
          END
           as PURPOSE_DESC,
          case
              when ks.group_cd = 'заем'
              and ats.activity_type_ru_desc = 'Банк'
                  then (
                        select
                              ART_CD
                        from dwh.INSTRUMENT_TYPES it
                        where INSTRUMENT_RU_NAM = 'МБК - актив'
                          and it.begin_dt <= p_REPORT_DT
                          and it.end_dt > p_REPORT_DT
                       )
              when ks.group_cd = 'заем'
              and (ats.activity_type_ru_desc != 'Банк'
               or ats.activity_type_ru_desc is null)
                  then (
                        select
                              ART_CD
                        from dwh.INSTRUMENT_TYPES
                        where INSTRUMENT_RU_NAM = 'Прочие процентные активы'
                          and begin_dt <= p_REPORT_DT
                          and end_dt > p_REPORT_DT
                       )
              when ks.group_cd = 'ВТБ'
                  then (
                        select
                              ART_CD
                        from dwh.INSTRUMENT_TYPES it
                        where INSTRUMENT_RU_NAM = 'МБК - пассив'
                          and it.begin_dt <= p_REPORT_DT
                          and it.end_dt > p_REPORT_DT
                       )
              when ks.group_cd = 'другие'
              and ats.activity_type_ru_desc = 'Банк'
                  then (
                        select
                              ART_CD
                        from dwh.INSTRUMENT_TYPES it
                        where INSTRUMENT_RU_NAM = 'МБК - пассив'
                          and it.begin_dt <= p_REPORT_DT
                          and it.end_dt > p_REPORT_DT
                       )
              when ks.group_cd = 'другие'
              and (ats.activity_type_ru_desc != 'Банк'
              or ats.activity_type_ru_desc is null)
              and bc.business_cat_ru_nam='малый'
                  then (
                        select ART_CD
                        from dwh.INSTRUMENT_TYPES it
                        where INSTRUMENT_RU_NAM = 'Депозиты малого бизнеса'
                        and it.begin_dt <= p_REPORT_DT
                        and it.end_dt > p_REPORT_DT
                       )
              when ks.group_cd = 'другие'
              and (ats.activity_type_ru_desc != 'Банк'
              or ats.activity_type_ru_desc is null)
              and bc.business_cat_ru_nam='средний'
                  then (
                        select ART_CD
                        from dwh.INSTRUMENT_TYPES it
                        where INSTRUMENT_RU_NAM = 'Депозиты среднего бизнеса'
                        and it.begin_dt <= p_REPORT_DT
                        and it.end_dt > p_REPORT_DT
                       )
              when ks.group_cd = 'другие'
              and (ats.activity_type_ru_desc != 'Банк'
              or ats.activity_type_ru_desc is null)
              and bc.business_cat_ru_nam='крупный'
                  then (
                        select ART_CD
                        from dwh.INSTRUMENT_TYPES it
                        where INSTRUMENT_RU_NAM = 'Депозиты крупного бизнеса'
                        and it.begin_dt <= p_REPORT_DT
                        and it.end_dt > p_REPORT_DT
                       )
          end as ART_CD,
          777 as PROCESS_KEY,
          SYSDATE AS INSERT_DT
    from
          ks_flow ks,
          ks_ncd  ncd,
          dwh.contracts cs,
          dwh.clients cl,
          dwh.currencies cr,
          dwh.exchange_rates er,
          dwh.currencies cr2,
          dwh.ACTIVITY_TYPES ats,
          DWH.IFRS_VTB_GROUP gr,
          dwh.periods p1,
          dwh.periods p2,
          dwh.periods p3,
          dwh.period_types pt1,
          dwh.period_types pt2,
          dwh.period_types pt3,
          dwh.reg_group bg,
          dwh.business_categories bc,
          dwh.interest_rate_types irt -- added by okrupko for task CHR-448 14/11/2018
    where cl.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and irt.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') -- added by okrupko for task CHR-448 14/11/2018
      and cs.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and cr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and cr2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and er.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and p1.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and p2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and p3.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and gr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and bg.begin_dt <= p_REPORT_DT
      and bg.end_dt > p_REPORT_DT
      and cs.branch_key = bg.branch_key
      and bg.reg_group_key = p_reg_group_key
      and pt1.begin_dt <= p_REPORT_DT
      and pt1.end_dt > p_REPORT_DT
      and pt2.begin_dt <= p_REPORT_DT
      and pt2.end_dt > p_REPORT_DT
      and pt3.begin_dt <= p_REPORT_DT
      and pt3.end_dt > p_REPORT_DT
      and cr.begin_dt <= p_REPORT_DT
      and cr.end_dt > p_REPORT_DT
      and cr2.begin_dt <= p_REPORT_DT
      and cr2.end_dt > p_REPORT_DT
      and gr.begin_dt <= p_REPORT_DT
      and gr.end_dt > p_REPORT_DT
      and ats.valid_to_dttm (+) = to_date('01.01.2400', 'dd.mm.yyyy')
      and cs.open_dt <= p_REPORT_DT
      --and nvl(cs.close_dt, p_REPORT_DT) >= p_REPORT_DT
      and p1.period_type_key = pt1.period_type_key
      and p2.period_type_key = pt2.period_type_key
      and p3.period_type_key = pt3.period_type_key
      and pt1.period_type_cd = 1
      and pt2.period_type_cd = 2
      and pt3.period_type_cd = 3
      and (CASE WHEN cs.FLOAT_RATE_TYPE_KEY = 2 then decode(ks.PAY_DT - p_REPORT_DT, 1, 2, ks.PAY_DT - p_REPORT_DT)
                 WHEN cs.FLOAT_RATE_TYPE_KEY = 92 then 30
                      ELSE least(decode(ks.PAY_DT - p_REPORT_DT,1,2, ks.PAY_DT - p_REPORT_DT), irt.UNFIXED_TERM_CNT) end) > p1.days_from_cnt -- changed by okrupko for CHR-448 prev: ks.PAY_DT - p_REPORT_DT
      and
          (CASE WHEN cs.FLOAT_RATE_TYPE_KEY = 2 then decode(ks.PAY_DT - p_REPORT_DT, 1, 2, ks.PAY_DT - p_REPORT_DT)
                 WHEN cs.FLOAT_RATE_TYPE_KEY = 92 then 30
                      ELSE least(decode(ks.PAY_DT - p_REPORT_DT,1,2, ks.PAY_DT - p_REPORT_DT), irt.UNFIXED_TERM_CNT) end) <= p1.days_to_cnt -- changed by okrupko for CHR-448 prev: ks.PAY_DT - p_REPORT_DT
      and ks.PAY_DT - p_REPORT_DT > p2.days_from_cnt and ks.PAY_DT - p_REPORT_DT <= p2.days_to_cnt
      and ks.PAY_DT - p_REPORT_DT > p3.days_from_cnt and ks.PAY_DT - p_REPORT_DT <= p3.days_to_cnt
      and ats.begin_dt (+) <= p_REPORT_DT and ats.end_dt (+) > p_REPORT_DT
      and ks.contract_key = cs.contract_key
      and ks.CURRENCY_KEY = cr.currency_key
      and cs.client_key = cl.client_key
      and cl.member_key = gr.member_key
      and ks.currency_key = er.currency_key
      and er.base_currency_key = cr2.currency_key
      and irt.rate_key = cs.float_rate_type_key -- added by okrupko for task CHR-448 14/11/2018
      and er.ex_rate_dt = p_REPORT_DT
      and cl.activity_type_key = ats.activity_type_key (+)
      and cr2.currency_letter_cd = 'RUB'
      and ks.contract_key=ncd.contract_key(+)
      and (gr.cons_cis_flg != 0 or gr.mrd_flg != 0 or gr.cons_cis_flg is null or gr.mrd_flg is null or gr.member_cd = 0) -- отсекаем данные, которые не должны учитываться в отчете

      and bc.valid_to_dttm(+)= to_date('01.01.2400', 'dd.mm.yyyy')
      and bc.begin_dt(+) <= to_date('30.04.2015','dd.mm.yyyy')
      and bc.end_dt(+) > to_date('30.04.2015','dd.mm.yyyy')
      and bc.business_category_key(+)=cl.business_category_key
      and cl.branch_key is null; --add vzanozin for ЗА 5266
   dm.u_log(p_proc => 'DM.P_DM_REG_KS',
           p_step => 'insert into DM.DM_REG_KS',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');
commit;

end;
/

