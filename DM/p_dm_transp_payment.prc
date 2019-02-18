create or replace procedure dm.P_DM_TRANSP_PAYMENT
 (v_pay_start_dt date, v_pay_end_dt date, v_snapshot_cd varchar2)
  is

v_sql varchar2(32767);
v_sql1 varchar2(32767);
--v_snapshot_cd varchar2(32767);
v_in_clause varchar2(32767);
v_in_clause1 varchar2(32767);
v_c_clause varchar2(32767);
--v_pay_start_dt date;
--v_pay_end_dt date;
cnt number;
begin
  --list of dates
if v_snapshot_cd like '%MONTH%' then  
select  listagg(''''||case when c.is_month = 'Y' then to_char(c.first_day,'dd.mm.yyyy') else to_char(c.snapshot_dt,'yyyy') end||'''',',') WITHIN GROUP (ORDER BY snapshot_dt) x  into v_in_clause from dwh.calendar c
where snapshot_dt>=add_months(v_pay_start_dt,1) and snapshot_dt <= add_months(v_pay_end_dt,1) and is_month='Y'
 or (extract(year from snapshot_dt) between extract(year from add_months(v_pay_start_dt,1)) and extract(year from add_months(v_pay_end_dt,1)) and is_month='N') ;
  -- header
select  listagg(''''||case when c.is_month = 'Y' then to_char(c.first_day,'dd.mm.yyyy') else 'Год '||to_char(c.snapshot_dt,'yyyy') end||'''',',') WITHIN GROUP (ORDER BY snapshot_dt) x  into v_in_clause1 from dwh.calendar c
where snapshot_dt>=add_months(v_pay_start_dt,1) and snapshot_dt <= add_months(v_pay_end_dt,1) and is_month='Y'
 or (extract(year from snapshot_dt) between extract(year from add_months(v_pay_start_dt,1)) and extract(year from add_months(v_pay_end_dt,1)) and is_month='N') ;
elsif  v_snapshot_cd like  '%QUARTER%' then
   --list of dates
 select  listagg(''''||case when s.fl = 'Y' then to_char(s.s,'dd.mm.yyyy') else to_char(s.s,'yyyy') end||'''',',') WITHIN GROUP (ORDER BY s.d) x  into v_in_clause 
 from (select min(c.snapshot_dt) d, c.is_month fl,
 case when c.is_month = 'Y' then trunc(c.first_day,'Q') else trunc(c.snapshot_dt,'yyyy') end s
 from dwh.calendar c
where snapshot_dt>=add_months(v_pay_start_dt,1) and snapshot_dt <= add_months(v_pay_end_dt,1) and is_month='Y'
 or (extract(year from snapshot_dt) between extract(year from add_months(v_pay_start_dt,1)) and extract(year from add_months(v_pay_end_dt,1)) and is_month='N')
group by 
case when c.is_month = 'Y' then trunc(c.first_day,'Q') else trunc(c.snapshot_dt,'yyyy') end,  c.is_month  
order by 1
) s;
 -- header
select  listagg(''''||case when s.fl = 'Y' then 'Квартал '||to_char(s.s,'Q') else 'Год '||to_char(s.s,'yyyy') end||'''',',') WITHIN GROUP (ORDER BY s.d) x  into v_in_clause1 
 from (select  min(c.snapshot_dt) d, c.is_month fl,
 case when c.is_month = 'Y' then trunc(c.first_day,'Q') else trunc(c.snapshot_dt,'yyyy') end s
 from dwh.calendar c
where snapshot_dt>=add_months(v_pay_start_dt,1) and snapshot_dt <= add_months(v_pay_end_dt,1) and is_month='Y'
 or (extract(year from snapshot_dt) between extract(year from add_months(v_pay_start_dt,1)) and extract(year from add_months(v_pay_end_dt,1)) and is_month='N')
group by 
case when c.is_month = 'Y' then trunc(c.first_day,'Q')else trunc(c.snapshot_dt,'yyyy') end,  c.is_month 
order by 1 
) s;

end if;


if v_snapshot_cd like '%MONTH%' then  

select count(*) into cnt from dwh.calendar c
where  snapshot_dt>=add_months(v_pay_start_dt,1) and snapshot_dt <= add_months(v_pay_end_dt,1) and is_month='Y'
 or (extract(year from snapshot_dt) between extract(year from add_months(v_pay_start_dt,1)) and extract(year from add_months(v_pay_end_dt,1)) and is_month='N') ;
elsif  v_snapshot_cd like  '%QUARTER%' then
select count(distinct case when is_month='Y' then trunc(c.first_day,'Q') else snapshot_dt end) into cnt from dwh.calendar c
where  snapshot_dt>=add_months(v_pay_start_dt,1) and snapshot_dt <= add_months(v_pay_end_dt,1) and is_month='Y'
 or (extract(year from snapshot_dt) between extract(year from add_months(v_pay_start_dt,1)) and extract(year from add_months(v_pay_end_dt,1)) and is_month='N');
end if;


v_in_clause:=v_in_clause||', ''Total''';
v_in_clause1:=','||v_in_clause1||', ''Итого''';
v_c_clause:= 'REPORT_ID, CONTRACT_ID_CD, branch_nam, snapshot_dt, client_nam, currency_letter_cd, auto_flg, rn';

   FOR i IN 1..cnt+1 LOOP

      v_c_clause := v_c_clause||', f'||i;
        
   END LOOP;

-- insert into dm.temp_log (val1, val2) values (v_in_clause1, v_c_clause);

   COMMIT;
v_sql1:=Q'~insert into dm.DM_OL_PAYMENT_NIL_PERIOD([colum_clause])
select distinct REPORT_ID REPORT_ID,'ID договора' CONTRACT_ID_CD, 'Организация' BRANCH_NAM, SNAPSHOT_DT
, 'Наименование клиента' CLIENT_NAM , 'CURRENCY' CURRENCY_LETTER_CD, 'Продукт' AUTO_FLG, 1 rn
[continue]
from 
dm.PAY_OL_ON_MONTH
order by 1~';
v_sql1:=replace(v_sql1,'[continue]',v_in_clause1);
v_sql1:=replace(v_sql1,'[colum_clause]',v_c_clause);
--dbms_output.put_line(v_sql1);
--insert into dm.temp_log (val1) values (v_sql1);
commit;


execute immediate v_sql1;
commit;

v_sql:=Q'~insert into dm.DM_OL_PAYMENT_NIL_PERIOD([colum_clause])
select * from dm.PAY_OL_ON_MONTH
pivot
(
    avg(val) as val
   for pay_dt in ([clause])
 ) f
order by 2~';
v_sql:=replace(v_sql,'[clause]',v_in_clause);
v_sql:=replace(v_sql,'[colum_clause]',v_c_clause);

--dbms_output.put_line(v_sql);
execute immediate v_sql;
commit;

end;
/

