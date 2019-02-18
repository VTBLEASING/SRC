CREATE OR REPLACE PROCEDURE DM.p_DM_REG_DEPOSIT (p_REPORT_DT in date, p_reg_group_key in number default 1)
IS

BEGIN

delete from dm.DM_REG_DEPOSIT where snapshot_dt = p_REPORT_DT and branch_key in (select branch_key from dwh.reg_group where reg_group_key = p_reg_group_key);

insert into dm.DM_REG_DEPOSIT (
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
                          INSERT_DT) 
                 
  select 
          'Основной КИС' SNAPSHOT_CD,
          p_REPORT_DT SNAPSHOT_DT,
          to_char(p_REPORT_DT, 'MM') as snapshot_month,
          to_char(p_REPORT_DT, 'YYYY') as snapshot_year,
          ba.BRANCH_KEY BRANCH_KEY,
          ba.ACCOUNT_KEY ACCOUNT_KEY,
          null as contract_key,
          null as client_key,
          ba.BANK_KEY BANK_KEY,
          b.MEMBER_KEY MEMBER_KEY,
           case
              when gr.MEMBER_CD is not null and gr.MEMBER_CD <> 0
               and gr.CONS_CIS_FLG = 1 and gr.MRD_FLG = 1
                  then 'Y'
              else 'N'
           end
          as VTB_MEMBER_FLG,
          
          -- типа инструмента
           (select INSTRUMENT_KEY
            from dwh.INSTRUMENT_TYPES
            where Upper(INSTRUMENT_RU_NAM) LIKE '%МБК%АКТИВ'
            And Upper(INSTRUMENT_TYPE_DESC) = 'ПРОЦЕНТНЫЙ'
            And BEGIN_DT <= p_REPORT_DT
            AND END_DT > p_REPORT_DT
            )
          as INSTRUMENT_KEY,
          
          --статья
           (select INSTRUMENT_KIND_CD
            from dwh.INSTRUMENT_TYPES
            where Upper(INSTRUMENT_RU_NAM) LIKE '%МБК%АКТИВ'
            And Upper(INSTRUMENT_TYPE_DESC) = 'ПРОЦЕНТНЫЙ'
            And BEGIN_DT <= p_REPORT_DT
            AND END_DT > p_REPORT_DT
            ) 
          AS INSTRUMENT_KIND_CD,
          fct.CURRENCY_KEY  SRC_CURRENCY_KEY,
          --валюта КИС
           case
                when cr.CURRENCY_LETTER_CD in ('USD','EUR','RUB') 
                     then fct.CURRENCY_KEY
                else (select CURRENCY_KEY
                      from  DWH.CURRENCIES 
                      where VALID_TO_DTTM = to_date('01.01.2400','dd.mm.yyyy')
                        And BEGIN_DT <= p_REPORT_DT
                        AND END_DT > p_REPORT_DT
                        and CURRENCY_LETTER_CD = 'OTH'
                     )
           end
          AS CIS_CURRENCY_KEY,
          
          --СРОК должен быть больше 1. Если срок равен 1, то кладем на срок 2.
          decode((ba.CLOSE_DT-p_REPORT_DT),1,2,(ba.CLOSE_DT-p_REPORT_DT)) AS TERM_CNT,
          --тип периода 1
          p1.period_key as PERIOD1_TYPE_KEY,
          p2.period_key as PERIOD2_TYPE_KEY,
          p3.period_key as PERIOD3_TYPE_KEY,
          
          --сумма в исходной валюте
          fct.BALANCE_AMT SRC_AMT,
          --сумма в рублях
          case 
               when cr.CURRENCY_LETTER_CD = 'RUB'
                    then fct.BALANCE_AMT
               else
                    fct.BALANCE_AMT * er.EXCHANGE_RATE
          end 
          as RUR_AMT,
          
          --сумма в валюте КИС
          case
                when cr.CURRENCY_LETTER_CD in ('USD','EUR','RUB') 
                     then fct.BALANCE_AMT
                else 
                     fct.BALANCE_AMT * er.EXCHANGE_RATE
           end
          as CIS_AMT,
          
          --сумма взвешенная по ставке
           (case
                when cr.CURRENCY_LETTER_CD in ('USD','EUR','RUB') 
                    then fct.BALANCE_AMT
                else fct.BALANCE_AMT * er.EXCHANGE_RATE
           end
           ) * nvl(ba.RATE_AMT,0) / 100
          as RATE_W_AMT,
          
          --сумма взвешенная по сроку
            (case
                when cr.CURRENCY_LETTER_CD in ('USD','EUR','RUB') 
                    then fct.BALANCE_AMT
                else fct.BALANCE_AMT * er.EXCHANGE_RATE
            end
            ) * decode((ba.CLOSE_DT - p_REPORT_DT), 1, 2, (ba.CLOSE_DT - p_REPORT_DT))
          as TERM_W_AMT,
          
          --сумма Ликвидность в исходной валюте
          fct.BALANCE_AMT + nvl (fct.INT_TERM_AMT, 0)
          as  SRC_LIQ_AMT,
          
          --сумма Ликвидность в валюте КИС
           case
                when cr.CURRENCY_LETTER_CD in ('USD','EUR','RUB')
                    then fct.BALANCE_AMT + fct.INT_TERM_AMT
                else (fct.BALANCE_AMT + nvl (fct.INT_TERM_AMT, 0)) * er.EXCHANGE_RATE
           end
          as CIS_LIQ_AMT,
          
          --сумма MR в исходной валюте
          fct.BALANCE_AMT + nvl (fct.INT_TERM_AMT, 0)
          as SRC_MR_AMT,
          
          --сумма MR в рублях
           case 
                when cr.CURRENCY_LETTER_CD = 'RUB'
                    then  (fct.BALANCE_AMT + nvl (fct.INT_TERM_AMT, 0))
                else  (fct.BALANCE_AMT + nvl (fct.INT_TERM_AMT, 0)) * er.EXCHANGE_RATE
           end 
          as RUR_MR_AMT,
          
          --сумма MR взвешенная
           (case 
                when cr.CURRENCY_LETTER_CD = 'RUB'
                    then  (fct.BALANCE_AMT + nvl (fct.INT_TERM_AMT, 0))
                else  (fct.BALANCE_AMT + nvl (fct.INT_TERM_AMT, 0)) * er.EXCHANGE_RATE
            end) * nvl(ba.RATE_AMT, 0) / 100
          as RATE_W_MR_AMT,
          
          ba.CLOSE_DT as PAY_DT,
          case 
                when cr.CURRENCY_LETTER_CD = 'RUB' 
                    then 1 
                else er.EXCHANGE_RATE 
          end as EX_RATE,
          ba.FLOATING_RATE_FLG as FLOAT_RATE_FLG,
          nvl(ba.RATE_AMT, 0) / 100 as RATE_AMT ,
          ( select PURPOSE_DESC
            from dwh.OPERATION_PURPOSES
            where Upper(INSTRUMENT_RU_NAM) LIKE '%МБК%АКТИВ'
              And Upper(INSTRUMENT_SOURCE_NAM)LIKE '%ДЕПОЗИТ%'
              And BEGIN_DT <= p_REPORT_DT
              AND END_DT > p_REPORT_DT
            ) as PURPOSE_DESC,                      
          
           (select ART_CD
            from dwh.INSTRUMENT_TYPES
            where Upper(INSTRUMENT_RU_NAM) LIKE '%МБК%АКТИВ'
              And Upper(INSTRUMENT_TYPE_DESC)='ПРОЦЕНТНЫЙ'
              And BEGIN_DT <= p_REPORT_DT
              AND END_DT > p_REPORT_DT
            ) as ART_CD,
          777 as process_key,
          sysdate as insert_dt

from
        dwh.fact_account_balance fct, 
        dwh.bank_accounts ba, 
        dwh.banks b,
        DWH.IFRS_VTB_GROUP gr,
        dwh.currencies cr,
        dwh.exchange_rates er,
        dwh.currencies cr2,
        dwh.periods p1,
        dwh.periods p2,
        dwh.periods p3, 
        dwh.period_types pt1, 
        dwh.period_types pt2,
        dwh.period_types pt3,
        dwh.reg_group bg
  where fct.BALANCE_DT = p_REPORT_DT
    and fct.SNAPSHOT_CD = 'Отчетность'
    and fct.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
    and ba.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
    and b.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
    and gr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
    and cr.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
    and er.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
    and cr2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
    and p1.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
    and p2.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
    and p3.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
    and ba.close_dt > p_REPORT_DT
    and gr.begin_dt <= p_REPORT_DT
    and gr.end_dt > p_REPORT_DT
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
    and pt1.begin_dt <= p_REPORT_DT
    and pt1.end_dt > p_REPORT_DT
    and pt2.begin_dt <= p_REPORT_DT
    and pt2.end_dt > p_REPORT_DT  
    and pt3.begin_dt <= p_REPORT_DT
    and pt3.end_dt > p_REPORT_DT  
    and bg.begin_dt <= p_REPORT_DT
    and bg.end_dt > p_REPORT_DT  
    and fct.account_key = ba.account_key
    and bg.reg_group_key = p_reg_group_key
    and bg.branch_key = ba.branch_key
    and b.bank_key = ba.bank_key
    and b.member_key = gr.member_key
    and fct.CURRENCY_KEY = cr.CURRENCY_KEY
    and fct.currency_key = er.currency_key
    and er.base_currency_key = cr2.currency_key
    and p1.period_type_key = pt1.period_type_key
    and p2.period_type_key = pt2.period_type_key
    and p3.period_type_key = pt3.period_type_key
    and pt1.period_type_cd = 1 
    and pt2.period_type_cd = 2 
    and pt3.period_type_cd = 3 
    and ba.CLOSE_DT - p_REPORT_DT > p1.days_from_cnt and ba.CLOSE_DT - p_REPORT_DT <= p1.days_to_cnt
    and ba.CLOSE_DT - p_REPORT_DT > p2.days_from_cnt and ba.CLOSE_DT - p_REPORT_DT <= p2.days_to_cnt
    and ba.CLOSE_DT - p_REPORT_DT > p3.days_from_cnt and ba.CLOSE_DT - p_REPORT_DT <= p3.days_to_cnt
    and upper (ba.account_kind_cd) like '%ДЕПОЗИТ%'
    and er.ex_rate_dt = p_REPORT_DT
    and cr2.currency_letter_cd = 'RUB'; 


                  
                  commit;
end;
/

