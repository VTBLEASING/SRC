create or replace force view dm.v_m6 as
select "INS_STATEMENT","OPER_TYPE","SHORT_CLIENT_RU_NAM","ACC_TYPE","CURRENCY_CD","MRUR","RATE","START_DT","END_DT" from
(select
case when xxx.INSTRUMENT_KEY=999 then 'Кредиты ЮЛ, вкл РЕПО'
     when xxx.INSTRUMENT_KEY=888 then 'Средства банков'
     else ins.M7_desc end as INS_STATEMENT,
case when xxx.DELTA_USD>0 and xxx.INSTRUMENT_KIND_CD='Активы' then 'Привлечение'
     when xxx.DELTA_USD<0 and xxx.INSTRUMENT_KIND_CD='Пассивы' then 'Привлечение'
     when xxx.DELTA_USD>0 and xxx.INSTRUMENT_KIND_CD='Пассивы' then 'Погашение'
     when xxx.DELTA_USD<0 and xxx.INSTRUMENT_KIND_CD='Активы' then 'Погашение' 
     end as OPER_TYPE,
cli.SHORT_CLIENT_RU_NAM,
case when ins.M7_CD in ('10610','10620','10630','10640','10650','10450','20210','20220','20230') then ins.M7_desc else null end as ACC_TYPE,
cur.CURRENCY_CD,
xxx.rur_amt/1000000 as MRUR,
xxx.RATE,
case when xxx.INSTRUMENT_KEY in (1,48) then acc.open_dt
     when xxx.INSTRUMENT_KEY in (999) then cgp.start_dt 
     when xxx.INSTRUMENT_KEY in (888) then ks.contract_dt 
     when xxx.REG_SOURCE_CD='KS' then ks.contract_dt 
     else null end as START_DT,
case when xxx.INSTRUMENT_KEY in (1,48) then acc.close_dt
     when xxx.INSTRUMENT_KEY in (999) then cgp.end_dt 
     when xxx.INSTRUMENT_KEY in (888) then ks.end_dt 
     when xxx.REG_SOURCE_CD='KS' then ks.end_dt
     else null end as END_DT
from 
----------------------------------------------------------
(select 
tt.SNAPSHOT_DT, 
tt.INSTRUMENT_KEY, 
TT.CONTRACT_KEY, 
tt.ACСOUNT_KEY, 
tt.CLIENT_KEY, 
tt.BRANCH_KEY, 
tt.BANK_KEY, 
tt.reg_source_cd, 
tt.SRC_CURRENCY_KEY as currency,
tt.INSTRUMENT_KIND_CD,
tt.RATE_AMT as RATE,
tt.rur_amt, 
tt.Prev_rur, 
(tt.rur_AMT-tt.PREV_rur)/ex.exchange_rate as delta_usd
from
(select t.SNAPSHOT_DT, t.INSTRUMENT_KIND_CD, t.INSTRUMENT_KEY, t.CONTRACT_KEY, t.ACСOUNT_KEY, t.CLIENT_KEY, t.BRANCH_KEY, t.BANK_KEY, t.reg_source_cd, t.SRC_CURRENCY_KEY, t.PAY_DT, t.rur_amt, t.rate_amt,
lag(rur_amt,1,0) over(partition by t.INSTRUMENT_KEY, t.CONTRACT_KEY, t.ACСOUNT_KEY, t.CLIENT_KEY, t.BRANCH_KEY, t.BANK_KEY, t.reg_source_cd,t.SRC_CURRENCY_KEY, t.PAY_DT order by t.snapshot_dt) as prev_rur
from dm.dm_reg t
where t.instrument_key in (1,9,22,48)
) tt
join dwh.EXCHANGE_RATES ex on ex.EX_RATE_DT=tt.snapshot_dt and ex.BASE_CURRENCY_KEY=125 and ex.CURRENCY_KEY=149

union all

select 
tt.SNAPSHOT_DT, 
999 as INSTRUMENT_KEY, 
TT.CONTRACT_KEY, 
null as ACСOUNT_KEY, 
tt.CLIENT_KEY, 
tt.BRANCH_KEY, 
null as BANK_KEY, 
'CGPPPP' as reg_source_cd, 
tt.CURRENCY_KEY as currency, 
'Активы' as INSTRUMENT_KIND_CD,
tt.XIRR_RATE as RATE,
tt.rur_amt, 
tt.Prev_term_rur as prev_rur,
(tt.rur_amt-tt.prev_term_rur)/exx.exchange_rate as delta_usd 
from
(select t.SNAPSHOT_DT, t.CONTRACT_KEY, t.BRANCH_KEY, t.CLIENT_KEY, t.CURRENCY_KEY ,t.xirr_rate ,t.term_amt, t.term_amt*ex.exchange_rate as rur_amt,
(lag(t.term_amt,1,0) over(partition by t.CONTRACT_KEY, t.BRANCH_KEY, t.CLIENT_KEY, t.CURRENCY_KEY order by t.SNAPSHOT_DT))*ex.exchange_rate as prev_term_rur
from dm.DM_CGP t
join dwh.EXCHANGE_RATES ex on ex.EX_RATE_DT=t.snapshot_dt and ex.BASE_CURRENCY_KEY=125 and ex.CURRENCY_KEY=t.CURRENCY_KEY
--where t.snapshot_dt <> '31.07.2014'
) tt
join dwh.EXCHANGE_RATES exx on exx.EX_RATE_DT=tt.snapshot_dt and exx.BASE_CURRENCY_KEY=125 and exx.CURRENCY_KEY=149

union all

select 
to_date('30.06.2014','dd.mm.yyyy') as SNAPSHOT_DT, 
888 as INSTRUMENT_KEY, 
t.CONtract_key, 
null as ACСOUNT_KEY, 
t.CLIENT_KEY, 
null as BRANCH_KEY, 
null as BANK_KEY, 
'KSSS' as reg_source_cd, 
t.CURRENCY_KEY as currency, 
'Пассивы' as INSTRUMENT_KIND_CD,
t.rate,
nvl(t.pay_in_amt,0)+nvl(t.PAY_term_amt,0)+nvl(nkd_amt,0) as rur_amt, 
null as prev_rur,
nvl(t.pay_in_amt,0)+nvl(t.PAY_term_amt,0)+nvl(nkd_amt,0) as delta_usd
from dwh.FACT_KS_FLOW t
where t.KS_SRC_KEY=1
and t.PAY_DT between trunc(to_date('30.06.2014','dd.mm.yyyy'), 'mm') and to_date('30.06.2014','dd.mm.yyyy')
) xxx
------------------------------------------------------
left join dwh.INSTRUMENT_TYPES ins on xxx.INSTRUMENT_KEY=ins.INSTRUMENT_KEY 
left join dwh.CLIENTS cli on xxx.client_key=cli.CLIENT_KEY and cli.VALID_TO_DTTM>SYSDATE+100
left join dwh.currencies cur on cur.currency_key=xxx.currency and cur.VALID_TO_DTTM>SYSDATE+100
left join dwh.bank_accounts acc on acc.ACcount_key=ACСOUNT_KEY and acc.valid_to_dttm>sysdate + 100
left join dm.dm_cgp cgp on cgp.contract_key=xxx.contract_key and xxx.snapshot_dt=cgp.snapshot_dt
left join 
(select contract_key, contract_dt, max(pay_dt) as end_dt from dwh.fact_ks_flow where valid_to_dttm>sysdate + 100 group by contract_key, contract_dt) ks 
   on ks.contract_key=xxx.contract_key --and (xxx.REG_SOURCE_CD='KS' or xxx.instrument_key =888)
where 1=1 
and xxx.delta_usd>=50000000)
;

