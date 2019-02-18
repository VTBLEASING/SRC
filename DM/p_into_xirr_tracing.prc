CREATE OR REPLACE PROCEDURE DM."P_INTO_XIRR_TRACING" (
p_contract_id in number,
p_REPORT_DT in date

)
IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
insert into xirr_calc_log  values (p_contract_id, systimestamp, p_REPORT_DT);
commit;
end;
/

