CREATE OR REPLACE PROCEDURE DM.P_DM_REG_OTHER (p_REPORT_DT in date)
IS


BEGIN

    delete from dm.DM_REG_OTHER where snapshot_dt = p_REPORT_DT;
  dm.u_log(p_proc => 'dm.DM_REG_OTHER',
           p_step => 'delete from dm.DM_REG_OTHER',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');     
    insert into dm.DM_REG_OTHER( 
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
                  PAY_DT,EX_RATE,
                  FLOAT_RATE_FLG,
                  RATE_AMT,
                  PURPOSE_DESC,
                  ART_CD,
                  PROCESS_KEY,
                  INSERT_DT
                )
            -- актив
 with all_dm as (
          select SNAPSHOT_CD,
                 INSERT_DT,
                 PROCESS_KEY,
                 ART_CD,
                 PURPOSE_DESC,
                 RATE_AMT,
                 FLOAT_RATE_FLG,
                 EX_RATE,
                 PAY_DT,
                 RATE_W_MR_AMT,
                 RUR_MR_AMT,
                 SRC_MR_AMT,
                 CIS_LIQ_AMT,
                 SRC_LIQ_AMT,
                 TERM_W_AMT,
                 RATE_W_AMT,
                 CIS_AMT,
                 RUR_AMT,
                 SRC_AMT,
                 PERIOD3_TYPE_KEY,
                 PERIOD2_TYPE_KEY,
                 PERIOD1_TYPE_KEY,
                 TERM_CNT,
                 CIS_CURRENCY_KEY,
                 SRC_CURRENCY_KEY,
                 INSTRUMENT_KIND_CD,
                 INSTRUMENT_KEY,
                 VTB_MEMBER_FLG,
                 MEMBER_KEY,
                 BANK_KEY,
                 CLIENT_KEY,
                 CONTRACT_KEY,
                 ACСOUNT_KEY,
                 BRANCH_KEY,
                 SNAPSHOT_YEAR,
                 SNAPSHOT_MONTH,
                 SNAPSHOT_DT 
         from 
                 DM.DM_REG_BOND 
           where snapshot_dt = p_REPORT_DT
         UNION ALL
         
         select SNAPSHOT_CD,INSERT_DT,PROCESS_KEY,ART_CD,PURPOSE_DESC,RATE_AMT,FLOAT_RATE_FLG,EX_RATE,PAY_DT,RATE_W_MR_AMT,RUR_MR_AMT,SRC_MR_AMT,CIS_LIQ_AMT,SRC_LIQ_AMT,TERM_W_AMT,RATE_W_AMT,
                CIS_AMT,RUR_AMT,SRC_AMT,PERIOD3_TYPE_KEY,PERIOD2_TYPE_KEY,PERIOD1_TYPE_KEY,TERM_CNT,CIS_CURRENCY_KEY,SRC_CURRENCY_KEY,INSTRUMENT_KIND_CD,INSTRUMENT_KEY,VTB_MEMBER_FLG,MEMBER_KEY,
                BANK_KEY,CLIENT_KEY,CONTRACT_KEY,ACСOUNT_KEY,BRANCH_KEY,SNAPSHOT_YEAR,SNAPSHOT_MONTH,SNAPSHOT_DT 
         from 
                DM.DM_REG_CGP 
          where snapshot_dt = p_REPORT_DT
               
         UNION ALL
       
         select SNAPSHOT_CD,INSERT_DT,PROCESS_KEY,ART_CD,PURPOSE_DESC,RATE_AMT,FLOAT_RATE_FLG,EX_RATE,PAY_DT,RATE_W_MR_AMT,RUR_MR_AMT,SRC_MR_AMT,CIS_LIQ_AMT,SRC_LIQ_AMT,TERM_W_AMT,RATE_W_AMT,
                CIS_AMT,RUR_AMT,SRC_AMT,PERIOD3_TYPE_KEY,PERIOD2_TYPE_KEY,PERIOD1_TYPE_KEY,TERM_CNT,CIS_CURRENCY_KEY,SRC_CURRENCY_KEY,INSTRUMENT_KIND_CD,INSTRUMENT_KEY,VTB_MEMBER_FLG,MEMBER_KEY,
                BANK_KEY,CLIENT_KEY,CONTRACT_KEY,ACСOUNT_KEY,BRANCH_KEY,SNAPSHOT_YEAR,SNAPSHOT_MONTH,SNAPSHOT_DT 
         from 
                DM.DM_REG_DEPOSIT 
          where snapshot_dt = p_REPORT_DT
          
         UNION ALL
       
         select SNAPSHOT_CD,INSERT_DT,PROCESS_KEY,ART_CD,PURPOSE_DESC,RATE_AMT,FLOAT_RATE_FLG,EX_RATE,PAY_DT,RATE_W_MR_AMT,RUR_MR_AMT,SRC_MR_AMT,CIS_LIQ_AMT,SRC_LIQ_AMT,TERM_W_AMT,RATE_W_AMT,
                CIS_AMT,RUR_AMT,SRC_AMT,PERIOD3_TYPE_KEY,PERIOD2_TYPE_KEY,PERIOD1_TYPE_KEY,TERM_CNT,CIS_CURRENCY_KEY,SRC_CURRENCY_KEY,INSTRUMENT_KIND_CD,INSTRUMENT_KEY,VTB_MEMBER_FLG,MEMBER_KEY,
                BANK_KEY,CLIENT_KEY,CONTRACT_KEY,ACСOUNT_KEY,BRANCH_KEY,SNAPSHOT_YEAR,SNAPSHOT_MONTH,SNAPSHOT_DT 
         from 
                DM.DM_REG_MISC 
          where snapshot_dt = p_REPORT_DT
               
         UNION ALL
      
         select SNAPSHOT_CD,INSERT_DT,PROCESS_KEY,ART_CD,PURPOSE_DESC,RATE_AMT,FLOAT_RATE_FLG,EX_RATE,PAY_DT,RATE_W_MR_AMT,RUR_MR_AMT,SRC_MR_AMT,CIS_LIQ_AMT,SRC_LIQ_AMT,TERM_W_AMT,RATE_W_AMT,
                CIS_AMT,RUR_AMT,SRC_AMT,PERIOD3_TYPE_KEY,PERIOD2_TYPE_KEY,PERIOD1_TYPE_KEY,TERM_CNT,CIS_CURRENCY_KEY,SRC_CURRENCY_KEY,INSTRUMENT_KIND_CD,INSTRUMENT_KEY,VTB_MEMBER_FLG,MEMBER_KEY,
                BANK_KEY,CLIENT_KEY,CONTRACT_KEY,ACСOUNT_KEY,BRANCH_KEY,SNAPSHOT_YEAR,SNAPSHOT_MONTH,SNAPSHOT_DT 
         from 
                DM.DM_REG_IRS 
          where snapshot_dt = p_REPORT_DT
          
         UNION ALL
          
         select SNAPSHOT_CD,INSERT_DT,PROCESS_KEY,ART_CD,PURPOSE_DESC,RATE_AMT,FLOAT_RATE_FLG,EX_RATE,PAY_DT,RATE_W_MR_AMT,RUR_MR_AMT,SRC_MR_AMT,CIS_LIQ_AMT,SRC_LIQ_AMT,TERM_W_AMT,RATE_W_AMT,
                CIS_AMT,RUR_AMT,SRC_AMT,PERIOD3_TYPE_KEY,PERIOD2_TYPE_KEY,PERIOD1_TYPE_KEY,TERM_CNT,CIS_CURRENCY_KEY,SRC_CURRENCY_KEY,INSTRUMENT_KIND_CD,INSTRUMENT_KEY,VTB_MEMBER_FLG,MEMBER_KEY,
                BANK_KEY,CLIENT_KEY,CONTRACT_KEY,ACСOUNT_KEY,BRANCH_KEY,SNAPSHOT_YEAR,SNAPSHOT_MONTH,SNAPSHOT_DT 
        from 
                DM.DM_REG_IR_GAP 
         where snapshot_dt = p_REPORT_DT /*and instrument_key not in (select instrument_key from dwh.instrument_types 
                                                                  where instrument_ru_nam = 'Прочие непроцентные активы' 
                                                                  and begin_dt < p_REPORT_DT 
                                                                  and end_dt >= p_REPORT_DT)*/

        UNION ALL
          -- выбираем Прочие непроцентные активы со знаком минус для корректного заполнения DM_REG_OTHER
         /*select SNAPSHOT_CD,INSERT_DT,PROCESS_KEY,ART_CD,PURPOSE_DESC,RATE_AMT,FLOAT_RATE_FLG,EX_RATE,PAY_DT,RATE_W_MR_AMT,RUR_MR_AMT,SRC_MR_AMT,CIS_LIQ_AMT,SRC_LIQ_AMT,TERM_W_AMT,RATE_W_AMT,
                CIS_AMT,-RUR_AMT,SRC_AMT,PERIOD3_TYPE_KEY,PERIOD2_TYPE_KEY,PERIOD1_TYPE_KEY,TERM_CNT,CIS_CURRENCY_KEY,SRC_CURRENCY_KEY,INSTRUMENT_KIND_CD,INSTRUMENT_KEY,VTB_MEMBER_FLG,MEMBER_KEY,
                BANK_KEY,CLIENT_KEY,CONTRACT_KEY,ACСOUNT_KEY,BRANCH_KEY,SNAPSHOT_YEAR,SNAPSHOT_MONTH,SNAPSHOT_DT 
        from 
                DM.DM_REG_IR_GAP 
         where snapshot_dt = p_REPORT_DT and instrument_key in (select instrument_key from dwh.instrument_types 
                                                                  where instrument_ru_nam = 'Прочие непроцентные активы' 
                                                                  and begin_dt < p_REPORT_DT 
                                                                  and end_dt >= p_REPORT_DT)                                                                
         
         UNION ALL*/  
         
         select SNAPSHOT_CD,INSERT_DT,PROCESS_KEY,ART_CD,PURPOSE_DESC,RATE_AMT,FLOAT_RATE_FLG,EX_RATE,PAY_DT,RATE_W_MR_AMT,RUR_MR_AMT,SRC_MR_AMT,CIS_LIQ_AMT,SRC_LIQ_AMT,TERM_W_AMT,RATE_W_AMT,
                CIS_AMT,RUR_AMT,SRC_AMT,PERIOD3_TYPE_KEY,PERIOD2_TYPE_KEY,PERIOD1_TYPE_KEY,TERM_CNT,CIS_CURRENCY_KEY,SRC_CURRENCY_KEY,INSTRUMENT_KIND_CD,INSTRUMENT_KEY,VTB_MEMBER_FLG,MEMBER_KEY,
                BANK_KEY,CLIENT_KEY,CONTRACT_KEY,ACСOUNT_KEY,BRANCH_KEY,SNAPSHOT_YEAR,SNAPSHOT_MONTH,SNAPSHOT_DT 
         from 
                DM.DM_REG_KS 
          where snapshot_dt = p_REPORT_DT
       
         UNION ALL
       
         select SNAPSHOT_CD,INSERT_DT,PROCESS_KEY,ART_CD,PURPOSE_DESC,RATE_AMT,FLOAT_RATE_FLG,EX_RATE,PAY_DT,RATE_W_MR_AMT,RUR_MR_AMT,SRC_MR_AMT,CIS_LIQ_AMT,SRC_LIQ_AMT,TERM_W_AMT,RATE_W_AMT,
                CIS_AMT,RUR_AMT,SRC_AMT,PERIOD3_TYPE_KEY,PERIOD2_TYPE_KEY,PERIOD1_TYPE_KEY,TERM_CNT,CIS_CURRENCY_KEY,SRC_CURRENCY_KEY,INSTRUMENT_KIND_CD,INSTRUMENT_KEY,VTB_MEMBER_FLG,MEMBER_KEY,
                BANK_KEY,CLIENT_KEY,CONTRACT_KEY,ACСOUNT_KEY,BRANCH_KEY,SNAPSHOT_YEAR,SNAPSHOT_MONTH,SNAPSHOT_DT 
         from 
                DM.DM_REG_NOSTRO 
          where snapshot_dt = p_REPORT_DT
       
         UNION ALL
       
         select SNAPSHOT_CD,INSERT_DT,PROCESS_KEY,ART_CD,PURPOSE_DESC,RATE_AMT,FLOAT_RATE_FLG,EX_RATE,PAY_DT,RATE_W_MR_AMT,RUR_MR_AMT,SRC_MR_AMT,CIS_LIQ_AMT,SRC_LIQ_AMT,TERM_W_AMT,RATE_W_AMT,
                CIS_AMT,RUR_AMT,SRC_AMT,PERIOD3_TYPE_KEY,PERIOD2_TYPE_KEY,PERIOD1_TYPE_KEY,TERM_CNT,CIS_CURRENCY_KEY,SRC_CURRENCY_KEY,INSTRUMENT_KIND_CD,INSTRUMENT_KEY,VTB_MEMBER_FLG,MEMBER_KEY,
                BANK_KEY,CLIENT_KEY,CONTRACT_KEY,ACСOUNT_KEY,BRANCH_KEY,SNAPSHOT_YEAR,SNAPSHOT_MONTH,SNAPSHOT_DT 
         from 
                DM.DM_REG_OWNBILL 
         where snapshot_dt = p_REPORT_DT
       
         UNION ALL
       
         select SNAPSHOT_CD,INSERT_DT,PROCESS_KEY,ART_CD,PURPOSE_DESC,RATE_AMT,FLOAT_RATE_FLG,EX_RATE,PAY_DT,RATE_W_MR_AMT,RUR_MR_AMT,SRC_MR_AMT,CIS_LIQ_AMT,SRC_LIQ_AMT,TERM_W_AMT,RATE_W_AMT,
                CIS_AMT,RUR_AMT,SRC_AMT,PERIOD3_TYPE_KEY,PERIOD2_TYPE_KEY,PERIOD1_TYPE_KEY,TERM_CNT,CIS_CURRENCY_KEY,SRC_CURRENCY_KEY,INSTRUMENT_KIND_CD,INSTRUMENT_KEY,VTB_MEMBER_FLG,MEMBER_KEY,
                BANK_KEY,CLIENT_KEY,CONTRACT_KEY,ACСOUNT_KEY,BRANCH_KEY,SNAPSHOT_YEAR,SNAPSHOT_MONTH,SNAPSHOT_DT 
         from 
                DM.DM_REG_REPAYMENT_SCHEDULE 
          where snapshot_dt = p_REPORT_DT and instrument_key is not null
       
         UNION ALL
       
         select SNAPSHOT_CD,INSERT_DT,PROCESS_KEY,ART_CD,PURPOSE_DESC,RATE_AMT,FLOAT_RATE_FLG,EX_RATE,PAY_DT,RATE_W_MR_AMT,RUR_MR_AMT,SRC_MR_AMT,CIS_LIQ_AMT,SRC_LIQ_AMT,TERM_W_AMT,RATE_W_AMT,
                CIS_AMT,RUR_AMT,SRC_AMT,PERIOD3_TYPE_KEY,PERIOD2_TYPE_KEY,PERIOD1_TYPE_KEY,TERM_CNT,CIS_CURRENCY_KEY,SRC_CURRENCY_KEY,INSTRUMENT_KIND_CD,INSTRUMENT_KEY,VTB_MEMBER_FLG,MEMBER_KEY,
                BANK_KEY,CLIENT_KEY,CONTRACT_KEY,ACСOUNT_KEY,BRANCH_KEY,SNAPSHOT_YEAR,SNAPSHOT_MONTH,SNAPSHOT_DT 
         from 
                DM.DM_REG_SWAP 
          where snapshot_dt = p_REPORT_DT
         
         -- [apolyakov 24.08.2016]: добавление расчета РЕПО  
          UNION ALL
       
         select SNAPSHOT_CD,INSERT_DT,PROCESS_KEY,ART_CD,PURPOSE_DESC,RATE_AMT,FLOAT_RATE_FLG,EX_RATE,PAY_DT,RATE_W_MR_AMT,RUR_MR_AMT,SRC_MR_AMT,CIS_LIQ_AMT,SRC_LIQ_AMT,TERM_W_AMT,RATE_W_AMT,
                CIS_AMT,RUR_AMT,SRC_AMT,PERIOD3_TYPE_KEY,PERIOD2_TYPE_KEY,PERIOD1_TYPE_KEY,TERM_CNT,CIS_CURRENCY_KEY,SRC_CURRENCY_KEY,INSTRUMENT_KIND_CD,INSTRUMENT_KEY,VTB_MEMBER_FLG,MEMBER_KEY,
                BANK_KEY,CLIENT_KEY,CONTRACT_KEY,ACСOUNT_KEY,BRANCH_KEY,SNAPSHOT_YEAR,SNAPSHOT_MONTH,SNAPSHOT_DT 
         from 
                DM.DM_REG_REPO
          where snapshot_dt = p_REPORT_DT)
       
        select 
                'Основной КИС' as snapshot_cd,
                p_REPORT_DT as snapshot_dt,
                to_char(p_REPORT_DT, 'MM') as snapshot_month,
                to_char(p_REPORT_DT, 'YYYY') as snapshot_year,
                (select branch_key
                                     from dwh.org_structure
                                     where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy') and branch_cd='VTB_LEASING'
                                     ) as branch_key,
                null as account_key,
                null as contract_key,
                null as client_key,
                null as bank_key,
                (
                    select member_key 
                    from dwh.IFRS_VTB_GROUP 
                    where member_cd = 32 
                      and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') 
                      and begin_dt <= p_REPORT_DT 
                      and end_dt > p_REPORT_DT
                ) as member_key,
                null as vtb_member_flg,
                (
                    select instrument_key 
                    from dwh.INSTRUMENT_TYPES 
                    where instrument_ru_nam = 'Прочие непроцентные активы' 
                    and begin_dt <= p_REPORT_DT 
                    and end_dt > p_REPORT_DT
                ) as instrument_key,
                (
                    select instrument_kind_cd 
                    from dwh.INSTRUMENT_TYPES 
                    where instrument_ru_nam = 'Прочие непроцентные активы' 
                    and begin_dt <= p_REPORT_DT 
                    and end_dt > p_REPORT_DT
                ) as instrument_kind_cd,
                (select currency_key 
                  from dwh.currencies where currency_letter_cd = 'RUB' and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') 
                  and begin_dt <= p_REPORT_DT and end_dt > p_REPORT_DT) as src_currency_key,
                (select currency_key 
                  from dwh.currencies where currency_letter_cd = 'RUB' and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') 
                  and begin_dt <= p_REPORT_DT and end_dt > p_REPORT_DT) as cis_currency_key,
                null as term_cnt,
                (select period_key from dwh.periods where period_type_key =
                  (select period_type_key from dwh.period_types where period_type_cd = 1 
                    and begin_dt <= p_REPORT_DT 
                    and end_dt > p_REPORT_DT)
                  and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                  and begin_dt <= p_REPORT_DT 
                  and end_dt > p_REPORT_DT
                  and days_to_cnt > 3800) as period1_type_key,
                null as period2_type_key,
                null as period3_type_key,
                -sum(all_dm.rur_amt) as src_amt,
                -sum(all_dm.rur_amt) as rur_amt,
                -sum(all_dm.rur_amt) as cis_amt,
                null as rate_w_amt,
                null as term_w_amt,
                null as src_liq_amt,
                null as cis_liq_amt,
                null as src_mr_amt,
                null as rur_mr_amt,
                null as rate_w_mr_amt,
                p_REPORT_DT as pay_dt,
                1 as ex_rate,
                null as float_rate_flg,
                0 as rate_amt,
                null as purpose_desc,
                null as art_cd,
                777 as process_key,
                sysdate as insert_date
           from all_dm
           group by 1;

   dm.u_log(p_proc => 'DM.P_DM_REG_OTHER',
           p_step => 'insert into dm.DM_REG_OTHER',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted'); 
--commit;
end;
/

