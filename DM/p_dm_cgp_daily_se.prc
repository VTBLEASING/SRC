CREATE OR REPLACE PROCEDURE DM.P_DM_CGP_DAILY_SE (
    p_REPORT_DT in date,
    p_REPORT_DT_FROM date default null
 )
is
--v_sql clob;
BEGIN
    dm.u_log(p_proc => 'P_DM_CGP_DAILY_SE',
           p_step => 'INPUT PARAMS',
           p_info => 'p_REPORT_DT:'||p_REPORT_DT);

dbms_mview.refresh('MV$LEASING_CONTRACTS',atomic_refresh=>FALSE);
   dm.u_log(p_proc => 'DM.P_DM_CGP_DAILY_SE',
           p_step => 'MV$LEASING_CONTRACTS are refreshed',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');

execute immediate 'TRUNCATE TABLE T$CALENDAR';
IF p_report_dt_from is null then
INSERT INTO T$CALENDAR(snapshot_dt) values(p_report_dt);
else
INSERT INTO T$CALENDAR(snapshot_dt) select snapshot_dt from dwh.calendar where snapshot_dt between p_REPORT_DT_FROM and p_REPORT_DT;
end if;
   dm.u_log(p_proc => 'DM.P_DM_CGP_DAILY_SE',
           p_step => 'T$CALENDAR',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');
   analyze_table(p_table_name => 'T$CALENDAR',p_schema => 'DM');
   analyze_table(p_table_name => 'MV$LEASING_CONTRACTS',p_schema => 'DM');
   dm.u_log(p_proc => 'DM.P_DM_CGP_DAILY_SE',
           p_step => 'MV$LEASING_CONTRACTS are analyzed',
           p_info => '');
delete from DM.DM_CGP_DAILY
where SNAPSHOT_DT = p_REPORT_DT;
  dm.u_log(p_proc => 'DM.P_DM_CGP_DAILY_SE',
           p_step => 'delete from DM.DM_CGP_DAILY',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
INSERT into DM.DM_CGP_DAILY (
                          SNAPSHOT_DT,
                          SNAPSHOT_MONTH,
                          CONTRACT_KEY,
                          CRM_CONTRACT_KEY,
                          CONTRACT_NUM,
                          CONTRACT_ID_CD,
                          app_num, --ov
                          INN,
                          SHORT_CLIENT_RU_NAM,
                          OGRN, --added by ovilkova 01/06/2018 due to 5611
                          TRANSMIT_SUBJECT_NAM,
                          LEASING_SUBJECT_KEY,
                          LEASING_DEAL_KEY,
                          LEASING_OFFER_KEY,
                          PRODUCT_NAM,
                          ACTUAL_FLG,
                          STATUS_1C_DESC,
                          CONTRACT_STATUS_KEY,
                          STATE_STATUS_KEY,
                          SUBJECT_STATUS_KEY,
                          CUR_LEAS_OVERDUE_DAYS,
                          MAX_LEAS_OVERDUE_DAYS,
                          MAX_LEAS_OVERDUE_DAYS_12, --[by ovilkova due to cross-checker 25/07/2017]
                          AVG_LEAS_OVERDUE_DAYS,
                          AVG_LEAS_OVERDUE_DAYS_12, --[by ovilkova due to cross-checker 25/07/2017]
                          CUR_ADV_OVERDUE_DAYS,
                          MAX_ADV_OVERDUE_DAYS,
                          AVG_ADV_OVERDUE_DAYS,
                          CUR_RED_OVERDUE_DAYS,
                          MAX_RED_OVERDUE_DAYS,
                          AVG_RED_OVERDUE_DAYS,
                          CUR_OTH_COM_OVERDUE_DAYS,
                          MAX_OTH_COM_OVERDUE_DAYS,
                          AVG_OTH_COM_OVERDUE_DAYS,
                          CUR_FIX_COM_OVERDUE_DAYS,
                          MAX_FIX_COM_OVERDUE_DAYS,
                          AVG_FIX_COM_OVERDUE_DAYS,
                          CUR_SUB_OVERDUE_DAYS,
                          MAX_SUB_OVERDUE_DAYS,
                          AVG_SUB_OVERDUE_DAYS,
                          CUR_ADD_INS_OVERDUE_DAYS,
                          MAX_ADD_INS_OVERDUE_DAYS,
                          AVG_ADD_INS_OVERDUE_DAYS,
                          CUR_INS_OVERDUE_DAYS,
                          MAX_INS_OVERDUE_DAYS,
                          AVG_INS_OVERDUE_DAYS,
                          CUR_REG_OVERDUE_DAYS,
                          MAX_REG_OVERDUE_DAYS,
                          AVG_REG_OVERDUE_DAYS,
                          CUR_FOR_OVERDUE_DAYS,
                          MAX_FOR_OVERDUE_DAYS,
                          AVG_FOR_OVERDUE_DAYS,
                          CUR_PEN_OVERDUE_DAYS,
                          MAX_PEN_OVERDUE_DAYS,
                          AVG_PEN_OVERDUE_DAYS,
                          CUR_OVR_OVERDUE_DAYS,
                          MAX_OVR_OVERDUE_DAYS,
                          AVG_OVR_OVERDUE_DAYS,
                          CUR_INSUR_OVERDUE_DAYS,
                          MAX_INSUR_OVERDUE_DAYS,
                          AVG_INSUR_OVERDUE_DAYS,
                          CUR_OTH_OVERDUE_DAYS,
                          MAX_OTH_OVERDUE_DAYS,
                          AVG_OTH_OVERDUE_DAYS,
                          LEASING_PAYMENTS_COUNT,
                          LEASING_PAYMENTS_COUNT_12, --[by ovilkova due to cross-checker 24/07/2017]
                          LEASING_PAYMENTS_SUM,
                          CUR_LEAS_OVERDUE_AMT,
                          CUR_ADV_OVERDUE_AMT,
                          CUR_RED_OVERDUE_AMT,
                          CUR_OTH_COM_OVERDUE_AMT,
                          CUR_FIX_COM_OVERDUE_AMT,
                          CUR_SUB_OVERDUE_AMT,
                          CUR_ADD_OVERDUE_AMT,
                          CUR_INS_OVERDUE_AMT,
                          CUR_REG_OVERDUE_AMT,
                          CUR_FOR_OVERDUE_AMT,
                          CUR_PEN_OVERDUE_AMT,
                          CUR_OVR_OVERDUE_AMT,
                          CUR_INSUR_OVERDUE_AMT,
                          CUR_OTH_OVERDUE_AMT,
                          OVERDUE_LEASING_PAYMENTS_COUNT,
                          LEAS_COUNT_12,  --[by ovilkova due to cross-checker 24/07/2017]
                          CUR_LEAS_OVERDUE_DT,
                          MAX_LEAS_PAY_DT,
                          TOTAL_LEAS_OVERDUE_DAYS,
                          CIS_OVERDUE_AMT,
                          --CIS_AVG_OVERDUE_AMT, --6053
                          CIS_OVERDUE_AMT_TAX,
                          CIS_TERM_AMT_RISK,
                          CIS_TERM_AMT,
                          CIS_TERM_AMT_TAX_RISK,
                          CIS_TERM_AMT_TAX,
                          NIL,
                          FINANCE_AMT,
                          GR_FIN_START_AMT,
                          CL_FIN_START_AMT,
                          GR_FIN_CUR_AMT,
                          CL_FIN_CUR_AMT,
                          PTS_FLG,
                          PTS_DT,
                          PTS_COMM,
                          NONEED,
                          INSERT_DT,
                          SUBPRODUCT_NAM,
                          LEASE_TERM_CNT,
                          end_dt, --[by ovilkova due to cross-checker 1/08/2017]
                          advance_rub, --[by ovilkova due to cross-checker 1/08/2017]
                          SUPPLY_RUB, --[by ovilkova due to cross-checker 1/08/2017]
                          balance, --[by ovilkova due to cross-checker 1/08/2017]
                          cr_ch_flg, --[by ovilkova due to cross-checker 1/08/2017]
                          U_MAX_LEAS_OVERDUE_DAYS,
                          U_MAX_LEAS_OVERDUE_DAYS_12,
                          U_AVG_LEAS_OVERDUE_DAYS,
                          U_AVG_LEAS_OVERDUE_DAYS_12,
                          U_MAX_ADV_OVERDUE_DAYS,
                          U_AVG_ADV_OVERDUE_DAYS,
                          U_MAX_RED_OVERDUE_DAYS,
                          U_AVG_RED_OVERDUE_DAYS,
                          U_MAX_OTH_COM_OVERDUE_DAYS,
                          U_AVG_OTH_COM_OVERDUE_DAYS,
                          U_MAX_FIX_COM_OVERDUE_DAYS,
                          U_AVG_FIX_COM_OVERDUE_DAYS,
                          U_MAX_SUB_OVERDUE_DAYS,
                          U_AVG_SUB_OVERDUE_DAYS,
                          U_MAX_ADD_INS_OVERDUE_DAYS,
                          U_AVG_ADD_INS_OVERDUE_DAYS,
                          U_MAX_INS_OVERDUE_DAYS,
                          U_AVG_INS_OVERDUE_DAYS,
                          U_MAX_REG_OVERDUE_DAYS,
                          U_AVG_REG_OVERDUE_DAYS,
                          U_MAX_FOR_OVERDUE_DAYS,
                          U_AVG_FOR_OVERDUE_DAYS,
                          U_MAX_PEN_OVERDUE_DAYS,
                          U_AVG_PEN_OVERDUE_DAYS,
                          U_MAX_OVR_OVERDUE_DAYS,
                          U_AVG_OVR_OVERDUE_DAYS,
                          U_MAX_INSUR_OVERDUE_DAYS,
                          U_AVG_INSUR_OVERDUE_DAYS,
                          U_MAX_OTH_OVERDUE_DAYS,
                          U_AVG_OTH_OVERDUE_DAYS,
                          U_TOTAL_LEAS_OVERDUE_DAYS
                         ,lease_subject_cnt
                         ,doc_from
                         ,leasing_offer_num
                         ,pay_sum
                         ,adv_payment
                         ,Prepay_Rate
                         ,leasing_subject_nam --?
                         ,CONTRACT_STAGE
                         ,rehiring_flg
                         ,rehireable_flg
                        )

select
        SNAPSHOT_DT,
        SNAPSHOT_MONTH,
        CONTRACT_KEY,
        CRM_CONTRACT_KEY,
        CONTRACT_NUM,
        CONTRACT_ID_CD,
        app_num, --ov
        INN,
        SHORT_CLIENT_RU_NAM,
        OGRN, --added by ovilkova 01/06/2018 due to 5611
        TRANSMIT_SUBJECT_NAM,
        LEASING_SUBJECT_KEY,
        LEASING_DEAL_KEY,
        LEASING_OFFER_KEY,
        PRODUCT_NAM,
        ACTUAL_FLG,
        STATUS_1C_DESC,
        CONTRACT_STATUS_KEY,
        STATE_STATUS_KEY,
        SUBJECT_STATUS_KEY,
        CUR_LEAS_OVERDUE_DAYS,
        MAX_LEAS_OVERDUE_DAYS,
        MAX_LEAS_OVERDUE_DAYS_12, --[by ovilkova due to cross-checker 25/07/2017]
        AVG_LEAS_OVERDUE_DAYS,
        AVG_LEAS_OVERDUE_DAYS_12, --[by ovilkova due to cross-checker 25/07/2017]
        CUR_ADV_OVERDUE_DAYS,
        MAX_ADV_OVERDUE_DAYS,
        AVG_ADV_OVERDUE_DAYS,
        CUR_RED_OVERDUE_DAYS,
        MAX_RED_OVERDUE_DAYS,
        AVG_RED_OVERDUE_DAYS,
        CUR_OTH_COM_OVERDUE_DAYS,
        MAX_OTH_COM_OVERDUE_DAYS,
        AVG_OTH_COM_OVERDUE_DAYS,
        CUR_FIX_COM_OVERDUE_DAYS,
        MAX_FIX_COM_OVERDUE_DAYS,
        AVG_FIX_COM_OVERDUE_DAYS,
        CUR_SUB_OVERDUE_DAYS,
        MAX_SUB_OVERDUE_DAYS,
        AVG_SUB_OVERDUE_DAYS,
        CUR_ADD_INS_OVERDUE_DAYS,
        MAX_ADD_INS_OVERDUE_DAYS,
        AVG_ADD_INS_OVERDUE_DAYS,
        CUR_INS_OVERDUE_DAYS,
        MAX_INS_OVERDUE_DAYS,
        AVG_INS_OVERDUE_DAYS,
        CUR_REG_OVERDUE_DAYS,
        MAX_REG_OVERDUE_DAYS,
        AVG_REG_OVERDUE_DAYS,
        CUR_FOR_OVERDUE_DAYS,
        MAX_FOR_OVERDUE_DAYS,
        AVG_FOR_OVERDUE_DAYS,
        CUR_PEN_OVERDUE_DAYS,
        MAX_PEN_OVERDUE_DAYS,
        AVG_PEN_OVERDUE_DAYS,
        CUR_OVR_OVERDUE_DAYS,
        MAX_OVR_OVERDUE_DAYS,
        AVG_OVR_OVERDUE_DAYS,
        CUR_INSUR_OVERDUE_DAYS,
        MAX_INSUR_OVERDUE_DAYS,
        AVG_INSUR_OVERDUE_DAYS,
        CUR_OTH_OVERDUE_DAYS,
        MAX_OTH_OVERDUE_DAYS,
        AVG_OTH_OVERDUE_DAYS,
        LEASING_PAYMENTS_COUNT,
        LEASING_PAYMENTS_COUNT_12, --[by ovilkova due to cross-checker 24/07/2017]
        LEASING_PAYMENTS_SUM,
        CUR_LEAS_OVERDUE_AMT,
        CUR_ADV_OVERDUE_AMT,
        CUR_RED_OVERDUE_AMT,
        CUR_OTH_COM_OVERDUE_AMT,
        CUR_FIX_COM_OVERDUE_AMT,
        CUR_SUB_OVERDUE_AMT,
        CUR_ADD_OVERDUE_AMT,
        CUR_INS_OVERDUE_AMT,
        CUR_REG_OVERDUE_AMT,
        CUR_FOR_OVERDUE_AMT,
        CUR_PEN_OVERDUE_AMT,
        CUR_OVR_OVERDUE_AMT,
        CUR_INSUR_OVERDUE_AMT,
        CUR_OTH_OVERDUE_AMT,
        OVERDUE_LEASING_PAYMENTS_COUNT,
        LEAS_COUNT_12,  --[by ovilkova due to cross-checker 24/07/2017]
        CUR_LEAS_OVERDUE_DT,
        MAX_LEAS_PAY_DT,
        TOTAL_LEAS_OVERDUE_DAYS,
        CIS_OVERDUE_AMT,
        --CIS_AVG_OVERDUE_AMT, --6053
        CIS_OVERDUE_AMT_TAX,
        CIS_TERM_AMT_RISK,
        CIS_TERM_AMT,
        CIS_TERM_AMT_TAX_RISK,
        CIS_TERM_AMT_TAX,
        NIL,
        FINANCE_AMT,
        GR_FIN_START_AMT,
        CL_FIN_START_AMT,
        -- Совокупная сумма финансирования по группе компаний со стороны ВТБЛ, руб., текущая
        SUM (NIL) OVER (PARTITION BY nvl (account_group_key, contract_key)) as GR_FIN_CUR_AMT,
        -- Совокупная сумма финансирования по клиенту со стороны ВТБЛ, руб., текущая
        SUM (NIL) OVER (PARTITION BY crm_client_key) as CL_FIN_CUR_AMT,
        PTS_FLG,
        PTS_DT,
        PTS_COMM,
        NONEED,
--       	decode(rn,1,PTS_FLG,null) PTS_FLG, --Шишляников
--        decode(rn,1,PTS_DT,null) PTS_DT, --Шишляников
--        decode(rn,1,PTS_COMM,null) PTS_COMM, --Шишляников
--        decode(rn,1,NONEED,null) NONEED, --Шишляников
        INSERT_DT,
        SUBPRODUCT_NAM,
        LEASE_TERM_CNT,
        end_dt, --[by ovilkova due to cross-checker 1/08/2017]
        ADVANCE_RUB, --[by ovilkova due to cross-checker 1/08/2017]
        SUPPLY_RUB, --[by ovilkova due to cross-checker 1/08/2017]
        BALANCE, --[by ovilkova due to cross-checker 1/08/2017]
        cr_ch_flg, --[by ovilkova due to cross-checker 1/08/2017]
        U_MAX_LEAS_OVERDUE_DAYS,
        U_MAX_LEAS_OVERDUE_DAYS_12,
        U_AVG_LEAS_OVERDUE_DAYS,
        U_AVG_LEAS_OVERDUE_DAYS_12,
        U_MAX_ADV_OVERDUE_DAYS,
        U_AVG_ADV_OVERDUE_DAYS,
        U_MAX_RED_OVERDUE_DAYS,
        U_AVG_RED_OVERDUE_DAYS,
        U_MAX_OTH_COM_OVERDUE_DAYS,
        U_AVG_OTH_COM_OVERDUE_DAYS,
        U_MAX_FIX_COM_OVERDUE_DAYS,
        U_AVG_FIX_COM_OVERDUE_DAYS,
        U_MAX_SUB_OVERDUE_DAYS,
        U_AVG_SUB_OVERDUE_DAYS,
        U_MAX_ADD_INS_OVERDUE_DAYS,
        U_AVG_ADD_INS_OVERDUE_DAYS,
        U_MAX_INS_OVERDUE_DAYS,
        U_AVG_INS_OVERDUE_DAYS,
        U_MAX_REG_OVERDUE_DAYS,
        U_AVG_REG_OVERDUE_DAYS,
        U_MAX_FOR_OVERDUE_DAYS,
        U_AVG_FOR_OVERDUE_DAYS,
        U_MAX_PEN_OVERDUE_DAYS,
        U_AVG_PEN_OVERDUE_DAYS,
        U_MAX_OVR_OVERDUE_DAYS,
        U_AVG_OVR_OVERDUE_DAYS,
        U_MAX_INSUR_OVERDUE_DAYS,
        U_AVG_INSUR_OVERDUE_DAYS,
        U_MAX_OTH_OVERDUE_DAYS,
        U_AVG_OTH_OVERDUE_DAYS,
        U_TOTAL_LEAS_OVERDUE_DAYS
                         ,lease_subject_cnt
                         ,doc_from
                         ,leasing_offer_num
                         ,pay_sum
                         ,adv_payment
                         ,Prepay_Rate
                         ,leasing_subject_nam
                         ,CONTRACT_STAGE
                         ,rehiring_flg
                         ,rehireable_flg


from DM.V$DM_CGP_DAILY;
   dm.u_log(p_proc => 'DM.P_DM_CGP_DAILY_SE',
           p_step => 'INSERT into DM.DM_CGP_DAILY',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');
   --analyze_table(p_table_name => 'DM_CGP_DAILY',p_schema => 'DM');
commit;

end;
/

