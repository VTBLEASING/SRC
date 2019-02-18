CREATE OR REPLACE PROCEDURE DM.P_DM_REG_REPAYMENT_SCHEDULE (p_REPORT_DT in date, p_reg_group_key in number default 1)
IS

BEGIN
    delete from DM.DM_REG_REPAYMENT_SCHEDULE where snapshot_dt = p_REPORT_DT and branch_key in (select branch_key from dwh.reg_group where reg_group_key = p_reg_group_key);

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
                  cc.branch_key as branch_key,
                  null as account_key,
                  pp.contract_key as contract_key,
                  pp.client_key as client_key,
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
                  cc.CURRENCY_KEY as SRC_CURRENCY_KEY,
                  case
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB')
                      then cc.CURRENCY_KEY
                    else (
                          select currency_key
                          from dwh.currencies
                          where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                           and currency_letter_cd = 'OTH'
                          )
                  end as cis_currency_key,
                  --rs.PAY_DT - p_REPORT_DT as TERM_CNT,
                  --decode(pp.date_ - p_REPORT_DT,1,2,pp.date_ - p_REPORT_DT) as TERM_CNT, --vklavsut  пересчитываем, если 1, то умножаем на 2
				  case when cc.float_rate_type_key = 2 then decode(pp.date_ - p_REPORT_DT,1,2,pp.date_ - p_REPORT_DT) else least(decode(pp.date_ - p_REPORT_DT,1,2,pp.date_ - p_REPORT_DT), irt.UNFIXED_TERM_CNT) end as TERM_CNT, --26092018 New req
				  --========================================
                  /*case when cc.float_rate_type_key = 2 then p1.period_key else pp1.period_key end*/
				  p1.period_key as PERIOD1_TYPE_KEY, -- changed by okrupko 20180918
                  p2.period_key as PERIOD2_TYPE_KEY,
                  p3.period_key as PERIOD3_TYPE_KEY,
                  pp.sum_discount AS SRC_AMT,
                  case
                    when cr.currency_letter_cd = 'RUB'
                      then pp.sum_discount
                    else pp.sum_discount * er.exchange_rate
                  end as RUR_AMT,
                  case
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB')
                      then pp.sum_discount
                    else pp.sum_discount * er.exchange_rate
                  end as CIS_AMT,
                 (case
                                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB')
                                      then pp.sum_discount * pp.xirr --added by okrupko 20180914
                                    else pp.sum_discount * pp.xirr * er.exchange_rate --added by okrupko 20180914
                                   end
                  ) as RATE_W_AMT,
                  --vklavsut  СРОК должен быть больше 1. Если срок равен 1, то кладем на срок 2
                 /* (pp.date_ - p_REPORT_DT)*/
                  --decode(pp.date_ - p_REPORT_DT,1,2,pp.date_ - p_REPORT_DT)*
				  case when cc.float_rate_type_key = 2 then decode(pp.date_ - p_REPORT_DT,1,2,pp.date_ - p_REPORT_DT) else least(decode(pp.date_ - p_REPORT_DT,1,2,pp.date_ - p_REPORT_DT), irt.UNFIXED_TERM_CNT) end * --20180927 New req
                   (
                                                                       /*case
                                                                        when cr.currency_letter_cd in ('USD', 'EUR', 'RUB')
                                                                          then pp.sum_
                                                                        else pp.sum_ * er.exchange_rate
                                                                       end*/
																	   pp.sum_discount --20180927 Requirement from YPolyanskaya
                  ) as TERM_W_AMT,
                  /*rs.LEASING_PAY_AMT*/ pp.SUM_ AS SRC_LIQ_AMT,
                  case
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB')
                      then pp.SUM_
                    else /*rs.LEASING_PAY_AMT * er.exchange_rate*/ pp.SUM_* er.exchange_rate
                  end as CIS_LIQ_AMT,
                  pp.sum_ as SRC_MR_AMT,
                  case
                    when cr.currency_letter_cd = 'RUB'
                      then pp.sum_
                    else pp.sum_ * er.exchange_rate
                  end as RUR_MR_AMT,
                  case
                    when cr.currency_letter_cd = 'RUB'
                      then pp.sum_discount
                      else pp.sum_discount * er.exchange_rate end
                      as RATE_W_MR_AMT,
                  pp.date_ as PAY_DT,
                  case
                    when cr.currency_letter_cd = 'RUB'
                      then 1
                    else er.exchange_rate
                  end as ex_rate,
                  '0' as FLOAT_RATE_FLG,
                  pp.xirr as rate_amt,
                  null as purpose_desc,
                  'V-1.3.1.1' as ART_CD,
                  777 AS PROCESS_KEY,
                  SYSDATE AS INSERT_DT
           from
                  --dm.dm_cgp cgp,
                  dwh.clients cl,
                  dwh.business_categories bc,
                  --dm.dm_repayment_schedule rs,
                  dm.dm_cgp_report pp, -- added by okrupko ЗА 5995
                  dwh.currencies cr,
                  DWH.IFRS_VTB_GROUP gr,
                  dwh.periods p1,
                  --dwh.periods pp1,
                  dwh.periods p2,
                  dwh.periods p3,
                  dwh.period_types pt1,
                  dwh.period_types pt2,
                  dwh.period_types pt3,
                  dwh.exchange_rates er,
                  dwh.currencies cr2,
                  dwh.parties_types pt,
                  dwh.reg_group bg,
                  dwh.contracts cc,
                  dwh.interest_rate_types irt -- added by okrupko ЗА 5995
           where pp.SNAPSHOT_DT = p_REPORT_DT
             --and cgp.SNAPSHOT_CD = 'Основной КИС'
             --and rs.SNAPSHOT_CD = 'Основной КИС'
             --and rs.SNAPSHOT_DT = p_REPORT_DT
             --and pp.date_ > p_REPORT_DT
             --and pp.sum_ > 0
             and cl.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and bc.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and cr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and cr2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and er.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and p1.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             --and pp1.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and p2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and p3.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and gr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and cc.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
             and irt.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
              and gr.end_dt = date'2099-12-31' --18/07/2017 added by ovilkova 3-fold lines in dm_reg
             and pt.valid_to_dttm(+) = to_date('01.01.2400', 'dd.mm.yyyy')
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
             and cc.branch_key = bg.branch_key -- changed by okrupko ЗА 5995
             and bg.reg_group_key = p_reg_group_key
             and cl.client_key = pp.client_key
             and cl.member_key = gr.member_key
             --and pp.contract_key = rs.contract_key -- changed 20183008 by okrupko
             and cc.CURRENCY_KEY = cr.CURRENCY_KEY -- changed 20183008 by okrupko
             and p1.period_type_key = pt1.period_type_key
             --and pp1.period_type_key = pt1.period_type_key -- added by okrupko 20180830
             and p2.period_type_key = pt2.period_type_key
             and p3.period_type_key = pt3.period_type_key
             and pt1.period_type_cd = 1
             and pt2.period_type_cd = 2
             and pt3.period_type_cd = 3
             --and (case when cc.float_rate_type_key = 2 then pp.date_ - p_REPORT_DT else least(pp.date_ - p_REPORT_DT, irt.UNFIXED_TERM_CNT) end)> p1.days_from_cnt and (case when cc.float_rate_type_key = 2 then pp.date_ - p_REPORT_DT else least(pp.date_ - p_REPORT_DT, irt.UNFIXED_TERM_CNT) end)<= p1.days_to_cnt --changed 20180918 by okrupko
             --and pp.date_ - p_REPORT_DT > p2.days_from_cnt and pp.date_ - p_REPORT_DT <= p2.days_to_cnt --changed 20183008 by okrupko
             --and pp.date_ - p_REPORT_DT > p3.days_from_cnt and pp.date_ - p_REPORT_DT <= p3.days_to_cnt --changed 20183008 by okrupko
             and (case when cc.float_rate_type_key = 2 then decode(pp.date_ - p_REPORT_DT,1,2,pp.date_ - p_REPORT_DT) else least(decode(pp.date_ - p_REPORT_DT,1,2,pp.date_ - p_REPORT_DT), irt.UNFIXED_TERM_CNT) end)> p1.days_from_cnt
			 and (case when cc.float_rate_type_key = 2 then decode(pp.date_ - p_REPORT_DT,1,2,pp.date_ - p_REPORT_DT) else least(decode(pp.date_ - p_REPORT_DT,1,2,pp.date_ - p_REPORT_DT), irt.UNFIXED_TERM_CNT) end)<= p1.days_to_cnt --20180927 New req
             and decode(pp.date_ - p_REPORT_DT,1,2,pp.date_ - p_REPORT_DT) > p2.days_from_cnt
			 and decode(pp.date_ - p_REPORT_DT,1,2,pp.date_ - p_REPORT_DT) <= p2.days_to_cnt --20180927 New req
             and decode(pp.date_ - p_REPORT_DT,1,2,pp.date_ - p_REPORT_DT) > p3.days_from_cnt
			 and decode(pp.date_ - p_REPORT_DT,1,2,pp.date_ - p_REPORT_DT) <= p3.days_to_cnt --20180927 New req
             and cl.business_category_key = bc.business_category_key
             and bc.begin_dt <= pp.snapshot_dt -- changed by okrupko ЗА 5995
             and bc.end_dt > pp.snapshot_dt -- changed by okrupko ЗА 5995
             and cc.currency_key = er.currency_key -- changed by okrupko ЗА 5995
             and er.base_currency_key = cr2.currency_key
             and er.ex_rate_dt = p_REPORT_DT
             and cr2.currency_letter_cd = 'RUB'
             and cl.parties_type_key  = pt.parties_type_key (+)
             --and pp.contract_key = cgp.contract_key -- changed by okrupko ЗА 5995
             and pp.contract_key = cc.contract_key -- added by okrupko ЗА 5995
             and cc.float_rate_type_key = irt.rate_key; -- added by okrupko ЗА 5995

commit;
end;
/

