CREATE OR REPLACE PROCEDURE DM."P_DM_REG_IR_GAP" (p_REPORT_DT in date, p_reg_group_key in number default 1)
IS 

BEGIN

IF p_reg_group_key = 1 then 
delete from DM_REG_IR_GAP where SNAPSHOT_DT = p_REPORT_DT;
else 
delete from DM_REG_IR_GAP where SNAPSHOT_DT = p_REPORT_DT and branch_key in (select branch_key from dwh.reg_group where reg_group_key = p_reg_group_key);
end if;

insert into DM_REG_IR_GAP (
                          SNAPSHOT_CD,
                          SNAPSHOT_DT,
                          snapshot_month,
                          snapshot_year,
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
                 
                                          
                    --расчет данных витрины IR GAP
                select
                          'Основной КИС' SNAPSHOT_CD,
                          p_REPORT_DT SNAPSHOT_DT,
                          to_char(p_REPORT_DT, 'MM') as snapshot_month,
                          to_char(p_REPORT_DT, 'YYYY') as snapshot_year,
                          a.BRANCH_KEY,
                          null ACCOUNT_KEY,
                          null CONTRACT_KEY,
                          null CLIENT_KEY,
                          null BANK_KEY,
                          MEMBER_KEY,
                          VTB_MEMBER_FLG,
                          INSTRUMENT_KEY,
                          INSTRUMENT_KIND_CD,
                          SRC_CURRENCY_KEY,
                          CIS_CURRENCY_KEY,
                          null TERM_CNT,
                          PERIOD1_TYPE_KEY,
                          null PERIOD2_TYPE_KEY,
                          null PERIOD3_TYPE_KEY,
                          SRC_AMT,
                          RUR_AMT,
                          CIS_AMT,
                          null RATE_W_AMT,
                          null TERM_W_AMT,
                          null SRC_LIQ_AMT,
                          null CIS_LIQ_AMT,
                          null SRC_MR_AMT,
                          null RUR_MR_AMT,
                          null RATE_W_MR_AMT,
                          PAY_DT,
                          EX_RATE,
                          null FLOAT_RATE_FLG,
                          null RATE_AMT,
                          null PURPOSE_DESC,
                          ART_CD,
                          777 PROCESS_KEY,
                          sysdate INSERT_DT
                    from (
                          
                          select 
                          gr.MEMBER_KEY MEMBER_KEY,
                          case when gr. MEMBER_CD is not null and GR.MEMBER_CD<>0 
                          then 'Y' else 'N' end VTB_MEMBER_FLG,
                          fct.branch_key as branch_key,
                          -- типа инструмента
                          instr.INSTRUMENT_KEY as INSTRUMENT_KEY,
                          
                          --статья
                          instr.INSTRUMENT_KIND_CD INSTRUMENT_KIND_CD,
                          cur.CURRENCY_KEY  SRC_CURRENCY_KEY,
                          --валюта КИС
                           case
                           when upper(cur.CURRENCY_LETTER_CD) in ('USD','EUR','RUB') 
                           then cur.CURRENCY_KEY
                           else (select CURRENCY_KEY
                                 from DWH.CURRENCIES 
                                 where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                 And BEGIN_DT<=p_REPORT_DT  AND END_DT>p_REPORT_DT
                                 and CURRENCY_LETTER_CD='OTH')
                           end
                          AS CIS_CURRENCY_KEY,
                           --тип периода 1
                             (select p.PERIOD_KEY
                              FROM DWH.PERIODS P, DWH.PERIOD_TYPES PT
                              where p.PERIOD_TYPE_KEY=pt.PERIOD_TYPE_KEY
                                and pt.PERIOD_TYPE_CD=1
                                and upper(p.PERIOD_EN_NAM) LIKE '%>10Y%'
                                and p.BEGIN_DT<=p_REPORT_DT       
                                and p.END_DT>p_REPORT_DT
                                and pt.BEGIN_DT<=p_REPORT_DT
                                and pt.END_DT>p_REPORT_DT
                                and p.VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                                            
                             )
                             as PERIOD1_TYPE_KEY,
                          
                          --сумма в исходной валюте, для пассивов с обратным знаком
                           case
                           when upper(instr.INSTRUMENT_KIND_CD) like '%АКТИВ%'
                           THEN fct.SOURCE_AMT 
                           ELSE (-1)*fct.SOURCE_AMT
                           END
                          AS SRC_AMT,
                          --сумма в рублях, для пассивов с обратным знаком
                           case when upper(fct.CURRENCY_LETTER_CD) in ('RUB') and upper(instr.INSTRUMENT_KIND_CD) like '%АКТИВ%'
                           then fct.SOURCE_AMT
                           when upper(fct.CURRENCY_LETTER_CD) in ('RUB') and upper(instr.INSTRUMENT_KIND_CD) like '%ПАССИВ%'
                           then (-1)*fct.SOURCE_AMT
                           when upper(fct.CURRENCY_LETTER_CD) NOT in ('RUB') and upper(instr.INSTRUMENT_KIND_CD) like '%АКТИВ%'
                           then fct.SOURCE_AMT*rate.EXCHANGE_RATE
                           when upper(fct.CURRENCY_LETTER_CD) NOT  in ('RUB') and upper(instr.INSTRUMENT_KIND_CD) like '%ПАССИВ%'
                           then (-1)*fct.SOURCE_AMT*rate.EXCHANGE_RATE
                           ELSE NULL 
                           end 
                          as RUR_AMT,
                          --валюта КИС
                          case
                           when upper(cur.CURRENCY_LETTER_CD) in ('USD','EUR','RUB') 
                           then case
                                 when upper(instr.INSTRUMENT_KIND_CD) like '%АКТИВ%'
                                 THEN fct.SOURCE_AMT 
                                 ELSE (-1)*fct.SOURCE_AMT
                                END
                            else (case when upper(fct.CURRENCY_LETTER_CD) in ('RUB') and upper(instr.INSTRUMENT_KIND_CD) like '%АКТИВ%'
                                   then fct.SOURCE_AMT
                                   when upper(fct.CURRENCY_LETTER_CD) in ('RUB') and upper(instr.INSTRUMENT_KIND_CD) like '%ПАССИВ%'
                                   then (-1)*fct.SOURCE_AMT
                                   when upper(fct.CURRENCY_LETTER_CD) NOT in ('RUB') and upper(instr.INSTRUMENT_KIND_CD) like '%АКТИВ%'
                                   then fct.SOURCE_AMT*rate.EXCHANGE_RATE
                                   when upper(fct.CURRENCY_LETTER_CD) NOT  in ('RUB') and upper(instr.INSTRUMENT_KIND_CD) like '%ПАССИВ%'
                                   then (-1)*fct.SOURCE_AMT*rate.EXCHANGE_RATE
                                   ELSE NULL 
                                   end)
                                 end
                          AS CIS_AMT,
                          p_REPORT_DT as PAY_DT,
                          nvl(rate.EXCHANGE_RATE,1) as EX_RATE,
                          instr.ART_CD as ART_CD
                          from
                          
                          --выбор данных по данным IR_GAP
                          (select INSTRUMENT_CD, OPERATION_TYPE_CD, CURRENCY_LETTER_CD, SOURCE_AMT, MEMBER_CD, branch_key from DWH.IR_GAP
                          where REPORT_PERIOD_DT =p_REPORT_DT
                          and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')) fct
                          
                          --справочник организаций для member_key
                          left join (select MEMBER_KEY, MEMBER_CD from DWH.IFRS_VTB_GROUP 
                          where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                          And BEGIN_DT<=p_REPORT_DT  AND END_DT>p_REPORT_DT) gr
                          on fct.MEMBER_CD=gr.MEMBER_CD
                          
                          --справочник типов инструментов
                          left join (select INSTRUMENT_KEY,INSTRUMENT_CD,INSTRUMENT_KIND_CD, OPERATION_TYPE_CD , INSTRUMENT_RU_NAM , ART_CD from dwh.INSTRUMENT_TYPES 
                          where  BEGIN_DT<=p_REPORT_DT and END_DT>p_REPORT_DT
                          AND UPPER(INSTRUMENT_TYPE_DESC) LIKE '%НЕПРОЦЕНТНЫЙ%') instr
                          on fct.INSTRUMENT_CD =instr.INSTRUMENT_CD 
                          
                          
                          --справочник валют для определения валюты КИС
                          left join (select CURRENCY_KEY, CURRENCY_LETTER_CD from DWH.CURRENCIES 
                          where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                          And BEGIN_DT<=p_REPORT_DT  AND END_DT>p_REPORT_DT) cur
                          on fct.CURRENCY_LETTER_CD =cur.CURRENCY_LETTER_CD 
                          
                          --курс валют
                          left join (select CURRENCY_KEY, EXCHANGE_RATE
                                     from DWH.EXCHANGE_RATES 
                                     where EX_RATE_DT=p_REPORT_DT
                                     and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                     and BASE_CURRENCY_KEY=(select CURRENCY_KEY from DWH.CURRENCIES 
                                                            where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                                            And BEGIN_DT<=p_REPORT_DT  AND END_DT>p_REPORT_DT
                                                            and CURRENCY_LETTER_CD in ('RUB'))
                                                            )
                           rate
                          on cur.CURRENCY_KEY=rate.CURRENCY_KEY
                          ) a, dwh.reg_group b
                          where nvl(a.branch_key, 0) = b.branch_key
                          and b.reg_group_key = p_reg_group_key
                          and b.begin_dt <= p_REPORT_DT
                          and b.end_dt > p_REPORT_DT;                  
                  commit;
end;
/

