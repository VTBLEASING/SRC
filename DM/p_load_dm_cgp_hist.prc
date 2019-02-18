create or replace procedure dm.P_LOAD_DM_CGP_HIST(P_LOAD_DT date)
as
--    v_cnt number;
    v_dt date := P_LOAD_DT;
    v_file_id number;
    v_snapshot_dt date;
begin
    dm.u_log(p_proc => 'dm.P_LOAD_DM_CGP_HIST',
           p_step => 'INPUT PARAMS',
           p_info => 'P_LOAD_DT:'||P_LOAD_DT); 
    select max(file_id), max(SNAPSHOT_DT)
    into v_file_id,v_snapshot_dt
    from
        (   select to_number(file_id) file_id, to_date(substr(SNAPSHOT_DT,1,10), 'dd.mm.yyyy') SNAPSHOT_DT
            from stg_xls.DM_CGP_HIST
            union all
            select -1, to_date('01.01.1900', 'dd.mm.yyyy')  from dual
        );                        
    
    if v_file_id <> -1 then


        insert into TMP_DM_CGP_HIST
        (
        RID, COL_FLG
        , SNAPSHOT_CD, SNAPSHOT_DT, CONTRACT_KEY, SNAPSHOT_MONTH, BRANCH_KEY, CLIENT_KEY
        , BUSINESS_CATEGORY_KEY, CLIENT_NAM, CREDIT_RATING_KEY, RATING_AGENCY_KEY, ACTIVITY_TYPE_KEY
        , REG_COUNTRY_KEY, RISK_COUNTRY_KEY, LOAN_TYPE_KEY, LENDING_PURPOSE_KEY, RISK_TRANS_FLG, CONTRACT_NUM
        , START_DT, END_DT, CURRENCY_KEY, ASSETS_TRANSFER_FLG, XIRR_RATE, TERM_AMT, AVG_TERM_AMT, OVERDUE_AMT
        , AVG_OVERDUE_AMT, OVERDUE_VAT_FREE_AMT
        , AVG_OVERDUE_VAT_FREE_AMT, OVERDUE_DT, FLOAT_BASE_FLG, FLOAT_BASE_TYPE_KEY, FLOAT_BASE_AMT, ADD_AMT, IAS3_TERM_KEY
        , IAS3_OVERDUE_KEY, STATUS, FACT_CLOSE_DT, CONTRACT_STATUS_KEY, INSERT_DT, FILE_ID 
        , CONTRACT_ID_CD, CLIENT_ID, CLIENT_1C_CD
        )
        select
        t.RID, decode(nvl(t.CONTRACT_KEY,0),0, 'I',s.CONTRACT_KEY,'U', 'D') COL_FLG
        , nvl(s.SNAPSHOT_CD, t.SNAPSHOT_CD) as SNAPSHOT_CD
        , nvl(s.SNAPSHOT_DT, t.SNAPSHOT_DT) as SNAPSHOT_DT
        , nvl(s.CONTRACT_KEY, t.CONTRACT_KEY) as CONTRACT_KEY   
        , s.SNAPSHOT_MONTH, s.BRANCH_KEY, s.CLIENT_KEY
        , s.BUSINESS_CATEGORY_KEY, s.CLIENT_NAM, s.CREDIT_RATING_KEY, s.RATING_AGENCY_KEY, s.ACTIVITY_TYPE_KEY
        , s.REG_COUNTRY_KEY, s.RISK_COUNTRY_KEY, s.LOAN_TYPE_KEY, s.LENDING_PURPOSE_KEY, s.RISK_TRANS_FLG, s.CONTRACT_NUM
        , s.START_DT, s.END_DT, s.CURRENCY_KEY, s.ASSETS_TRANSFER_FLG, s.XIRR_RATE, s.TERM_AMT, s.AVG_TERM_AMT, s.OVERDUE_AMT
        , s.AVG_OVERDUE_AMT,s.OVERDUE_VAT_FREE_AMT,s.AVG_OVERDUE_VAT_FREE_AMT, s.OVERDUE_DT, s.FLOAT_BASE_FLG, s.FLOAT_BASE_TYPE_KEY, s.FLOAT_BASE_AMT, s.ADD_AMT, s.IAS3_TERM_KEY
        , s.IAS3_OVERDUE_KEY, s.STATUS, s.FACT_CLOSE_DT, s.CONTRACT_STATUS_KEY, s.INSERT_DT, s.FILE_ID 
        , s.CONTRACT_ID_CD, s.CLIENT_ID
        , nvl (s.CLIENT_1C_CD, t.CLIENT_1C_CD ) as CLIENT_1C_CD
        from           
        (   select
              s.SNAPSHOT_CD, s.SNAPSHOT_DT, s.SNAPSHOT_MONTH, s.CONTRACT_KEY, s.BRANCH_KEY, s.CLIENT_KEY
            , s.BUSINESS_CATEGORY_KEY, s.CLIENT_NAM, s.CREDIT_RATING_KEY, s.RATING_AGENCY_KEY, s.ACTIVITY_TYPE_KEY
            , s.REG_COUNTRY_KEY, s.RISK_COUNTRY_KEY, s.LOAN_TYPE_KEY, s.LENDING_PURPOSE_KEY, 0 RISK_TRANS_FLG, s.CONTRACT_NUM
            , s.START_DT, s.END_DT, s.CURRENCY_KEY, null as ASSETS_TRANSFER_FLG, s.XIRR_RATE, s.TERM_AMT, s.AVG_TERM_AMT, s.OVERDUE_AMT
            , s.AVG_OVERDUE_AMT,s.OVERDUE_VAT_FREE_AMT, s.AVG_OVERDUE_VAT_FREE_AMT, s.OVERDUE_DT, FLOAT_BASE_FLG, s.RATE_KEY FLOAT_BASE_TYPE_KEY, 0 as FLOAT_BASE_AMT, s.ADD_AMT, s.IAS3_TERM_KEY
            , s.IAS3_OVERDUE_KEY, s.STATUS, s.FACT_CLOSE_DT, 90 CONTRACT_STATUS_KEY, v_dt INSERT_DT, s.FILE_ID 
            , s.CONTRACT_CD as CONTRACT_ID_CD, s.CLIENT_ID, s.CLIENT_CD_FILE as CLIENT_1C_CD
    --        , s.CLIENT_1C_CD, 1
            from stg_xls.v_DM_CGP_HIST s) s
        full outer join
        (select t.rowid rid
        ,t.*
        from DM_CGP_HIST t
--            inner join DM_CGP cgp
--                on t.CONTRACT_KEY = cgp.CONTRACT_KEY
--                and cgp.SNAPSHOT_DT = v_snapshot_dt
--                and cgp.SNAPSHOT_CD = 'Основной КИС'
        where 1=1
        and t.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy') 
        and t.SNAPSHOT_DT = v_snapshot_dt
        and t.SNAPSHOT_CD = 'Основной КИС'
        ) t
        on (
                t.CONTRACT_KEY = s.CONTRACT_KEY
            and t.SNAPSHOT_DT = s.SNAPSHOT_DT
        )
        where  (
                decode(t.SNAPSHOT_MONTH,s.SNAPSHOT_MONTH,0,1)=1 or
                decode(t.BRANCH_KEY,s.BRANCH_KEY,0,1)=1 or
                decode(t.CLIENT_KEY,s.CLIENT_KEY,0,1)=1 or
                decode(t.BUSINESS_CATEGORY_KEY,s.BUSINESS_CATEGORY_KEY,0,1)=1 or
                decode(t.CLIENT_NAM,s.CLIENT_NAM,0,1)=1 or
                decode(t.CREDIT_RATING_KEY,s.CREDIT_RATING_KEY,0,1)=1 or
                decode(t.RATING_AGENCY_KEY,s.RATING_AGENCY_KEY,0,1)=1 or
                decode(t.ACTIVITY_TYPE_KEY,s.ACTIVITY_TYPE_KEY,0,1)=1 or
                decode(t.REG_COUNTRY_KEY,s.REG_COUNTRY_KEY,0,1)=1 or
                decode(t.RISK_COUNTRY_KEY,s.RISK_COUNTRY_KEY,0,1)=1 or
                decode(t.LOAN_TYPE_KEY,s.LOAN_TYPE_KEY,0,1)=1 or
                decode(t.LENDING_PURPOSE_KEY,s.LENDING_PURPOSE_KEY,0,1)=1 or
                decode(t.RISK_TRANS_FLG,s.RISK_TRANS_FLG,0,1)=1 or
                decode(t.CONTRACT_NUM,s.CONTRACT_NUM,0,1)=1 or
                decode(t.START_DT,s.START_DT,0,1)=1 or
                decode(t.END_DT,s.END_DT,0,1)=1 or
                decode(t.CURRENCY_KEY,s.CURRENCY_KEY,0,1)=1 or
                decode(t.ASSETS_TRANSFER_FLG,s.ASSETS_TRANSFER_FLG,0,1)=1 or
                decode(t.XIRR_RATE,s.XIRR_RATE,0,1)=1 or
                decode(t.TERM_AMT,s.TERM_AMT,0,1)=1 or
                decode(t.AVG_TERM_AMT,s.AVG_TERM_AMT,0,1)=1 or
                decode(t.OVERDUE_VAT_FREE_AMT,s.OVERDUE_VAT_FREE_AMT,0,1)=1 or
                --decode(t.AVG_OVERDUE_AMT,s.AVG_OVERDUE_AMT,0,1)=1 or
                --decode(t.OVERDUE_DT,s.OVERDUE_DT,0,1)=1 or
                decode(t.AVG_OVERDUE_VAT_FREE_AMT,s.AVG_OVERDUE_VAT_FREE_AMT,0,1)=1 or
                decode(t.OVERDUE_DT,s.OVERDUE_DT,0,1)=1 or
                decode(t.FLOAT_BASE_FLG,s.FLOAT_BASE_FLG,0,1)=1 or
                decode(t.FLOAT_BASE_TYPE_KEY,s.FLOAT_BASE_TYPE_KEY,0,1)=1 or
                --decode(t.FLOAT_BASE_AMT,s.FLOAT_BASE_AMT,0,1)=1 or
                decode(t.ADD_AMT,s.ADD_AMT,0,1)=1 or
                decode(t.IAS3_TERM_KEY,s.IAS3_TERM_KEY,0,1)=1 or
                decode(t.IAS3_OVERDUE_KEY,s.IAS3_OVERDUE_KEY,0,1)=1 or
                decode(t.CONTRACT_STATUS_KEY,s.CONTRACT_STATUS_KEY,0,1)=1 or
                --decode(t.INSERT_DT,s.INSERT_DT,0,1)=1 or
                decode(t.FACT_CLOSE_DT,s.FACT_CLOSE_DT,0,1)=1 or
                decode(t.STATUS,s.STATUS,0,1)=1 or
                --decode(t.CONTRACT_ID_CD,s.CONTRACT_ID_CD,0,1)=1 or
                decode(t.CLIENT_ID,s.CLIENT_ID,0,1)=1
                --decode(t.CLIENT_1C_CD,s.CLIENT_1C_CD,0,1)=1 
             );        
     dm.u_log(p_proc => 'dm.P_LOAD_DM_CGP_HIST',
           p_step => 'insert into TMP_DM_CGP_HIST',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');  
    
    -------------------------------------------------------------------------------------- 
    -- Close deleted and updated rows 
    -------------------------------------------------------------------------------------- 
    merge into dm.DM_CGP_HIST trg
    using TMP_DM_CGP_HIST src
    on(trg.rowid = src.rid)
        when matched then update
            set trg.VALID_TO_DTTM = v_dt - 1/(24*60*60)
            ,trg.CLOSED_ROW_FILE_ID = decode(src.COL_FLG, 'D',v_file_id);

     dm.u_log(p_proc => 'dm.P_LOAD_DM_CGP_HIST',
           p_step => 'merge into dm.DM_CGP_HIST (Close deleted and updated rows )',
           p_info => SQL%ROWCOUNT|| ' row(s) merged');    

    -------------------------------------------------------------------------------------- 
    -- Insert new rows 
    -------------------------------------------------------------------------------------- 
            
    insert into dm.DM_CGP_HIST           
    (
        SNAPSHOT_CD,SNAPSHOT_DT, BUSINESS_CATEGORY_KEY, CLIENT_NAM, CREDIT_RATING_KEY, RATING_AGENCY_KEY, ACTIVITY_TYPE_KEY
        , CONTRACT_KEY, REG_COUNTRY_KEY, RISK_COUNTRY_KEY, LOAN_TYPE_KEY, LENDING_PURPOSE_KEY, RISK_TRANS_FLG, CONTRACT_NUM
        , START_DT, END_DT, CURRENCY_KEY, ASSETS_TRANSFER_FLG, XIRR_RATE, TERM_AMT, AVG_TERM_AMT, OVERDUE_AMT
        , AVG_OVERDUE_AMT,OVERDUE_VAT_FREE_AMT,AVG_OVERDUE_VAT_FREE_AMT, OVERDUE_DT, FLOAT_BASE_FLG, FLOAT_BASE_TYPE_KEY, FLOAT_BASE_AMT, ADD_AMT, IAS3_TERM_KEY
        , IAS3_OVERDUE_KEY, STATUS, FACT_CLOSE_DT, CONTRACT_STATUS_KEY, INSERT_DT,  CONTRACT_ID_CD, CLIENT_ID
        , CLIENT_1C_CD, CUSTOM_FLG, CLOSED_ROW_FILE_ID,SNAPSHOT_MONTH,CLIENT_KEY,BRANCH_KEY
        , VALID_FROM_DTTM, VALID_TO_DTTM, PROCESS_KEY, FILE_ID,VAT_OVERDUE_AMT,VAT_TERM_AMT

    )
    select 
    s.SNAPSHOT_CD, s.SNAPSHOT_DT, s.BUSINESS_CATEGORY_KEY, s.CLIENT_NAM, s.CREDIT_RATING_KEY, s.RATING_AGENCY_KEY, s.ACTIVITY_TYPE_KEY
    , s.CONTRACT_KEY, s.REG_COUNTRY_KEY, s.RISK_COUNTRY_KEY, s.LOAN_TYPE_KEY, s.LENDING_PURPOSE_KEY, s.RISK_TRANS_FLG, s.CONTRACT_NUM
    , s.START_DT, s.END_DT, s.CURRENCY_KEY, s.ASSETS_TRANSFER_FLG, s.XIRR_RATE, s.TERM_AMT, s.AVG_TERM_AMT,  OVERDUE_VAT_FREE_AMT*(1+c.contract_vat_rate) AS OVERDUE_AMT
    , AVG_OVERDUE_VAT_FREE_AMT*(1+c.contract_vat_rate) as AVG_OVERDUE_AMT, OVERDUE_VAT_FREE_AMT, AVG_OVERDUE_VAT_FREE_AMT, s.OVERDUE_DT, s.FLOAT_BASE_FLG, s.FLOAT_BASE_TYPE_KEY, s.FLOAT_BASE_AMT, s.ADD_AMT, IAS3_TERM_KEY
    , s.IAS3_OVERDUE_KEY, s.STATUS, s.FACT_CLOSE_DT, s.CONTRACT_STATUS_KEY, sysdate INSERT_DT,  s.CONTRACT_ID_CD, s.CLIENT_ID
    , s.CLIENT_1C_CD, 1 CUSTOM_FLG, s.CLOSED_ROW_FILE_ID,s.SNAPSHOT_MONTH,s.CLIENT_KEY,s.BRANCH_KEY
    , P_LOAD_DT, to_date('01.01.2400', 'dd.mm.yyyy') , 888, v_file_id,OVERDUE_VAT_FREE_AMT*(c.contract_vat_rate),TERM_AMT*c.contract_vat_rate
    from TMP_DM_CGP_HIST s
    join DWH.CONTRACTS c on s.CONTRACT_KEY=c.CONTRACT_KEY and c.valid_to_dttm=to_date('01.01.2400', 'dd.mm.yyyy')
    where COL_FLG in('I','U');
     dm.u_log(p_proc => 'dm.P_LOAD_DM_CGP_HIST',
           p_step => 'insert into dm.DM_CGP_HIST',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');       
          
    end if;
    
--    exception 
--        when others then
--            ETL.SET_FILE_STATUS(v_file_id,'-40');
end;
/

