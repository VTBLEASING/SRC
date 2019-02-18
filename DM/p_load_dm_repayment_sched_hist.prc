create or replace procedure dm.P_LOAD_DM_REPAYMENT_SCHED_HIST(P_LOAD_DT date)
as
--    v_cnt number;
    v_dt date := P_LOAD_DT;
    v_file_id number;
    v_snapshot_dt date;
begin
--    into v_file_id,v_snapshot_dt--    select max(file_id), max(SNAPSHOT_DT)
--
--    from
--        (   select to_number(file_id) file_id, to_date(substr(SNAPSHOT_DT,1,10), 'dd.mm.yyyy') SNAPSHOT_DT
--            from stg_xls.DM_REPAYMENT_SCHEDULE_HIST
--            union all
--            select -1, to_date('01.01.1900', 'dd.mm.yyyy')  from dual
--        );                        

    

    SELECT /*+  NO_PARALLEL */  
    MAX (FILE_ID), MAX (SNAPSHOT_DT)
    into v_file_id,v_snapshot_dt
    FROM (SELECT /*+   NO_PARALLEL  cardinality(a,2775694 ) FIRST_ROWS(10)  */ 
            TO_NUMBER (FILE_ID) FILE_ID,
            TO_DATE (SUBSTR (SNAPSHOT_DT, 1, 10), 'dd.mm.yyyy') SNAPSHOT_DT
          FROM STG_XLS.DM_REPAYMENT_SCHEDULE_HIST a
          where rownum < 10
          UNION ALL
          SELECT /*+  NO_PARALLEL */   
          -1, TO_DATE ('01.01.1900', 'dd.mm.yyyy')
          FROM DUAL
         );
         
           
    
         
            
    
    if v_file_id <> -1 then
    
        EXECUTE_SQL('truncate table  TMP_DM_REPAYMENT_SCHEDULE_HIST');
        EXECUTE_SQL('truncate table  TMP_V_DM_REPAYMENT_SCHED_HIST');
--        delete from TMP_DM_REPAYMENT_SCHEDULE_HIST;
--        delete from TMP_V_DM_REPAYMENT_SCHED_HIST;
        
        insert into TMP_V_DM_REPAYMENT_SCHED_HIST
        select * from  stg_xls.V_DM_REPAYMENT_SCHEDULE_HIST;
        
        insert into TMP_DM_REPAYMENT_SCHEDULE_HIST
        (
        RID 
        )
        select t.rowid rid
        from DM_REPAYMENT_SCHEDULE_HIST t
            inner join DM_CGP cgp
                on t.CONTRACT_KEY = cgp.CONTRACT_KEY
                and cgp.SNAPSHOT_DT = v_snapshot_dt
                and cgp.SNAPSHOT_CD = 'Основной КИС'
        where 1=1
        and t.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy') 
        and not (
                    t.SNAPSHOT_DT = v_snapshot_dt
                and t.SNAPSHOT_CD = 'Основной КИС'
                and t.NIL_AMT > 0
                and cgp.TERM_AMT <> 0
                and t.PAY_DT > v_snapshot_dt
                )
        and exists
        (
            select 1
            from TMP_V_DM_REPAYMENT_SCHED_HIST s
            where t.CONTRACT_KEY = s.CONTRACT_KEY
            and t.SNAPSHOT_DT = s.SNAPSHOT_DT
            and t.PAY_DT = s.PAY_DT
            and t.CURRENCY_KEY =  s.CURRENCY_KEY                
        );        
                        

        insert into TMP_DM_REPAYMENT_SCHEDULE_HIST
        (
        RID, COL_FLG, PAY_DT, SNAPSHOT_DT, NIL_AMT, TRANCHE_NUM, FILE_ID, CONTRACT_KEY, CURRENCY_KEY, SNAPSHOT_CD, SNAPSHOT_MONTH, BRANCH_KEY
        )
        select 
        t.rid, decode(nvl(t.CONTRACT_KEY,0),0, 'I',s.CONTRACT_KEY,'U', 'D') COL_FLG 
        ,nvl(s.PAY_DT, t.PAY_DT) PAY_DT
        ,nvl(s.SNAPSHOT_DT,t.SNAPSHOT_DT),
        s.NIL_AMT, s.TRANCHE_NUM,s.FILE_ID
        ,nvl(s.CONTRACT_KEY,t.CONTRACT_KEY)
        ,nvl(s.CURRENCY_KEY, t.CURRENCY_KEY)
        ,s.SNAPSHOT_CD,s.SNAPSHOT_MONTH,s.BRANCH_KEY
        from stg_xls.v_DM_REPAYMENT_SCHEDULE_HIST s
        full outer join
        (select t.rowid rid
        ,t.*
        from DM_REPAYMENT_SCHEDULE_HIST t
            inner join DM_CGP cgp
                on t.CONTRACT_KEY = cgp.CONTRACT_KEY
                and cgp.SNAPSHOT_DT = v_snapshot_dt
                and cgp.SNAPSHOT_CD = 'Основной КИС'
        where 1=1
        and t.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy') 
        and t.SNAPSHOT_DT = v_snapshot_dt
        and t.SNAPSHOT_CD = 'Основной КИС'
        and t.NIL_AMT > 0
        and cgp.TERM_AMT <> 0
        and t.PAY_DT > v_snapshot_dt
        ) t
        on (
                t.CONTRACT_KEY = s.CONTRACT_KEY
            and t.SNAPSHOT_DT = s.SNAPSHOT_DT
            and t.PAY_DT = s.PAY_DT
            and t.CURRENCY_KEY =  s.CURRENCY_KEY       
        )
        where 1=1
        and (decode(round(t.NIL_AMT,2),s.NIL_AMT,0,1)=1 or
             decode(round(t.TRANCHE_NUM,2),s.TRANCHE_NUM,0,1)=1
             );

    
    -------------------------------------------------------------------------------------- 
    -- Close deleted and updated rows 
    -------------------------------------------------------------------------------------- 
    merge into dm.DM_REPAYMENT_SCHEDULE_HIST trg
    using TMP_DM_REPAYMENT_SCHEDULE_HIST src
    on(trg.rowid = src.rid)
        when matched then update
            set trg.VALID_TO_DTTM = v_dt - 1/(24*60*60)
            ,trg.CLOSED_ROW_FILE_ID = decode(src.COL_FLG, 'D',v_file_id);


    -------------------------------------------------------------------------------------- 
    -- Insert new rows 
    -------------------------------------------------------------------------------------- 
            
    insert into dm.DM_REPAYMENT_SCHEDULE_HIST           
    (
        SNAPSHOT_DT, SNAPSHOT_CD, SNAPSHOT_MONTH, CONTRACT_KEY, TRANCHE_NUM, PAY_DT, CURRENCY_KEY  
        ,NIL_AMT, PROCESS_KEY, INSERT_DT, BRANCH_KEY, FILE_ID, VALID_FROM_DTTM, VALID_TO_DTTM, CUSTOM_FLG, CLOSED_ROW_FILE_ID
    )
    select SNAPSHOT_DT,SNAPSHOT_CD,SNAPSHOT_MONTH,CONTRACT_KEY,TRANCHE_NUM,PAY_DT,CURRENCY_KEY
    ,NIL_AMT, 888, SYSDATE, BRANCH_KEY,FILE_ID, v_dt, to_date('01.01.2400', 'dd.mm.yyyy'),1, null
    from TMP_DM_REPAYMENT_SCHEDULE_HIST s
    where COL_FLG in('I','U');
    
--    commit;
    
    end if;
    
--    exception 
--        when others then
--            ETL.SET_FILE_STATUS(v_file_id,'-40');
end;
/

