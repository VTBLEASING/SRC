CREATE OR REPLACE PROCEDURE DM."P_DM_CGP_RECALC" (
    p_report_dt in date,
    p_snapshot_cd in varchar

)
IS

begin
      dm.u_log(p_proc => 'P_DM_CGP_RECALC',
           p_step => 'INPUT PARAMS',
           p_info => /*'p_group_key:'||p_group_key||*/'p_REPORT_DT:'||p_REPORT_DT||'p_snapshot_cd:'||p_snapshot_cd); 
for x in (
          select contract_id 
          from dm_xirr_contract
          )
  
loop
p_dm_xirr_calc_kis_single (x.contract_id, p_report_dt);
p_dm_nil_calc_kis_single (x.contract_id, p_report_dt);
p_dm_overdue_calc_single (x.contract_id, p_report_dt, p_snapshot_cd);
p_dm_avg_overdue_calc_single (x.contract_id, p_report_dt, p_snapshot_cd);
p_dm_overdue_dt_single (x.contract_id, p_report_dt, p_snapshot_cd);
p_dm_max_dt_single (p_report_dt, x.contract_id);
p_dm_cgp_single (x.contract_id, p_report_dt, p_snapshot_cd);
delete from dm_xirr_contract where contract_id = x.contract_id;
commit;
end loop;
end;
/

