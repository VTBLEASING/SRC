create or replace procedure dm.MERGE_DM_REPAYMENT_SCHEDULE as
 v_dm_dt varchar2(30);
 v_cnt number;
begin
    select nvl(max(SNAPSHOT_DT),'01.01.0001') 
    into v_dm_dt 
    from stg_xls.DM_REPAYMENT_SCHEDULE_HIST;
    if (v_dm_dt <> '01.01.0001') then
        delete from DM.DM_REPAYMENT_SCHEDULE d
        where not exists
        (
            select 1
            from DM.DM_REPAYMENT_SCHEDULE_HIST s 
            where VALID_TO_DTTM = to_date('01.01.2400','dd.mm.yyyy') 
            and SNAPSHOT_DT = to_date(v_dm_dt,'dd.mm.yyyy') 
            and d.SNAPSHOT_CD = s.SNAPSHOT_CD
            and d.SNAPSHOT_DT = s.SNAPSHOT_DT
            and d.CONTRACT_KEY = s.CONTRACT_KEY
            and d.CURRENCY_KEY = s.CURRENCY_KEY    
            and d.PAY_DT = s.PAY_DT            
        )
        and SNAPSHOT_DT = to_date(v_dm_dt,'dd.mm.yyyy');
  dm.u_log(p_proc => 'MERGE_DM_REPAYMENT_SCHEDULE',
           p_step => 'delete from DM.DM_REPAYMENT_SCHEDULEE',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');  
        MERGE INTO DM.DM_REPAYMENT_SCHEDULE d
        USING ( select * from DM.DM_REPAYMENT_SCHEDULE_HIST 
                where VALID_TO_DTTM = to_date('01.01.2400','dd.mm.yyyy') 
                and SNAPSHOT_DT = to_date(v_dm_dt,'dd.mm.yyyy') 
              ) s
        ON
          ( d.SNAPSHOT_CD = s.SNAPSHOT_CD
            and   d.SNAPSHOT_DT = s.SNAPSHOT_DT
            and   d.CONTRACT_KEY = s.CONTRACT_KEY
            and   d.CURRENCY_KEY = s.CURRENCY_KEY    
            and   d.PAY_DT = s.PAY_DT
          )
        WHEN MATCHED
        THEN
        UPDATE SET
          d.SNAPSHOT_MONTH = s.SNAPSHOT_MONTH,
          d.BRANCH_KEY = s.BRANCH_KEY,
          d.NIL_AMT = s.NIL_AMT,
          d.TRANCHE_NUM = s.TRANCHE_NUM,
          d.PROCESS_KEY = s.PROCESS_KEY,
          d.INSERT_DT = s.INSERT_DT,
          d.CUSTOM_FLG = s.CUSTOM_FLG,
          d.FACT_PAY_AMT = s.FACT_PAY_AMT,
          d.PLAN_PAY_AMT = s.PLAN_PAY_AMT,
          d.LEASING_PAY_AMT = s.LEASING_PAY_AMT,
          d.SUPPLY_PAY_AMT = s.SUPPLY_PAY_AMT,
          d.PAY_AMT = s.PAY_AMT,
          d.INTEREST_AMT = s.INTEREST_AMT,
          d.PRINCIPAL_AMT = s.PRINCIPAL_AMT,
          d.DNIL_AMT = s.DNIL_AMT,
          d.KA = s.KA,
          d.KB = s.KB,
          d.NIL_ORIG_AMT = s.NIL_ORIG_AMT,
          d.UNDERPAY_LEAS = s.UNDERPAY_LEAS
        WHEN NOT MATCHED
        THEN INSERT(d.SNAPSHOT_DT, d.SNAPSHOT_CD, d.SNAPSHOT_MONTH, d.CONTRACT_KEY, d.TRANCHE_NUM, d.PAY_DT, d.CURRENCY_KEY, d.FACT_PAY_AMT, d.PLAN_PAY_AMT, d.LEASING_PAY_AMT, d.SUPPLY_PAY_AMT, d.PAY_AMT, d.NIL_AMT, d.INTEREST_AMT, d.PRINCIPAL_AMT, d.DNIL_AMT, d.KA, d.KB, d.PROCESS_KEY, d.INSERT_DT, d.BRANCH_KEY, d.NIL_ORIG_AMT, d.UNDERPAY_LEAS, d.CUSTOM_FLG)           
        VALUES(s.SNAPSHOT_DT, s.SNAPSHOT_CD, s.SNAPSHOT_MONTH, s.CONTRACT_KEY, s.TRANCHE_NUM, s.PAY_DT, s.CURRENCY_KEY, s.FACT_PAY_AMT, s.PLAN_PAY_AMT, s.LEASING_PAY_AMT, s.SUPPLY_PAY_AMT, s.PAY_AMT, s.NIL_AMT, s.INTEREST_AMT, s.PRINCIPAL_AMT, s.DNIL_AMT, s.KA, s.KB, s.PROCESS_KEY, s.INSERT_DT, s.BRANCH_KEY, s.NIL_ORIG_AMT, s.UNDERPAY_LEAS, s.CUSTOM_FLG);        
  dm.u_log(p_proc => 'MERGE_DM_REPAYMENT_SCHEDULE',
           p_step => 'merge into DM_REPAYMENT_SCHEDULE',
           p_info => SQL%ROWCOUNT|| ' row(s) merged');  
--        commit;
    end if;
end;
/

