CREATE OR REPLACE PROCEDURE DM.p_DM_RISK_EC_TABLE2_NSBU (
    p_REPORT_DT date,
    p_SNAPSHOT_CD varchar2
)


is


BEGIN

    delete from DM_RISK_EC_TABLE2_NSBU 
    where SNAPSHOT_DT = p_REPORT_DT and SNAPSHOT_CD = p_SNAPSHOT_CD;

    insert into DM_RISK_EC_TABLE2_NSBU
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
   WITH tt
        AS (SELECT /*+ materialize */
                  *
              FROM dwh.CONTRACTS c
             WHERE     c.contract_leasing_key IS NULL
                   AND NVL (c.rehiring_flg, '0') = '0'
                   AND c.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy'))
   SELECT t66.credit_rating_cd,
          nxk.k,
          base.b_NSBU,
          nxk.nx,
          t.snapshot_dt,
          base_prev.snapshot_dt AS PREV_NSBU_SNAPSHOT_DT,
          TRUNC ( (t.SNAPSHOT_DT+1), 'Q')-1 AS IFRS_SNAPSHOT_DT,
          t.CLIENT_NAM,
          t4.CLIENT_ID,
          t5.GROUP_RU_NAM,
          t5.GROUP_CD,
          t9.ACTIVITY_TYPE_RU_DESC,
          t21.org_type_en_nam,
          --IFRS_CGP.RF_GOV_FLG,
          t8.COUNTRY_CD AS reg_country_cd,
          t3.LEASING_SUBJECT_DESC,
          T20.leasing_subject_type_cd,
          T7.rating_agency_en_nam,
          cli_d.CAR_DEFAULT_FLG,
          BASE.R,
          base.corr_r,
          cli_d.REVENUE_AMT,
          t10.BUSINESS_CATEGORY_CD AS SME_FLG,
          1 AS OPER_TYPE_CON,
          t10.BUSINESS_CAT_RU_NAM,
          t8.COUNTRY_RU_NAM AS REG_COUNTRY_NAM,
          con_d.type_oc_ipo,
          t9.ACTIVITY_TYPE_CD,
          CASE
             WHEN t4.MEMBER_KEY IS NOT NULL AND t4.MEMBER_KEY <> 1 THEN 'Yes'
             ELSE 'No'
          END
             AS VTB_FLG,
          t.CONTRACT_NUM,
          t2.CONTRACT_ID_CD,
          base.SP_RAT_CD,
          1 AS CCF,
          base.PD AS SPD,
          t20.LGD AS LGD_EC,
          base.OLD_M,
          base.M,
          t9.ACTIVITY_TYPE_CD AS OTRASL_CD,
          '2' AS BUSINESS_TYPE,
          cli_d.RATING_POINTS,
          --CLIENT_CATEGORY,
          t11.COUNTRY_CD AS risk_coun_CD,
          t12.CURRENCY_LETTER_CD,
          NVL (t.SNAPSHOT_DT - t.OVERDUE_DT, 0) AS OVD_DAYS,
          t.OVERDUE_DT,
          t.xirr_rate,
          con_d.AGG_LIST_CROUP_CD,
          t11.COUNTRY_RU_NAM AS risk_country_nam,
          T16_r.RATE_CD AS risk_country_rating,
          t18.VAT_RATE,
          ban.BANK_NAM,
          cli_d.BENEF_GROUP_CD,
          cli_d.DIVISION_CD,
          sec.val_en_desc AS SECURITY_TYPE_KEY,
          base.TOT_NOVAT_AMT,
          base.TOT_NOVAT_RUR_AMT,
          base_PREV.TOT_NOVAT_AMT AS PREV_TOT_NOVAT_AMT,
          base_PREV.TOT_NOVAT_RUR_AMT AS PREV_TOT_NOVAT_RUR_AMT,
          base.TOT_VAT_AMT,
          base.TOT_VAT_RUR_AMT,
          base_PREV.TOT_VAT_AMT AS PREV_TOT_VAT_AMT,
          base_PREV.TOT_VAT_RUR_AMT AS PREV_TOT_VAT_RUR_AMT,
          con_d.BAD_STATUS_CD AS PZ_PPZ,
          con_d.BAD_STATUS_DT AS PZ_PPZ_DT,
          con_d.IPO_FLG,
          con_d.DEAL_CIS_TYPE,
          con_d.IPO_FLG AS IND_PRIZN_OBESC,
          '-' AS SWIFT_CD,
          t2.OPEN_DT AS OPER_START,
          t.END_DT,
          base.tot_amt AS NSBU_GROSS_BALANCE, --Сумма требований (Gross balance), млн. руб., НСБУ ПЕРЕНОСИТСЯ ИЗ ПРЕДЫДУЩЕГО ПЕРИОДА?????????????
          base_prev.tot_amt AS NSBU_GROSS_BALANCE_PREV,
          base.tot_rur_amt AS NSBU_rur_EAD, --Сумма под риском (EAD), млн. руб., НСБУ,
          base_prev.tot_rur_amt AS NSBU_rur_EAD_PREV,
          base.PD * t20.LGD * base.tot_RUR_amt AS NSBU_EL, --Ожидаемые потери (EL), млн. руб., НСБУ,
          base.PD * t20.LGD * base_prev.tot_RUR_amt AS NSBU_EL_PREV,
          nxk.K * base.tot_RUR_amt AS NSBU_UL, --Неожидаемые потери (UL), млн. руб., НСБУ
          nxk.K * base_prev.tot_RUR_amt AS NSBU_UL_PREV,
          base.tot_amt * base.PD * t20.LGD * 0.5 AS NSBU_PROVISIONS, --Резервы под обесценение (Provisions), млн. руб., НСБУ
          base_prev.tot_amt * base.PD * t20.LGD * 0.5 AS NSBU_PROVISIONS_PREV,
          CASE
             WHEN base.tot_amt < 0
             THEN
                  base.PD * t20.LGD * base.TOT_RUR_AMT
                + nxk.K * base.TOT_RUR_AMT
                + base.TOT_RUR_AMT * base.PD * t20.LGD * 0.5
             ELSE
                GREATEST (
                   0,
                   (  base.PD * t20.LGD * base.TOT_RUR_AMT
                    + nxk.K * base.TOT_RUR_AMT
                    + base.TOT_RUR_AMT * base.PD * t20.LGD * 0.5))
          END
             AS NSBU_CAR_RUR,   --Требования к капиталу (CAR), млн. руб., НСБУ
          CASE
             WHEN base_prev.tot_amt < 0
             THEN
                  base.PD * t20.LGD * base_prev.TOT_RUR_AMT
                + nxk.K * base_prev.TOT_RUR_AMT
                + base_prev.TOT_RUR_AMT * base.PD * t20.LGD * 0.5
             ELSE
                GREATEST (
                   0,
                   (  base.PD * t20.LGD * base_prev.TOT_RUR_AMT
                    + nxk.K * base_prev.TOT_RUR_AMT
                    + base_prev.TOT_RUR_AMT * base.PD * t20.LGD * 0.5))
          END
             AS NSBU_CAR_RUR_PREV,
            (CASE
                WHEN base.tot_amt < 0
                THEN
                     base.PD * t20.LGD * base.TOT_RUR_AMT
                   + nxk.K * base.TOT_RUR_AMT
                   + base.TOT_RUR_AMT * base.PD * t20.LGD * 0.5
                ELSE
                   GREATEST (
                      0,
                      (  base.PD * t20.LGD * base.TOT_RUR_AMT
                       + nxk.K * base.TOT_RUR_AMT
                       + base.TOT_RUR_AMT * base.PD * t20.LGD * 0.5))
             END)
          / DECODE (base.tot_rur_amt, 0, -1000000000)
             AS NSBUCAR_RUR_PRC,
            (CASE
                WHEN base_prev.tot_amt < 0
                THEN
                     base.PD * t20.LGD * base_prev.TOT_RUR_AMT
                   + nxk.K * base_prev.TOT_RUR_AMT
                   + base_prev.TOT_RUR_AMT * base.PD * t20.LGD * 0.5
                ELSE
                   GREATEST (
                      0,
                      (  base.PD * t20.LGD * base_prev.TOT_RUR_AMT
                       + nxk.K * base_prev.TOT_RUR_AMT
                       + base_prev.TOT_RUR_AMT * base.PD * t20.LGD * 0.5))
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
          t66.CREDIT_RATING AS RATE_LOCAL_MODEL, --Рейтинг по локальной модели (если нет количества баллов)
          con_d.GWL_CD AS GWL,                            --GLOBAL_WATCH_LIST,
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
                        GREATEST (base.tot_amt * t20.LGD - (0), 0)
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
                             * t20.LGD,
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
          CASE WHEN t3.AUTO_FLG = 1 THEN 'Да' ELSE 'Нет' END AS AUTO_FLG,
          CASE
             WHEN t5.GROUP_RU_NAM IS NULL THEN t.CLIENT_NAM
             ELSE t5.GROUP_RU_NAM
          END
             AS GROUP_OR_CLIENT,
          con_d.ind_col_ASD AS IND_COL_ASD, --individually assessed от проведения индивидуальной оценки*/
          sysdate,
          p_SNAPSHOT_CD
     FROM tt t2
          LEFT JOIN dm.dm_cgp t
             ON     t2.CONTRACT_KEY = t.CONTRACT_KEY
                AND SNAPSHOT_CD = 'Основной КИС'
                AND t.SNAPSHOT_DT = p_REPORT_DT
          LEFT JOIN DWH.LEASING_CONTRACTS t3
             ON     t3.CONTRACT_KEY = t.CONTRACT_KEY
                AND t3.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
          LEFT JOIN dwh.clients t4
             ON     t4.CLIENT_KEY = t2.CLIENT_KEY
                AND t4.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
          LEFT JOIN DWH.GROUPS t5
             ON     t5.GROUP_KEY = t4.GROUP_KEY
                AND t5.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
          --клиентские рейтинги ----------------------------------------
          --[apolyakov 21.03.2016]: добавление нового справочника для ЭК
          LEFT JOIN dwh.REF_CLIENT_RATINGS_EC cli_r
             ON     cli_r.client_key = t4.client_key
                AND t.snapshot_dt BETWEEN cli_r.begin_dt AND cli_r.end_dt
                AND cli_r.VALID_TO_DTTM =
                       TO_DATE ('01.01.2400', 'dd.mm.yyyy')
          --рейтинг!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!--------------------------
          LEFT JOIN DWH.CREDIT_RATINGS t66
             ON     t66.CREDIT_RATING_KEY = t.CREDIT_RATING_KEY
                AND t66.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                AND t66.BEGIN_DT <= t.SNAPSHOT_DT
                AND t66.END_DT >= t.SNAPSHOT_DT
                AND t66.AGENCY_KEY = 4
          LEFT JOIN DWH.CREDIT_RATINGS t6
             ON     t6.CREDIT_RATING_KEY = cli_r.RATING_KEY
                AND t6.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                AND t6.BEGIN_DT <= t.SNAPSHOT_DT
                AND t6.END_DT >= t.SNAPSHOT_DT
          LEFT JOIN DWH.RATING_AGENCIES t7
             ON     t7.RATING_AGENCY_KEY = t6.AGENCY_KEY
                AND t7.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                AND t7.BEGIN_DT <= t.SNAPSHOT_DT
                AND t7.END_DT >= t.SNAPSHOT_DT
          --рейтинг !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!---------------------------
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
          LEFT JOIN dwh.org_types t21
             ON     t21.org_type_key = t4.org_type_key
                AND t21.valid_to_dttm > SYSDATE + 100
                AND t.snapshot_dt BETWEEN t21.begin_dt AND t21.end_dt
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
          LEFT JOIN DWH.REF_COUNTRY_RATING T16_r
             ON T16_r.COUNTRY_KEY = t11.COUNTRY_KEY
            AND T16_r.BEGIN_DT <= t.SNAPSHOT_DT
            AND T16_r.END_DT > t.SNAPSHOT_DT
            AND T16_r.VALID_TO_DTTM > SYSDATE + 100
          LEFT JOIN dwh.VAT t18
             ON     t18.BRANCH_KEY = t.BRANCH_KEY
                AND t18.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                AND t.SNAPSHOT_DT BETWEEN t18.BEGIN_DT AND t18.END_DT
          LEFT JOIN dwh.risk_EC_CONTRACT_DATA CON_D
             ON con_d.CONTRACT_key = t2.contract_key
            AND con_d.BEGIN_DT <= t.SNAPSHOT_DT
            AND con_d.END_DT > t.SNAPSHOT_DT
            AND con_d.VALID_TO_DTTM > SYSDATE + 100
          LEFT JOIN dwh.risk_EC_CLIENT_DATA CLI_D
             ON cli_d.CLIENT_key = t4.CLIENT_key
            AND cli_d.BEGIN_DT <= t.SNAPSHOT_DT
            AND cli_d.END_DT > t.SNAPSHOT_DT
            AND cli_d.VALID_TO_DTTM > SYSDATE + 100
          LEFT JOIN DWH.REF_LGD t19
             ON     t19.LEASING_SUBJECT_TYPE_CD =
                       (CASE
                           WHEN t2.CONtract_num LIKE 'АЛ%'
                           THEN
                              'Автолизинг'
                           ELSE
                              TRIM (CON_D.ASSET_TYPE_COL)
                        END)
                AND t19.LGD_TYPE_CD = 'RES'
                AND t19.BEGIN_DT <= t.SNAPSHOT_DT
                AND t19.END_DT > t.SNAPSHOT_DT
                AND t19.VALID_TO_DTTM > SYSDATE + 100
          LEFT JOIN DWH.REF_LGD t20
             ON     t20.LEASING_SUBJECT_TYPE_CD =
                       (CASE
                           WHEN t2.CONtract_num LIKE 'АЛ%'
                           THEN
                              'Автолизинг'
                           ELSE
                              TRIM (con_d.ASSET_TYPE_EC)
                        END)
                AND t20.LGD_TYPE_CD = 'EC'
                AND t20.BEGIN_DT <= t.SNAPSHOT_DT
                AND t20.END_DT > t.SNAPSHOT_DT
                AND t20.VALID_TO_DTTM > SYSDATE + 100
          LEFT JOIN
          (  SELECT snapshot_dt,
                    snapshot_cd,
                    contract_key,
                    CASE
                       WHEN SUM (plan_pay_amt) <> 0
                       THEN
                          CASE
                             WHEN   SUM (cf)
                                  / DECODE (SUM (plan_pay_amt), 0, -1000000000)
                                  / 365 < 1
                             THEN
                                1
                             WHEN   SUM (cf)
                                  / DECODE (SUM (plan_pay_amt), 0, -1000000000)
                                  / 365 > 5
                             THEN
                                5
                             ELSE
                                  SUM (cf)
                                / DECODE (SUM (plan_pay_amt), 0, -1000000000)
                                / 365
                          END
                       ELSE
                          0
                    END
                       AS M
               FROM (SELECT t.snapshot_dt,
                            t.snapshot_cd,
                            t.contract_key,
                            t.PAY_DT,
                            t.plan_pay_amt,
                            t.pay_dt - t.snapshot_dt + 1 days,
                            t.plan_pay_amt * (t.pay_dt - t.snapshot_dt + 1) cf
                       FROM DM.DM_REPAYMENT_SCHEDULE t
                      WHERE 1 = 1                       --t.CONTRACT_KEY=17737
                                  --and t.SNAPSHOT_DT='28.02.2015'
                            AND t.PAY_DT > t.snapshot_dt)
           GROUP BY snapshot_dt, snapshot_cd, contract_key) New_m
             ON     new_m.contract_key = t.contract_key
                AND new_m.SNAPSHOT_Dt = t.snapshot_dt
                AND new_m.SNAPSHOT_CD = t.snapshot_CD
          LEFT JOIN dwh.V_RISK_EC_BASE_NSBU base
             ON     base.snapshot_cd = t.snapshot_cd
                AND base.snapshot_dt = t.snapshot_dt
                AND base.contract_key = t.contract_key
          LEFT JOIN dwh.V_RISK_EC_BASE_NSBU base_prev
             ON     base_prev.snapshot_cd = t.snapshot_cd
                AND base_prev.snapshot_dt = ADD_MONTHS (t.snapshot_dt, -1)
                AND base_prev.contract_key = t.contract_key
          LEFT JOIN dwh.V_RISK_EC_NXK_NSBU nxk
             ON     nxk.snapshot_dt = base.snapshot_dt
                AND nxk.CONTRACT_ID_CD = base.CONTRACT_ID_CD
                AND nxk.snapshot_cd = base.snapshot_cd
          LEFT JOIN dwh.banks ban
             ON     ban.valid_to_dttm > SYSDATE + 100
                AND ban.bank_key = con_d.bank_key
          LEFT JOIN dwh.securities_ref sec
             ON     con_d.security_type_key = sec.val_key
                AND sec.ref_key = 6
                AND sec.valid_to_dttm > SYSDATE + 100
    WHERE t.snapshot_dt =  p_REPORT_DT
/*where t2.contract_leasing_key is null and nvl(t2.rehiring_flg, 0) = 0
  AND t2.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')*/
;

      
      commit;
END;
/

