CREATE OR REPLACE PROCEDURE DM.P_DM_REG_MISC (
    p_REPORT_DT in DATE, p_reg_group_key in number default 1)

IS

BEGIN

DELETE FROM DM.DM_REG_MISC WHERE snapshot_DT = p_REPORT_DT and branch_key in (select branch_key from dwh.reg_group where reg_group_key = p_reg_group_key);

insert into DM.DM_REG_MISC(
                  SNAPSHOT_CD,
                  SNAPSHOT_DT,
                  SNAPSHOT_MONTH,
                  SNAPSHOT_YEAR,
                  BRANCH_KEY,
                  ACСOUNT_KEY,
                  CONTRACT_KEY,
                  CLIENT_KEY,
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

    select /*+ cardinality(p1, 500) cardinality(p2, 500) cardinality(p3, 500) cardinality(cl, 5000) cardinality(er, 50000) cardinality(pt1, 500) cardinality(pt2, 500) cardinality(pt3, 500) use_hash(p1, p2, p3, pt1, pt2, pt3) */
          'Основной КИС' as snapshot_cd,
          p_REPORT_DT as snapshot_dt,
          to_char(p_REPORT_DT, 'MM') as snapshot_month,
          to_char(p_REPORT_DT, 'YYYY') as snapshot_year,
          1 as branch_key,
          null as ACСOUNT_KEY,
          mf.contract_KEY as contract_KEY,
          mf.bank_key as client_key,
          cl.member_key as member_key,
          case 
                    when gr.member_cd <> 0 
                      then 'Y' 
                    else 'N' 
                  end as VTB_MEMBER_FLG,
          mf.instrument_key as instrument_key,
          (select max (instrument_kind_cd)
           from DWH.INSTRUMENT_TYPES it
           WHERE it.INSTRUMENT_key = mf.INSTRUMENT_key
           and it.begin_dt <= p_REPORT_DT 
           and it.end_dt > p_REPORT_DT
          ) as instrument_kind_cd,
          mf.currency_key as SRC_CURRENCY_KEY,
          case 
              when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                  then mf.CURRENCY_KEY
              else (
                    select 
                          currency_key 
                    from dwh.currencies 
                    where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') 
                      and currency_letter_cd = 'OTH'
          ) end as cis_currency_key,
          mf.PAY_DT - p_REPORT_DT as term_cnt,
          p1.period_key as PERIOD1_TYPE_KEY,
          p2.period_key as PERIOD2_TYPE_KEY,
          p3.period_key as PERIOD3_TYPE_KEY,
          mf.PAY_TERM_AMT as src_amt,
          case 
              when cr.currency_letter_cd = 'RUB' 
                  then mf.PAY_TERM_AMT
              else mf.PAY_TERM_AMT * er.exchange_rate 
          end as RUR_AMT,
          case 
              when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                  then mf.PAY_TERM_AMT 
              else mf.PAY_TERM_AMT * er.exchange_rate 
          end as CIS_AMT,
          
          (case when  mf.rate > 1 then  mf.rate/100 else  mf.rate end)
          * (case 
                        when cr.currency_letter_cd = 'RUB' 
                            then mf.PAY_TERM_AMT 
                        else mf.PAY_TERM_AMT  --* er.exchange_rate
                     end) as RATE_W_AMT,
   /*      vklavsut - переводим в CIS ,чтобы потом на отчете ОПР для расчета показателя - Средневзвешенный срок до пересмотра процентной ставки (дни)
           все типы инструментов разделить на sum(CIS_amt)*/
--OLD:    mf.PAY_TERM_AMT * (mf.PAY_DT - p_REPORT_DT) as TERM_W_AMT,
        (case 
              when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                  then mf.PAY_TERM_AMT 
              else mf.PAY_TERM_AMT * er.exchange_rate 
          end) * (mf.PAY_DT - p_REPORT_DT) as TERM_W_AMT,
          nvl(mf.PAY_TERM_AMT, 0) + nvl(mf.PAY_INT_AMT, 0)  as SRC_LIQ_AMT,
          case 
                when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                    then nvl(mf.PAY_TERM_AMT, 0) + nvl(mf.PAY_INT_AMT, 0) 
                else (nvl(mf.PAY_TERM_AMT, 0) + nvl(mf.PAY_INT_AMT, 0)) * er.exchange_rate 
          end as CIS_LIQ_AMT,
          nvl(mf.PAY_TERM_AMT, 0)+nvl(mf.NKD_AMT,0) as SRC_MR_AMT,
          case 
              when cr.currency_letter_cd = 'RUB' 
                  then nvl(mf.PAY_TERM_AMT, 0)+nvl(mf.NKD_AMT,0)
              else (nvl(mf.PAY_TERM_AMT, 0)+nvl(mf.NKD_AMT,0)) * er.exchange_rate 
          end as RUR_MR_AMT,
          (case when  mf.rate > 1 then  mf.rate/100 else  mf.rate end)
           * (case 
                         when cr.currency_letter_cd = 'RUB' 
                            then (nvl(mf.PAY_TERM_AMT, 0)+nvl(mf.NKD_AMT,0))
                         else (nvl(mf.PAY_TERM_AMT, 0)+nvl(mf.NKD_AMT,0))* er.exchange_rate 
          end) as RATE_W_MR_AMT,
          mf.pay_dt as PAY_DT,
          case 
              when cr.currency_letter_cd = 'RUB' 
                  then 1 
              else er.exchange_rate 
          end as EX_RATE,
          '0' as FLOAT_RATE_FLG,
          (case when  mf.rate > 1 then  mf.rate/100 else  mf.rate end) as RATE_AMT,
          null as PURPOSE_DESC,
          (select max (art_cd)
           from DWH.INSTRUMENT_TYPES it
           WHERE it.INSTRUMENT_key = mf.INSTRUMENT_key
           and it.begin_dt <= p_REPORT_DT 
           and it.end_dt > p_REPORT_DT
          ) as ART_CD,
          777 as PROCESS_KEY,
          SYSDATE AS INSERT_DT
 from 
          dwh.fact_misc_flow mf, 
          dwh.clients cl,
          DWH.IFRS_VTB_GROUP gr,
          dwh.currencies cr, 
          dwh.exchange_rates er, 
          dwh.currencies cr2, 
          dwh.periods p1, 
          dwh.periods p2, 
          dwh.periods p3, 
          dwh.period_types pt1, 
          dwh.period_types pt2, 
          dwh.period_types pt3          
    where cl.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and mf.REPORT_DT=p_REPORT_DT
      and cl.client_key = mf.bank_key
      and mf.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and cr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and cr2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and er.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and gr.valid_to_dttm(+) = to_date('01.01.2400', 'dd.mm.yyyy')
      and p1.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and p2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and p3.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
      and pt1.begin_dt <= p_REPORT_DT
      and pt1.end_dt > p_REPORT_DT
      and pt2.begin_dt <= p_REPORT_DT
      and pt2.end_dt > p_REPORT_DT
      and pt3.begin_dt <= p_REPORT_DT
      and pt3.end_dt > p_REPORT_DT
      and p1.period_type_key = pt1.period_type_key
      and p2.period_type_key = pt2.period_type_key
      and p3.period_type_key = pt3.period_type_key
      and upper(mf.vtb_group_flg) =upper( gr.member_ru_nam(+))
      and pt1.period_type_cd = 1
      and pt2.period_type_cd = 2
      and pt3.period_type_cd = 3
      and mf.PAY_DT - p_REPORT_DT > p1.days_from_cnt and mf.PAY_DT - p_REPORT_DT <= p1.days_to_cnt
      and mf.PAY_DT - p_REPORT_DT > p2.days_from_cnt and mf.PAY_DT - p_REPORT_DT <= p2.days_to_cnt
      and mf.PAY_DT - p_REPORT_DT > p3.days_from_cnt and mf.PAY_DT - p_REPORT_DT <= p3.days_to_cnt
      and mf.CURRENCY_KEY = cr.currency_key
      and mf.currency_key = er.currency_key
      and er.base_currency_key = cr2.currency_key
      and er.ex_rate_dt = p_REPORT_DT
      and cr2.currency_letter_cd = 'RUB'
      and p_reg_group_key in (1, 2);
      
commit;

end;
/

