create or replace procedure dm.MERGE_DM_CGP as
 v_dm_dt varchar2(30);
 v_cnt number;
begin
    select nvl(max(SNAPSHOT_DT),'01.01.0001') 
    into v_dm_dt 
    from stg_xls.DM_CGP_HIST;
    if (v_dm_dt <> '01.01.0001') then
        delete from DM.DM_CGP d
        where not exists
        (
            select 1
            from DM.DM_CGP_HIST s 
            where VALID_TO_DTTM = to_date('01.01.2400','dd.mm.yyyy') 
            and SNAPSHOT_DT = to_date(v_dm_dt,'dd.mm.yyyy') 
            and d.SNAPSHOT_CD = s.SNAPSHOT_CD
            and d.SNAPSHOT_DT = s.SNAPSHOT_DT
            and d.CONTRACT_KEY = s.CONTRACT_KEY
        )
        and SNAPSHOT_DT = to_date(v_dm_dt,'dd.mm.yyyy');        
        dm.u_log(p_proc => 'MERGE_DM_CGP',
                 p_step => 'delete from DM.DM_CGP',
                 p_info => SQL%ROWCOUNT|| ' row(s) deleted');  

        MERGE INTO DM.DM_CGP d
        USING ( select * from DM.DM_CGP_HIST 
                where VALID_TO_DTTM = to_date('01.01.2400','dd.mm.yyyy') 
                and SNAPSHOT_DT = to_date(v_dm_dt,'dd.mm.yyyy') 
              ) s
        ON
          ( d.SNAPSHOT_CD = s.SNAPSHOT_CD
            and   d.SNAPSHOT_DT = s.SNAPSHOT_DT
            and   d.CONTRACT_KEY = s.CONTRACT_KEY
          )
        WHEN MATCHED
        THEN
        UPDATE SET
          d.SNAPSHOT_MONTH = s.SNAPSHOT_MONTH,
          d.BRANCH_KEY = s.BRANCH_KEY,
          d.CLIENT_KEY = s.CLIENT_KEY,
          d.BUSINESS_CATEGORY_KEY = s.BUSINESS_CATEGORY_KEY,
          d.CLIENT_NAM = s.CLIENT_NAM,
          d.CREDIT_RATING_KEY = s.CREDIT_RATING_KEY,
          d.RATING_AGENCY_KEY = s.RATING_AGENCY_KEY,
          d.ACTIVITY_TYPE_KEY = s.ACTIVITY_TYPE_KEY,
          d.REG_COUNTRY_KEY = s.REG_COUNTRY_KEY,
          d.RISK_COUNTRY_KEY = s.RISK_COUNTRY_KEY,
          d.LOAN_TYPE_KEY = s.LOAN_TYPE_KEY,
          d.LENDING_PURPOSE_KEY = s.LENDING_PURPOSE_KEY,
          d.RISK_TRANS_FLG = s.RISK_TRANS_FLG,
          d.CONTRACT_NUM = s.CONTRACT_NUM,
          d.START_DT = s.START_DT,
          d.END_DT = s.END_DT,
          d.CURRENCY_KEY = s.CURRENCY_KEY,
          d.ASSETS_TRANSFER_FLG = s.ASSETS_TRANSFER_FLG,
          d.XIRR_RATE = s.XIRR_RATE,
          d.TERM_AMT = s.TERM_AMT,
          d.AVG_TERM_AMT = s.AVG_TERM_AMT,
          d.OVERDUE_AMT = s.OVERDUE_AMT,
          d.AVG_OVERDUE_AMT = s.AVG_OVERDUE_AMT,
          d.OVERDUE_VAT_FREE_AMT = s.OVERDUE_VAT_FREE_AMT,
          d.AVG_OVERDUE_VAT_FREE_AMT = s.AVG_OVERDUE_VAT_FREE_AMT,
          d.OVERDUE_DT = s.OVERDUE_DT,
          d.FLOAT_BASE_FLG = s.FLOAT_BASE_FLG,
          d.FLOAT_BASE_TYPE_KEY = s.FLOAT_BASE_TYPE_KEY,
          d.FLOAT_BASE_AMT = s.FLOAT_BASE_AMT,
          d.ADD_AMT = s.ADD_AMT,
          d.IAS3_TERM_KEY = s.IAS3_TERM_KEY,
          d.IAS3_OVERDUE_KEY = s.IAS3_OVERDUE_KEY,
          d.CONTRACT_STATUS_KEY = s.CONTRACT_STATUS_KEY,
          d.PROCESS_KEY = s.PROCESS_KEY,
          d.INSERT_DT = s.INSERT_DT,
          d.FACT_CLOSE_DT = s.FACT_CLOSE_DT,
          d.STATUS = s.STATUS
          ,d.VAT_OVERDUE_AMT=s.VAT_OVERDUE_AMT
          ,d.VAT_TERM_AMT=s.VAT_TERM_AMT

        WHEN NOT MATCHED
        THEN INSERT (d.SNAPSHOT_CD, d.SNAPSHOT_DT, d.SNAPSHOT_MONTH, d.CONTRACT_KEY, d.BRANCH_KEY, d.CLIENT_KEY, d.BUSINESS_CATEGORY_KEY, d.CLIENT_NAM, d.CREDIT_RATING_KEY, d.RATING_AGENCY_KEY, d.ACTIVITY_TYPE_KEY, d.REG_COUNTRY_KEY, d.RISK_COUNTRY_KEY, d.LOAN_TYPE_KEY, d.LENDING_PURPOSE_KEY, d.RISK_TRANS_FLG, d.CONTRACT_NUM, d.START_DT, d.END_DT, d.CURRENCY_KEY, d.ASSETS_TRANSFER_FLG, d.XIRR_RATE, d.TERM_AMT, d.AVG_TERM_AMT, d.OVERDUE_AMT, d.AVG_OVERDUE_AMT,d.OVERDUE_VAT_FREE_AMT,d.AVG_OVERDUE_VAT_FREE_AMT, d.OVERDUE_DT, d.FLOAT_BASE_FLG, d.FLOAT_BASE_TYPE_KEY, d.FLOAT_BASE_AMT, d.ADD_AMT, d.IAS3_TERM_KEY, d.IAS3_OVERDUE_KEY, d.CONTRACT_STATUS_KEY, d.PROCESS_KEY, d.INSERT_DT, d.FACT_CLOSE_DT, d.STATUS, d.CONTRACT_ID_CD, d.CLIENT_ID, d.cLIENT_1c_cD, d.CUSTOM_FLG,d.VAT_OVERDUE_AMT,d.VAT_TERM_AMT)
            values(s.SNAPSHOT_CD, s.SNAPSHOT_DT, s.SNAPSHOT_MONTH, s.CONTRACT_KEY, s.BRANCH_KEY, s.CLIENT_KEY, s.BUSINESS_CATEGORY_KEY, s.CLIENT_NAM, s.CREDIT_RATING_KEY, s.RATING_AGENCY_KEY, s.ACTIVITY_TYPE_KEY, s.REG_COUNTRY_KEY, s.RISK_COUNTRY_KEY, s.LOAN_TYPE_KEY, s.LENDING_PURPOSE_KEY, s.RISK_TRANS_FLG, s.CONTRACT_NUM, s.START_DT, s.END_DT, s.CURRENCY_KEY, s.ASSETS_TRANSFER_FLG, s.XIRR_RATE, s.TERM_AMT, s.AVG_TERM_AMT, s.OVERDUE_AMT, s.AVG_OVERDUE_AMT,s.OVERDUE_VAT_FREE_AMT,s.AVG_OVERDUE_VAT_FREE_AMT, s.OVERDUE_DT, s.FLOAT_BASE_FLG, s.FLOAT_BASE_TYPE_KEY, s.FLOAT_BASE_AMT, s.ADD_AMT, s.IAS3_TERM_KEY, s.IAS3_OVERDUE_KEY, s.CONTRACT_STATUS_KEY, s.PROCESS_KEY, s.INSERT_DT, s.FACT_CLOSE_DT, s.STATUS, s.CONTRACT_ID_CD, s.CLIENT_ID, s.cLIENT_1c_cD, s.CUSTOM_FLG,s.VAT_OVERDUE_AMT,s.VAT_TERM_AMT);        
        dm.u_log(p_proc => 'MERGE_DM_CGP',
                 p_step => 'merge into DM.DM_CGP',
                 p_info => SQL%ROWCOUNT|| ' row(s) merged');  

--        commit;
    end if;
end;
/

