create or replace force view dm.v_ias3mrur_det as
select 
reg.SNAPSHOT_DT,
reg.REG_SOURCE_CD,
reg.CONTRACT_KEY, reg.CLIENT_KEY, reg."ACÑOUNT_KEY", reg.INSTRUMENT_KIND_CD, reg.INSTRUMENT_KEY,
substr(ins.M7_CD,1,3) as IAS1,
ins.M7_CD,
ins.M7_DESC_TMP,
reg.RUR_MR_AMT/1000000 as MRUR,
reg.RUR_MR_AMT/1000 as TRUR
from dm.dm_reg reg
join dwh.INSTRUMENT_TYPES ins on  ins.INSTRUMENT_KEY=reg.INSTRUMENT_KEY and ins.M7_CD is not null
where reg.instrument_key<>23
union all
select 
reg.SNAPSHOT_DT,
reg.REG_SOURCE_CD,
reg.CONTRACT_KEY, reg.CLIENT_KEY, reg."ACÑOUNT_KEY", reg.INSTRUMENT_KIND_CD, reg.INSTRUMENT_KEY,
substr(ins.M7_CD,1,3) as IAS1,
ins.M7_CD,
ins.M7_DESC_TMP,
reg.RUR_MR_AMT/1000000 as MRUR,
reg.RUR_MR_AMT/1000 as TRUR
from dm.dm_reg reg
join dwh.INSTRUMENT_TYPES ins on  ins.INSTRUMENT_KEY=reg.INSTRUMENT_KEY and ins.M7_CD is not null
join dwh.CLIENTS cl on cl.CLIENT_KEY=reg.CLIENT_KEY and cl.VALID_TO_DTTM>sysdate + 100 and cl.ORG_TYPE_KEY=7
where reg.instrument_key=23 
union all
select 
reg.SNAPSHOT_DT,
reg.REG_SOURCE_CD,
reg.CONTRACT_KEY, reg.CLIENT_KEY, reg."ACÑOUNT_KEY", reg.INSTRUMENT_KIND_CD, reg.INSTRUMENT_KEY,
'203' as IAS1,
'20310' as M7_CD,
'Êðåäèòû è ÄÎ íå áàíêîâ' as M7_DESC_TMP,
reg.RUR_MR_AMT/1000000 as MRUR,
reg.RUR_MR_AMT/1000 as TRUR
from dm.dm_reg reg
join dwh.CLIENTS cl on cl.CLIENT_KEY=reg.CLIENT_KEY and cl.VALID_TO_DTTM>sysdate + 100 and cl.ORG_TYPE_KEY<>7
where reg.instrument_key=23 --and reg.BANK_KEY is not null
;

