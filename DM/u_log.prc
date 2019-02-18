create or replace procedure dm.u_log(p_proc varchar2,p_step varchar2,p_info varchar2)
is
pragma autonomous_transaction;
begin
  insert into L$DM(dt,proc_name,step_name,info) values(systimestamp,p_proc,p_step,p_info);
  commit;
  end;
/
grant execute on DM.U_LOG to ADM;


