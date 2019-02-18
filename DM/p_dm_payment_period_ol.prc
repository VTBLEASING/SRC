CREATE OR REPLACE PROCEDURE DM.P_DM_PAYMENT_PERIOD_OL
(
P_REPORT_ID number
)
IS
    v_snapshot_cd varchar2(100);
    v_snapshot_dt date;
    v_branch_key number;
    v_contract_key number;
    v_currency_key number;
    v_auto_flg varchar2(100);
    v_pay_start_dt date;
    v_pay_end_dt date;
    
    
BEGIN




select  SNAPSHOT_DT
        ,SNAPSHOT_CD
        ,CONTRACT_KEY
        ,BRANCH_KEY
        ,CURRENCY_KEY
        ,AUTO_FLG
        ,nvl(PAY_START_DT, to_date ('01.01.2000', 'dd.mm.yyyy'))
        ,nvl(PAY_END_DT,to_date ('31.12.3999', 'dd.mm.yyyy'))
into    v_snapshot_dt
        ,v_snapshot_cd
        ,v_contract_key
        ,v_branch_key
        ,v_currency_key           
        ,v_auto_flg
        ,v_pay_start_dt
        ,v_pay_end_dt
from vtbl.PAYMENT_NIL_PERIOD_LOG
where REPORT_ID = P_REPORT_ID;  
     
  dm.u_log(p_proc => 'DM.P_DM_PAYMENT_PERIOD_OL',
           p_step => 'INPUT PARAMS',
           p_info => 'v_snapshot_cd:'||v_snapshot_cd||'v_snapshot_dt:'||v_snapshot_dt||'v_branch_key:'
           ||v_branch_key||'v_contract_key:'||v_contract_key||'v_currency_key:'||v_currency_key||'v_auto_flg:'
           ||v_auto_flg||'v_pay_start_dt:'||v_pay_start_dt||'v_pay_end_dt:'||v_pay_end_dt); 


case v_snapshot_cd
    when 'PAYMENT_RUB_MONTH' then null;
    when 'PAYMENT_RUB_QUARTER' then null;
    when 'PAYMENT_ORIG_MONTH' then null;
    when 'PAYMENT_ORIG_QUARTER' then null;
    when 'NIL_RUB_MONTH' then null;
    when 'NIL_RUB_QUARTER' then null;
    when 'NIL_ORIG_MONTH' then null;
    when 'NIL_ORIG_QUARTER' then null;
    when 'NIL_DET_RUB_MONTH' then null;
    when 'NIL_DET_RUB_QUARTER' then null;
    when 'NIL_DET_ORIG_MONTH' then null;
    when 'NIL_DET_ORIG_QUARTER' then null;
     when 'SUM_PAYMENT_OL_RUB_MONTH' then null;
    when 'SUM_PAYMENT_OL_RUB_QUARTER' then null;
    when 'SUM_PAYMENT_OL_ORIG_MONTH' then null;
    when 'SUM_PAYMENT_OL_ORIG_QUARTER' then null;
else  
    raise_application_error (-20928,'Parameter "P_SNAPSHOT_CD" is not coorect. Correct values: PAYMENT_RUB_MONTH, PAYMENT_RUB_QUARTER, PAYMENT_ORIG_MONTH, PAYMENT_ORIG_QUARTER, NIL_RUB_MONTH, NIL_RUB_QUARTER,
     NIL_ORIG_MONTH, NIL_ORIG_QUARTER, NIL_DET_RUB_MONTH, NIL_DET_RUB_QUARTER, NIL_DET_ORIG_MONTH, NIL_DET_ORIG_QUARTER,
      SUM_PAYMENT_OL_RUB_MONTH, SUM_PAYMENT_OL_RUB_QUARTER, SUM_PAYMENT_OL_ORIG_MONTH, SUM_PAYMENT_OL_ORIG_QARTER   ');
end case;


execute immediate 'truncate table dm.PAY_OL_ON_MONTH';

INSERT INTO dm.PAY_OL_ON_MONTH
select  P_REPORT_ID, t2.con, t2.branch_nam, t2.snapshot_dt, t2.cl, t2.cu, t2.auto_flg, t2.pay_dt, t2.val, 2 from(
/*
with cgp_s as
(
    select *
    from dm.dm_cgp cgp
    where t.snapshot_cd = 'Основной КИС'
    and t.snapshot_dt=v_pay_end_dt
)
,cgp_client as
(
    select cgp_s.* 
    from cgp_s
    where 0 = (select count(1) from  vtbl.PAYMENT_NIL_PERIOD_CLIENTS where report_id = P_REPORT_ID)
    union all
    select cgp_s.* 
        from cgp_s cgp_s
            inner join vtbl.PAYMENT_NIL_PERIOD_CLIENTS pnpc
                on  report_id = P_REPORT_ID
                and cgp_s.CLIENT_KEY = pnpc.CLIENT_KEY    
    
)*/
select t1.con con, t1.branch_nam, t1.snapshot_dt,  t1.cl, t1.auto_flg, t1.cu, t1.pay_dt pay_dt, t1.val val 
 from

(select ct.contract_id_cd con, --t.contract_id_cd con, 


case when  v_snapshot_cd like '%MONTH%' then
to_char(add_months (trunc(t.pay_dt, 'MONTH'), 1),'dd.mm.yyyy') 
when  v_snapshot_cd like '%QUARTER%' then
  to_char(trunc(add_months (trunc(t.pay_dt, 'MONTH'), 1), 'Q'),'dd.mm.yyyy')
  end as pay_dt 


,t3.BRANCH_NAM branch_nam
  
,t.snapshot_dt
,round(
        case when v_snapshot_cd like '%RUB%' then to_number(sum(t.pay_amt*t4.EXCHANGE_RATE))   
            when v_snapshot_cd like '%ORIG%' then to_number(sum(t.pay_amt))
        end
      ,2) as val      
,cl.SHORT_CLIENT_RU_NAM cl
,case when nvl (lc.auto_flg, 0) != 0 then 'Автолизинг' else 'Корпоративный' end auto_flg
,cur.currency_letter_cd cu
from dm.dm_ol_flow_orig t
--left join dm.dm_ol_flow_orig t on t.l_key = t.contract_key and t.snapshot_dt = t.snapshot_dt and t.snapshot_cd = 'Основной КИС' 
left join dwh.leasing_contracts lc on  t.l_key = lc.contract_key and lc.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
left join dwh.contracts ct on  ct.contract_key = lc.contract_key and ct.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
left join dwh.currencies cur on  t.cur1 = cur.currency_key and cur. valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') and cur.begin_dt <=  t.snapshot_dt and cur.end_dt >  t.snapshot_dt
left join dwh.org_structure t3 on t3.branch_key =  t.BRANCH_KEY and t3.VALID_TO_DTTM > sysdate+100
left join dwh.clients cl on ct.client_key=cl.client_key and cl.VALID_TO_DTTM > sysdate+100
left join dwh.exchange_rates t4 on t4.base_currency_key = 125 and t4.valid_to_dttm > sysdate+100 and t4.currency_key = t.cur1 and t4.ex_rate_dt = v_pay_end_dt
where 1=1 
and  t.snapshot_dt = v_snapshot_dt
and  t.TP = 'OL_PLAN' 
and  t.CBC_DESC in ('ОД.1.1', 'ОД.1.3', 'ОД.1.4')
-------------------------------------------------------------------------------------- 
and t3.branch_key = nvl (null, t3.branch_key)
and t.branch_key = nvl (v_branch_key, t.branch_key)
and t.l_key = nvl (v_contract_key, t.l_key)
and cur.currency_key = nvl (v_currency_key, cur.currency_key)
and case when nvl (lc.auto_flg, 0) != 0 then 'AUTOLEASING' else 'CORPORATIVE' end = nvl (null, case when nvl (lc.auto_flg, 0) != 0 then 'AUTOLEASING' else 'CORPORATIVE' end)
and t.pay_dt >= nvl (v_pay_start_dt, to_date('01.01.2000', 'dd.mm.yyyy'))
and t.pay_dt <= nvl (v_pay_end_dt, to_date ('31.12.3999', 'dd.mm.yyyy'))
-------------------------------------------------------------------------------------- 
group by 
case when  v_snapshot_cd like '%MONTH%' then
to_char(add_months (trunc(t.pay_dt, 'MONTH'), 1),'dd.mm.yyyy') 
when  v_snapshot_cd like '%QUARTER%' then
  to_char(trunc(add_months (trunc(t.pay_dt, 'MONTH'), 1), 'Q'),'dd.mm.yyyy')
  end
  
,t3.BRANCH_NAM 
,ct.contract_id_cd  
,t.snapshot_dt
,cl.SHORT_CLIENT_RU_NAM
,case when nvl (lc.auto_flg, 0) != 0 then 'Автолизинг' else 'Корпоративный' end 
,cur.currency_letter_cd   
--having t.contract_id_cd in ('116/01-06', '116/01-11', 'FRE-01')

union --sum on year

select
ct.contract_id_cd con,
to_char(add_months (trunc(t.pay_dt, 'MONTH'), 1),'YYYY') pay_dt 
,t3.BRANCH_NAM  
,t.snapshot_dt
,round(
        case when v_snapshot_cd like '%RUB%' then to_number(sum(t.pay_amt*t4.EXCHANGE_RATE))   
            when v_snapshot_cd like '%ORIG%' then to_number(sum(t.pay_amt))
        end
      ,2) as val  
,cl.SHORT_CLIENT_RU_NAM cl   
,case when nvl (lc.auto_flg, 0) != 0 then 'Автолизинг' else 'Корпоративный' end auto_flg
,cur.currency_letter_cd cu
                                            
from dm.dm_ol_flow_orig t
--left join dm.dm_xirr_flow_orig t on t.l_key = t.contract_key and t.snapshot_dt = t.snapshot_dt and t.snapshot_cd = 'Основной КИС' 
left join dwh.leasing_contracts lc on t.l_key = lc.contract_key and lc.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
left join dwh.contracts ct on  ct.contract_key = lc.contract_key and ct.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
left join dwh.currencies cur on t.cur1 = cur.currency_key and cur. valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') and cur.begin_dt <= t.snapshot_dt and cur.end_dt > t.snapshot_dt
left join dwh.clients cl on ct.client_key=cl.client_key and cl.VALID_TO_DTTM > sysdate+100
left join dwh.org_structure t3 on t3.branch_key = t.BRANCH_KEY and t3.VALID_TO_DTTM > sysdate+100
left join dwh.exchange_rates t4 on t4.base_currency_key = 125 and t4.valid_to_dttm > sysdate+100 and t4.currency_key = t.cur1 and t4.ex_rate_dt = v_pay_end_dt
where 1=1 
and t.snapshot_dt = v_snapshot_dt
and t.TP = 'OL_PLAN' 
and t.CBC_DESC in ('ОД.1.1', 'ОД.1.3', 'ОД.1.4')
-------------------------------------------------------------------------------------- 
and t3.branch_key = nvl (null, t3.branch_key)
and t.branch_key = nvl (v_branch_key, t.branch_key)
and t.l_key = nvl (v_contract_key, t.l_key)
and cur.currency_key = nvl (v_currency_key, cur.currency_key)
and case when nvl (lc.auto_flg, 0) != 0 then 'AUTOLEASING' else 'CORPORATIVE' end = nvl (null, case when nvl (lc.auto_flg, 0) != 0 then 'AUTOLEASING' else 'CORPORATIVE' end)
and t.pay_dt >= nvl (v_pay_start_dt, to_date('01.01.2000', 'dd.mm.yyyy'))
and t.pay_dt <= nvl (v_pay_end_dt, to_date ('31.12.3999', 'dd.mm.yyyy'))
group by 
to_char(add_months (trunc(t.pay_dt, 'MONTH'), 1),'YYYY')

,t3.BRANCH_NAM 
,ct.contract_id_cd 
,t.snapshot_dt
,cl.SHORT_CLIENT_RU_NAM
,case when nvl (lc.auto_flg, 0) != 0 then 'Автолизинг' else 'Корпоративный' end 
,cur.currency_letter_cd 
--having t.contract_id_cd in ('116/01-06', '116/01-11', 'FRE-01')

union 

select -- total sums
ct.contract_id_cd num,
'Total'
,t3.BRANCH_NAM  
,t.snapshot_dt
,round(
        case when v_snapshot_cd like '%RUB%' then to_number(sum(t.pay_amt*t4.EXCHANGE_RATE))   
            when v_snapshot_cd like '%ORIG%' then to_number(sum(t.pay_amt))
        end
      ,2) as val     
,cl.SHORT_CLIENT_RU_NAM cl   
,case when nvl (lc.auto_flg, 0) != 0 then 'Автолизинг' else 'Корпоративный' end auto_flg
,cur.currency_letter_cd cu
                                            
from dm.dm_ol_flow_orig t
--left join dm.dm_xirr_flow_orig t on t.l_key = t.contract_key and t.snapshot_dt = t.snapshot_dt and t.snapshot_cd = 'Основной КИС' 
left join dwh.leasing_contracts lc on t.l_key = lc.contract_key and lc.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
left join dwh.contracts ct on  ct.contract_key = lc.contract_key and ct.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
left join dwh.currencies cur on t.cur1 = cur.currency_key and cur. valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy') and cur.begin_dt <= t.snapshot_dt and cur.end_dt > t.snapshot_dt
left join dwh.clients cl on ct.client_key=cl.client_key and cl.VALID_TO_DTTM > sysdate+100
left join dwh.org_structure t3 on t3.branch_key = t.BRANCH_KEY and t3.VALID_TO_DTTM > sysdate+100
left join dwh.exchange_rates t4 on t4.base_currency_key = 125 and t4.valid_to_dttm > sysdate+100 and t4.currency_key = t.cur1 and t4.ex_rate_dt = v_pay_end_dt
where 1=1 
and t.snapshot_dt = v_snapshot_dt
and t.TP = 'OL_PLAN' 
and t.CBC_DESC in ('ОД.1.1', 'ОД.1.3', 'ОД.1.4')
-------------------------------------------------------------------------------------- 
and t3.branch_key = nvl (null, t3.branch_key)
and t.branch_key = nvl (v_branch_key, t.branch_key)
and t.l_key = nvl (v_contract_key, t.l_key)
and cur.currency_key = nvl (v_currency_key, cur.currency_key)
and case when nvl (lc.auto_flg, 0) != 0 then 'AUTOLEASING' else 'CORPORATIVE' end = nvl (null, case when nvl (lc.auto_flg, 0) != 0 then 'AUTOLEASING' else 'CORPORATIVE' end)
and t.pay_dt >= nvl (v_pay_start_dt, to_date('01.01.2000', 'dd.mm.yyyy'))
and t.pay_dt <= nvl (v_pay_end_dt, to_date ('31.12.3999', 'dd.mm.yyyy'))
group by 
--to_char(add_months (trunc(t.pay_dt, 'MONTH'), 1),'YYYY')

t3.BRANCH_NAM 
,ct.contract_id_cd  
,t.snapshot_dt
,cl.SHORT_CLIENT_RU_NAM
,case when nvl (lc.auto_flg, 0) != 0 then 'Автолизинг' else 'Корпоративный' end 
,cur.currency_letter_cd 
--having t.contract_id_cd in ('116/01-06', '116/01-11', 'FRE-01')


order by  CON, PAY_DT

) t1

) t2;
commit;

 dm.u_log(p_proc => 'DM.P_DM_PAYMENT_PERIOD_OL',
  p_step => 'insert into DM.P_DM_PAYMENT_PERIOD_OL',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');


dm.p_dm_transp_payment( v_pay_start_dt, v_pay_end_dt, v_snapshot_cd); -- raznoska to mesyacam/kvartalam i godam


end;

--------------------------------------------------------------------------------
/

