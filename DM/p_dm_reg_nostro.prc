CREATE OR REPLACE PROCEDURE DM.p_DM_REG_NOSTRO (p_REPORT_DT in date, p_reg_group_key in number default 1)
IS

BEGIN

delete from DM_REG_NOSTRO where snapshot_dt = p_REPORT_DT and branch_key in (select branch_key from dwh.reg_group where reg_group_key = p_reg_group_key);

insert into DM_REG_NOSTRO (
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
                        to_char(p_REPORT_DT, 'MM') SNAPSHOT_MONTH,
                        to_char(p_REPORT_DT, 'YYYY') SNAPSHOT_YEAR,
                        a.BRANCH_KEY,
                        ACCOUNT_KEY,
                        null CONTRACT_KEY,
                        null CLIENT_KEY,
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
                        777 PROCESS_KEY,
                        sysdate INSERT_DT
                  from (
                  
                        select 
                              acc.BRANCH_KEY BRANCH_KEY,
                              fct.ACCOUNT_KEY ACCOUNT_KEY,
                              acc.BANK_KEY BANK_KEY,
                              bank.MEMBER_KEY MEMBER_KEY,
                              case
                                   when gr.MEMBER_CD is not null 
                                   and gr.MEMBER_CD<>'0' 
                                      then 'Y'
                                    else 'N'
                              end 
                              as VTB_MEMBER_FLG,
                             -- типа инструмента
                               CASE 
                               WHEN acc.RATE_AMT=0 THEN
                                                (select INSTRUMENT_KEY
                                                 from dwh.INSTRUMENT_TYPES
                                                 where Upper(INSTRUMENT_RU_NAM)  = 'СЧЕТА НОСТРО НЕПРОЦЕНТНЫЕ'
                                                 And Upper(INSTRUMENT_TYPE_DESC)='НЕПРОЦЕНТНЫЙ'
                                                 And BEGIN_DT<=p_REPORT_DT
                                                 AND END_DT>p_REPORT_DT
                                                 )
                                ELSE
 
                                                (select INSTRUMENT_KEY
                                                 from dwh.INSTRUMENT_TYPES
                                                 where Upper(INSTRUMENT_RU_NAM) ='СЧЕТА НОСТРО'
                                                 And Upper(INSTRUMENT_TYPE_DESC)='ПРОЦЕНТНЫЙ'
                                                 And BEGIN_DT<=p_REPORT_DT
                                                 and END_DT>p_REPORT_DT
                                                 ) 
                               END
                             as INSTRUMENT_KEY,
                              --статья
                              CASE 
                               WHEN acc.RATE_AMT=0 THEN
                                                (select INSTRUMENT_KIND_CD
                                                 from dwh.INSTRUMENT_TYPES
                                                 where Upper(INSTRUMENT_RU_NAM)  = 'СЧЕТА НОСТРО НЕПРОЦЕНТНЫЕ'
                                                 And Upper(INSTRUMENT_TYPE_DESC)='НЕПРОЦЕНТНЫЙ'
                                                 And BEGIN_DT<=p_REPORT_DT
                                                 AND END_DT>p_REPORT_DT
                                                 )
                                ELSE
 
                                                (select INSTRUMENT_KIND_CD
                                                 from dwh.INSTRUMENT_TYPES
                                                 where Upper(INSTRUMENT_RU_NAM) ='СЧЕТА НОСТРО'
                                                 And Upper(INSTRUMENT_TYPE_DESC)='ПРОЦЕНТНЫЙ'
                                                 And BEGIN_DT<=p_REPORT_DT
                                                 and END_DT>p_REPORT_DT
                                                 ) 
                               END
                              AS INSTRUMENT_KIND_CD,
                              fct.CURRENCY_KEY  SRC_CURRENCY_KEY,
                            
                              --валюта КИС
                              case
                                  when upper(cur.CURRENCY_LETTER_CD) in ('USD','EUR','RUB') 
                                     then fct.CURRENCY_KEY
                                  else (select CURRENCY_KEY
                                        from DWH.CURRENCIES 
                                        where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                        And BEGIN_DT<=p_REPORT_DT  and END_DT>p_REPORT_DT
                                        and CURRENCY_LETTER_CD='OTH')
                              end
                              AS CIS_CURRENCY_KEY,
                              1 AS TERM_CNT,
                            
                              --тип периода 1
                             (select p.PERIOD_KEY
                              FROM DWH.PERIODS P, DWH.PERIOD_TYPES PT
                              where p.PERIOD_TYPE_KEY=pt.PERIOD_TYPE_KEY
                                and pt.PERIOD_TYPE_CD=1
                                and lower(p.PERIOD_RU_NAM) LIKE '%1 день%'
                                and p.BEGIN_DT<=p_REPORT_DT       
                                and p.END_DT>p_REPORT_DT
                                and pt.BEGIN_DT<=p_REPORT_DT
                                and pt.END_DT>p_REPORT_DT
                                and p.VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                                            
                             )
                             as PERIOD1_TYPE_KEY,
                            
                            --тип периода 2
                             (select p.PERIOD_KEY
                              FROM DWH.PERIODS P, DWH.PERIOD_TYPES PT
                              where p.PERIOD_TYPE_KEY=pt.PERIOD_TYPE_KEY
                                and pt.PERIOD_TYPE_CD=2
                                and lower(p.PERIOD_RU_NAM) LIKE '%1 день%'
                                and p.BEGIN_DT<=p_REPORT_DT       
                                and p.END_DT>p_REPORT_DT
                                and pt.BEGIN_DT<=p_REPORT_DT
                                and pt.END_DT>p_REPORT_DT
                                and p.VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                          
                            
                             )
                            as PERIOD2_TYPE_KEY,
                            
                            --тип периода 3
                             (select p.PERIOD_KEY
                              FROM DWH.PERIODS P, DWH.PERIOD_TYPES PT
                              where p.PERIOD_TYPE_KEY=pt.PERIOD_TYPE_KEY
                                and pt.PERIOD_TYPE_CD=3
                                and lower(p.PERIOD_RU_NAM) LIKE '%до востребования%'
                                and p.BEGIN_DT<=p_REPORT_DT       
                                and p.END_DT>p_REPORT_DT
                                and pt.BEGIN_DT<=p_REPORT_DT
                                and pt.END_DT>p_REPORT_DT
                                and p.VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                              
                            
                             )
                            as PERIOD3_TYPE_KEY,
                            
                            --сумма в исходной валюте
                            fct.BALANCE_AMT SRC_AMT,
                            --сумма в рублях
                             case when upper(cur.CURRENCY_LETTER_CD) in ('RUB')
                             then fct.BALANCE_AMT
                             else
                             fct.BALANCE_AMT*rate.EXCHANGE_RATE
                             end 
                            as RUR_AMT,
                            
                            --сумма в валюте КИС
                             case
                             when upper(cur.CURRENCY_LETTER_CD) in ('USD','EUR','RUB') then fct.BALANCE_AMT
                             else fct.BALANCE_AMT*rate.EXCHANGE_RATE
                             end
                            as CIS_AMT,
                            
                            --сумма взвешенная по ставке
                             (case
                             when upper(cur.CURRENCY_LETTER_CD) in ('USD','EUR','RUB') then fct.BALANCE_AMT
                             else fct.BALANCE_AMT*rate.EXCHANGE_RATE
                             end) * nvl(acc.RATE_AMT,0)/100
                            as RATE_W_AMT,
                            
                            --сумма взвешенная по сроку
                             case
                             when upper(cur.CURRENCY_LETTER_CD) in ('USD','EUR','RUB') then fct.BALANCE_AMT
                             else fct.BALANCE_AMT*rate.EXCHANGE_RATE
                             end * 1 as  TERM_W_AMT,
                            
                            --сумма Ликвидность в исходной валюте
                            fct.BALANCE_AMT SRC_LIQ_AMT,
                            
                            --сумма Ликвидность в валюте КИС
                             case
                             when upper(cur.CURRENCY_LETTER_CD) in ('USD','EUR','RUB') then fct.BALANCE_AMT
                             else fct.BALANCE_AMT*rate.EXCHANGE_RATE
                             end
                            as CIS_LIQ_AMT,
                            
                            --сумма MR в исходной валюте
                            fct.BALANCE_AMT SRC_MR_AMT,
                            --сумма MR в рублях
                             case when upper(cur.CURRENCY_LETTER_CD) in ('RUB')
                             then fct.BALANCE_AMT
                             else
                             fct.BALANCE_AMT*rate.EXCHANGE_RATE
                             end 
                            as RUR_MR_AMT,
                            
                            --сумма MR взвешенная
                             (case when upper(cur.CURRENCY_LETTER_CD) in ('RUB')
                             then fct.BALANCE_AMT
                             else
                             fct.BALANCE_AMT*rate.EXCHANGE_RATE
                             end) * nvl(acc.RATE_AMT,0)/100
                            as RATE_W_MR_AMT,
                            p_REPORT_DT as PAY_DT,
                            case when upper(cur.CURRENCY_LETTER_CD) in ('RUB') then 1 else rate.EXCHANGE_RATE end as EX_RATE,
                            acc.FLOATING_RATE_FLG as FLOAT_RATE_FLG,
                            nvl(acc.RATE_AMT,0)/100 as RATE_AMT ,
                            (select PURPOSE_DESC
                            from dwh.OPERATION_PURPOSES
                            where Upper(INSTRUMENT_RU_NAM) ='СЧЕТА НОСТРО'
                            And Upper(INSTRUMENT_SOURCE_NAM)LIKE '%НОСТРО%'
                            And BEGIN_DT<=p_REPORT_DT
                            AND END_DT>p_REPORT_DT)
                            as PURPOSE_DESC, 
                              CASE 
                               WHEN acc.RATE_AMT=0 THEN
                                                (select ART_CD
                                                 from dwh.INSTRUMENT_TYPES
                                                 where Upper(INSTRUMENT_RU_NAM)  = 'СЧЕТА НОСТРО НЕПРОЦЕНТНЫЕ'
                                                 And Upper(INSTRUMENT_TYPE_DESC)='НЕПРОЦЕНТНЫЙ'
                                                 And BEGIN_DT<=p_REPORT_DT
                                                 AND END_DT>p_REPORT_DT
                                                 )
                                ELSE
 
                                                (select ART_CD
                                                 from dwh.INSTRUMENT_TYPES
                                                 where Upper(INSTRUMENT_RU_NAM) ='СЧЕТА НОСТРО'
                                                 And Upper(INSTRUMENT_TYPE_DESC)='ПРОЦЕНТНЫЙ'
                                                 And BEGIN_DT<=p_REPORT_DT
                                                 and END_DT>p_REPORT_DT
                                                 ) 
                               END                                                   
                             as ART_CD
                            
                            from
                            
                            --выбор данных по остаткам на счетах НОСТРО
                            (select ACCOUNT_KEY,CURRENCY_KEY,BALANCE_AMT from dwh.FACT_ACCOUNT_BALANCE 
                            where BALANCE_DT=p_REPORT_DT
                            and BALANCE_AMT<>0
                            -- and SNAPSHOT_CD='Отчетность' aapolyakov30.09: Убираем фильтр, поскольку из xls данное поле не грузится
                            and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')) fct
                            
                            --выбор по расчетным счетам из справочника Банковских счетов
                            join (select ACCOUNT_KEY,BANK_KEY,BRANCH_KEY,CURRENCY_KEY,FLOATING_RATE_FLG,RATE_AMT from dwh.BANK_ACCOUNTS
                            where upper(ACCOUNT_KIND_CD) like '%РАСЧЕТНЫЙ%'
                            and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')) acc
                            on fct.ACCOUNT_KEY=acc.ACCOUNT_KEY
                            
                            --справочник банков для определения группы ВТБ member_key
                            left join (select BANK_KEY,MEMBER_KEY from dwh.BANKS
                            where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')) bank
                            on acc.BANK_KEY=bank.BANK_KEY
                            
                            --справочник групп для определения флага группы
                            left join (select MEMBER_KEY, MEMBER_CD from DWH.IFRS_VTB_GROUP 
                            where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                            And BEGIN_DT<=p_REPORT_DT  and END_DT>p_REPORT_DT) gr
                            on bank.MEMBER_KEY=gr.MEMBER_KEY
                            
                            --справочник валют для определения валюты КИС
                            left join (select CURRENCY_KEY, CURRENCY_LETTER_CD from DWH.CURRENCIES 
                            where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                            And BEGIN_DT<=p_REPORT_DT  and END_DT>p_REPORT_DT) cur
                            on fct.CURRENCY_KEY=cur.CURRENCY_KEY
                            
                            --курс валют
                            left join (select CURRENCY_KEY, EXCHANGE_RATE
                                       from DWH.EXCHANGE_RATES 
                                       where EX_RATE_DT=p_REPORT_DT
                                       and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                       and BASE_CURRENCY_KEY=(select CURRENCY_KEY from DWH.CURRENCIES 
                                                              where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                                              And BEGIN_DT<=p_REPORT_DT  and END_DT>p_REPORT_DT
                                                              and CURRENCY_LETTER_CD in ('RUB'))
                                                              )
                         rate
                  on fct.CURRENCY_KEY=rate.CURRENCY_KEY
                  ) a, dwh.reg_group b
                          where a.branch_key = b.branch_key (+)
                          and b.reg_group_key (+) = p_reg_group_key
                          and b.begin_dt (+) <= p_REPORT_DT
                          and b.end_dt (+) > p_REPORT_DT 
                          and (p_reg_group_key = 1 or b.reg_group_key is not null);
                  commit;
end;
/

