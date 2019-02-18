create or replace procedure dm.dm_xirr_chunk_new(p_REPORT_DT date, p_lo_rid in number, p_hi_rid in number) is
begin
    for x in (select L_KEY, branch_key, flag  from dm_xirr_flow_uniq where rid between p_lo_rid and p_hi_rid )
    loop
        insert into dm_xirr_new values (x.L_KEY, nvl(f_xirr_calc_new(x.L_KEY, p_REPORT_DT), -1), p_REPORT_DT, x.branch_key, 'Основной КИС', x.flag);
    end loop;
end;
/

