create or replace procedure dm.EXECUTE_SQL(p_sql varchar2) as
 PRAGMA AUTONOMOUS_TRANSACTION;
begin
    execute immediate p_sql;
    commit;
end;
/

