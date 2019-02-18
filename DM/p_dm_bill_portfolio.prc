CREATE OR REPLACE PROCEDURE DM.P_DM_BILL_PORTFOLIO (p_REPORT_DT in date, p_reg_group_key in number default 1)
IS


BEGIN

    delete from DM_BILL_PORTFOLIO where snapshot_dt = p_REPORT_DT and branch_key in (select branch_key from dwh.reg_group where reg_group_key = p_reg_group_key);


 -- dm.p_DM_NIL_OWNBILLS_CALC(p_REPORT_DT);

  insert into DM_BILL_PORTFOLIO(
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

          select 
                'Основной КИС' as snapshot_cd,
                p_REPORT_DT as snapshot_dt,
                to_char(p_REPORT_DT, 'MM') as snapshot_month,
                to_char(p_REPORT_DT, 'YYYY') as snapshot_year,
                (
                 select branch_key
                 from dwh.org_structure
                 where branch_cd='VTB_LEASING'
                 and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                ) as branch_key,
                null as account_key,
                bp.bill_key as contract_key,
                bp.client_key as client_key,
                null as bank_key,
                cl.member_key as member_key,
                --все векселя в отчетности идут в негрупповые операции!
                'N' as VTB_MEMBER_FLG,
                (
                  select INSTRUMENT_KEY 
                  from dwh.INSTRUMENT_TYPES it 
                  where INSTRUMENT_RU_NAM = 'Собственные векселя' 
                    and it.begin_dt <= p_REPORT_DT 
                    and it.end_dt > p_REPORT_DT
                ) as instrument_key,
                'Пассивы' as instrument_kind_cd,
                bp.currency_key as SRC_CURRENCY_KEY,
                case 
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                        then bp.CURRENCY_KEY
                    else (
                          select currency_key 
                          from dwh.currencies 
                          where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') 
                            and currency_letter_cd = 'OTH'
                         ) 
                end as cis_currency_key,
                bp.PRESENT_DT + 365 - p_REPORT_DT as term_cnt,
                p1.period_key as PERIOD1_TYPE_KEY,
                p2.period_key as PERIOD2_TYPE_KEY,
                p3.period_key as PERIOD3_TYPE_KEY,
                -1 * (case 
                when bp.prc_rate = 0 
                  then bp.NOMINAL_AMT - dm.NIL
                else fb.pay_amt end) as src_amt,
                -1 * (case 
                    when cr.currency_letter_cd = 'RUB' 
                        then (case when bp.prc_rate = 0 then bp.NOMINAL_AMT - dm.NIL else fb2.pay_amt end)
                    else (case when bp.prc_rate = 0 then bp.NOMINAL_AMT - dm.NIL else fb2.pay_amt end) * er.exchange_rate 
                end) as RUR_AMT,
                -1 * (case 
                    when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                        then (case when bp.prc_rate = 0 then bp.NOMINAL_AMT - dm.NIL else fb2.pay_amt end) 
                    else (case when bp.prc_rate = 0 then bp.NOMINAL_AMT - dm.NIL else fb2.pay_amt end) * er.exchange_rate 
                end) as CIS_AMT,
                -1 * (case when bp.prc_rate = 0 then dm.xirr else bp.prc_rate/100 end) * (case 
                              when cr.currency_letter_cd = 'RUB' 
                                  then (case when bp.prc_rate = 0 then bp.NOMINAL_AMT - dm.NIL else fb2.pay_amt end)
                              else (case when bp.prc_rate = 0 then bp.NOMINAL_AMT - dm.NIL else fb2.pay_amt end) * er.exchange_rate 
                           end) as RATE_W_AMT,
                -1 * (case when bp.prc_rate = 0 then bp.NOMINAL_AMT - dm.NIL else fb2.pay_amt end) * (bp.PRESENT_DT + 365 - p_REPORT_DT) as TERM_W_AMT,
                -1 * (case when bp.prc_rate = 0 then fb.pay_amt else fb2.pay_amt end) as SRC_LIQ_AMT,
                -1 * (case when bp.prc_rate = 0 then fb.pay_amt else fb2.pay_amt end) * (case 
                                  when cr.currency_letter_cd in ('USD', 'EUR', 'RUB') 
                                      then 1 
                                  else er.exchange_rate 
                              end) as CIS_LIQ_AMT,
                -1 * (case when bp.prc_rate = 0 then bp.NOMINAL_AMT - dm.NIL else fb2.pay_amt end) as SRC_MR_AMT,
                -1 * (case 
                    when cr.currency_letter_cd = 'RUB' 
                        then (case when bp.prc_rate = 0 then bp.NOMINAL_AMT - dm.NIL else fb2.pay_amt end)
                    else (case when bp.prc_rate = 0 then bp.NOMINAL_AMT - dm.NIL else fb2.pay_amt end) * er.exchange_rate 
                end) as RUR_MR_AMT,
                -1 * (case when bp.prc_rate = 0 then dm.xirr else bp.prc_rate/100 end) * (case 
                              when cr.currency_letter_cd = 'RUB' 
                                  then (case when bp.prc_rate = 0 then bp.NOMINAL_AMT - dm.NIL else fb2.pay_amt end)
                              else (case when bp.prc_rate = 0 then bp.NOMINAL_AMT - dm.NIL else fb2.pay_amt end) * er.exchange_rate 
                           end) as RATE_W_MR_AMT,
                bp.PRESENT_DT + 365 as PAY_DT,
                case 
                    when cr.currency_letter_cd = 'RUB' 
                        then 1 
                    else er.exchange_rate 
                end as EX_RATE,
                '0' as FLOAT_RATE_FLG,
                (case when bp.prc_rate = 0 then dm.xirr else bp.prc_rate/100 end) as RATE_AMT,
                null as PURPOSE_DESC,
                'V-1.16.1' as ART_CD,
                777 as PROCESS_KEY,
                SYSDATE AS INSERT_DT
          from 
                dwh.BILLS_PORTFOLIO bp, 
                dwh.clients cl, 
                dwh.currencies cr, 
                dwh.currencies cr2, 
                dm.dm_nil_ownbills dm, 
                dwh.exchange_rates er, 
                --DWH.IFRS_VTB_GROUP gr,
                dwh.fact_bills_plan fb,
                dwh.periods p1, 
                dwh.periods p2, 
                dwh.periods p3,
                dwh.period_types pt1, 
                dwh.period_types pt2,
                dwh.period_types pt3,
                dwh.fact_bills_plan fb2,
                dwh.reg_group bg
          where bp.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') 
            and cl.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            and cr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            and cr2.valid_to_dttm(+) = to_date('01.01.2400', 'dd.mm.yyyy')
            and er.valid_to_dttm (+)= to_date('01.01.2400', 'dd.mm.yyyy')
            and p1.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            and p2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            and p3.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            and fb.valid_to_dttm (+) = to_date('01.01.2400', 'dd.mm.yyyy')
            --and gr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
            and fb2.valid_to_dttm (+) = to_date('01.01.2400', 'dd.mm.yyyy')
            and fb2.begin_dt <= p_REPORT_DT
            and fb2.end_dt > p_REPORT_DT            
            and pt1.begin_dt <= p_REPORT_DT
            and pt1.end_dt > p_REPORT_DT
            and pt2.begin_dt <= p_REPORT_DT
            and pt2.end_dt > p_REPORT_DT
            and pt3.begin_dt <= p_REPORT_DT
            and pt3.end_dt > p_REPORT_DT
            and dm.odttm (+) = p_REPORT_DT
            and bg.begin_dt <= p_REPORT_DT
            and bg.end_dt > p_REPORT_DT
            and cr.begin_dt <= p_REPORT_DT
            and cr.end_dt > p_REPORT_DT
            and cr2.begin_dt <= p_REPORT_DT
            and cr2.end_dt > p_REPORT_DT
            and p1.begin_dt <= p_REPORT_DT
            and p1.end_dt > p_REPORT_DT
            and p2.begin_dt <= p_REPORT_DT
            and p2.end_dt > p_REPORT_DT
            and p3.begin_dt <= p_REPORT_DT
            and p3.end_dt > p_REPORT_DT
            and (select branch_key
                 from dwh.org_structure
                 where branch_cd='VTB_LEASING'
                 and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                ) = bg.branch_key
            and bg.reg_group_key = p_reg_group_key
            and bp.bill_key = fb2.bill_key (+)
            and fb2.cbc_desc (+) = 'ФД.17.1'
            and p1.period_type_key = pt1.period_type_key
            and p2.period_type_key = pt2.period_type_key
            and p3.period_type_key = pt3.period_type_key
            and pt1.period_type_cd = 1
            and pt2.period_type_cd = 2
            and pt3.period_type_cd = 3
            --!!!!!!!!!! changed 15/07/2015/////////////////////////////////////
            and bp.PRESENT_DT + 365 - p_REPORT_DT > p1.days_from_cnt and bp.PRESENT_DT + 365 - p_REPORT_DT <= p1.days_to_cnt
            and bp.PRESENT_DT + 365 - p_REPORT_DT > p2.days_from_cnt and bp.PRESENT_DT + 365 - p_REPORT_DT <= p2.days_to_cnt
            and bp.PRESENT_DT + 365 - p_REPORT_DT > p3.days_from_cnt and bp.PRESENT_DT + 365 - p_REPORT_DT <= p3.days_to_cnt
            --///////////////////////////////////////////////////////////////////
            and bp.own_flg = '1'
            and bp.client_key = cl.client_key
            --and cl.member_key = gr.member_key
            and bp.CURRENCY_KEY = cr.currency_key(+)
            and bp.bill_key = dm.BILL_KEY (+)
            and bp.currency_key = er.currency_key
            and er.base_currency_key = cr2.currency_key
            and cr2.currency_letter_cd = 'RUB'
            and er.ex_rate_dt(+) = p_REPORT_DT
            and bp.bill_key = fb.bill_key (+)
            and fb.cbc_desc (+) = 'ФД.9.1'
            and (bp.close_dt>=p_REPORT_DT or bp.close_dt is null)
            and fb.pay_amt <> 0
            and fb2.pay_amt<>0
;
            
commit;

end;
/

