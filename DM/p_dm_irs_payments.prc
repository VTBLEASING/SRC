CREATE OR REPLACE PROCEDURE DM.P_DM_IRS_PAYMENTS (p_REPORT_DT in date)
IS

BEGIN

delete from DM_IRS_PAYMENTS where SNAPSHOT_DT = p_REPORT_DT;

insert into DM_IRS_PAYMENTS (
                          CONTRACT_KEY,
                          SNAPSHOT_DT,
                          PAYMENT_NUM,
                          PAY_PERIOD_BEGIN_DT,
                          PAY_PERIOD_END_DT,
                          PERIOD_TERM_CNT,
                          CALC_BASE_AMT,
                          MAIN_DEBT_AMT,
                          AMORT_AMT,
                          FIX_RATE,
                          PAYMENT_FIX_AMT,
                          FLOAT_RATE,
                          PAYMENT_FLOAT_AMT,
                          RESULT_AMT,
                          EX_RATE,
                          REVAL_RUR_AMT,
                          VALID_FROM_DTTM,
                          VALID_TO_DTTM,
                          PROCESS_KEY) 
                 
                --расчет витрины DM_IRS_PAYMENTS
                          SELECT
                          CONTRACT_KEY,
                          p_REPORT_DT SNAPSHOT_DT,
                          PAYMENT_NUM,
                          PAY_PERIOD_BEGIN_DT,
                          PAY_PERIOD_END_DT,
                          PERIOD_TERM_CNT,
                          CALC_BASE_AMT,
                          MAIN_DEBT_AMT,
                          AMORT_AMT,
                          FIX_RATE,
                          PAYMENT_FIX_AMT,
                          FLOAT_RATE,
                          PAYMENT_FLOAT_AMT,
                          RESULT_AMT,
                          EX_RATE,
                          REVAL_RUR_AMT,
                          TO_DATE('01.01.1900','DD.MM.YYYY') VALID_FROM_DTTM,
                          TO_DATE('01.01.2400','DD.MM.YYYY')VALID_TO_DTTM,
                          777 PROCESS_KEY
                          FROM 
                          (
                          
                          select
                          fct.CONTRACT_KEY,
                          fct.REPORT_DT as REPORT_DT,
                          NULL as PAYMENT_NUM,
                          fct.PAY_PERIOD_BEGIN_DT as PAY_PERIOD_BEGIN_DT,
                          fct.PAY_PERIOD_END_DT as PAY_PERIOD_END_DT,
                          (fct.PAY_PERIOD_END_DT-fct.PAY_PERIOD_BEGIN_DT) as PERIOD_TERM_CNT,
                          fct.CALC_BASE_AMT as CALC_BASE_AMT,
                          fct.MAIN_DEBT_AMT as MAIN_DEBT_AMT,
                          fct.AMORT_AMT as AMORT_AMT,
                          fct.FIX_RATE as FIX_RATE,
                          
                          --сумма платежа по fix ставке
                          fct.MAIN_DEBT_AMT* fct.FIX_RATE * (fct.PAY_PERIOD_END_DT-fct.PAY_PERIOD_BEGIN_DT) / fct. CALC_BASE_AMT/100
                          as
                          PAYMENT_FIX_AMT,
                          
                          fct.FLOAT_RATE as FLOAT_RATE,
                          
                          --сумма платежа по float ставке
                          fct.MAIN_DEBT_AMT* fct.FLOAT_RATE * (fct.PAY_PERIOD_END_DT-fct.PAY_PERIOD_BEGIN_DT) / fct. CALC_BASE_AMT/100
                          as PAYMENT_FLOAT_AMT,
                          --результирующая сумма
                          (fct.MAIN_DEBT_AMT* fct.FLOAT_RATE * (fct.PAY_PERIOD_END_DT-fct.PAY_PERIOD_BEGIN_DT) / fct. CALC_BASE_AMT/100)-
                          (fct.MAIN_DEBT_AMT* fct.FIX_RATE * (fct.PAY_PERIOD_END_DT-fct.PAY_PERIOD_BEGIN_DT) / fct. CALC_BASE_AMT/100)
                          as RESULT_AMT,
                          
                          RATE.EXCHANGE_RATE as EX_RATE,
                          --переоценка в рублях
                          ((fct.MAIN_DEBT_AMT* fct.FLOAT_RATE * (fct.PAY_PERIOD_END_DT-fct.PAY_PERIOD_BEGIN_DT) / fct. CALC_BASE_AMT/100)-
                          (fct.MAIN_DEBT_AMT* fct.FIX_RATE * (fct.PAY_PERIOD_END_DT-fct.PAY_PERIOD_BEGIN_DT) / fct. CALC_BASE_AMT/100))
                          * RATE.EXCHANGE_RATE
                          as REVAL_RUR_AMT
                          
                          from
                          --финансовый поток IRS
                          (select REPORT_DT,CONTRACT_KEY,PAY_PERIOD_BEGIN_DT,PAY_PERIOD_END_DT,MAIN_DEBT_AMT,AMORT_AMT,FLOAT_RATE,FIX_RATE,CALC_BASE_AMT
                           from	dwh.FACT_IRS_PAYMENTS
                           where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                           and REPORT_DT=p_REPORT_DT
                           ) fct
                           
                          left join
                          --справочник договоров IRS
                          (select CONTRACT_KEY, CONTRACT_CD,CURRENCY_KEY, BEGIN_DT, END_DT
                           from dwh.IRS_CONTRACTS
                           where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                           --where END_DT>p_REPORT_DT
                           ) dim
                          on (FCT.CONTRACT_KEY=DIM.CONTRACT_KEY
                          )
                                                    
                          --справочник курсов валют
                          left join (select CURRENCY_KEY, EXCHANGE_RATE,EX_RATE_DT
                                     from DWH.EXCHANGE_RATES 
                                     where BASE_CURRENCY_KEY=(select CURRENCY_KEY from DWH.CURRENCIES 
                                                            where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                                            and CURRENCY_LETTER_CD in ('RUB'))
                                     and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy') 
                                    -- and EX_RATE_DT<=p_REPORT_DT+1
                                     )
                           rate
                          on dim.CURRENCY_KEY=rate.CURRENCY_KEY
                          and fct.PAY_PERIOD_END_DT=RATE.EX_RATE_DT
                          )
                          ;
                  commit;
end;
/

