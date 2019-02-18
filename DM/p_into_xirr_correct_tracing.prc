CREATE OR REPLACE PROCEDURE DM."P_INTO_XIRR_CORRECT_TRACING" (
p_contract_id in number,
p_REPORT_DT in date,
p_OPER_TYPE in varchar2,
p_cnt number

)
IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
insert into xirr_correct_calc_log  values (p_contract_id, systimestamp, p_REPORT_DT, p_OPER_TYPE, p_cnt);
commit;
end;
/

