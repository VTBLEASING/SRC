create or replace procedure dm.p_load_dm_reg is
    v_status_cd VARCHAR2(100) := '-55';
   -- v_dt date:= sysdate;
    v_file_id number;
    v_snapshot_dt date;
begin
    select max(file_id), max(SNAPSHOT_DT)
    into v_file_id, v_snapshot_dt
    from
        (   select to_number(file_id) file_id, to_date(substr(SNAPSHOT_DT,1,10), 'dd.mm.yyyy') SNAPSHOT_DT
            from stg_xls.DM_CGP_HIST
            union all
            select -1, to_date('01.01.1900', 'dd.mm.yyyy')  from dual
        );
    if v_file_id <> -1 then
        --v_status_cd := '-51' ;
        DM.P_DM_EXP_CGP_ADAPT_TO_EXCEL(v_snapshot_dt+1);
        --------------------------------------------------------------------------------------
        --v_status_cd := '-52' ;
        dm.p_dm_reg_cgp_n (v_snapshot_dt, 1);
        --------------------------------------------------------------------------------------
        --v_status_cd := '-53' ;
        dm.p_dm_reg_repayment_schedule_n (v_snapshot_dt, 1);
        --------------------------------------------------------------------------------------
        --v_status_cd := '-54' ;
        DM.p_dm_reg_run(v_snapshot_dt);
        --------------------------------------------------------------------------------------
        commit;
        dm.P_DM_EXP_REG_LIQ_TO_XLS(v_snapshot_dt + 1);
        commit;
    end if;
    exception when others
            then ETL.SET_FILE_STATUS(p_file_id => v_file_id , p_status_cd => v_status_cd);
            raise;
end;
/

