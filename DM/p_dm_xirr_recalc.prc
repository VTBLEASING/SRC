CREATE OR REPLACE PROCEDURE DM."P_DM_XIRR_RECALC" (
    p_report_dt in date

)
IS

begin
for x in (
          select contract_id
          from dm_xirr_contract
          )
  
loop
p_dm_xirr_calc_kis_single (x.contract_id, p_report_dt);
delete from dm_xirr_contract where contract_id = x.contract_id;
commit;
end loop;
end;
/

