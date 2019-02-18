CREATE OR REPLACE PROCEDURE ETL."P_DM_WORK_STATUSES_REFRESH"
IS

v_sys_dt date;
v_oper_key number;

BEGIN

select sysdate into v_sys_dt from dual;

select SQ_DM_WORK_STATUSES.nextval into v_oper_key from dual;

for rec in (SELECT ADD_MONTHS (month_min, LEVEL - 1) month_
                       FROM (SELECT MIN (lease_month) month_min,
                                    trunc (last_day (sysdate)) month_max
                               FROM dm.dm_transmit_subjects)
                 CONNECT BY ADD_MONTHS (month_min, LEVEL - 1) <= month_max)                 
loop

DM.P_DM_WORK_STATUSES (rec.month_);

insert into DM_WORK_STAT_LOG_TIMESTAMP (OPER_KEY, DM_NAME, T_TIME, REPORT_DT)
values (v_oper_key, 'DM_WORK_STATUSES', sysdate, rec.month_);
commit;

DM.P_DM_VINTAGE (rec.month_);

insert into DM_WORK_STAT_LOG_TIMESTAMP (OPER_KEY, DM_NAME, T_TIME, REPORT_DT)
values (v_oper_key, 'DM_VINTAGE', sysdate, rec.month_);
commit;

end loop;

end;
/

