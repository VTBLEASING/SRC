CREATE OR REPLACE PROCEDURE DM."P_DM_CGP_RECALC_REPORT_DT" (
    p_snapshot_cd in varchar

)
IS

begin
for x in (
          select contract_id, 
          report_dt
          from dm_xirr_contract
          order by report_dt
          )
  
loop
p_dm_xirr_calc_kis_single (x.contract_id, x.report_dt);
p_dm_nil_calc_kis_single (x.contract_id, x.report_dt);
p_dm_overdue_calc_single (x.contract_id, x.report_dt, p_snapshot_cd);
p_dm_avg_overdue_calc_single (x.contract_id, x.report_dt, p_snapshot_cd);
p_dm_overdue_dt_single (x.contract_id, x.report_dt, p_snapshot_cd);
p_dm_max_dt_single (x.report_dt, x.contract_id);
p_dm_cgp_single (x.contract_id, x.report_dt, p_snapshot_cd);
delete from dm_xirr_contract where contract_id = x.contract_id and report_dt = x.report_dt;
commit;
end loop;
end;
/

