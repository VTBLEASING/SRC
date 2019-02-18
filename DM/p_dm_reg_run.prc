create or replace procedure dm.p_dm_reg_run(p_REPORT_DT date) as
    v_lockid                VARCHAR2 (30);
    v_code number;
begin

      DBMS_LOCK.allocate_unique ('DM_REG_OTHER', v_lockid);
      v_code := -1;
      
      v_code :=
            sys.DBMS_LOCK.request (v_lockid,
                                   sys.DBMS_LOCK.x_mode,
                                   10,
                                   TRUE);

      if v_code <> 0
        then raise_application_error (-20926,'Procedure p_dm_reg_run has already launched');
      end if;      
      
      dm.p_dm_reg_other (p_REPORT_DT);

      dm.p_dm_reg (p_REPORT_DT);

      v_code := DBMS_LOCK.release (v_lockid);

      commit;

--EXCEPTION
--   WHEN OTHERS
--   THEN
--            etl.ctl_log_pkg.ctl_log_err(str);
--      RAISE;

end;
/

