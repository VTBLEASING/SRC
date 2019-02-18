CREATE OR REPLACE PROCEDURE DM.p_DM_IFRS_NIL_FLI(
    p_REPORT_DT date,
    p_SCRIPT_CD number)
is

BEGIN

  /*
     Процедура расчета витрины DM_CL_PL полностью.
     В качестве входного параметра подается дата составления отчета
  */
    dm.u_log(p_proc => 'DM.p_DM_IFRS_NIL_FLI',
           p_step => 'INPUT PARAMS',
           p_info => 'p_REPORT_DT: '||p_REPORT_DT);
  delete from DM.IFRS_NIL_FLI where snapshot_dt = p_REPORT_DT and script_cd = p_script_cd;

  dm.u_log(p_proc => 'DM.p_DM_IFRS_NIL_FLI',
           p_step => 'delete from DM.IFRS_NIL_FLI',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');

  commit;

INSERT /*+ APPEND */ INTO DM.IFRS_NIL_FLI

select a.*,
ls.script_cd as script_cd
from DM.V$IFRS_NIL_FLI a
LEFT JOIN dwh.ifrs_load_script ls on p_SCRIPT_cd = ls.script_cd
where a.snapshot_dt = p_REPORT_DT;

   dm.u_log(p_proc => 'DM.p_DM_IFRS_NIL_FLI',
           p_step => 'insert DM.p_DM_IFRS_NIL_FLI',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');

      commit;

   dm.analyze_table(p_table_name => 'IFRS_NIL_FLI',p_schema => 'DM');

   dm.u_log(p_proc => 'DM.p_DM_IFRS_NIL_FLI',
           p_step => 'analyze_table DM.IFRS_NIL_FLI',
           p_info => 'analyze_table done');
   etl.P_DM_LOG('IFRS_NIL_FLI');
END;
/

