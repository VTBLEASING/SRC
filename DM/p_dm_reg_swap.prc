CREATE OR REPLACE PROCEDURE DM."P_DM_REG_SWAP" (p_REPORT_DT in date, p_reg_group_key in number default 1)
IS


BEGIN

    delete from DM_REG_SWAP where snapshot_dt = p_REPORT_DT and branch_key in (select branch_key from dwh.reg_group where reg_group_key = p_reg_group_key);
    
    insert into DM_REG_SWAP( 
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
                  PAY_DT,EX_RATE,
                  FLOAT_RATE_FLG,
                  RATE_AMT,
                  PURPOSE_DESC,
                  ART_CD,
                  PROCESS_KEY,
                  INSERT_DT   
                )
            -- актив
           select 
                  'Основной КИС' as snapshot_cd,
                  p_REPORT_DT as snapshot_dt,
                  to_char(p_REPORT_DT, 'MM') as snapshot_month,
                  to_char(p_REPORT_DT, 'YYYY') as snapshot_year,
                  sw.branch_key as branch_key,
                  null as account_key,
                  sw.contract_key as contract_key,
                  sc.client_key as client_key,
                  null as bank_key,
                  cl.member_key as member_key,
                  case 
                    when gr.member_cd <> 0 
                      then 'Y' 
                    else 'N' 
                  end as VTB_MEMBER_FLG,
                  (
                    select 
                          it.instrument_key 
                    from 
                          dwh.INSTRUMENT_TYPES it 
                    where it.INSTRUMENT_RU_NAM = 'Конверсионные операции (своп, форвард, опцион)' 
                      and it.INSTRUMENT_KIND_CD = 'Активы' 
                      and it.begin_dt <= p_REPORT_DT 
                      and it.end_dt > p_REPORT_DT
                  ) as instrument_key,
                  'Активы' as instrument_kind_cd,
                  sw.CURRENCY1_KEY as SRC_CURRENCY_KEY,
                  case 
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                      then sw.CURRENCY1_KEY
                    else (
                          select currency_key 
                          from dwh.currencies 
                          where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') 
                          and begin_dt <= p_REPORT_DT and end_dt > p_REPORT_DT
                          and currency_letter_cd = 'OTH'
                          ) 
                  end as cis_currency_key,
--СРОК должен быть больше 1. Если срок равен 1, то кладем на срок 2.
                  decode(sw.END_DT - p_REPORT_DT,1,2,sw.END_DT - p_REPORT_DT) AS TERM_CNT,                  
                  p1.period_key as PERIOD1_TYPE_KEY,
                  p2.period_key as PERIOD2_TYPE_KEY,
                  p3.period_key as PERIOD3_TYPE_KEY,
                  sw.BUY2_DISC_AMT as src_amt,
                  sw.BUY2_DISC_AMT * er.exchange_rate as RUR_AMT,
                  case 
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                      then sw.BUY2_DISC_AMT 
                    else sw.BUY2_DISC_AMT * er.exchange_rate 
                  end as CIS_AMT,
                  0 as RATE_W_AMT,
                  case 
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB')
                      then sw.BUY2_DISC_AMT * decode(sw.END_DT - p_REPORT_DT,1,2,sw.END_DT - p_REPORT_DT) 
                    else sw.BUY2_DISC_AMT * decode(sw.END_DT - p_REPORT_DT,1,2,sw.END_DT - p_REPORT_DT) * er.exchange_rate end as TERM_W_AMT,
                  sw.BUY2_AMT as SRC_LIQ_AMT,
                  case 
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                      then sw.BUY2_AMT 
                    else sw.BUY2_AMT * er.exchange_rate 
                  end as CIS_LIQ_AMT,
                  null as SRC_MR_AMT,
                  null as RUR_MR_AMT,
                  null as RATE_W_MR_AMT,
                  sw.END_DT as PAY_DT,
                  er.exchange_rate as EX_RATE,
                  '0' as FLOAT_RATE_FLG,
                  null as RATE_AMT,
                  (select PURPOSE_DESC
                   from dwh.OPERATION_PURPOSES
                   where (INSTRUMENT_RU_NAM) LIKE 'Конверсионные операции (своп, форвард, опцион)' 
                   And Upper(INSTRUMENT_SOURCE_NAM)LIKE '%SWAP%'
                   And BEGIN_DT<=p_REPORT_DT
                   AND END_DT>p_REPORT_DT)
                   as PURPOSE_DESC, 
                  null as ART_CD,
                  777 as PROCESS_KEY,
                  SYSDATE AS INSERT_DT
          from 
                  dm.dm_swap_npv sw, 
                  dwh.clients cl, 
                  DWH.IFRS_VTB_GROUP gr,
                  dwh.swap_contracts sc, 
                  dwh.currencies cr, 
                  dwh.periods p1, 
                  dwh.periods p2, 
                  dwh.periods p3, 
                  dwh.period_types pt1, 
                  dwh.period_types pt2, 
                  dwh.period_types pt3,
                  dwh.exchange_rates er, 
                  dwh.currencies cr2,
                  dwh.reg_group bg
          where sw.SNAPSHOT_DT = p_REPORT_DT
            and cl.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            and sc.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            and cr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            and p1.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            and p2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            and p3.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            and cr2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            and er.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            and gr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            and pt1.begin_dt <= p_REPORT_DT
            and pt1.end_dt > p_REPORT_DT
            and gr.begin_dt <= p_REPORT_DT
            and gr.end_dt > p_REPORT_DT            
            and cr.begin_dt <= p_REPORT_DT
            and cr.end_dt > p_REPORT_DT 
            and cr2.begin_dt <= p_REPORT_DT
            and cr2.end_dt > p_REPORT_DT                     
            and pt2.begin_dt <= p_REPORT_DT
            and pt2.end_dt > p_REPORT_DT
            and pt3.begin_dt <= p_REPORT_DT
            and pt3.end_dt > p_REPORT_DT
            and bg.begin_dt <= p_REPORT_DT
            and bg.end_dt > p_REPORT_DT  
            and sw.branch_key = bg.branch_key
            and bg.reg_group_key = p_reg_group_key
            and p1.period_type_key = pt1.period_type_key
            and p2.period_type_key = pt2.period_type_key
            and p3.period_type_key = pt3.period_type_key
            and pt1.period_type_cd = 1
            and pt2.period_type_cd = 2
            and pt3.period_type_cd = 3
            and sw.END_DT - p_REPORT_DT > p1.days_from_cnt and sw.END_DT - p_REPORT_DT <= p1.days_to_cnt
            and sw.END_DT - p_REPORT_DT > p2.days_from_cnt and sw.END_DT - p_REPORT_DT <= p2.days_to_cnt
            and sw.END_DT - p_REPORT_DT > p3.days_from_cnt and sw.END_DT - p_REPORT_DT <= p3.days_to_cnt
            and sw.contract_key = sc.contract_key
            and sw.CURRENCY1_KEY = cr.currency_key
            and sc.client_key = cl.client_key
            and sw.CURRENCY1_KEY = er.currency_key
            and cl.member_key = gr.member_key
            and er.base_currency_key = cr2.currency_key
            and er.ex_rate_dt = p_REPORT_DT
            and cr2.currency_letter_cd = 'RUB'
            and sc.end_dt > p_REPORT_DT;
          
          
          insert into DM_REG_SWAP( 
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
                  PAY_DT,EX_RATE,
                  FLOAT_RATE_FLG,
                  RATE_AMT,
                  PURPOSE_DESC,
                  ART_CD,
                  PROCESS_KEY,
                  INSERT_DT   
                )        
          -- пассив
          select 
                  'Основной КИС' as snapshot_cd,
                  p_REPORT_DT as snapshot_dt,
                  to_char(p_REPORT_DT, 'MM') as snapshot_month,
                  to_char(p_REPORT_DT, 'YYYY') as snapshot_year,
                  sw.branch_key as branch_key,
                  null as account_key,
                  sw.contract_key as contract_key,
                  sc.client_key as client_key,
                  null as bank_key,
                  cl.member_key as member_key,
                  case 
                    when gr.member_cd <> 0 
                      then 'Y' 
                    else 'N' 
                  end as VTB_MEMBER_FLG,
                  (
                    select it.instrument_key 
                    from dwh.INSTRUMENT_TYPES it 
                    where it.INSTRUMENT_RU_NAM = 'Конверсионные операции (своп, форвард, опцион)' 
                      and it.INSTRUMENT_KIND_CD = 'Пассивы' 
                      and it.begin_dt <= p_REPORT_DT 
                      and it.end_dt > p_REPORT_DT
                  ) as instrument_key,
                  'Пассивы' as instrument_kind_cd,
                  sw.CURRENCY2_KEY as SRC_CURRENCY_KEY,
                  case 
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                      then sw.CURRENCY2_KEY
                    else (
                          select currency_key 
                          from dwh.currencies 
                          where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') 
                          and begin_dt <= p_REPORT_DT and end_dt > p_REPORT_DT
                          and currency_letter_cd = 'OTH'
                         ) 
                  end as cis_currency_key,
                  decode(sw.END_DT - p_REPORT_DT,1,2,sw.END_DT - p_REPORT_DT) as term_cnt,
                  p1.period_key as PERIOD1_TYPE_KEY,
                  p2.period_key as PERIOD2_TYPE_KEY,
                  p3.period_key as PERIOD3_TYPE_KEY,
                  -sw.SELL2_DISC_AMT as src_amt,
                  -sw.SELL2_DISC_AMT * er.exchange_rate as RUR_AMT,
                  case 
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                      then -sw.SELL2_DISC_AMT 
                    else -sw.SELL2_DISC_AMT * er.exchange_rate
                  end as CIS_AMT,
                  0 as RATE_W_AMT,
                  case 
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB')
                      then -sw.SELL2_DISC_AMT * decode(sw.END_DT - p_REPORT_DT,1,2,sw.END_DT - p_REPORT_DT) 
                    else -sw.SELL2_DISC_AMT * decode(sw.END_DT - p_REPORT_DT,1,2,sw.END_DT - p_REPORT_DT) * er.exchange_rate end as TERM_W_AMT,
                  -sw.SELL2_AMT as SRC_LIQ_AMT,
                  case 
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                      then -sw.SELL2_AMT 
                    else -sw.SELL2_AMT * er.exchange_rate 
                  end as CIS_LIQ_AMT,
                  null as SRC_MR_AMT,
                  null as RUR_MR_AMT,
                  null as RATE_W_MR_AMT,
                  sw.END_DT as PAY_DT,
                  er.exchange_rate as EX_RATE,
                  '0' as FLOAT_RATE_FLG,
                  null as RATE_AMT,
                  (select PURPOSE_DESC
                   from dwh.OPERATION_PURPOSES
                   where (INSTRUMENT_RU_NAM) LIKE 'Конверсионные операции (своп, форвард, опцион)' 
                   And Upper(INSTRUMENT_SOURCE_NAM)LIKE '%SWAP%'
                   And BEGIN_DT<=p_REPORT_DT
                   AND END_DT>p_REPORT_DT)
                   as PURPOSE_DESC, 
                  null as ART_CD,
                  777 as PROCESS_KEY,
                  SYSDATE AS INSERT_DT
            from 
                  dm.dm_swap_npv sw, 
                  dwh.clients cl,  
                  DWH.IFRS_VTB_GROUP gr,
                  dwh.swap_contracts sc, 
                  dwh.currencies cr, 
                  dwh.periods p1, 
                  dwh.periods p2, 
                  dwh.periods p3, 
                  dwh.period_types pt1, 
                  dwh.period_types pt2, 
                  dwh.period_types pt3,
                  dwh.exchange_rates er, 
                  dwh.currencies cr2,
                  dwh.reg_group bg
            where 
                  sw.SNAPSHOT_DT = p_REPORT_DT
                  and cl.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                  and sc.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                  and cr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                  and p1.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                  and p2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                  and p3.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                  and cr2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                  and er.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                  and gr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                  and pt1.begin_dt <= p_REPORT_DT
                  and pt1.end_dt > p_REPORT_DT
                  and pt2.begin_dt <= p_REPORT_DT
                  and pt2.end_dt > p_REPORT_DT
                  and pt3.begin_dt <= p_REPORT_DT
                  and pt3.end_dt > p_REPORT_DT
                  and gr.begin_dt <= p_REPORT_DT
                  and gr.end_dt > p_REPORT_DT            
                  and cr.begin_dt <= p_REPORT_DT
                  and cr.end_dt > p_REPORT_DT 
                  and cr2.begin_dt <= p_REPORT_DT
                  and cr2.end_dt > p_REPORT_DT
                  and bg.begin_dt <= p_REPORT_DT
                  and bg.end_dt > p_REPORT_DT  
                  and sw.branch_key = bg.branch_key
                  and bg.reg_group_key = p_reg_group_key
                  and p1.period_type_key = pt1.period_type_key
                  and p2.period_type_key = pt2.period_type_key
                  and p3.period_type_key = pt3.period_type_key
                  and pt1.period_type_cd = 1
                  and pt2.period_type_cd = 2
                  and pt3.period_type_cd = 3
                  and sw.END_DT - p_REPORT_DT > p1.days_from_cnt and sw.END_DT - p_REPORT_DT <= p1.days_to_cnt
                  and sw.END_DT - p_REPORT_DT > p2.days_from_cnt and sw.END_DT - p_REPORT_DT <= p2.days_to_cnt
                  and sw.END_DT - p_REPORT_DT > p3.days_from_cnt and sw.END_DT - p_REPORT_DT <= p3.days_to_cnt
                  and sw.contract_key = sc.contract_key
                  and sw.CURRENCY2_KEY = cr.currency_key
                  and sc.client_key = cl.client_key
                  and sw.CURRENCY2_KEY = er.currency_key
                  and cl.member_key = gr.member_key
                  and er.base_currency_key = cr2.currency_key
                  and er.ex_rate_dt = p_REPORT_DT
                  and cr2.currency_letter_cd = 'RUB'
                  and sc.end_dt > p_REPORT_DT
                  ;

commit;
end;
/

