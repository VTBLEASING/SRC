CREATE OR REPLACE PROCEDURE DM.p_DM_RISK_TABLE2_NSBU (
    p_REPORT_DT date,
    p_SNAPSHOT_CD varchar2
)


is


BEGIN

    delete from dm.DM_RISK_EC_TABLE2_NSBU 
    where SNAPSHOT_DT = p_REPORT_DT and SNAPSHOT_CD = p_SNAPSHOT_CD;

    insert into dm.DM_RISK_EC_TABLE2_NSBU
    (      
    CREDIT_RATING_CD,
    K,
    B_NSBU,
    NX,
    SNAPSHOT_DT,
    PREV_NSBU_SNAPSHOT_DT,
    IFRS_SNAPSHOT_DT,
    CLIENT_NAM,
    CLIENT_ID,
    GROUP_RU_NAM,
    GROUP_CD,
    ACTIVITY_TYPE_RU_DESC,
    ORG_TYPE_EN_NAM,
    REG_COUNTRY_CD,
    LEASING_SUBJECT_DESC,
    LEASING_SUBJECT_TYPE_CD,
    RATING_AGENCY_EN_NAM,
    CAR_DEFAULT_FLG,
    R,
    CORR_R,
    REVENUE_AMT,
    SME_FLG,
    OPER_TYPE_CON,
    BUSINESS_CAT_RU_NAM,
    REG_COUNTRY_NAM,
    TYPE_OC_IPO,
    ACTIVITY_TYPE_CD,
    VTB_FLG,
    CONTRACT_NUM,
    CONTRACT_ID_CD,
    SP_RAT_CD,
    CCF,
    SPD,
    LGD_EC,
    OLD_M,
    M,
    OTRASL_CD,
    BUSINESS_TYPE,
    RATING_POINTS,
    RISK_COUN_CD,
    CURRENCY_LETTER_CD,
    OVD_DAYS,
    OVERDUE_DT,
    XIRR_RATE,
    AGG_LIST_CROUP_CD,
    RISK_COUNTRY_NAM,
    RISK_COUNTRY_RATING,
    VAT_RATE,
    BANK_NAM,
    BENEF_GROUP_CD,
    DIVISION_CD,
    SECURITY_TYPE_KEY,
    TOT_NOVAT_AMT,
    TOT_NOVAT_RUR_AMT,
    PREV_TOT_NOVAT_AMT,
    PREV_TOT_NOVAT_RUR_AMT,
    TOT_VAT_AMT,
    TOT_VAT_RUR_AMT,
    PREV_TOT_VAT_AMT,
    PREV_TOT_VAT_RUR_AMT,
    PZ_PPZ,
    PZ_PPZ_DT,
    IPO_FLG,
    DEAL_CIS_TYPE,
    IND_PRIZN_OBESC,
    SWIFT_CD,
    OPER_START,
    END_DT,
    NSBU_GROSS_BALANCE,
    NSBU_GROSS_BALANCE_PREV,
    NSBU_RUR_EAD,
    NSBU_RUR_EAD_PREV,
    NSBU_EL,
    NSBU_EL_PREV,
    NSBU_UL,
    NSBU_UL_PREV,
    NSBU_PROVISIONS,
    NSBU_PROVISIONS_PREV,
    NSBU_CAR_RUR,
    NSBU_CAR_RUR_PREV,
    NSBUCAR_RUR_PRC,
    PREV_NSBUCAR_RUR_PRC,
    NSBU_NIL_AMT,
    NSBU_NIL_AMT_RUR,
    PREV_NSBU_NIL_AMT,
    PREV_NSBU_NIL_AMT_RUR,
    OVERDUE_NOVAT_AMT,
    OVD_NOVAT_RUR,
    PREV_OVERDUE_NOVAT_AMT,
    PREV_OVD_NOVAT_RUR,
    OVERDUE_AMT,
    OVD_RUR,
    PREV_OVERDUE_AMT,
    PREV_OVD_RUR,
    NSBU_NIL_AMT_PREV,
    SLX,
    RATE_LOCAL_MODEL,
    GWL,
    PD_COUNTRY,
    EL_COUNTRY_RISK,
    PRIZNAK_PROBL_COUNTRY_LIM,
    MIR_CODE,
    MIR_CODE_NEW,
    AUTO_FLG,
    GROUP_OR_CLIENT,
    IND_COL_ASD,
    INSERT_DT,
    SNAPSHOT_CD
    )
      SELECT base.credit_rating_cd,
          base.k,
          base.b_NSBU,
          base.nx,
          base.snapshot_dt,
          base_prev.snapshot_dt AS PREV_NSBU_SNAPSHOT_DT,
          TRUNC ( (base.SNAPSHOT_DT+1), 'Q')-1 AS IFRS_SNAPSHOT_DT,
          base.CLIENT_NAM,
          base.CLIENT_ID,
          base.GROUP_RU_NAM,
          base.GROUP_ID GROUP_CD,
          base.ACTIVITY_TYPE_RU_DESC,
          base.org_type_en_nam,
          --IFRS_CGP.RF_GOV_FLG,
          base.reg_country_cd,
          base.LEASING_SUBJECT_DESC,
          base.LEASING_SUBJECT_TYPE_EC,
          base.rating_agency_en_nam,
          base.CAR_DEFAULT_FLG,
          base.R,
          base.corr_r,
          base.REVENUE_AMT,
          base.SME_FLG,
          1 OPER_TYPE_CON,
          base.BUSINESS_CAT_RU_NAM,
          base.REG_COUNTRY_NAM,
          base.type_oc_ipo,
          base.ACTIVITY_TYPE_CD,
          base.VTB_FLG,
          base.CONTRACT_NUM,
          base.CONTRACT_ID_CD,
          base.SP_RAT_CD,
          1 AS CCF,
          base.PD AS SPD,
          base.LGD_EC,
          base.OLD_M,
          base.M,
          base.ACTIVITY_TYPE_CD AS OTRASL_CD,
          '2' AS BUSINESS_TYPE,
          base.RATING_POINTS,
          --CLIENT_CATEGORY,
          base.risk_coun_CD,
          base.CURRENCY_LETTER_CD,
          base.OVD_DAYS,
          base.OVERDUE_DT,
          base.xirr_rate,
          base.AGG_LIST_CROUP_CD,
          base.risk_country_nam,
          base.risk_country_rating,
          base.VAT_RATE,
          base.BANK_NAM,
          base.BENEF_GROUP_CD,
          base.DIVISION_CD,
          base.SECURITY_TYPE_KEY,
          base.TOT_NOVAT_AMT,
          base.TOT_NOVAT_RUR_AMT,
          base_PREV.TOT_NOVAT_AMT AS PREV_TOT_NOVAT_AMT,
          base_PREV.TOT_NOVAT_RUR_AMT AS PREV_TOT_NOVAT_RUR_AMT,
          base.TOT_VAT_AMT,
          base.TOT_VAT_RUR_AMT,
          base_PREV.TOT_VAT_AMT AS PREV_TOT_VAT_AMT,
          base_PREV.TOT_VAT_RUR_AMT AS PREV_TOT_VAT_RUR_AMT,
          base.PZ_PPZ,
          base.PZ_PPZ_DT,
          base.IPO_FLG,
          base.DEAL_CIS_TYPE,
          base.IND_PRIZN_OBESC,
          '-' AS SWIFT_CD,
          base.OPER_START,
          base.END_DT,
          base.tot_amt AS NSBU_GROSS_BALANCE, --Сумма требований (Gross balance), млн. руб., НСБУ ПЕРЕНОСИТСЯ ИЗ ПРЕДЫДУЩЕГО ПЕРИОДА?????????????
          base_prev.tot_amt AS NSBU_GROSS_BALANCE_PREV,
          base.tot_rur_amt AS NSBU_rur_EAD, --Сумма под риском (EAD), млн. руб., НСБУ,
          base_prev.tot_rur_amt AS NSBU_rur_EAD_PREV,
          base.PD * base.LGD_EC * base.tot_RUR_amt AS NSBU_EL, --Ожидаемые потери (EL), млн. руб., НСБУ,
          base.PD * base.LGD_EC * base_prev.tot_RUR_amt AS NSBU_EL_PREV,
          base.K * base.tot_RUR_amt AS NSBU_UL, --Неожидаемые потери (UL), млн. руб., НСБУ
          base.K * base_prev.tot_RUR_amt AS NSBU_UL_PREV,
          base.PROVISIONS_AMT_RUB AS NSBU_PROVISIONS, --Резервы под обесценение (Provisions), млн. руб., НСБУ
          base_prev.PROVISIONS_AMT_RUB AS NSBU_PROVISIONS_PREV,
          base.CAR AS NSBU_CAR_RUR,   --Требования к капиталу (CAR), млн. руб., НСБУ
          CASE
             WHEN base_prev.tot_amt < 0
             THEN
                  base.PD * base.LGD_EC * base_prev.TOT_RUR_AMT
                + base.K * base_prev.TOT_RUR_AMT
                + base_prev.TOT_RUR_AMT * base.PD * base.LGD_EC * 0.5
             ELSE
                GREATEST (
                   0,
                   (  base.PD * base.LGD_EC * base_prev.TOT_RUR_AMT
                    + base.K * base_prev.TOT_RUR_AMT
                    + base_prev.TOT_RUR_AMT * base.PD * base.LGD_EC * 0.5))
          END
             AS NSBU_CAR_RUR_PREV,
            (CASE
                WHEN base.tot_amt < 0
                THEN
                     base.PD * base.LGD_EC * base.TOT_RUR_AMT
                   + base.K * base.TOT_RUR_AMT
                   + base.TOT_RUR_AMT * base.PD * base.LGD_EC * 0.5
                ELSE
                   GREATEST (
                      0,
                      (  base.PD * base.LGD_EC * base.TOT_RUR_AMT
                       + base.K * base.TOT_RUR_AMT
                       + base.TOT_RUR_AMT * base.PD * base.LGD_EC * 0.5))
             END)
          / DECODE (base.tot_rur_amt, 0, -1000000000)
             AS NSBUCAR_RUR_PRC,
            (CASE
                WHEN base_prev.tot_amt < 0
                THEN
                     base.PD * base.LGD_EC * base_prev.TOT_RUR_AMT
                   + base.K * base_prev.TOT_RUR_AMT
                   + base_prev.TOT_RUR_AMT * base.PD * base.LGD_EC * 0.5
                ELSE
                   GREATEST (
                      0,
                      (  base.PD * base.LGD_EC * base_prev.TOT_RUR_AMT
                       + base.K * base_prev.TOT_RUR_AMT
                       + base_prev.TOT_RUR_AMT * base.PD * base.LGD_EC * 0.5))
             END)
          / DECODE (base_prev.tot_rur_amt, 0, -1000000000)
             AS PREV_NSBUCAR_RUR_PRC,
          base.term_amt AS NSBU_NIL_AMT,
          base.TERM_RUR AS NSBU_NIL_AMT_RUR,
          base_prev.term_amt AS PREV_NSBU_NIL_AMT,
          base_prev.TERM_RUR AS PREV_NSBU_NIL_AMT_RUR,
          base.OVERDUE_NOVAT_AMT,
          base.OVD_NOVAT_RUR,
          base_prev.OVERDUE_NOVAT_AMT AS PREV_OVERDUE_NOVAT_AMT,
          base_prev.OVD_NOVAT_RUR AS PREV_OVD_NOVAT_RUR,
          base.OVERDUE_AMT,
          base.OVD_RUR,
          base_prev.OVERDUE_AMT AS PREV_OVERDUE_AMT,
          base_prev.OVD_RUR AS PREV_OVD_RUR,
          base_prev.term_amt AS NSBU_NIL_AMT_PREV,
          '-' AS SLX,                                    --SLX код при наличии
          base.RATE_LOCAL_MODEL, --Рейтинг по локальной модели (если нет количества баллов)
          base.GWL,                            --GLOBAL_WATCH_LIST,
          CASE
             WHEN base.PD > 0.9 THEN 1
             ELSE CASE WHEN base.PD > 0.3 THEN 0.4 ELSE base.PD END
          END
             AS PD_COUNTRY,
            CASE
               WHEN    (t4.MEMBER_KEY IS NOT NULL AND t4.MEMBER_KEY <> 1)
                    OR t11.COUNTRY_CD = '643'
               THEN
                  0
               ELSE
                  CASE
                     WHEN    (NVL (t.SNAPSHOT_DT - t.OVERDUE_DT, 0) > 90)
                          /*or GWL=8*/
                          OR (CASE
                                 WHEN base.PD > 0.9
                                 THEN
                                    1
                                 ELSE
                                    CASE
                                       WHEN base.PD > 0.3 THEN 0.4
                                       ELSE base.PD
                                    END
                              END) > 0.9
                     THEN
                        GREATEST (base.tot_amt * base.LGD_EC - (0), 0)
                     ELSE
                          GREATEST (
                               (CASE
                                   WHEN base.PD > 0.9
                                   THEN
                                      1
                                   ELSE
                                      CASE
                                         WHEN base.PD > 0.3 THEN 0.4
                                         ELSE base.PD
                                      END
                                END)
                             * base.LGD_EC,
                             t17.PD * 0.2)
                        * base.tot_amt
                  END
            END
          + CASE
               WHEN    (t4.MEMBER_KEY IS NOT NULL AND t4.MEMBER_KEY <> 1)
                    OR t11.COUNTRY_CD = '643'
               THEN
                  0
               ELSE
                  CASE
                     WHEN    (NVL (t.SNAPSHOT_DT - t.OVERDUE_DT, 0) > 90) /*or GWL=8*/
                          OR base.PD > 0.9
                     THEN
                        GREATEST (
                           t16.sanc_pr,
                           t17.PD * 0.2 * GREATEST (base.tot_amt - 0, 0))
                     ELSE
                        GREATEST (t16.sanc_pr, t17.PD * 0.2)
                  END
            END
             AS EL_COUNTRY_RISK,
          CASE
             WHEN base.PD > 0.9 OR NVL (t.SNAPSHOT_DT - t.OVERDUE_DT, 0) > 90 /*or GWL=7*/
             THEN
                1
             ELSE
                0
          END
             AS PRIZNAK_PROBL_COUNTRY_LIM,
          --org.country_cd AS ORG_COUNTR,
          /*по бранчу определяем по справочнику страну ДБ*/
          'LND_017' AS Mir_code,
          'LND_017_CIB' AS Mir_code_NEW,
          base.AUTO_FLG,
          base.GROUP_OR_CLIENT,
          base.IND_COL_ASD, --individually assessed от проведения индивидуальной оценки*/
          sysdate,
          p_SNAPSHOT_CD
     FROM dm.DM_RISK_BASE_TABLE base
          LEFT JOIN dm.DM_RISK_BASE_TABLE base_prev
             ON     base_prev.CONTRACT_KEY = base.CONTRACT_KEY
                AND base_prev.snapshot_cd = base.snapshot_cd
                AND base_prev.snapshot_dt = ADD_MONTHS (base.snapshot_dt, -1)
          LEFT JOIN dm.dm_cgp t
             ON     base.CONTRACT_KEY = t.CONTRACT_KEY
                AND base.snapshot_dt = t.snapshot_dt
                AND t.SNAPSHOT_CD = 'Основной КИС'
          LEFT JOIN dwh.clients t4
             ON     t4.CLIENT_KEY = t.CLIENT_KEY
                AND t4.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
          LEFT JOIN DWH.COUNTRIES t11
             ON     t11.country_key = t.RISK_COUNTRY_KEY
                AND t11.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                AND t11.BEGIN_DT <= t.SNAPSHOT_DT
                AND t11.END_DT >= t.SNAPSHOT_DT
          --рейтинг !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!---------------------------
          LEFT JOIN DWH.COUNTRIES t8
             ON     t8.COUNTRY_KEY = t.REG_COUNTRY_KEY
                AND t8.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                AND t8.BEGIN_DT <= t.SNAPSHOT_DT
                AND t8.END_DT >= t.SNAPSHOT_DT
          -- [apolyakov 21.03.2016]: связка не по CONTRACT_CD, а пое KEY + историчность
          LEFT JOIN DWH.REF_COUNTRY_RATING T16
             ON T16.COUNTRY_KEY = t8.COUNTRY_KEY
            AND T16.BEGIN_DT <= t.SNAPSHOT_DT
            AND T16.END_DT > t.SNAPSHOT_DT
            AND T16.VALID_TO_DTTM > SYSDATE + 100
          LEFT JOIN dwh.REF_SP_PD t17 
             ON T16.SP_CALC_RATE_CD = t17.SP_RATE_CD
            AND t17.BEGIN_DT <= t.SNAPSHOT_DT
            AND t17.END_DT > t.SNAPSHOT_DT
            AND t17.VALID_TO_DTTM > SYSDATE + 100
WHERE base.snapshot_dt =  p_REPORT_DT;

      
      commit;
END;
/

