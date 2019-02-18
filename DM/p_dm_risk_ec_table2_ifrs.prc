CREATE OR REPLACE PROCEDURE DM.p_DM_RISK_EC_TABLE2_IFRS (
    p_REPORT_DT date,
    p_SNAPSHOT_CD varchar2
)


is

    v_REPORT_DT date  := p_REPORT_DT - 1;
    


BEGIN

    delete from DM_RISK_EC_TABLE2_IFRS 
    where IFRS_SNAPSHOT_DT = v_REPORT_DT and SNAPSHOT_CD = p_SNAPSHOT_CD;

    insert into DM_RISK_EC_TABLE2_IFRS
    (      
    CREDIT_RATING_CD,
    IFRS_K,
    B_IFRS,
    NX,
    LESSEE,
    IFRS_GROUP_NAM,
    IFRS_BEGIN_DT,
    IFRS_END_DT,
    DAYS_OVERDUE2,
    DAYS_OVERDUE,
    IFRS_VTB_FLG,
    IFRS_SNAPSHOT_DT,
    PREV_IFRS_SNAPSHOT_DT,
    SHORT_CLIENT_RU_NAM,
    CLIENT_ID,
    GROUP_RU_NAM,
    GROUP_CD,
    IFRS_BRANCH_1,
    AGG_LIST_CROUP_CD,
    RISK_COUNTRY_NAM,
    RISK_COUNTRY_RATING,
    RF_GOV_FLG_1,
    IFRS_BRANCH,
    IFRS_EFFECTIVE_RATE,
    IFRS_CLIENT_TYPE,
    NPL_STATUS,
    BANK_NAM,
    BENEF_GROUP_CD,
    DIVISION_CD,
    T12_CLIENT_CATEGORY_CD,
    SECURITY_TYPE,
    IFRS_NIL_SA_CONCCY,
    IFRS_SETTLE_AMT,
    IFRS_TOT_OVD_CONCCY,
    IFRS_TOT_OVD,
    OVD_AMT,
    SETTLE_OVD_AMT,
    IFRS_GROSS_BALANCE_CONCCY,
    IFRS_PROVISIONS_CONCCY,
    PREV_IFRS_NIL_SA_CONCCY,
    PREV_IFRS_NIL,
    PREV_IFRS_SETTLE_AMT,
    PREV_IFRS_TOT_OVD_CONCCY,
    PREV_OVD_AMT,
    PREV_SETTLE_OVD_AMT,
    PREV_IFRS_GROSS_BALANCE_CONCCY,
    PREV_IFRS_PROVISIONS_CONCCY,
    UL_EL_PROVIS,
    PROVIS_ADD,
    TRANS_DIFF,
    ACTIVITY_TYPE_RU_DESC,
    ORG_TYPE_EN_NAM,
    RF_GOV_FLG,
    REG_COUNTRY_CD,
    LEASING_SUBJECT_DESC,
    LEASING_SUBJECT_TYPE_CD,
    RATING_AGENCY_EN_NAM,
    CAR_DEFAULT_FLG,
    R,
    CORR_R,
    REVENUE_AMT,
    SME_FLG,
    LGDRATEALL,
    PDLGDRATEALL,
    OPER_TYPE_CON,
    BUSINESS_CAT_RU_NAM,
    REG_COUNTRY_NAM,
    TYPE_OC_IPO,
    ACTIVITY_TYPE_CD,
    PROVIS_LOSS,
    VTB_FLG,
    CONTRACT_NUM,
    CONTRACT_ID_CD,
    SP_RAT_CD,
    IFRS_GROSS_BALANCE,
    IFRS_GROSS_BALANCE_PREV,
    CCF,
    IFRS_EAD,
    IFRS_EAD_PREV,
    SPD,
    LGD_EC,
    IFRS_OLD_M,
    M,
    IFRS_EL,
    IFRS_EL_PREV,
    IFRS_UL,
    IFRS_UL_PREV,
    PROVISIONS_AMT,
    PROVISIONS_AMT_PREV,
    IFRS_NIL_AMT,
    IFRS_NIL_AMT_PREV,
    IFRS_SETTLE_AMT_PREV,
    IFRS_OVD_AMT,
    IFRS_OVD_AMT_PREV,
    IFRS_SETTLE_OVD_AMT,
    IFRS_SETTLE_OVD_AMT_PREV,
    IFRS_RATE_ALLOW,
    IFRS_RATE_ALLOW_PREV,
    IFRS_106_AMT,
    IFRS_107_AMT,
    IFRS_TRANS_DIFF,
    IFRS_TRANS_DIFF_PREV,
    IFRS_PROVIS_ADD,
    IFRS_PROVIS_ADD_PREV,
    IFRS_CAR,
    IFRS_CAR_PREV,
    IFRS_CAR_PRC,
    IFRS_CAR_PRC_PREV,
    OTRASL_CD,
    BUSINESS_TYPE,
    RATING_POINTS,
    RISK_COUN_CD,
    CURRENCY_LETTER_CD,
    IND_PRIZN_OBESC,
    SWIFT_CD,
    OPER_START,
    SLX,
    RATE_LOCAL_MODEL,
    GWL,
    PD_COUNTRY,
    EL_COUNTRY_RISK,
    PRIZNAK_PROBL_COUNTRY_LIM,
    ORG_COUNTR,
    MIR_CODE,
    MIR_CODE_NEW,
    AUTO_FLG,
    GROUP_OR_CLIENT,
    IND_COL_ASD,
    INSERT_DT,
    SNAPSHOT_CD
    )
     SELECT CREDIT_RATING_CD,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (IFRS_K * IFRS_EAD) / SUM (IFRS_EAD)
            END
               IFRS_K,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (B_IFRS * IFRS_EAD) / SUM (IFRS_EAD)
            END
               B_IFRS,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (NX * IFRS_EAD) / SUM (IFRS_EAD)
            END
               NX,
            LESSEE,
            IFRS_GROUP_NAM,
            MIN (IFRS_BEGIN_DT) IFRS_BEGIN_DT,
            MAX (IFRS_END_DT) IFRS_END_DT,
            MAX (DAYS_OVERDUE2) DAYS_OVERDUE2,
            MAX (DAYS_OVERDUE) DAYS_OVERDUE,
            IFRS_VTB_FLG,
            IFRS_SNAPSHOT_DT,
            PREV_IFRS_SNAPSHOT_DT,
            SHORT_CLIENT_RU_NAM,
            CLIENT_ID,
            GROUP_RU_NAM,
            GROUP_CD,
            IFRS_BRANCH_1,
            AGG_LIST_CROUP_CD,
            RISK_COUNTRY_NAM,
            RISK_COUNTRY_RATING,
            RF_GOV_FLG_1,
            IFRS_BRANCH,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (IFRS_EFFECTIVE_RATE * IFRS_EAD) / SUM (IFRS_EAD)
            END
               IFRS_EFFECTIVE_RATE,
            IFRS_CLIENT_TYPE,
            NPL_STATUS,
            BANK_NAM,
            BENEF_GROUP_CD,
            DIVISION_CD,
            T12_CLIENT_CATEGORY_CD,
            SECURITY_TYPE,
            SUM (IFRS_NIL_SA_CONCCY) IFRS_NIL_SA_CONCCY,
            SUM (IFRS_SETTLE_AMT) IFRS_SETTLE_AMT,
            SUM (IFRS_TOT_OVD_CONCCY) IFRS_TOT_OVD_CONCCY,
            SUM (IFRS_TOT_OVD) IFRS_TOT_OVD,
            SUM (OVD_AMT) OVD_AMT,
            SUM (SETTLE_OVD_AMT) SETTLE_OVD_AMT,
            SUM (IFRS_GROSS_BALANCE_CONCCY) IFRS_GROSS_BALANCE_CONCCY,
            SUM (IFRS_PROVISIONS_CONCCY) IFRS_PROVISIONS_CONCCY,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (PREV_IFRS_NIL_SA_CONCCY * IFRS_EAD) / SUM (IFRS_EAD)
            END
               PREV_IFRS_NIL_SA_CONCCY,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (PREV_IFRS_NIL * IFRS_EAD) / SUM (IFRS_EAD)
            END
               PREV_IFRS_NIL,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (PREV_IFRS_SETTLE_AMT * IFRS_EAD) / SUM (IFRS_EAD)
            END
               PREV_IFRS_SETTLE_AMT,
            SUM (PREV_IFRS_TOT_OVD_CONCCY) PREV_IFRS_TOT_OVD_CONCCY,
            SUM (PREV_OVD_AMT) PREV_OVD_AMT,
            SUM (PREV_SETTLE_OVD_AMT) PREV_SETTLE_OVD_AMT,
            CASE
               WHEN SUM (IFRS_EAD) = 0
               THEN
                  0
               ELSE
                    SUM (PREV_IFRS_GROSS_BALANCE_CONCCY * IFRS_EAD)
                  / SUM (IFRS_EAD)
            END
               PREV_IFRS_GROSS_BALANCE_CONCCY,
            CASE
               WHEN SUM (IFRS_EAD) = 0
               THEN
                  0
               ELSE
                  SUM (PREV_IFRS_PROVISIONS_CONCCY * IFRS_EAD) / SUM (IFRS_EAD)
            END
               PREV_IFRS_PROVISIONS_CONCCY,
            SUM (UL_EL_PROVIS) UL_EL_PROVIS,
            SUM (PROVIS_ADD) PROVIS_ADD,
            SUM (TRANS_DIFF) TRANS_DIFF,
            ACTIVITY_TYPE_RU_DESC,
            ORG_TYPE_EN_NAM,
            RF_GOV_FLG,
            REG_COUNTRY_CD,
            LEASING_SUBJECT_DESC,
            LEASING_SUBJECT_TYPE_CD,
            RATING_AGENCY_EN_NAM,
            CAR_DEFAULT_FLG,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (R * IFRS_EAD) / SUM (IFRS_EAD)
            END
               R,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (CORR_R * IFRS_EAD) / SUM (IFRS_EAD)
            END
               CORR_R,
            REVENUE_AMT,
            SME_FLG,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (LGDRATEALL * IFRS_EAD) / SUM (IFRS_EAD)
            END
               LGDRATEALL,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (PDLGDRATEALL * IFRS_EAD) / SUM (IFRS_EAD)
            END
               PDLGDRATEALL,
            OPER_TYPE_CON,
            BUSINESS_CAT_RU_NAM,
            REG_COUNTRY_NAM,
            TYPE_OC_IPO,
            ACTIVITY_TYPE_CD,
            SUM (PROVIS_LOSS) PROVIS_LOSS,
            VTB_FLG,
            CONTRACT_NUM,
            CONTRACT_ID_CD,
            SP_RAT_CD,
            SUM (IFRS_GROSS_BALANCE) IFRS_GROSS_BALANCE,
            SUM (IFRS_GROSS_BALANCE_PREV) IFRS_GROSS_BALANCE_PREV,
            CCF,
            SUM (IFRS_EAD) IFRS_EAD,
            SUM (IFRS_EAD_PREV) IFRS_EAD_PREV,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (SPD * IFRS_EAD) / SUM (IFRS_EAD)
            END
               SPD,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (LGD_EC * IFRS_EAD) / SUM (IFRS_EAD)
            END
               LGD_EC,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (IFRS_OLD_M * IFRS_EAD) / SUM (IFRS_EAD)
            END
               IFRS_OLD_M,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (M * IFRS_EAD) / SUM (IFRS_EAD)
            END
               M,
            SUM (IFRS_EL) IFRS_EL,
            SUM (IFRS_EL_PREV) IFRS_EL_PREV,
            SUM (IFRS_UL) IFRS_UL,
            SUM (IFRS_UL_PREV) IFRS_UL_PREV,
            SUM (PROVISIONS_AMT) PROVISIONS_AMT,
            SUM (PROVISIONS_AMT_PREV) PROVISIONS_AMT_PREV,
            SUM (IFRS_NIL_AMT) IFRS_NIL_AMT,
            SUM (IFRS_NIL_AMT_PREV) IFRS_NIL_AMT_PREV,
            SUM (IFRS_SETTLE_AMT_PREV) IFRS_SETTLE_AMT_PREV,
            SUM (IFRS_OVD_AMT) IFRS_OVD_AMT,
            SUM (IFRS_OVD_AMT_PREV) IFRS_OVD_AMT_PREV,
            SUM (IFRS_SETTLE_OVD_AMT) IFRS_SETTLE_OVD_AMT,
            SUM (IFRS_SETTLE_OVD_AMT_PREV) IFRS_SETTLE_OVD_AMT_PREV,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (IFRS_RATE_ALLOW * IFRS_EAD) / SUM (IFRS_EAD)
            END
               IFRS_RATE_ALLOW,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (IFRS_RATE_ALLOW_PREV * IFRS_EAD) / SUM (IFRS_EAD)
            END
               IFRS_RATE_ALLOW_PREV,
            SUM (IFRS_106_AMT) IFRS_106_AMT,
            SUM (IFRS_107_AMT) IFRS_107_AMT,
            SUM (IFRS_TRANS_DIFF) IFRS_TRANS_DIFF,
            SUM (IFRS_TRANS_DIFF_PREV) IFRS_TRANS_DIFF_PREV,
            SUM (IFRS_PROVIS_ADD) IFRS_PROVIS_ADD,
            SUM (IFRS_PROVIS_ADD_PREV) IFRS_PROVIS_ADD_PREV,
            SUM (IFRS_CAR) IFRS_CAR,
            SUM (IFRS_CAR_PREV) IFRS_CAR_PREV,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (IFRS_CAR_PRC * IFRS_EAD) / SUM (IFRS_EAD)
            END
               IFRS_CAR_PRC,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (IFRS_CAR_PRC_PREV * IFRS_EAD) / SUM (IFRS_EAD)
            END
               IFRS_CAR_PRC_PREV,
            OTRASL_CD,
            BUSINESS_TYPE,
            RATING_POINTS,
            RISK_COUN_CD,
            CURRENCY_LETTER_CD,
            IND_PRIZN_OBESC,
            SWIFT_CD,
            MIN (OPER_START) OPER_START,
            SLX,
            RATE_LOCAL_MODEL,
            GWL,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (PD_COUNTRY * IFRS_EAD) / SUM (IFRS_EAD)
            END
               PD_COUNTRY,
            CASE
               WHEN SUM (IFRS_EAD) = 0 THEN 0
               ELSE SUM (EL_COUNTRY_RISK * IFRS_EAD) / SUM (IFRS_EAD)
            END
               EL_COUNTRY_RISK,
            PRIZNAK_PROBL_COUNTRY_LIM,
            ORG_COUNTR,
            MIR_CODE,
            MIR_CODE_NEW,
            AUTO_FLG,
            GROUP_OR_CLIENT,
            IND_COL_ASD,
            SYSDATE INSERT_DT,
            p_SNAPSHOT_CD
       FROM (WITH tt
                  AS (SELECT /*+ materialize */
                            *
                        FROM dwh.CONTRACTS c
                       WHERE     c.contract_leasing_key IS NULL
                             AND NVL (c.rehiring_flg, '0') = '0'
                             AND c.VALID_TO_DTTM =
                                    TO_DATE ('01.01.2400', 'dd.mm.yyyy')),
                  tt1
                  AS (SELECT /*+ materialize */
                            a.*
                        FROM dwh.V_RISK_EC_BASE_IFRS a
                        where SNAPSHOT_DT = v_REPORT_DT-- between add_months(p_REPORT_DT, -3) and p_REPORT_DT
                        )
             SELECT t66.credit_rating_cd,
                    nxk.IFRS_K,
                    IFRS_CGP.b_IFRS,
                    nxk.nx,
                    --t.snapshot_dt,
                    ifrs_cgp.lessee,
                    ifrs_cgp.NAME_GROUP AS IFRS_GROUP_NAM,
                    ifrs_cgp.start_dt AS ifrs_begin_dt,
                    ifrs_cgp.end_dt AS ifrs_end_dt,
                    MAX (
                       ifrs_cgp.OVD_DAYS)
                    OVER (
                       PARTITION BY ifrs_cgp.snapshot_dt,
                                    ifrs_cgp.contract_id_CD)
                       AS days_overdue2,
                    ifrs_cgp.OVD_DAYS AS days_overdue,
                    ifrs_cgp.vtb_flg AS ifrs_vtb_flg,
                    IFRS_CGP.SNAPSHOT_DT AS IFRS_SNAPSHOT_DT,
                    IFRS_CGP_PREV.SNAPSHOT_DT AS PREV_IFRS_SNAPSHOT_DT,
                    t4.SHORT_CLIENT_RU_NAM,
                    t4.CLIENT_ID,
                    t5.GROUP_RU_NAM,
                    t5.GROUP_CD,
                    '-' AS ifrs_branch_1,
                    con_d.AGG_LIST_CROUP_CD,
                    t11.COUNTRY_RU_NAM AS risk_country_nam,
                    t16_r.rate_cd AS risk_country_rating,
                    '-' AS rf_gov_FLG_1,
                    IFRS_CGP.LEVEL1 AS IFRS_BRANCH,
                    IFRS_CGP.EFFECTIVE_RATE AS IFRS_EFFECTIVE_RATE,
                    ifrs_cgp.client_type AS ifrs_client_type,
                    CASE
                       WHEN NVL (IFRS_CGP.OVD_DAYS, 0) > 90 THEN 'Yes'
                       ELSE 'No'
                    END
                       AS NPL_STATUS,
                    ban.BANK_NAM,
                    cli_d.BENEF_GROUP_CD,
                    cli_d.DIVISION_CD,
                    t10.BUSINESS_CATEGORY_CD AS t12_client_category_cd,
                    sec.val_en_desc AS SECURITY_TYPE,
                    (nvl(IFRS_CGP.NIL,0) + nvl(IFRS_CGP.SETTLE_AMT,0)) / t13.exchange_rate
                       AS IFRS_NIL_SA_CONCCY,
                    IFRS_CGP.SETTLE_AMT AS IFRS_SETTLE_AMT,
                      (nvl(IFRS_CGP.OVD_AMT,0) + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                    / t13.exchange_rate
                       AS IFRS_TOT_OVD_CONCCY,
                    nvl(IFRS_CGP.OVD_AMT,0) + nvl(IFRS_CGP.SETTLE_OVD_AMT,0) AS IFRS_TOT_OVD,
                    IFRS_CGP.OVD_AMT,
                    IFRS_CGP.SETTLE_OVD_AMT,
                      (  nvl(IFRS_CGP.NIL,0)
                       + nvl(IFRS_CGP.SETTLE_AMT,0)
                       + nvl(IFRS_CGP.OVD_AMT,0)
                       + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                    / t13.exchange_rate
                       AS IFRS_GROSS_BALANCE_CONCCY,
                    IFRS_CGP.PROVISIONS_AMT / t13.exchange_rate
                       AS IFRS_PROVISIONS_CONCCY,
                      (nvl(IFRS_CGP_PREV.NIL,0) + nvl(IFRS_CGP_PREV.SETTLE_AMT,0))
                    / t13.exchange_rate
                       AS PREV_IFRS_NIL_SA_CONCCY,
                    IFRS_CGP_PREV.NIL AS PREV_IFRS_NIL,
                    IFRS_CGP_PREV.SETTLE_AMT AS PREV_IFRS_SETTLE_AMT,
                      (nvl(IFRS_CGP_PREV.OVD_AMT,0) + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0))
                    / t13.exchange_rate
                       AS PREV_IFRS_TOT_OVD_CONCCY,
                    IFRS_CGP_PREV.OVD_AMT AS PREV_OVD_AMT,
                    IFRS_CGP_PREV.SETTLE_OVD_AMT AS PREV_SETTLE_OVD_AMT,
                      (  nvl(IFRS_CGP_PREV.NIL,0)
                       + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                       + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                       + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0))
                    / t13.exchange_rate
                       AS PREV_IFRS_GROSS_BALANCE_CONCCY,
                    IFRS_CGP_PREV.PROVISIONS_AMT / t13.exchange_rate
                       AS PREV_IFRS_PROVISIONS_CONCCY,
                        IFRS_CGP.PD
                      * t20.LGD
                      * (  nvl(IFRS_CGP.NIL,0)
                         + nvl(IFRS_CGP.SETTLE_AMT,0)
                         + nvl(IFRS_CGP.OVD_AMT,0)
                         + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                    +   nvl(nxk.IFRS_K,0)
                      * (  nvl(IFRS_CGP.NIL,0)
                         + nvl(IFRS_CGP.SETTLE_AMT,0)
                         + nvl(IFRS_CGP.OVD_AMT,0)
                         + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                    - nvl(IFRS_CGP.PROVISIONS_AMT,0)
                       AS UL_EL_PROVIS,
                    IFRS_CGP.PROVIS_ADD,
                    IFRS_CGP.TRANS_DIFF,
                    t9.ACTIVITY_TYPE_RU_DESC,
                    t21.org_type_en_nam,
                    IFRS_CGP.RF_GOV_FLG,
                    t8.COUNTRY_CD AS reg_country_cd,
                    t3.LEASING_SUBJECT_DESC,
                    T20.leasing_subject_type_cd,
                    T7.rating_agency_en_nam,
                    cli_d.CAR_DEFAULT_FLG,
                    IFRS_CGP.R,
                    IFRS_CGP.corr_r,
                    cli_d.REVENUE_AMT,
                    t10.BUSINESS_CATEGORY_CD AS SME_FLG,
                    t20.LGD - ifrs_cgp.rate_allow AS LGDRATEALL,
                    IFRS_CGP.PD * t20.LGD - ifrs_cgp.rate_allow AS PDLGDRATEALL,
                    1 AS OPER_TYPE_CON,
                    t10.BUSINESS_CAT_RU_NAM,
                    t8.COUNTRY_RU_NAM AS REG_COUNTRY_NAM,
                    con_d.type_oc_ipo,
                    t9.ACTIVITY_TYPE_CD,
                    ifrs_cgp.provis_loss,
                    CASE
                       WHEN t4.MEMBER_KEY IS NOT NULL AND t4.MEMBER_KEY <> 1
                       THEN
                          'Yes'
                       ELSE
                          'No'
                    END
                       AS VTB_FLG,
                    t2.CONTRACT_NUM,
                    t2.CONTRACT_ID_CD,
                    IFRS_CGP.SP_RAT_CD,
                      nvl(IFRS_CGP.NIL,0)
                    + nvl(IFRS_CGP.SETTLE_AMT,0)
                    + nvl(IFRS_CGP.OVD_AMT,0)
                    + nvl(IFRS_CGP.SETTLE_OVD_AMT,0)
                       AS IFRS_GROSS_BALANCE,
                      nvl(IFRS_CGP_PREV.NIL,0)
                    + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                    + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                    + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0)
                       AS IFRS_GROSS_BALANCE_PREV,
                    1 AS CCF,
                      nvl(IFRS_CGP.NIL,0)
                    + nvl(IFRS_CGP.SETTLE_AMT,0)
                    + nvl(IFRS_CGP.OVD_AMT,0)
                    + nvl(IFRS_CGP.SETTLE_OVD_AMT,0)
                       AS IFRS_EAD,
                      nvl(IFRS_CGP_PREV.NIL,0)
                    + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                    + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                    + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0)
                       AS IFRS_EAD_PREV,
                    IFRS_CGP.PD AS SPD,
                    t20.LGD AS LGD_EC,
                    IFRS_CGP.IFRS_OLD_M,
                    IFRS_CGP.M,
                      IFRS_CGP.PD
                    * nvl(t20.LGD,0)
                    * (  nvl(IFRS_CGP.NIL,0)
                       + nvl(IFRS_CGP.SETTLE_AMT,0)
                       + nvl(IFRS_CGP.OVD_AMT,0)
                       + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                       AS IFRS_EL,
                      nvl(IFRS_CGP.PD,0)
                    * nvl(t20.LGD,0)
                    * (  nvl(IFRS_CGP_PREV.NIL,0)
                       + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                       + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                       + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0))
                       AS IFRS_EL_PREV,
                      nvl(nxk.IFRS_K,0)
                    * (  nvl(IFRS_CGP.NIL,0)
                       + nvl(IFRS_CGP.SETTLE_AMT,0)
                       + nvl(IFRS_CGP.OVD_AMT,0)
                       + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                       AS IFRS_UL,
                      nvl(nxk.IFRS_K,0)
                    * (  nvl(IFRS_CGP_PREV.NIL,0)
                       + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                       + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                       + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0))
                       AS IFRS_UL_PREV,
                    IFRS_CGP.PROVISIONS_AMT AS PROVISIONS_AMT,
                    IFRS_CGP_PREV.PROVISIONS_AMT AS PROVISIONS_AMT_PREV,
                    IFRS_CGP.NIL AS IFRS_NIL_AMT,
                    IFRS_CGP_PREV.NIL AS IFRS_NIL_AMT_PREV,
                    IFRS_CGP_PREV.SETTLE_AMT AS IFRS_SETTLE_AMT_PREV,
                    IFRS_CGP.OVD_AMT AS IFRS_OVD_AMT,
                    IFRS_CGP_PREV.OVD_AMT AS IFRS_OVD_AMT_PREV,
                    IFRS_CGP.SETTLE_OVD_AMT AS IFRS_SETTLE_OVD_AMT,
                    IFRS_CGP_PREV.SETTLE_OVD_AMT AS IFRS_SETTLE_OVD_AMT_PREV,
                    IFRS_CGP.RATE_ALLOW AS IFRS_RATE_ALLOW,
                    IFRS_CGP_PREV.RATE_ALLOW AS IFRS_RATE_ALLOW_PREV,
                        (nvl(IFRS_CGP.PD,0) * nvl(t20.LGD,0) + nvl(nxk.IFRS_K,0))
                      * (  nvl(IFRS_CGP.NIL,0)
                         + nvl(IFRS_CGP.SETTLE_AMT,0)
                         + nvl(IFRS_CGP.OVD_AMT,0)
                         + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                    - nvl(IFRS_CGP.PROVISIONS_AMT,0)
                       AS IFRS_106_AMT,
                        (nvl(IFRS_CGP.PD,0) * nvl(t20.LGD,0) + nvl(nxk.IFRS_K,0))
                      * (  nvl(IFRS_CGP_PREV.NIL,0)
                         + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                         + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                         + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0))
                    - nvl(IFRS_CGP_PREV.PROVISIONS_AMT,0)
                       AS IFRS_107_AMT,
                    IFRS_CGP.TRANS_DIFF AS IFRS_TRANS_DIFF,
                    IFRS_CGP_PREV.TRANS_DIFF AS IFRS_TRANS_DIFF_PREV,
                    IFRS_CGP.PROVIS_ADD AS IFRS_PROVIS_ADD,
                    IFRS_CGP_PREV.PROVIS_ADD AS IFRS_PROVIS_ADD_PREV,
                    CASE
                       WHEN   nvl(IFRS_CGP.NIL,0)
                            + nvl(IFRS_CGP.SETTLE_AMT,0)
                            + nvl(IFRS_CGP.OVD_AMT,0)
                            + nvl(IFRS_CGP.SETTLE_OVD_AMT,0) < 0
                       THEN
                              nvl(IFRS_CGP.PD,0)
                            * nvl(t20.LGD,0)
                            * (  nvl(IFRS_CGP.NIL,0)
                               + nvl(IFRS_CGP.SETTLE_AMT,0)
                               + nvl(IFRS_CGP.OVD_AMT,0)
                               + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                          +   nvl(nxk.IFRS_K,0)
                            * (  nvl(IFRS_CGP.NIL,0)
                               + nvl(IFRS_CGP.SETTLE_AMT,0)
                               + nvl(IFRS_CGP.OVD_AMT,0)
                               + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                          + nvl(IFRS_CGP.PROVISIONS_AMT,0)
                       ELSE
                          GREATEST (
                             0,
                             (    nvl(IFRS_CGP.PD,0)
                                * nvl(t20.LGD,0)
                                * (  nvl(IFRS_CGP.NIL,0)
                                   + nvl(IFRS_CGP.SETTLE_AMT,0)
                                   + nvl(IFRS_CGP.OVD_AMT,0)
                                   + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                              +   nvl(nxk.IFRS_K,0)
                                * (  nvl(IFRS_CGP.NIL,0)
                                   + nvl(IFRS_CGP.SETTLE_AMT,0)
                                   + nvl(IFRS_CGP.OVD_AMT,0)
                                   + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                              + nvl(IFRS_CGP.PROVISIONS_AMT,0)))
                    END
                       AS IFRS_CAR,
                    CASE
                       WHEN   nvl(IFRS_CGP_PREV.NIL,0)
                            + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                            + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                            + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0) < 0
                       THEN
                              nvl(IFRS_CGP.PD,0)
                            * nvl(t20.LGD,0)
                            * (  nvl(IFRS_CGP_PREV.NIL,0)
                               + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                               + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                               + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0))
                          +   nvl(nxk.IFRS_K,0)
                            * (  nvl(IFRS_CGP_PREV.NIL,0)
                               + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                               + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                               + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0))
                          + nvl(IFRS_CGP_PREV.PROVISIONS_AMT,0)
                       ELSE
                          GREATEST (
                             0,
                             (    nvl(IFRS_CGP.PD,0)
                                * nvl(t20.LGD,0)
                                * (  nvl(IFRS_CGP_PREV.NIL,0)
                                   + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                                   + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                                   + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0))
                              +   nvl(nxk.IFRS_K,0)
                                * (  nvl(IFRS_CGP_PREV.NIL,0)
                                   + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                                   + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                                   + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0))
                              + nvl(IFRS_CGP_PREV.PROVISIONS_AMT,0)))
                    END
                       AS IFRS_CAR_PREV,
                    CASE
                       WHEN   nvl(IFRS_CGP.NIL,0)
                            + nvl(IFRS_CGP.SETTLE_AMT,0)
                            + nvl(IFRS_CGP.OVD_AMT,0)
                            + nvl(IFRS_CGP.SETTLE_OVD_AMT,0) = 0
                       THEN
                          0
                       ELSE
                            (CASE
                                WHEN   nvl(IFRS_CGP.NIL,0)
                                     + nvl(IFRS_CGP.SETTLE_AMT,0)
                                     + nvl(IFRS_CGP.OVD_AMT,0)
                                     + nvl(IFRS_CGP.SETTLE_OVD_AMT,0) < 0
                                THEN
                                       nvl(IFRS_CGP.PD,0)
                                     * nvl(t20.LGD,0)
                                     * (  nvl(IFRS_CGP.NIL,0)
                                        + nvl(IFRS_CGP.SETTLE_AMT,0)
                                        + nvl(IFRS_CGP.OVD_AMT,0)
                                        + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                                   +   nvl(nxk.IFRS_K,0)
                                     * (  nvl(IFRS_CGP.NIL,0)
                                        + nvl(IFRS_CGP.SETTLE_AMT,0)
                                        + nvl(IFRS_CGP.OVD_AMT,0)
                                        + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                                   + nvl(IFRS_CGP.PROVISIONS_AMT,0)
                                ELSE
                                   GREATEST (
                                      0,
                                      (    nvl(IFRS_CGP.PD,0)
                                         * nvl(t20.LGD,0)
                                         * (  nvl(IFRS_CGP.NIL,0)
                                            + nvl(IFRS_CGP.SETTLE_AMT,0)
                                            + nvl(IFRS_CGP.OVD_AMT,0)
                                            + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                                       +   nvl(nxk.IFRS_K,0)
                                         * (  nvl(IFRS_CGP.NIL,0)
                                            + nvl(IFRS_CGP.SETTLE_AMT,0)
                                            + nvl(IFRS_CGP.OVD_AMT,0)
                                            + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                                       + nvl(IFRS_CGP.PROVISIONS_AMT,0)))
                             END)
                          / (  nvl(IFRS_CGP.NIL,0)
                             + nvl(IFRS_CGP.SETTLE_AMT,0)
                             + nvl(IFRS_CGP.OVD_AMT,0)
                             + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                    END
                       AS IFRS_CAR_PRC,
                    CASE
                       WHEN   nvl(IFRS_CGP_PREV.NIL,0)
                            + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                            + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                            + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0) = 0
                       THEN
                          0
                       ELSE
                            (CASE
                                WHEN   nvl(IFRS_CGP_PREV.NIL,0)
                                     + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                                     + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                                     + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0) < 0
                                THEN
                                       nvl(IFRS_CGP.PD,0)
                                     * nvl(t20.LGD,0)
                                     * (  nvl(IFRS_CGP_PREV.NIL,0)
                                        + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                                        + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                                        + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0))
                                   +   nvl(nxk.IFRS_K,0)
                                     * (  nvl(IFRS_CGP_PREV.NIL,0)
                                        + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                                        + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                                        + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0))
                                   + nvl(IFRS_CGP_PREV.PROVISIONS_AMT,0)
                                ELSE
                                   GREATEST (
                                      0,
                                      (    nvl(IFRS_CGP.PD,0)
                                         * nvl(t20.LGD,0)
                                         * (  nvl(IFRS_CGP_PREV.NIL,0)
                                            + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                                            + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                                            + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0))
                                       +   nvl(nxk.IFRS_K,0)
                                         * (  nvl(IFRS_CGP_PREV.NIL,0)
                                            + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                                            + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                                            + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0))
                                       + nvl(IFRS_CGP_PREV.PROVISIONS_AMT,0)))
                             END)
                          / (  nvl(IFRS_CGP_PREV.NIL,0)
                             + nvl(IFRS_CGP_PREV.SETTLE_AMT,0)
                             + nvl(IFRS_CGP_PREV.OVD_AMT,0)
                             + nvl(IFRS_CGP_PREV.SETTLE_OVD_AMT,0))
                    END
                       AS IFRS_CAR_PRC_PREV,
                    t9.ACTIVITY_TYPE_CD AS OTRASL_CD,
                    '2' AS BUSINESS_TYPE,
                    cli_d.RATING_POINTS,
                    --CLIENT_CATEGORY,
                    t11.COUNTRY_CD AS risk_coun_CD,
                    t12.CURRENCY_LETTER_CD,
                    con_d.IPO_FLG AS IND_PRIZN_OBESC,
                    '-' AS SWIFT_CD,
                    t2.OPEN_DT AS OPER_START,
                    --  t2.END_DT,
                    '-' AS SLX,                          --SLX код при наличии
                    t66.CREDIT_RATING AS RATE_LOCAL_MODEL, --Рейтинг по локальной модели (если нет количества баллов)
                    '-' AS GWL,                           --GLOBAL_WATCH_LIST,
                    CASE
                       WHEN IFRS_CGP.PD > 0.9
                       THEN
                          1
                       ELSE
                          CASE
                             WHEN IFRS_CGP.PD > 0.3 THEN 0.4
                             ELSE IFRS_CGP.PD
                          END
                    END
                       AS PD_COUNTRY,
                      CASE
                         WHEN    (    t4.MEMBER_KEY IS NOT NULL
                                  AND t4.MEMBER_KEY <> 1)
                              OR t11.COUNTRY_CD = '643'
                         THEN
                            0
                         ELSE
                            CASE
                               WHEN    (NVL (IFRS_CGP.OVD_DAYS, 0) > 90)
                                    /*or GWL=8*/
                                    OR (CASE
                                           WHEN IFRS_CGP.PD > 0.9
                                           THEN
                                              1
                                           ELSE
                                              CASE
                                                 WHEN IFRS_CGP.PD > 0.3
                                                 THEN
                                                    0.4
                                                 ELSE
                                                    IFRS_CGP.PD
                                              END
                                        END) > 0.9
                               THEN
                                  GREATEST (
                                         (  nvl(IFRS_CGP.NIL,0)
                                          + nvl(IFRS_CGP.SETTLE_AMT,0)
                                          + nvl(IFRS_CGP.OVD_AMT,0)
                                          + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                                       * nvl(t20.LGD,0)
                                     - (nvl(IFRS_CGP.PROVISIONS_AMT,0)),
                                     0)
                               ELSE
                                    GREATEST (
                                         (CASE
                                             WHEN IFRS_CGP.PD > 0.9
                                             THEN
                                                1
                                             ELSE
                                                CASE
                                                   WHEN IFRS_CGP.PD > 0.3
                                                   THEN
                                                      0.4
                                                   ELSE
                                                      IFRS_CGP.PD
                                                END
                                          END)
                                       * nvl(t20.LGD,0),
                                       nvl(t17.PD,0) * 0.2)
                                  * (  nvl(IFRS_CGP.NIL,0)
                                     + nvl(IFRS_CGP.SETTLE_AMT,0)
                                     + nvl(IFRS_CGP.OVD_AMT,0)
                                     + nvl(IFRS_CGP.SETTLE_OVD_AMT,0))
                            END
                      END
                    + CASE
                         WHEN    (    t4.MEMBER_KEY IS NOT NULL
                                  AND t4.MEMBER_KEY <> 1)
                              OR t11.COUNTRY_CD = '643'
                         THEN
                            0
                         ELSE
                            CASE
                               WHEN    (NVL (IFRS_CGP.OVD_DAYS, 0) > 90) /*or GWL=8*/
                                    OR IFRS_CGP.PD > 0.9
                               THEN
                                  GREATEST (
                                     nvl(t16.sanc_pr,0),
                                       nvl(t17.PD,0)
                                     * 0.2
                                     * GREATEST (
                                            nvl(IFRS_CGP.NIL,0)
                                          + nvl(IFRS_CGP.SETTLE_AMT,0)
                                          + nvl(IFRS_CGP.OVD_AMT,0)
                                          + nvl(IFRS_CGP.SETTLE_OVD_AMT,0)
                                          - nvl(IFRS_CGP.PROVISIONS_AMT,0),
                                          0))
                               ELSE
                                  GREATEST (nvl(t16.sanc_pr,0), nvl(t17.PD,0) * 0.2)
                            END
                      END
                       AS EL_COUNTRY_RISK,
                    CASE
                       WHEN    IFRS_CGP.PD > 0.9
                            OR NVL (IFRS_CGP.OVD_DAYS, 0) > 90    /*or GWL=7*/
                       THEN
                          1
                       ELSE
                          0
                    END
                       AS PRIZNAK_PROBL_COUNTRY_LIM,
                    org.country_cd AS ORG_COUNTR,
                    /*по бранчу определяем по справочнику страну ДБ*/
                    'LND_017' AS Mir_code,
                    'LND_017_CIB' AS Mir_code_NEW,
                    CASE WHEN t3.AUTO_FLG = 1 THEN 'Да' ELSE 'Нет' END
                       AS AUTO_FLG,
                    CASE
                       WHEN t5.GROUP_RU_NAM IS NULL THEN t4.SHORT_CLIENT_RU_NAM
                       ELSE t5.GROUP_RU_NAM
                    END
                       AS GROUP_OR_CLIENT,
                    con_d.ind_col_ASD AS IND_COL_ASD --individually assessed от проведения индивидуальной оценки*/
               FROM tt t2
                    ------------%%%%%%%%%%%%%%%%%%%%%%%%------------------------------
                    /*LEFT JOIN dm.dm_cgp t
                    ON t2.CONTRACT_KEY  =t.CONTRACT_KEY*/
                    LEFT JOIN tt1 IFRS_CGP
                       ON IFRS_CGP.CONTRACT_ID_CD = t2.CONTRACT_ID_CD
                    LEFT JOIN dwh.RISK_IFRS_CGP IFRS_CGP_PREV
                       ON     IFRS_CGP_PREV.CONTRACT_ID = t2.CONTRACT_ID_CD
                          AND IFRS_CGP_PREV.contract_num =
                                 IFRS_CGP.contract_num
                          AND IFRS_CGP_PREV.SNAPSHOT_DT =
                                 ADD_MONTHS (IFRS_CGP.SNAPSHOT_DT, -3)
                          -- [APOLYAKOV 16.03.2016]: добавление истории
                          AND IFRS_CGP_PREV.VALID_TO_DTTM = TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                    ---------------%%%%%%%%%%%%%%%%%%%%%%%%----------------------------
                    LEFT JOIN DWH.LEASING_CONTRACTS t3
                       ON     t3.CONTRACT_KEY = t2.CONTRACT_KEY
                          AND t3.VALID_TO_DTTM =
                                 TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                    LEFT JOIN dwh.clients t4
                       ON     t4.CLIENT_KEY = t2.CLIENT_KEY
                          AND t4.VALID_TO_DTTM =
                                 TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                    LEFT JOIN DWH.GROUPS t5
                       ON     t5.GROUP_KEY = t4.GROUP_KEY
                          AND t5.VALID_TO_DTTM =
                                 TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                    --клиентские рейтинги ----------------------------------------
                    --[apolyakov 17.03.2016]: добавление нового справочника для ЭК
                    LEFT JOIN dwh.REF_CLIENT_RATINGS_EC cli_r
                       ON     cli_r.client_key = t4.client_key
                          AND IFRS_CGP.snapshot_dt BETWEEN cli_r.begin_dt
                                                       AND cli_r.end_dt
                          AND cli_r.valid_to_dttm > SYSDATE + 100
                    --рейтинг!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!--------------------------
                    LEFT JOIN DWH.CREDIT_RATINGS t66
                       ON     t66.CREDIT_RATING_KEY = t4.CREDIT_RATING_KEY
                          AND t66.VALID_TO_DTTM =
                                 TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                          AND t66.BEGIN_DT <= IFRS_CGP.SNAPSHOT_DT
                          AND t66.END_DT >= IFRS_CGP.SNAPSHOT_DT
                          AND t66.AGENCY_KEY = 4
                    LEFT JOIN DWH.CREDIT_RATINGS t6
                       ON     t6.CREDIT_RATING_KEY = cli_r.RATING_KEY
                          AND t6.VALID_TO_DTTM =
                                 TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                          AND t6.BEGIN_DT <= IFRS_CGP.SNAPSHOT_DT
                          AND t6.END_DT >= IFRS_CGP.SNAPSHOT_DT
                    LEFT JOIN DWH.RATING_AGENCIES t7
                       ON     t7.RATING_AGENCY_KEY = t6.AGENCY_KEY
                          AND t7.VALID_TO_DTTM =
                                 TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                          AND t7.BEGIN_DT <= IFRS_CGP.SNAPSHOT_DT
                          AND t7.END_DT >= IFRS_CGP.SNAPSHOT_DT
                    --рейтинг !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!---------------------------
                    LEFT JOIN DWH.COUNTRIES t8
                       ON     t8.COUNTRY_KEY = t4.REG_COUNTRY_KEY
                          AND t8.VALID_TO_DTTM =
                                 TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                          AND t8.BEGIN_DT <= IFRS_CGP.SNAPSHOT_DT
                          AND t8.END_DT >= IFRS_CGP.SNAPSHOT_DT
                    LEFT JOIN DWH.ACTIVITY_TYPES t9
                       ON     t9.ACTIVITY_TYPE_KEY = t4.ACTIVITY_TYPE_KEY
                          AND t9.VALID_TO_DTTM =
                                 TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                          AND t9.BEGIN_DT <= IFRS_CGP.SNAPSHOT_DT
                          AND t9.END_DT >= IFRS_CGP.SNAPSHOT_DT
                    LEFT JOIN DWH.BUSINESS_CATEGORIES t10
                       ON     t10.BUSINESS_CATEGORY_KEY =
                                 t4.BUSINESS_CATEGORY_KEY
                          AND t10.VALID_TO_DTTM =
                                 TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                          AND t10.BEGIN_DT <= IFRS_CGP.SNAPSHOT_DT
                          AND t10.END_DT >= IFRS_CGP.SNAPSHOT_DT
                    LEFT JOIN DWH.COUNTRIES t11
                       ON     t11.country_key = t4.RISK_COUNTRY_KEY
                          AND t11.VALID_TO_DTTM =
                                 TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                          AND t11.BEGIN_DT <= IFRS_CGP.SNAPSHOT_DT
                          AND t11.END_DT >= IFRS_CGP.SNAPSHOT_DT
                    --[apolyakov 17.03.2016]: правильное определение валют
                    LEFT JOIN (SELECT a.*,
                                      ROW_NUMBER ()
                                      OVER (PARTITION BY CURRENCY_LETTER_CD
                                            ORDER BY VALID_FROM_DTTM DESC)
                                         rn
                                FROM dwh.CURRENCIES a
                              WHERE VALID_TO_DTTM = TO_DATE ('01.01.2400', 'dd.mm.yyyy')) t12
                       ON     t12.CURRENCY_KEY = t2.CURRENCY_KEY
                          AND t12.rn = 1
                          AND t12.BEGIN_DT <= IFRS_CGP.SNAPSHOT_DT
                          AND t12.END_DT >= IFRS_CGP.SNAPSHOT_DT
                    LEFT JOIN dwh.org_types t21
                       ON     t21.org_type_key = t4.org_type_key
                          AND t21.valid_to_dttm > SYSDATE + 100
                          AND IFRS_CGP.snapshot_dt BETWEEN t21.begin_dt
                                                       AND t21.end_dt
                    -- [apolyakov 17.03.2016]: выбор валюты из справочника и изменение привязки по ключу с t2!
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
                          AND T13.BEGIN_DT <= IFRS_CGP.SNAPSHOT_DT
                          AND T13.END_DT > IFRS_CGP.SNAPSHOT_DT
                          AND t13.EX_RATE_DT = IFRS_CGP.SNAPSHOT_DT
                          AND t13.valid_to_dttm =
                                 TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                    -- [apolyakov 17.03.2016]: связка не по CONTRACT_CD, а пое KEY + историчность
                    LEFT JOIN DWH.REF_COUNTRY_RATING T16
                       ON T16.COUNTRY_KEY = t8.COUNTRY_KEY
                      AND T16.BEGIN_DT <= IFRS_CGP.SNAPSHOT_DT
                      AND T16.END_DT > IFRS_CGP.SNAPSHOT_DT
                      AND T16.VALID_TO_DTTM > SYSDATE + 100
                    LEFT JOIN DWH.REF_COUNTRY_RATING T16_R
                       ON T16_R.COUNTRY_KEY = t11.COUNTRY_KEY
                      AND T16_R.BEGIN_DT <= IFRS_CGP.SNAPSHOT_DT
                      AND T16_R.END_DT > IFRS_CGP.SNAPSHOT_DT
                      AND T16_R.VALID_TO_DTTM > SYSDATE + 100
                    LEFT JOIN dwh.REF_SP_PD t17
                       ON T16.SP_CALC_RATE_CD = t17.SP_RATE_CD
                      AND t17.BEGIN_DT <= IFRS_CGP.SNAPSHOT_DT
                      AND t17.END_DT > IFRS_CGP.SNAPSHOT_DT
                      AND t17.VALID_TO_DTTM > SYSDATE + 100
                    LEFT JOIN dwh.VAT t18
                       ON     t18.BRANCH_KEY = t2.BRANCH_KEY
                          AND t18.VALID_TO_DTTM =
                                 TO_DATE ('01.01.2400', 'dd.mm.yyyy')
                          AND IFRS_CGP.SNAPSHOT_DT BETWEEN t18.BEGIN_DT
                                                       AND t18.END_DT
                    LEFT JOIN dwh.risk_org_structure org
                       ON org.branch_nam = IFRS_CGP.level1
                    LEFT JOIN dwh.risk_EC_CONTRACT_DATA CON_D
                       ON con_d.CONTRACT_KEY = t2.contract_key
                      AND con_d.BEGIN_DT <= IFRS_CGP.SNAPSHOT_DT
                      AND con_d.END_DT > IFRS_CGP.SNAPSHOT_DT
                      AND con_d.VALID_TO_DTTM > SYSDATE + 100
                    LEFT JOIN dwh.risk_EC_CLIENT_DATA CLI_D
                       ON cli_d.CLIENT_key = t4.CLIENT_key
                      AND cli_d.BEGIN_DT <= IFRS_CGP.SNAPSHOT_DT
                      AND cli_d.END_DT > IFRS_CGP.SNAPSHOT_DT
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
                      AND t19.BEGIN_DT <= IFRS_CGP.SNAPSHOT_DT
                      AND t19.END_DT > IFRS_CGP.SNAPSHOT_DT
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
                      AND t20.BEGIN_DT <= IFRS_CGP.SNAPSHOT_DT
                      AND t20.END_DT > IFRS_CGP.SNAPSHOT_DT
                      AND t20.VALID_TO_DTTM > SYSDATE + 100  
                    LEFT JOIN dwh.V_RISK_EC_NXK_IFRS nxk
                       ON     nxk.snapshot_dt = IFRS_CGP.snapshot_dt
                          AND nxk.CONTRACT_ID_CD = IFRS_CGP.CONTRACT_ID_CD
                          AND nxk.CONTRACT_num = IFRS_CGP.CONTRACT_num
                    LEFT JOIN dwh.banks ban
                       ON     ban.bank_key = con_d.bank_key
                          AND ban.valid_to_dttm > SYSDATE + 100
                    LEFT JOIN dwh.securities_ref sec
                       ON     con_d.security_type_key = sec.val_key
                          AND sec.ref_key = 6
                          AND sec.valid_to_dttm > SYSDATE + 100
              WHERE IFRS_CGP.SNAPSHOT_DT IS NOT NULL 
                                                    )
   GROUP BY CREDIT_RATING_CD,
            LESSEE,
            IFRS_GROUP_NAM,
            IFRS_VTB_FLG,
            IFRS_SNAPSHOT_DT,
            PREV_IFRS_SNAPSHOT_DT,
            SHORT_CLIENT_RU_NAM,
            CLIENT_ID,
            GROUP_RU_NAM,
            GROUP_CD,
            IFRS_BRANCH_1,
            AGG_LIST_CROUP_CD,
            RISK_COUNTRY_NAM,
            RISK_COUNTRY_RATING,
            RF_GOV_FLG_1,
            IFRS_BRANCH,
            IFRS_CLIENT_TYPE,
            NPL_STATUS,
            BANK_NAM,
            BENEF_GROUP_CD,
            DIVISION_CD,
            T12_CLIENT_CATEGORY_CD,
            SECURITY_TYPE,
            ACTIVITY_TYPE_RU_DESC,
            ORG_TYPE_EN_NAM,
            RF_GOV_FLG,
            REG_COUNTRY_CD,
            LEASING_SUBJECT_DESC,
            LEASING_SUBJECT_TYPE_CD,
            RATING_AGENCY_EN_NAM,
            CAR_DEFAULT_FLG,
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
            OTRASL_CD,
            BUSINESS_TYPE,
            RATING_POINTS,
            RISK_COUN_CD,
            CURRENCY_LETTER_CD,
            IND_PRIZN_OBESC,
            SWIFT_CD,
            SLX,
            RATE_LOCAL_MODEL,
            GWL,
            PRIZNAK_PROBL_COUNTRY_LIM,
            ORG_COUNTR,
            MIR_CODE,
            MIR_CODE_NEW,
            AUTO_FLG,
            GROUP_OR_CLIENT,
            IND_COL_ASD;
      
      commit;
END;
/

