CREATE OR REPLACE PROCEDURE DM."P_DM_TASKS_DEFAULTS"
is

BEGIN 

execute immediate ('truncate table DM.DM_TASKS_DEFAULTS');

insert into  DM_TASKS_DEFAULTS (
          LEASING_DEAL_KEY,
          UNDER_NAM,
          UNDER_RESULT,
          RISK_AGREEMENT, 
          INSERT_DT
)

with tt as
(select
    leasing_deal_key,
    close_dt,
    OWNER_USER_NAM,
    APPROVAL_RESOLUTION,
    RISK_RESOLUTION
from
dm.dm_tasks
where OWNER_USER_NAM is not null
   or APPROVAL_RESOLUTION is not null
   or RISK_RESOLUTION is not null
)

select 
      leasing_deal_key,
      max(OWNER_USER_NAM) keep (dense_rank last order by case when OWNER_USER_NAM is null then 0 else 1 end, close_dt) as under_nam,
      max(APPROVAL_RESOLUTION) keep (dense_rank last order by case when APPROVAL_RESOLUTION is null then 0 else 1 end, close_dt) as under_result,
      max(RISK_RESOLUTION) keep (dense_rank last order by case when RISK_RESOLUTION is null then 0 else 1 end, close_dt) as risk_agreement,
      sysdate
from tt
group by leasing_deal_key;

COMMIT;

END;
/

