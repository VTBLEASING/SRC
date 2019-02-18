CREATE OR REPLACE PROCEDURE DM.P_DM_REG_REPAYMENT_SCHEDULE_N (p_REPORT_DT in date, p_group_key in number default 1) -- добавил Поляков для настройки матрицы
IS


BEGIN
  
    dm.u_log(p_proc => 'DM.P_DM_REG_REPAYMENT_SCHEDULE_N',
           p_step => 'INPUT PARAMS',
           p_info => 'p_group_key:'||p_group_key||'p_REPORT_DT:'||p_REPORT_DT); 
    delete from DM.DM_REG_REPAYMENT_SCHEDULE where snapshot_dt = p_REPORT_DT and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT);
    dm.u_log(p_proc => 'DM.P_DM_REG_REPAYMENT_SCHEDULE_N',
           p_step => 'delete from DM.DM_REG_REPAYMENT_SCHEDULE',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');        
    insert into DM.DM_REG_REPAYMENT_SCHEDULE (
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
                  SRC_AMT,RUR_AMT,
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
          select /*+ cardinality(p1, 50000) cardinality(p2, 50000) cardinality(p3, 50000) use_hash(p1, p2, p3) */
                  'Основной КИС' as snapshot_cd,
                  p_REPORT_DT as snapshot_dt,
                  to_char(p_REPORT_DT, 'MM') as snapshot_month,
                  to_char(p_REPORT_DT, 'YYYY') as snapshot_year,
                  cgp.branch_key as branch_key,
                  null as account_key,
                  cgp.contract_key as contract_key,
                  cgp.client_key as client_key,
                  null as bank_key,
                  cl.member_key as member_key,
                  case 
                    when gr.member_cd <> 0 or nvl(pt.parties_type_cd,0) <> 0
                      then 'Y' 
                    else 'N' 
                  end as VTB_MEMBER_FLG,
                  case 
                    when bc.business_category_cd = 1 
                      then (
                            select it.instrument_key 
                            from dwh.instrument_types it 
                            where it.instrument_ru_nam = 'Кредиты малому бизнесу' 
                             and it.begin_dt <= p_REPORT_DT 
                             and it.end_dt > p_REPORT_DT
                           )
                    when bc.business_category_cd = 2 
                      then (
                            select it.instrument_key 
                            from dwh.instrument_types it 
                            where it.instrument_ru_nam = 'Кредиты среднему бизнесу' 
                             and it.begin_dt <= p_REPORT_DT 
                            and it.end_dt > p_REPORT_DT
                           )
                    when bc.business_category_cd = 3 
                      then (
                            select it.instrument_key 
                            from dwh.instrument_types it 
                            where it.instrument_ru_nam = 'Кредиты крупному бизнесу' 
                             and it.begin_dt <= p_REPORT_DT 
                             and it.end_dt > p_REPORT_DT
                           ) 
                  end as instrument_key,
                  'Активы' as instrument_kind_cd,
                  rs.CURRENCY_KEY as SRC_CURRENCY_KEY,
                  case 
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                      then rs.CURRENCY_KEY
                    else (
                          select currency_key 
                          from dwh.currencies 
                          where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') 
                           and currency_letter_cd = 'OTH'
                          ) 
                  end as cis_currency_key,
                  --rs.PAY_DT - p_REPORT_DT as TERM_CNT, vklavsut
                  decode(rs.PAY_DT - p_REPORT_DT,1,2,rs.PAY_DT - p_REPORT_DT) as TERM_CNT,
                  p1.period_key as PERIOD1_TYPE_KEY,
                  p2.period_key as PERIOD2_TYPE_KEY,
                  p3.period_key as PERIOD3_TYPE_KEY,
                  rs.NIL_AMT AS SRC_AMT,
                  case 
                    when cr.currency_letter_cd = 'RUB' 
                      then rs.NIL_AMT
                    else rs.NIL_AMT * er.exchange_rate 
                  end as RUR_AMT,
                  case 
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                      then rs.NIL_AMT
                    else rs.NIL_AMT * er.exchange_rate 
                  end as CIS_AMT,
                  cgp.XIRR_RATE * (case 
                                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                                      then rs.NIL_AMT
                                    else rs.NIL_AMT * er.exchange_rate 
                                   end
                  ) as RATE_W_AMT,
                    --vklavsut  СРОК должен быть больше 1. Если срок равен 1, то кладем на срок 2
                   decode(rs.PAY_DT - p_REPORT_DT,1,2,rs.PAY_DT - p_REPORT_DT)*
                   (
                                                                       case 
                                                                        when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                                                                          then rs.NIL_AMT
                                                                        else rs.NIL_AMT * er.exchange_rate 
                                                                       end
                  ) as TERM_W_AMT,
          /*        (rs.PAY_DT - p_REPORT_DT) * (
                                                                       case 
                                                                        when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                                                                          then rs.NIL_AMT
                                                                        else rs.NIL_AMT * er.exchange_rate 
                                                                       end
                  ) as TERM_W_AMT,*/
                  -- [apolyakov]: доработка в рамках ЗА 4689
                  case 
                    when nvl (rs.custom_flg, 0) = 1
                          then round (rs.nil_amt 
                               + (sum (rs.nil_amt) over (
                                                    partition by rs.contract_key order by rs.pay_dt asc 
                                                        rows between current row and unbounded following
                                                    ) 
                                * (power ((1 + cgp.xirr_rate), 
                                           (rs.pay_dt - nvl (lag (rs.PAY_DT) over (partition by rs.contract_key order by rs.pay_dt asc), p_REPORT_DT)) / 365) - 1
                                  )
                                 )
                                 , 2)
                    else
                      rs.LEASING_PAY_AMT
                  end AS SRC_LIQ_AMT,
                  -- [apolyakov]: доработка в рамках ЗА 4689
                  case 
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                      then case 
                              when nvl (rs.custom_flg, 0) = 1
                                    then round (rs.nil_amt 
                                         + (sum (rs.nil_amt) over (
                                                              partition by rs.contract_key order by rs.pay_dt asc 
                                                                  rows between current row and unbounded following
                                                              ) 
                                          * (power ((1 + cgp.xirr_rate), 
                                                     (rs.pay_dt - nvl (lag (rs.PAY_DT) over (partition by rs.contract_key order by rs.pay_dt asc), p_REPORT_DT)) / 365) - 1
                                            )
                                           )
                                           , 2)
                              else
                                rs.LEASING_PAY_AMT
                            end
                    else case 
                            when nvl (rs.custom_flg, 0) = 1
                                  then round (rs.nil_amt 
                                       + (sum (rs.nil_amt) over (
                                                            partition by rs.contract_key order by rs.pay_dt asc 
                                                                rows between current row and unbounded following
                                                            ) 
                                        * (power ((1 + cgp.xirr_rate), 
                                                   (rs.pay_dt - nvl (lag (rs.PAY_DT) over (partition by rs.contract_key order by rs.pay_dt asc), p_REPORT_DT)) / 365) - 1
                                          )
                                         )
                                         , 2)
                            else
                              rs.LEASING_PAY_AMT
                          end * er.exchange_rate 
                  end as CIS_LIQ_AMT,
                  rs.NIL_AMT as SRC_MR_AMT,
                  case 
                    when cr.currency_letter_cd = 'RUB' 
                      then rs.NIL_AMT
                    else rs.NIL_AMT * er.exchange_rate 
                  end as RUR_MR_AMT,
                  case 
                    when cr.currency_letter_cd = 'RUB' 
                      then rs.NIL_AMT * cgp.XIRR_RATE 
                      else rs.NIL_AMT * cgp.XIRR_RATE * er.exchange_rate end
                      as RATE_W_MR_AMT,
                  rs.PAY_DT as PAY_DT,
                  case 
                    when cr.currency_letter_cd = 'RUB' 
                      then 1 
                    else er.exchange_rate 
                  end as ex_rate,
                  '0' as FLOAT_RATE_FLG,
                  cgp.xirr_rate as rate_amt,
                  null as purpose_desc,
                  'V-1.3.1.1' as ART_CD,
                  777 AS PROCESS_KEY,
                  SYSDATE AS INSERT_DT
           from 
                  dm.dm_cgp cgp, 
                  dwh.clients cl, 
                  dwh.business_categories bc, 
                  dm.dm_repayment_schedule rs, 
                  dwh.currencies cr,
                  DWH.IFRS_VTB_GROUP gr,
                  dwh.periods p1, 
                  dwh.periods p2, 
                  dwh.periods p3, 
                  dwh.period_types pt1, 
                  dwh.period_types pt2, 
                  dwh.period_types pt3,
                  dwh.exchange_rates er, 
                  dwh.currencies cr2,
                  dwh.parties_types pt,
                  dwh.cgp_group bg
           where cgp.SNAPSHOT_DT = p_REPORT_DT
             and cgp.SNAPSHOT_CD = 'Основной КИС'
             and rs.SNAPSHOT_CD = 'Основной КИС'
             and rs.SNAPSHOT_DT = p_REPORT_DT            
             and rs.PAY_DT > p_REPORT_DT
             and cgp.term_amt > 0
             and cl.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and bc.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and cr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and cr2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and er.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and p1.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and p2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and p3.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and gr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and pt.valid_to_dttm(+) = to_date('01.01.2400', 'dd.mm.yyyy')
             and gr.end_dt = date'2099-12-31' --18/07/2017 [ovilkova] затроение в dm_reg
             and pt1.begin_dt <= p_REPORT_DT
             and pt1.end_dt > p_REPORT_DT
             and pt2.begin_dt <= p_REPORT_DT
             and pt2.end_dt > p_REPORT_DT
             and pt3.begin_dt <= p_REPORT_DT
             and pt3.end_dt > p_REPORT_DT
             and pt.begin_dt(+) <= p_REPORT_DT
             and pt.end_dt(+) > p_REPORT_DT
             and bg.begin_dt <= p_REPORT_DT
             and bg.end_dt > p_REPORT_DT  
             and cgp.branch_key = bg.branch_key
             and bg.cgp_group_key = p_group_key
             and cl.client_key = cgp.client_key
             and cl.member_key = gr.member_key
             and cgp.contract_key = rs.contract_key
             and rs.CURRENCY_KEY = cr.CURRENCY_KEY
             and p1.period_type_key = pt1.period_type_key
             and p2.period_type_key = pt2.period_type_key
             and p3.period_type_key = pt3.period_type_key
             and pt1.period_type_cd = 1
             and pt2.period_type_cd = 2
             and pt3.period_type_cd = 3
             and rs.PAY_DT - p_REPORT_DT > p1.days_from_cnt and rs.PAY_DT - p_REPORT_DT <= p1.days_to_cnt
             and rs.PAY_DT - p_REPORT_DT > p2.days_from_cnt and rs.PAY_DT - p_REPORT_DT <= p2.days_to_cnt
             and rs.PAY_DT - p_REPORT_DT > p3.days_from_cnt and rs.PAY_DT - p_REPORT_DT <= p3.days_to_cnt
             and cgp.business_category_key = bc.business_category_key
             and bc.begin_dt <= cgp.snapshot_dt
             and bc.end_dt > cgp.snapshot_dt
             and rs.currency_key = er.currency_key
             and er.base_currency_key = cr2.currency_key
             and er.ex_rate_dt = p_REPORT_DT
             and cr2.currency_letter_cd = 'RUB'
             and cl.parties_type_key  = pt.parties_type_key (+);
   dm.u_log(p_proc => 'DM.P_DM_REG_REPAYMENT_SCHEDULE_N',
           p_step => 'insert into DM.DM_REG_REPAYMENT_SCHEDULE',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');                   
commit;
end;
/

