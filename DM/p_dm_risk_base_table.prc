CREATE OR REPLACE PROCEDURE DM.P_DM_RISK_BASE_TABLE (p_REPORT_DT in date, p_SNAPSHOT_CD in varchar2)
IS

BEGIN

  /* Процедура расчета витрины DM_RISK_BASE_TABLE полностью.
     В качестве входного параметра подается дата составления отчета 
  */
    dm.u_log(p_proc => 'DM.P_DM_RISK_BASE_TABLE',
           p_step => 'INPUT PARAMS',
           p_info => /*'p_group_key:'||p_group_key||*/'p_REPORT_DT:'||p_REPORT_DT||'p_snapshot_cd:'||p_snapshot_cd); 

delete from dm.DM_RISK_BASE_TABLE where SNAPSHOT_DT = p_REPORT_DT and SNAPSHOT_CD = p_SNAPSHOT_CD;
  dm.u_log(p_proc => 'dm.DM_RISK_BASE_TABLE',
           p_step => 'delete from dm.DM_RISK_BASE_TABLE',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');  
insert into dm.DM_RISK_BASE_TABLE (SNAPSHOT_DT,
                                SNAPSHOT_CD,
                                CONTRACT_KEY,
                                CURRENCY_KEY,
                                CLIENT_NAM,
                                CONTRACT_ID_CD,
                                CONTRACT_NUM,
                                AUTO_FLG,
                                OPER_START,
                                END_DT,
                                CLIENT_ID,
                                CRM_CODE,
                                GROUP_ID,
                                GROUP_RU_NAM,
                                CREDIT_RATING_CD,
                                RATE_LOCAL_MODEL,
                                RATING_AGENCY_EN_NAM,
                                REG_COUNTRY_CD,
                                REG_COUNTRY_NAM,
                                ACTIVITY_TYPE_CD,
                                ACTIVITY_TYPE_RU_DESC,
                                SME_FLG,
                                BUSINESS_CAT_RU_NAM,
                                RISK_COUN_CD,
                                RISK_COUNTRY_NAM,
                                STATUS,
                                XIRR_RATE,
                                CURRENCY_CD,
                                CURRENCY_LETTER_CD,
                                TERM_AMT,
                                TERM_RUR,
                                OVERDUE_AMT,
                                OVD_RUR,
                                TOT_AMT,
                                TOT_RUR_AMT,
                                OVERDUE_DT,
                                OVD_DAYS,
                                GROUP_OR_CLIENT,
                                MIR_CODE,
                                MAX_OVD_DAYS,
                                OVERDUE_NOVAT_AMT,
                                TOT_NOVAT_AMT,
                                OVD_NOVAT_RUR,
                                TOT_NOVAT_RUR_AMT,
                                SCORE_POINTS_CNT,
                                SP_RAT_CD,
                                PD_EC,
                                CAR_DEFAULT_FLG,
                                SP_RAT,
                                PD,
                                SP_RATING,
                                CLIENT_PD,
                                LEASING_SUBJECT_DESC,
                                LEASING_SUBJECT_TYPE_RES,
                                LEASING_SUBJECT_TYPE_EC,
                                LEASING_SUBJECT_TYPE_COMPARE,
                                COUNT_RAT,
                                PD_COUNT,
                                PD_RESULT,
                                LGD_COL,
                                LGD_EC,
                                AGG_LIST_CROUP_CD,
                                VAT_RATE,
                                LIP,
                                PD_LGD_LIP,
                                PZ_PPZ,
                                IND_COL_ASD,
                                DEAL_TYPE,
                                ASSESSMENT_FLG,
                                IPO_FLG_FILE,
                                SCENARIO_IPO_FLG,
                                RATE,
                                PROVISIONS_AMT_VAL,
                                PROVISIONS_AMT_RUB,
                                R,
                                CORR_R,
                                PROF_AMT,
                                B_NSBU,
                                M,
                                EAD,
                                insert_dt)                        
                   
   WITH tt
        AS (SELECT /*+ materialize */
                  *
              FROM dwh.CONTRACTS c
             WHERE     c.contract_kind_key in 
                                  (
                                    select contract_kind_key
                                    from dwh.contract_kinds
                                    where contract_kind_en_nam = 'Leasing'
                                  )
                   AND NVL (c.rehiring_flg, '0') = '0'
                   AND c.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
            ),
    RATINGS_EC 
    AS (SELECT DISTINCT
            CL.CLIENT_KEY,
            CL.SHORT_CLIENT_RU_NAM,
            BCAT.BUSINESS_CAT_RU_NAM,
            RA.RATING_AGENCY_EN_NAM RA_RATING_AGENCY_EN_NAM,
            CR.CREDIT_RATING CR_CREDIT_RATING,
            RACR_EC.RATING_AGENCY_EN_NAM RACR_EC_RATING_AGENCY_RU_NAM,
            CRCR_EC.CREDIT_RATING CRCR_EC_CREDIT_RATING,
            RCR_EC.BEGIN_DT RCR_EC_BEGIN_DT,
            RCR_EC.END_DT RCR_EC_END_DT,
            nvl (RCR_EC.rating_agency_key, ra.rating_agency_key) as agency_key_EC,
            case
                  when min (nvl (lc.auto_flg, 0)) over (partition by cl.client_key) = 1
                   and NVL (RACR_EC.rating_agency_en_nam, ra.rating_agency_en_nam) = 'No rating'
                      then 'Автолизинг'
                  else
                      case
                          when NVL (RACR_EC.rating_agency_en_nam, ra.rating_agency_en_nam) = 'No rating'
                           and bcat.business_cat_en_nam in ('Small', 'Medium')
                               then 
                                    (select credit_rating
                                     from dwh.credit_ratings
                                     where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                                     and sysdate between BEGIN_DT and END_DT
                                     and credit_rating_cd = '9999'
                                     )
                          when NVL (RACR_EC.rating_agency_en_nam, ra.rating_agency_en_nam) = 'No rating'
                           and bcat.business_cat_en_nam in ('Large')
                               then 
                                    (select credit_rating
                                     from dwh.credit_ratings
                                     where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                                     and sysdate between BEGIN_DT and END_DT
                                     and credit_rating_cd = '8888'
                                     )
                      else NVL (CRCR_EC.CREDIT_RATING, CR.CREDIT_RATING)
                  end
              end CREDIT_RATING_NEW_EC
     FROM DWH.CLIENTS CL
     LEFT JOIN DWH.REF_CLIENT_RATINGS_EC RCR_EC
             ON     RCR_EC.CLIENT_KEY = CL.CLIENT_KEY
                AND RCR_EC.valid_to_dttm > SYSDATE + 100
     LEFT JOIN DWH.RATING_AGENCIES RACR_EC
             ON     RACR_EC.valid_to_dttm > SYSDATE + 100
                AND RCR_EC.RATING_AGENCY_KEY = RACR_EC.RATING_AGENCY_KEY
                AND RACR_EC.END_DT > SYSDATE
     LEFT JOIN DWH.CREDIT_RATINGS CRCR_EC
             ON     RCR_EC.RATING_KEY = CRCR_EC.CREDIT_RATING_KEY
                AND CRCR_EC.valid_to_dttm > SYSDATE + 100
                AND CRCR_EC.END_DT > SYSDATE
     LEFT JOIN DWH.BUSINESS_CATEGORIES BCAT
             ON     BCAT.BUSINESS_CATEGORY_KEY = CL.BUSINESS_CATEGORY_KEY
                AND BCAT.VALID_TO_DTTM > SYSDATE + 100
                AND BCAT.END_DT > SYSDATE
     LEFT JOIN DWH.CREDIT_RATINGS CR
             ON     CR.CREDIT_RATING_KEY = CL.CREDIT_RATING_KEY
                AND CR.VALID_TO_DTTM > SYSDATE + 100
                AND CR.END_DT > SYSDATE
     LEFT JOIN DWH.RATING_AGENCIES RA
             ON     RA.RATING_AGENCY_KEY = CR.AGENCY_KEY
                AND RA.VALID_TO_DTTM > SYSDATE + 100
                AND RA.END_DT > SYSDATE
     LEFT JOIN DWH.CONTRACTS C
        ON     CL.CLIENT_KEY = C.CLIENT_KEY
           AND C.VALID_TO_DTTM > SYSDATE + 100
           AND C.CONTRACT_KIND_KEY = 4
     LEFT JOIN DWH.LEASING_CONTRACTS LC
        ON     LC.CONTRACT_KEY = C.CONTRACT_KEY
           AND LC.VALID_TO_DTTM = to_date ('01.01.2400', 'dd.mm.yyyy')
     WHERE     CL.VALID_TO_DTTM = to_date ('01.01.2400', 'dd.mm.yyyy')
    ),
    
    RATINGS_PRV 
    AS (SELECT DISTINCT
            CL.CLIENT_KEY,
            CL.SHORT_CLIENT_RU_NAM,
            BCAT.BUSINESS_CAT_RU_NAM,
            RA.RATING_AGENCY_EN_NAM RA_RATING_AGENCY_RU_NAM,
            CR.CREDIT_RATING CR_CREDIT_RATING,
            RACR_PRV.RATING_AGENCY_EN_NAM RACR_PRV_RATING_AGENCY_RU_NAM,
            CRCR_PRV.CREDIT_RATING CRCR_PRV_CREDIT_RATING,
            RCR_PRV.BEGIN_DT RCR_PRV_BEGIN_DT,
            RCR_PRV.END_DT RCR_PRV_END_DT,
            nvl (RCR_PRV.rating_agency_key, ra.rating_agency_key) as agency_key_PRV,
              case
                  when min (nvl (lc.auto_flg, 0)) over (partition by cl.client_key) = 1
                   and NVL (RACR_PRV.rating_agency_en_nam, ra.rating_agency_en_nam) = 'No rating'
                      then 'Автолизинг'
                  else
                      case
                          when NVL (RACR_PRV.rating_agency_en_nam, ra.rating_agency_en_nam) = 'No rating'
                           and bcat.business_cat_en_nam in ('Small', 'Medium')
                               then 
                                    (select credit_rating
                                     from dwh.credit_ratings
                                     where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                                     and sysdate between BEGIN_DT and END_DT
                                     and credit_rating_cd = '9999'
                                     )
                          when NVL (RACR_PRV.rating_agency_en_nam, ra.rating_agency_en_nam) = 'No rating'
                           and bcat.business_cat_en_nam in ('Large')
                               then 
                                    (select credit_rating
                                     from dwh.credit_ratings
                                     where valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                                     and sysdate between BEGIN_DT and END_DT
                                     and credit_rating_cd = '8888'
                                     )
                      else NVL (CRCR_PRV.CREDIT_RATING, CR.CREDIT_RATING)
                  end
              end CREDIT_RATING_NEW_PRV
     FROM DWH.CLIENTS CL
     LEFT JOIN DWH.REF_CLIENT_RATINGS_PROVIS RCR_PRV
             ON     RCR_PRV.CLIENT_KEY = CL.CLIENT_KEY
                AND RCR_PRV.valid_to_dttm > SYSDATE + 100
     LEFT JOIN DWH.RATING_AGENCIES RACR_PRV
             ON     RACR_PRV.valid_to_dttm > SYSDATE + 100
                AND RCR_PRV.RATING_AGENCY_KEY = RACR_PRV.RATING_AGENCY_KEY
                AND RACR_PRV.END_DT > SYSDATE
     LEFT JOIN DWH.CREDIT_RATINGS CRCR_PRV
             ON     RCR_PRV.RATING_KEY = CRCR_PRV.CREDIT_RATING_KEY
                AND CRCR_PRV.valid_to_dttm > SYSDATE + 100
                AND CRCR_PRV.END_DT > SYSDATE
     LEFT JOIN DWH.BUSINESS_CATEGORIES BCAT
             ON     BCAT.BUSINESS_CATEGORY_KEY = CL.BUSINESS_CATEGORY_KEY
                AND BCAT.VALID_TO_DTTM > SYSDATE + 100
                AND BCAT.END_DT > SYSDATE
     LEFT JOIN DWH.CREDIT_RATINGS CR
             ON     CR.CREDIT_RATING_KEY = CL.CREDIT_RATING_KEY
                AND CR.VALID_TO_DTTM > SYSDATE + 100
                AND CR.END_DT > SYSDATE
     LEFT JOIN DWH.RATING_AGENCIES RA
             ON     RA.RATING_AGENCY_KEY = CR.AGENCY_KEY
                AND RA.VALID_TO_DTTM > SYSDATE + 100
                AND RA.END_DT > SYSDATE
     LEFT JOIN DWH.CONTRACTS C
        ON     CL.CLIENT_KEY = C.CLIENT_KEY
           AND C.VALID_TO_DTTM > SYSDATE + 100
           AND C.CONTRACT_KIND_KEY = 4
     LEFT JOIN DWH.LEASING_CONTRACTS LC
        ON     LC.CONTRACT_KEY = C.CONTRACT_KEY
           AND LC.VALID_TO_DTTM = to_date ('01.01.2400', 'dd.mm.yyyy')
     WHERE     CL.VALID_TO_DTTM = to_date ('01.01.2400', 'dd.mm.yyyy')
    ),
    
SP_PD_UN AS
    (
     SELECT   
                    RAT.business_category_key,
                    RAT.rate_cd,
                    RAT.MOODYS_RATE_CD,
                    RAT.FITCH_RATE_CD,
                    RAT.SP_RATE_CD,
                    SP_PD.pd AS pd_ec,
                    SP_PD.pd_res as pd_res,
                    dwh.stdnormal_inv2 (pd/100) AS Spd,
                    SP_PD.BEGIN_DT AS PD_BEGIN_DT,
                    SP_PD.END_DT AS PD_END_DT,
                    RAT.BEGIN_DT AS RAT_BEGIN_DT,
                    RAT.END_DT AS RAT_END_DT
      FROM dwh.REF_SP_PD SP_PD
      INNER JOIN dwh.REF_RATINGS RAT
            ON   SP_PD.SP_RATE_CD =  RAT.SP_RATE_CD
             AND   RAT.valid_to_dttm > SYSDATE + 100
            WHERE  SP_PD.valid_to_dttm > SYSDATE + 100
    ),
    
FINAL_SP_PD_UN as (
                    SELECT  distinct 
                    business_category_key,
                    rate_cd AS RATE_CD,
                    4 AS ag_key,
                    case
                        when rate_cd = 'E'
                            THEN 'CCC'
                        ELSE SP_RATE_CD 
                    end AS sp_rat_cd,
                    pd_ec / 100 as pd_ec,
                    pd_res / 100 as pd_res,
                    Spd,
                    PD_BEGIN_DT,
                    PD_END_DT,
                    RAT_BEGIN_DT,
                    RAT_END_DT
            FROM SP_PD_UN
            
            UNION ALL
            
            SELECT  distinct 
                    business_category_key,
                    SP_RATE_CD AS RATE_CD,
                    1 AS ag_key,
                    SP_RATE_CD AS sp_rat_cd,
                    pd_ec / 100 as pd_ec,
                    pd_res / 100 as pd_res,
                    Spd,
                    PD_BEGIN_DT,
                    PD_END_DT,
                    RAT_BEGIN_DT,
                    RAT_END_DT
            FROM SP_PD_UN
            
            UNION ALL
            
            SELECT  distinct 
                    business_category_key,
                    FITCH_RATE_CD AS RATE_CD,
                    2 AS ag_key,
                    SP_RATE_CD AS sp_rat_cd,
                    pd_ec / 100 as pd_ec,
                    pd_res / 100 as pd_res,
                    Spd,
                    PD_BEGIN_DT,
                    PD_END_DT,
                    RAT_BEGIN_DT,
                    RAT_END_DT
            FROM SP_PD_UN
            
            UNION ALL
            
            SELECT  distinct 
                    business_category_key,
                    MOODYS_RATE_CD AS RATE_CD,
                    3 AS ag_key,
                    SP_RATE_CD AS sp_rat_cd,
                    pd_ec / 100 as pd_ec,
                    pd_res / 100 as pd_res,
                    Spd,
                    PD_BEGIN_DT,
                    PD_END_DT,
                    RAT_BEGIN_DT,
                    RAT_END_DT
            FROM SP_PD_UN
            
            UNION ALL

            SELECT  distinct RAT.business_category_key,
                    SP_PD.SP_RATE_CD AS RATE_CD,
                    6 AS ag_key,
                    SP_PD.SP_RATE_CD AS sp_rat_cd,
                    SP_PD.pd / 100 AS pd_ec,
                    SP_PD.pd_res / 100 AS pd_res,
                    dwh.stdnormal_inv2 (pd/100) AS Spd,
                    SP_PD.BEGIN_DT AS PD_BEGIN_DT,
                    SP_PD.END_DT AS PD_END_DT,
                    RAT.BEGIN_DT AS RAT_BEGIN_DT,
                    RAT.END_DT AS RAT_END_DT
            FROM dwh.REF_SP_PD SP_PD
            left JOIN dwh.REF_RATINGS RAT
              ON   SP_PD.SP_RATE_CD = RAT.SP_RATE_CD
             AND   RAT.valid_to_dttm > SYSDATE + 100
            WHERE  SP_PD.valid_to_dttm > SYSDATE + 100
            AND    SP_PD.SP_RATE_CD IN (
                                        SELECT CREDIT_RATING
                                        FROM DWH.CREDIT_RATINGS 
                                        WHERE valid_to_dttm > SYSDATE + 100
                                        AND CREDIT_RATING_CD IN ('8888', '9999', '7777')
            )),

  MAX_OVD_DAYS as (Select snapshot_dt, client_key, max(OVD_DAYS) MAX_OVD_DAYS
                   from (Select snapshot_dt, client_key, NVL (SNAPSHOT_DT - OVERDUE_DT + 1, 0) AS OVD_DAYS
                         from dm.dm_cgp)
                   group by snapshot_dt, client_key
                   )
   SELECT t.snapshot_dt,
          p_snapshot_cd,
          t.contract_key,
		  t.currency_key,
          t.CLIENT_NAM,
          t.CONTRACT_ID_CD,
          t.CONTRACT_NUM,
          CASE WHEN t3.AUTO_FLG = 1 THEN 'Да' ELSE 'Нет' END AS AUTO_FLG,
          coalesce (OPER_START_DT.OPER_START_DT, t2.OPER_START_DT, t2.OPEN_DT) AS OPER_START,
          case 
                when upper(t.STATUS) = 'OPEN' 
                      THEN t.END_DT 
                when upper(t.STATUS) = 'CLOSED' 
                 and t.FACT_CLOSE_DT < trunc (t.SNAPSHOT_DT, 'mm') 
                      then t.SNAPSHOT_DT 
                when upper(t.STATUS) = 'CLOSED' 
                 and t.FACT_CLOSE_DT >= trunc (t.SNAPSHOT_DT, 'mm') 
                      then t.FACT_CLOSE_DT 
          end as END_DT,
         -- to_char(dm_cl.CLIENT_ID) as CLIENT_ID,
          --dm_cl.CLIENT_CRM_CD CRM_CODE,
          
---
          t.client_id as CLIENT_ID,
         
          dm_cl.CLIENT_CRM_CD CRM_CODE,
          --t.CLIENT_CRM_ID as CLIENT_ID,
---
          nvl (t5.GROUP_CD, 0) GROUP_ID,
          nvl (t5.GROUP_RU_NAM, 0) as GROUP_RU_NAM,
          nvl (t6.CREDIT_RATING_CD, 0) as credit_rating_cd,
          nvl (t6.CREDIT_RATING, 0) AS CREDIT_RATING,
          nvl (t7.RATING_AGENCY_EN_NAM, 0) as rating_agency_en_nam,
          to_number (nvl (t8.COUNTRY_CD, 0)) as reg_country_cd,
          nvl (t8.COUNTRY_RU_NAM, 0) AS REG_COUNTRY_NAM,
          nvl (t9.ACTIVITY_TYPE_CD, 0) as ACTIVITY_TYPE_CD,
          nvl (t9.ACTIVITY_TYPE_RU_DESC, 0) as ACTIVITY_TYPE_RU_DESC,
          nvl (t10.BUSINESS_CATEGORY_CD, 0) AS SME_FLG,
          nvl (t10.BUSINESS_CAT_RU_NAM, 0) as BUSINESS_CAT_RU_NAM,
          to_number (nvl (t11.COUNTRY_CD, 0)) AS risk_coun_CD,
          nvl (t11.COUNTRY_RU_NAM, 0) AS risk_country_nam,
          t.STATUS,
          case when t.XIRR_RATE > 1 then 0.99 else t.XIRR_RATE end as XIRR_RATE,
          to_number (t12.CURRENCY_CD) as CURRENCY_CD,
          t12.CURRENCY_LETTER_CD,
          t.TERM_AMT,
          t.term_amt * t13.EXCHANGE_RATE AS TERM_RUR,
          case when t.OVERDUE_AMT = 0 then 0 when upper(t.STATUS) = 'CLOSED' and round(t.overdue_amt) = 0 then 0 else t.OVERDUE_AMT end OVERDUE_AMT,
          case when t.OVERDUE_AMT = 0 then 0 when upper(t.STATUS) = 'CLOSED' and round(t.overdue_amt) = 0 then 0 else t.OVERDUE_AMT end * t13.EXCHANGE_RATE AS OVD_RUR,
          nvl(t.TERM_AMT,0) + case when t.OVERDUE_AMT = 0 then 0 when upper(t.STATUS) = 'CLOSED' and round(t.overdue_amt) = 0 then 0 else t.OVERDUE_AMT end AS TOT_AMT,
          (t.term_amt * t13.EXCHANGE_RATE) + (case when t.OVERDUE_AMT = 0 then 0 when upper(t.STATUS) = 'CLOSED' and round(t.overdue_amt) = 0 then 0 else t.OVERDUE_AMT end * t13.EXCHANGE_RATE) AS TOT_RUR_AMT,
          t.OVERDUE_DT,
          NVL (t.SNAPSHOT_DT - t.OVERDUE_DT + 1, 0) AS OVD_DAYS,
          case when t5.group_RU_NAM is not null then t5.group_RU_NAM else t.CLIENT_NAM end AS GROUP_OR_CLIENT,
          'LND_017_CIB' AS Mir_code,
          MODS.MAX_OVD_DAYS,
          case when t.OVERDUE_AMT = 0 then 0 when upper(t.STATUS) = 'CLOSED' and round(t.overdue_amt) = 0 then 0 else t.OVERDUE_AMT end / (t18.vat_rate + 1) AS OVERDUE_NOVAT_AMT,
          t.TERM_AMT + case when t.OVERDUE_AMT = 0 then 0 when upper(t.STATUS) = 'CLOSED' and round(t.overdue_amt) = 0 then 0 else t.OVERDUE_AMT end / (t18.vat_rate + 1)  AS TOT_NOVAT_AMT,
          case when t.OVERDUE_AMT = 0 then 0 when upper(t.STATUS) = 'CLOSED' and round(t.overdue_amt) = 0 then 0 else t.OVERDUE_AMT end * t13.EXCHANGE_RATE / (t18.vat_rate + 1) AS OVD_NOVAT_RUR,
          (t.term_amt * t13.EXCHANGE_RATE) + ((case when t.OVERDUE_AMT = 0 then 0 when upper(t.STATUS) = 'CLOSED' and round(t.overdue_amt) = 0 then 0 else t.OVERDUE_AMT end 
          / (t18.vat_rate + 1)) * t13.EXCHANGE_RATE) AS TOT_NOVAT_RUR_AMT,
          t4.SCORE_POINTS_CNT,
          FINAL_SP_PD_UN_EC.SP_RAT_CD as SP_RAT_EC,
          CASE
             WHEN UPPER (RATINGS_EC.RA_RATING_AGENCY_EN_NAM) = 'INTERNAL'
              and t4.SCORE_POINTS_CNT is not null
             THEN
                EXP (t4.SCORE_POINTS_CNT * t23.param_a + t23b.param_b) / 100
          ELSE
                FINAL_SP_PD_UN_EC.PD_EC
          END PD_EC,
          CLI_D.CAR_DEFAULT_FLG,
          CASE
             WHEN nvl (CLI_D.CAR_DEFAULT_FLG, 0) != 0
             THEN 'D' 
             ELSE FINAL_SP_PD_UN_EC.SP_RAT_CD
          END SP_RAT_EC_DEF,
          CASE
             WHEN nvl (CLI_D.CAR_DEFAULT_FLG, 0) != 0
             THEN
                (SELECT PD_EC
                   FROM FINAL_SP_PD_UN rpd
                  WHERE     SP_RAT_CD = 'D'
                        AND rpd.PD_BEGIN_DT <= T.SNAPSHOT_DT
                        AND rpd.PD_END_DT > T.SNAPSHOT_DT
                        AND rpd.RAT_BEGIN_DT <= T.SNAPSHOT_DT
                        AND rpd.RAT_END_DT > T.SNAPSHOT_DT
                        AND rpd.BUSINESS_CATEGORY_KEY =
                               t4.BUSINESS_CATEGORY_KEY
                 )
            WHEN UPPER (RATINGS_EC.RA_RATING_AGENCY_EN_NAM) = 'INTERNAL'
              and t4.SCORE_POINTS_CNT is not null
             THEN
                 EXP (t4.SCORE_POINTS_CNT * t23.param_a + t23b.param_b) / 100
            ELSE
                FINAL_SP_PD_UN_EC.PD_EC
          END
            PD_EC_DEF,
          FINAL_SP_PD_UN_PRV.SP_RAT_CD as SP_RAT_PRV,
          FINAL_SP_PD_UN_PRV.PD_RES as PD_PRV,
          con_d.LEASING_SUBJECT_DESC || ' ' || con_d.LEASING_SUBJECT_COMMENT as LEASING_SUBJECT_DESC,
          CON_D.ASSET_TYPE_COL LEASING_SUBJECT_TYPE_RES,
          CON_D.ASSET_TYPE_EC LEASING_SUBJECT_TYPE_EC,
          CASE 
              WHEN CON_D.ASSET_TYPE_COL = CON_D.ASSET_TYPE_EC 
                  then 'ИСТИНА' 
              else 'ЛОЖЬ' 
          END LEASING_SUBJECT_TYPE_COMPARE,
          CR.SP_CALC_RATE_CD COUNT_RAT,
          SP_PD_CONTRY.PD_RES  / 100 PD_COUNT,
          GREATEST(FINAL_SP_PD_UN_PRV.PD_RES,SP_PD_CONTRY.PD_RES  / 100) PD_RESULT,
          t19.LGD AS LGD_COL,
          t20.LGD AS LGD_EC,
          CON_D.AGG_LIST_CROUP_CD,
          t18.VAT_RATE,
          nvl (CLI_D.LIP,0.25) as LIP,
          -1 * round(GREATEST(FINAL_SP_PD_UN_PRV.PD_RES,SP_PD_CONTRY.PD_RES  / 100) * t19.LGD * nvl(CLI_D.LIP,0.25),4) AS PD_LGD_LIP,
          case when CLIENT_R.PZ_PPZ is not null then CLIENT_R.PZ_PPZ
               when CONTRACT_R.PZ_PPZ is not null then CONTRACT_R.PZ_PPZ else CON_D.BAD_STATUS_CD end AS PZ_PPZ,
          case when CLIENT_R.ASSESSMENT is not null then CLIENT_R.ASSESSMENT
               when CONTRACT_R.ASSESSMENT is not null then CONTRACT_R.ASSESSMENT else 'Collectively assessed' end IND_COL_ASD,
          nvl (CON_D.DEAL_CIS_TYPE, -999999999) DEAL_TYPE,
          case when CLIENT_R.ASSESSMENT_FLG is not null then to_number (CLIENT_R.ASSESSMENT_FLG)
               when CONTRACT_R.ASSESSMENT_FLG is not null then to_number (CONTRACT_R.ASSESSMENT_FLG) else 0 end ASSESSMENT_FLG,
          case when CLIENT_R.IPO_FLG is not null then to_number (CLIENT_R.IPO_FLG)
               when CONTRACT_R.IPO_FLG is not null then to_number (CONTRACT_R.IPO_FLG) else 0 end IPO_FLG_FILE,
          case when CLIENT_R.SCENARIO_IPO_FLG is not null then to_number (CLIENT_R.SCENARIO_IPO_FLG)
               when CONTRACT_R.SCENARIO_IPO_FLG is not null then to_number (CONTRACT_R.SCENARIO_IPO_FLG) else null end SCENARIO_IPO_FLG,
          case when CLIENT_R.RATE is not null then round(CLIENT_R.RATE,4)
               when CONTRACT_R.RATE is not null then round(CONTRACT_R.RATE,4)
          else -1 * round(GREATEST(FINAL_SP_PD_UN_PRV.PD_RES,SP_PD_CONTRY.PD_RES  / 100) * t19.LGD * nvl(CLI_D.LIP,0.25),4)
          end RATE,
          (nvl(t.TERM_AMT,0) + case when t.OVERDUE_AMT = 0 then 0 when upper(t.STATUS) = 'CLOSED' and round(t.overdue_amt) = 0 then 0 else t.OVERDUE_AMT end 
          / (t18.vat_rate + 1)) * 
          case 
              when CLIENT_R.RATE is not null 
                    then round(CLIENT_R.RATE,4)
              when CONTRACT_R.RATE is not null 
                    then round(CONTRACT_R.RATE,4)
              else -1 * round(GREATEST(FINAL_SP_PD_UN_PRV.PD_RES,SP_PD_CONTRY.PD_RES  / 100) * t19.LGD * nvl(CLI_D.LIP,0.25),4)
          end PROVISIONS_AMT_VAL,
          ((nvl(t.term_amt,0) * t13.EXCHANGE_RATE) + 
          (case when t.OVERDUE_AMT = 0 then 0 when upper(t.STATUS) = 'CLOSED' and round(t.overdue_amt) = 0 then 0 else t.OVERDUE_AMT end  
          / (t18.vat_rate + 1)) * t13.EXCHANGE_RATE) * 
          case 
              when CLIENT_R.RATE is not null 
                    then round(CLIENT_R.RATE,4)
              when CONTRACT_R.RATE is not null 
                    then round(CONTRACT_R.RATE,4)
              else -1 * round(GREATEST(FINAL_SP_PD_UN_PRV.PD_RES,SP_PD_CONTRY.PD_RES / 100) * t19.LGD * nvl(CLI_D.LIP,0.25),4)
          end PROVISIONS_AMT_RUB,
          (0.12 * (1 - EXP (-50 * CASE
                                         WHEN nvl (CLI_D.CAR_DEFAULT_FLG, 0) != 0
                                         THEN
                                            (SELECT PD_EC
                                               FROM FINAL_SP_PD_UN rpd
                                              WHERE     SP_RAT_CD = 'D'
                                                    AND rpd.PD_BEGIN_DT <= T.SNAPSHOT_DT
                                                    AND rpd.PD_END_DT > T.SNAPSHOT_DT
                                                    AND rpd.RAT_BEGIN_DT <= T.SNAPSHOT_DT
                                                    AND rpd.RAT_END_DT > T.SNAPSHOT_DT
                                                    AND rpd.BUSINESS_CATEGORY_KEY =
                                                           t4.BUSINESS_CATEGORY_KEY
                                             )
                                        WHEN UPPER (RATINGS_EC.RA_RATING_AGENCY_EN_NAM) = 'INTERNAL'
                                          and t4.SCORE_POINTS_CNT is not null
                                         THEN
                                             EXP (t4.SCORE_POINTS_CNT * t23.param_a + t23b.param_b) / 100
                                        ELSE
                                            FINAL_SP_PD_UN_EC.PD_EC
                                      END
                             )
                  )
        + 0.24 * (1 - (1 - EXP (-50 * CASE
                                           WHEN nvl (CLI_D.CAR_DEFAULT_FLG, 0) != 0
                                           THEN
                                              (SELECT PD_EC
                                                 FROM FINAL_SP_PD_UN rpd
                                                WHERE     SP_RAT_CD = 'D'
                                                      AND rpd.PD_BEGIN_DT <= T.SNAPSHOT_DT
                                                      AND rpd.PD_END_DT > T.SNAPSHOT_DT
                                                      AND rpd.RAT_BEGIN_DT <= T.SNAPSHOT_DT
                                                      AND rpd.RAT_END_DT > T.SNAPSHOT_DT
                                                      AND rpd.BUSINESS_CATEGORY_KEY =
                                                             t4.BUSINESS_CATEGORY_KEY
                                               )
                                          WHEN UPPER (RATINGS_EC.RA_RATING_AGENCY_EN_NAM) = 'INTERNAL'
                                            and t4.SCORE_POINTS_CNT is not null
                                           THEN
                                               EXP (t4.SCORE_POINTS_CNT * t23.param_a + t23b.param_b) / 100
                                          ELSE
                                              FINAL_SP_PD_UN_EC.PD_EC
                                        END
                               )
                         )
                    )
                  )
            / (1 - EXP (-50))
          - CASE
               WHEN    t10.BUSINESS_CATEGORY_CD IN (3, 4)
                    OR CASE
                                           WHEN nvl (CLI_D.CAR_DEFAULT_FLG, 0) != 0
                                           THEN
                                              (SELECT PD_EC
                                                 FROM FINAL_SP_PD_UN rpd
                                                WHERE     SP_RAT_CD = 'D'
                                                      AND rpd.PD_BEGIN_DT <= T.SNAPSHOT_DT
                                                      AND rpd.PD_END_DT > T.SNAPSHOT_DT
                                                      AND rpd.RAT_BEGIN_DT <= T.SNAPSHOT_DT
                                                      AND rpd.RAT_END_DT > T.SNAPSHOT_DT
                                                      AND rpd.BUSINESS_CATEGORY_KEY =
                                                             t4.BUSINESS_CATEGORY_KEY
                                               )
                                          WHEN UPPER (RATINGS_EC.RA_RATING_AGENCY_EN_NAM) = 'INTERNAL'
                                            and t4.SCORE_POINTS_CNT is not null
                                           THEN
                                               EXP (t4.SCORE_POINTS_CNT * t23.param_a + t23b.param_b) / 100
                                          ELSE
                                              FINAL_SP_PD_UN_EC.PD_EC
                                        END = 1
                    OR   nvl(CLI_D.revenue_amt,0)
                       * cli_d.revenue_multiplicity
                       / cli_ex2.exchange_rate > 50
               THEN
                  0
               ELSE
                  CASE
                     WHEN   nvl(CLI_D.revenue_amt,0)
                          * cli_d.revenue_multiplicity
                          / cli_ex2.exchange_rate < 5
                     THEN
                        0.04 * (1 - (5 - 5) / 45)
                     ELSE
                        0.04 * (1 - (0 - 5) / 45)
                  END
            END
             AS R,
                    CASE
             WHEN    t10.BUSINESS_CATEGORY_CD IN (3, 4)
                  OR CASE
                                           WHEN nvl (CLI_D.CAR_DEFAULT_FLG, 0) != 0
                                           THEN
                                              (SELECT PD_EC
                                                 FROM FINAL_SP_PD_UN rpd
                                                WHERE     SP_RAT_CD = 'D'
                                                      AND rpd.PD_BEGIN_DT <= T.SNAPSHOT_DT
                                                      AND rpd.PD_END_DT > T.SNAPSHOT_DT
                                                      AND rpd.RAT_BEGIN_DT <= T.SNAPSHOT_DT
                                                      AND rpd.RAT_END_DT > T.SNAPSHOT_DT
                                                      AND rpd.BUSINESS_CATEGORY_KEY =
                                                             t4.BUSINESS_CATEGORY_KEY
                                               )
                                          WHEN UPPER (RATINGS_EC.RA_RATING_AGENCY_EN_NAM) = 'INTERNAL'
                                            and t4.SCORE_POINTS_CNT is not null
                                           THEN
                                               EXP (t4.SCORE_POINTS_CNT * t23.param_a + t23b.param_b) / 100
                                          ELSE
                                              FINAL_SP_PD_UN_EC.PD_EC
                                        END = 1
                  OR CLI_D.revenue_amt * cli_d.revenue_multiplicity / cli_ex2.exchange_rate >
                        50
             THEN
                0
             ELSE
                CASE
                   WHEN   nvl(CLI_D.revenue_amt,0)
                        * cli_d.revenue_multiplicity
                        / cli_ex2.exchange_rate < 5
                   THEN
                      0.04 * (1 - (5 - 5) / 45)
                   ELSE
                      0.04 * (1 - (0 - 5) / 45)
                END
          END
             AS CORR_R,
          nvl(CLI_D.revenue_amt,0) * cli_d.revenue_multiplicity/ cli_ex2.exchange_rate AS PROF_AMT,
          CASE
             WHEN (t.TERM_AMT + Case when t.OVERDUE_AMT = 0 then 0 when upper(t.STATUS) = 'CLOSED' and round(t.overdue_amt) = 0 then 0 else t.OVERDUE_AMT end) = 0 THEN 0
             ELSE ROUND (POWER (0.11852 - 0.05478 * LN (CASE
                                                            WHEN nvl (CLI_D.CAR_DEFAULT_FLG, 0) != 0
                                                                   THEN
                                                                      (SELECT PD_EC
                                                                         FROM FINAL_SP_PD_UN rpd
                                                                        WHERE     SP_RAT_CD = 'D'
                                                                              AND rpd.PD_BEGIN_DT <= T.SNAPSHOT_DT
                                                                              AND rpd.PD_END_DT > T.SNAPSHOT_DT
                                                                              AND rpd.RAT_BEGIN_DT <= T.SNAPSHOT_DT
                                                                              AND rpd.RAT_END_DT > T.SNAPSHOT_DT
                                                                              AND rpd.BUSINESS_CATEGORY_KEY =
                                                                                     t4.BUSINESS_CATEGORY_KEY
                                                                       )
                                                                  WHEN UPPER (RATINGS_EC.RA_RATING_AGENCY_EN_NAM) = 'INTERNAL'
                                                                    and t4.SCORE_POINTS_CNT is not null
                                                                   THEN
                                                                       EXP (t4.SCORE_POINTS_CNT * t23.param_a + t23b.param_b) / 100
                                                                  ELSE
                                                                      FINAL_SP_PD_UN_EC.PD_EC
                                                                END
                                                        ), 2
                                  ), 8)
          END
             AS B_NSBU,
          NEW_M.M AS M,
          (t.term_amt * t13.EXCHANGE_RATE) + (Case when t.OVERDUE_AMT = 0 then 0 when upper(t.STATUS) = 'CLOSED' and round(t.overdue_amt) = 0 then 0 else t.OVERDUE_AMT end
          / (t18.vat_rate + 1)) * t13.EXCHANGE_RATE EAD,
          sysdate
FROM tt t2
          LEFT JOIN dm.dm_cgp t
             ON     t2.CONTRACT_KEY = t.CONTRACT_KEY
                AND SNAPSHOT_CD = 'Основной КИС'
                AND snapshot_dt = p_REPORT_DT
          LEFT JOIN DWH.LEASING_CONTRACTS t3
             ON     t3.CONTRACT_KEY = t.CONTRACT_KEY
                AND t3.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
          LEFT JOIN DM.DM_OPER_START_DT OPER_START_DT 
             ON t.CONTRACT_KEY = OPER_START_DT.CONTRACT_KEY 
                AND t.SNAPSHOT_DT = OPER_START_DT.SNAPSHOT_DT
          LEFT JOIN dwh.clients t4
             ON     t4.CLIENT_KEY = t.CLIENT_KEY
                AND t4.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
          LEFT JOIN DM.DM_CLIENTS DM_CL 
             ON  t.CLIENT_KEY = DM_CL.CLIENT_KEY 
                AND t.SNAPSHOT_DT = DM_CL.SNAPSHOT_DT
          LEFT JOIN DWH.GROUPS t5
             ON     t5.GROUP_KEY = t4.GROUP_KEY
                AND t5.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
          
          -- клиентские рейтинги, используемые в ЭК / Резервах ----------------------------------------
          
          --[apolyakov 21.03.2016]: добавление нового справочника для ЭК
          LEFT JOIN RATINGS_EC RATINGS_EC
             ON     RATINGS_EC.CLIENT_KEY = t.CLIENT_KEY
                AND t.SNAPSHOT_DT BETWEEN RATINGS_EC.rcr_EC_BEGIN_DT AND RATINGS_EC.rcr_EC_END_DT     
          --[apolyakov 21.03.2017]: добавление нового справочника для Резервов
          LEFT JOIN RATINGS_PRV RATINGS_PRV
             ON     RATINGS_PRV.CLIENT_KEY = t.CLIENT_KEY
                AND t.SNAPSHOT_DT BETWEEN RATINGS_PRV.rcr_prv_BEGIN_DT AND RATINGS_PRV.rcr_prv_END_DT
                    
          --рейтинг!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!--------------------------
          LEFT JOIN DWH.CREDIT_RATINGS t6
             ON     t6.CREDIT_RATING_KEY = t.CREDIT_RATING_KEY
                AND t6.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                AND t6.BEGIN_DT <= t.SNAPSHOT_DT
                AND t6.END_DT >= t.SNAPSHOT_DT
          LEFT JOIN DWH.RATING_AGENCIES t7
             ON     t7.RATING_AGENCY_KEY = t6.AGENCY_KEY
                AND t7.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                AND t7.BEGIN_DT <= t.SNAPSHOT_DT
                AND t7.END_DT >= t.SNAPSHOT_DT
          --рейтинг !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ---------------------------
          LEFT JOIN DWH.COUNTRIES t8
             ON     t8.COUNTRY_KEY = t.REG_COUNTRY_KEY
                AND t8.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                AND t8.BEGIN_DT <= t.SNAPSHOT_DT
                AND t8.END_DT >= t.SNAPSHOT_DT
          LEFT JOIN DWH.ACTIVITY_TYPES t9
             ON     t9.ACTIVITY_TYPE_KEY = t.ACTIVITY_TYPE_KEY
                AND t9.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                AND t9.BEGIN_DT <= t.SNAPSHOT_DT
                AND t9.END_DT >= t.SNAPSHOT_DT
          LEFT JOIN DWH.BUSINESS_CATEGORIES t10
             ON     t10.BUSINESS_CATEGORY_KEY = t.BUSINESS_CATEGORY_KEY
                AND t10.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                AND t10.BEGIN_DT <= t.SNAPSHOT_DT
                AND t10.END_DT >= t.SNAPSHOT_DT
          LEFT JOIN DWH.COUNTRIES t11
             ON     t11.country_key = t.RISK_COUNTRY_KEY
                AND t11.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                AND t11.BEGIN_DT <= t.SNAPSHOT_DT
                AND t11.END_DT >= t.SNAPSHOT_DT
          --[apolyakov 21.03.2016]: правильное определение валют
          LEFT JOIN (SELECT a.*,
                            ROW_NUMBER ()
                            OVER (PARTITION BY CURRENCY_LETTER_CD
                                  ORDER BY VALID_FROM_DTTM DESC)
                               rn
                        FROM dwh.CURRENCIES a
                      WHERE VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')) t12
             ON     t12.CURRENCY_KEY = t.CURRENCY_KEY
                AND t12.rn = 1
                AND t12.BEGIN_DT <= t.SNAPSHOT_DT
                AND t12.END_DT >= t.SNAPSHOT_DT
          -- [apolyakov 21.03.2016]: выбор валюты из справочника и изменение привязки по ключу с t2!
          LEFT JOIN (SELECT ER.*, 
                           CUR.BEGIN_DT, 
                           CUR.END_DT
                    FROM dwh.EXCHANGE_RATES ER
                    INNER JOIN dwh.currencies CUR
                        ON ER.BASE_CURRENCY_KEY = CUR.CURRENCY_KEY
                    WHERE CUR.valid_to_dttm > SYSDATE + 100
                    AND   CUR.CURRENCY_LETTER_CD = 'RUB'
                    ) t13
             ON     t13.CURRENCY_KEY = t2.CURRENCY_KEY
                AND T13.BEGIN_DT <= t.SNAPSHOT_DT
                AND T13.END_DT > t.SNAPSHOT_DT
                AND t13.EX_RATE_DT = t.SNAPSHOT_DT
                AND t13.valid_to_dttm = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
          LEFT JOIN dwh.VAT t18
             ON     t18.BRANCH_KEY = t.BRANCH_KEY
                AND t18.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                AND t.SNAPSHOT_DT BETWEEN t18.BEGIN_DT AND t18.END_DT
          LEFT JOIN dwh.RISK_EC_CLIENT_DATA CLI_D
             ON     cli_d.CLIENT_KEY = t.CLIENT_KEY
                AND cli_d.BEGIN_DT <= T.SNAPSHOT_DT
                AND cli_d.END_DT > T.SNAPSHOT_DT
                AND cli_d.VALID_TO_DTTM > SYSDATE + 100
                
          --------- Матрица соответствия рейтингов      
          LEFT JOIN FINAL_SP_PD_UN FINAL_SP_PD_UN_EC
              ON RATINGS_EC.CREDIT_RATING_NEW_EC = FINAL_SP_PD_UN_EC.RATE_CD 
                 AND FINAL_SP_PD_UN_EC.BUSINESS_CATEGORY_KEY = t.BUSINESS_CATEGORY_KEY
                 AND FINAL_SP_PD_UN_EC.ag_key = RATINGS_EC.agency_key_EC
                 AND FINAL_SP_PD_UN_EC.PD_BEGIN_DT <= T.SNAPSHOT_DT
                 AND FINAL_SP_PD_UN_EC.PD_END_DT > T.SNAPSHOT_DT
                 AND FINAL_SP_PD_UN_EC.RAT_BEGIN_DT <= T.SNAPSHOT_DT
                 AND FINAL_SP_PD_UN_EC.RAT_END_DT > T.SNAPSHOT_DT
                 
           LEFT JOIN FINAL_SP_PD_UN FINAL_SP_PD_UN_PRV
              ON RATINGS_PRV.CREDIT_RATING_NEW_PRV = FINAL_SP_PD_UN_PRV.RATE_CD 
                 AND FINAL_SP_PD_UN_PRV.BUSINESS_CATEGORY_KEY = t.BUSINESS_CATEGORY_KEY
                 AND FINAL_SP_PD_UN_PRV.ag_key = RATINGS_PRV.agency_key_PRV
                 AND FINAL_SP_PD_UN_PRV.PD_BEGIN_DT <= T.SNAPSHOT_DT
                 AND FINAL_SP_PD_UN_PRV.PD_END_DT > T.SNAPSHOT_DT
                 AND FINAL_SP_PD_UN_PRV.RAT_BEGIN_DT <= T.SNAPSHOT_DT
                 AND FINAL_SP_PD_UN_PRV.RAT_END_DT > T.SNAPSHOT_DT
                 
          LEFT JOIN
          (  SELECT rrp.BEGIN_DT rrp_BEGIN_DT,
                    rrp.END_DT rrp_END_DT,
                    bc.BEGIN_DT bc_BEGIN_DT,
                    bc.END_DT bc_END_DT,
                    bc.BUSINESS_CATEGORY_KEY,
                    MAX (
                       CASE
                          WHEN     UPPER (bc.BUSINESS_CAT_EN_NAM) = 'LARGE'
                               AND PARAM_NAM = 'PD_A_LARGE'
                          THEN
                             PARAM_VAL
                          WHEN     UPPER (bc.BUSINESS_CAT_EN_NAM) IN ('MEDIUM',
                                                                      'SMALL')
                               AND PARAM_NAM = 'PD_A_SMALL_MEDIUM'
                          THEN
                             PARAM_VAL
                       END)
                       param_a
               FROM dwh.REF_RISK_PARAMS rrp,
                    dwh.BUSINESS_CATEGORIES bc
              -- [apolyakov 05.04.2016]: убрать лишние записи, разнес а и b.
              WHERE PARAM_NAM IN ('PD_A_LARGE',
                                  'PD_A_SMALL_MEDIUM')
              AND RRP.valid_to_dttm > SYSDATE + 100
              AND BC.valid_to_dttm > SYSDATE + 100
           GROUP BY rrp.BEGIN_DT,
                    rrp.END_DT,
                    bc.BEGIN_DT,
                    bc.END_DT,
                    bc.BUSINESS_CATEGORY_KEY) t23
             ON     t23.BUSINESS_CATEGORY_KEY = t.BUSINESS_CATEGORY_KEY
                AND t.SNAPSHOT_DT BETWEEN t23.rrp_BEGIN_DT AND t23.rrp_END_DT
                AND t.SNAPSHOT_DT BETWEEN t23.bc_BEGIN_DT AND t23.bc_END_DT
                -- [apolyakov 05.04.2016]: выбирать только непустые, чтобы не дублилось.
                AND t23.param_a is not null
          -- [apolyakov 05.04.2016]: убрать лишние записи, разнес а и b.
          LEFT JOIN
          (  SELECT rrp.BEGIN_DT rrp_BEGIN_DT,
                    rrp.END_DT rrp_END_DT,
                    bc.BEGIN_DT bc_BEGIN_DT,
                    bc.END_DT bc_END_DT,
                    bc.BUSINESS_CATEGORY_KEY,
                    MAX (
                       CASE
                          WHEN     UPPER (bc.BUSINESS_CAT_EN_NAM) = 'LARGE'
                               AND PARAM_NAM = 'PD_B_LARGE'
                          THEN
                             PARAM_VAL
                          WHEN     UPPER (bc.BUSINESS_CAT_EN_NAM) IN ('MEDIUM',
                                                                      'SMALL')
                               AND PARAM_NAM = 'PD_B_SMALL_MEDIUM'
                          THEN
                             PARAM_VAL
                       END)
                       param_b
               FROM dwh.REF_RISK_PARAMS rrp,
                    dwh.BUSINESS_CATEGORIES bc
              WHERE PARAM_NAM IN ('PD_B_LARGE',
                                  'PD_B_SMALL_MEDIUM')
              AND RRP.valid_to_dttm > SYSDATE + 100
              AND BC.valid_to_dttm > SYSDATE + 100
           GROUP BY rrp.BEGIN_DT,
                    rrp.END_DT,
                    bc.BEGIN_DT,
                    bc.END_DT,
                    bc.BUSINESS_CATEGORY_KEY) t23b
             ON     t23b.BUSINESS_CATEGORY_KEY = t.BUSINESS_CATEGORY_KEY
                AND t.SNAPSHOT_DT BETWEEN t23b.rrp_BEGIN_DT AND t23b.rrp_END_DT
                AND t.SNAPSHOT_DT BETWEEN t23b.bc_BEGIN_DT AND t23b.bc_END_DT
                -- [apolyakov 05.04.2016]: выбирать только непустые, чтобы не дублилось.
                AND t23b.param_b is not null
          LEFT JOIN dwh.RISK_EC_CLIENT_DATA t24
             ON     t24.CLIENT_KEY = t2.CLIENT_KEY
                AND t24.valid_to_dttm > SYSDATE + 100
                AND t.SNAPSHOT_DT BETWEEN t24.BEGIN_DT AND t24.END_DT
          LEFT JOIN dwh.REF_COUNTRY_RATING CR
             ON     t.RISK_COUNTRY_KEY = CR.COUNTRY_KEY
               AND  CR.valid_to_dttm > SYSDATE + 100
               AND  t.SNAPSHOT_DT BETWEEN CR.BEGIN_DT AND CR.END_DT
          LEFT JOIN dwh.REF_SP_PD SP_PD_CONTRY
             ON     SP_PD_CONTRY.SP_RATE_CD = CR.SP_CALC_RATE_CD
               AND  SP_PD_CONTRY.valid_to_dttm > SYSDATE + 100
               AND  t.SNAPSHOT_DT BETWEEN SP_PD_CONTRY.BEGIN_DT AND SP_PD_CONTRY.END_DT   
          /*LEFT JOIN PROVISIONS_PD PROVISIONS_PD
             ON     PROVISIONS_PD.CONTRACT_KEY = t2.CONTRACT_KEY
                AND t.snapshot_dt = PROVISIONS_PD.snapshot_dt*/
          LEFT JOIN dwh.RISK_EC_CONTRACT_DATA CON_D
             ON     con_d.CONTRACT_key = t2.contract_key
                AND con_d.BEGIN_DT <= T.SNAPSHOT_DT
                AND con_d.END_DT > T.SNAPSHOT_DT
                AND con_d.VALID_TO_DTTM > SYSDATE + 100
          LEFT JOIN DWH.REF_LGD t19
             ON     TRIM (upper (t19.LEASING_SUBJECT_TYPE_CD)) = TRIM (upper (CON_D.ASSET_TYPE_COL))
                AND t19.LGD_TYPE_CD = 'RES'
                AND t19.BEGIN_DT <= T.SNAPSHOT_DT
                AND t19.END_DT > T.SNAPSHOT_DT
                AND t19.VALID_TO_DTTM > SYSDATE + 100
          LEFT JOIN DWH.REF_LGD t20
             ON     TRIM (upper (t20.LEASING_SUBJECT_TYPE_CD)) = TRIM (upper (CON_D.ASSET_TYPE_EC))
                AND t20.LGD_TYPE_CD = 'EC'
                AND t20.BEGIN_DT <= T.SNAPSHOT_DT
                AND t20.END_DT > T.SNAPSHOT_DT
                AND t20.VALID_TO_DTTM > SYSDATE + 100
          LEFT JOIN DWH.FACT_CONTRACTS_RESERVES CONTRACT_R
             ON     t.CONTRACT_KEY = CONTRACT_R.CONTRACT_KEY
                AND t.snapshot_dt = CONTRACT_R.snapshot_dt
          LEFT JOIN DWH.FACT_CLIENTS_RESERVES CLIENT_R
             ON     t.CLIENT_KEY = CLIENT_R.CLIENT_KEY
                AND t.snapshot_dt = CLIENT_R.snapshot_dt
          LEFT JOIN (
                    SELECT ER.*, 
                           CUR1.BEGIN_DT BASE_BEGIN_DT, 
                           CUR1.END_DT BASE_END_DT,
                           CUR2.BEGIN_DT BEGIN_DT,
                           CUR2.END_DT END_DT
                    FROM dwh.EXCHANGE_RATES ER
                    INNER JOIN dwh.currencies CUR1
                        ON ER.BASE_CURRENCY_KEY = CUR1.CURRENCY_KEY
                    INNER JOIN dwh.currencies CUR2
                        ON ER.CURRENCY_KEY = CUR2.CURRENCY_KEY
                    WHERE CUR1.valid_to_dttm > SYSDATE + 100
                    AND   CUR2.valid_to_dttm > SYSDATE + 100
                    AND   CUR1.CURRENCY_LETTER_CD = 'RUB'
                    AND   CUR2.CURRENCY_LETTER_CD = 'EUR'
                    ) cli_ex2
             ON     cli_ex2.BASE_BEGIN_DT <= T.SNAPSHOT_DT
                AND cli_ex2.BASE_END_DT > T.SNAPSHOT_DT
                AND cli_ex2.BEGIN_DT <= T.SNAPSHOT_DT
                AND cli_ex2.END_DT > T.SNAPSHOT_DT
                AND cli_ex2.ex_rate_dt = t.snapshot_dt
                AND cli_ex2.valid_to_dttm > SYSDATE + 100
          LEFT JOIN
          (  SELECT snapshot_dt,
                    snapshot_cd,
                    contract_key,
                    CASE
                       WHEN SUM (plan_pay_amt) <> 0
                       THEN
                          CASE
                             WHEN SUM (cf) / SUM (plan_pay_amt) / 365 < 1
                             THEN
                                1
                             WHEN SUM (cf) / SUM (plan_pay_amt) / 365 > 5
                             THEN
                                5
                             ELSE
                                SUM (cf) / SUM (plan_pay_amt) / 365
                          END
                       ELSE
                          0
                    END
                       AS M,
                    MAX (PAY_DT) AS FINISH_DT
               FROM (SELECT t.snapshot_dt,
                            t.snapshot_cd,
                            t.contract_key,
                            t.PAY_DT,
                            t.plan_pay_amt,
                            t.pay_dt - t.snapshot_dt days,
                            t.plan_pay_amt * (t.pay_dt - t.snapshot_dt) cf
                       FROM DM.DM_REPAYMENT_SCHEDULE t
                      WHERE 1 = 1                       --t.CONTRACT_KEY=17737
                                  --and t.SNAPSHOT_DT='28.02.2015'
                            AND t.PAY_DT > t.snapshot_dt)
           GROUP BY snapshot_dt, snapshot_cd, contract_key) New_m
             ON     new_m.contract_key = t2.contract_key
                AND new_m.SNAPSHOT_Dt = t.snapshot_dt
                AND new_m.SNAPSHOT_CD = t.snapshot_CD
         left join MAX_OVD_DAYS MODS 
             on     T.SNAPSHOT_DT = MODS.SNAPSHOT_DT
                and t.client_key = MODS.client_key
WHERE t.snapshot_dt = p_REPORT_DT;
   dm.u_log(p_proc => 'DM.P_DM_RISK_BASE_TABLE',
           p_step => 'insert into dm.DM_RISK_BASE_TABLE',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');     
COMMIT;

END;
/

