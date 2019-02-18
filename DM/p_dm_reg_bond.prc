CREATE OR REPLACE PROCEDURE DM.p_DM_REG_BOND (p_REPORT_DT in date, p_reg_group_key in number default 1)
IS

BEGIN
    dm.u_log(p_proc => 'p_DM_REG_BOND',
           p_step => 'INPUT PARAMS',
           p_info => 'p_reg_group_key:'||p_reg_group_key||'p_REPORT_DT:'||p_REPORT_DT); 

delete from DM.DM_REG_BOND where snapshot_dt = p_REPORT_DT and branch_key in (select branch_key from dwh.reg_group where reg_group_key = p_reg_group_key);
  dm.u_log(p_proc => 'DM_REG_BOND',
           p_step => 'delete from DM.DM_REG_BOND',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');  
                --расчет витрины по облигациям DM_REG_BOND
insert into DM.DM_REG_BOND
(SNAPSHOT_CD,
SNAPSHOT_DT,
SNAPSHOT_MONTH,
SNAPSHOT_YEAR,
BRANCH_KEY,
ACСOUNT_KEY,
CONTRACT_KEY,
CLIENT_KEY,
BANK_KEY,
MEMBER_KEY,
VTB_MEMBER_FLG,
INSTRUMENT_KEY,
INSTRUMENT_KIND_CD,
SRC_CURRENCY_KEY,
CIS_CURRENCY_KEY,
TERM_CNT,
PERIOD1_TYPE_KEY,
PERIOD2_TYPE_KEY,
PERIOD3_TYPE_KEY,
SRC_AMT,
RUR_AMT,
CIS_AMT,
RATE_W_AMT,
TERM_W_AMT,
SRC_LIQ_AMT,
CIS_LIQ_AMT,
SRC_MR_AMT,
RUR_MR_AMT,
RATE_W_MR_AMT,
PAY_DT,
EX_RATE,
FLOAT_RATE_FLG,
RATE_AMT,
PURPOSE_DESC,
ART_CD,
PROCESS_KEY,
INSERT_DT)
select
'Основной КИС' SNAPSHOT_CD,
p_REPORT_DT SNAPSHOT_DT,
TO_CHAR(p_REPORT_DT, 'MM') AS SNAPSHOT_MONTH,
TO_CHAR(p_REPORT_DT, 'YYYY') AS SNAPSHOT_YEAR,
a.BRANCH_KEY,
null ACCOUNT_KEY,
CONTRACT_KEY,
CLIENT_KEY,
null BANK_KEY,
MEMBER_KEY,
VTB_MEMBER_FLG,
INSTRUMENT_KEY,
INSTRUMENT_KIND_CD,
SRC_CURRENCY_KEY,
CIS_CURRENCY_KEY,
TERM_CNT,
PERIOD1_TYPE_KEY,
PERIOD2_TYPE_KEY,
PERIOD3_TYPE_KEY,
SRC_AMT,
RUR_AMT,
CIS_AMT,
RATE_W_AMT,
TERM_W_AMT,
SRC_LIQ_AMT,
CIS_LIQ_AMT,
SRC_MR_AMT,
RUR_MR_AMT,
RATE_W_MR_AMT,
PAY_DT,
EX_RATE,
FLOAT_RATE_FLG,
RATE_AMT,
(select PURPOSE_DESC
                            from dwh.OPERATION_PURPOSES
                            where Upper(INSTRUMENT_RU_NAM) ='ВЫПУЩЕННЫЕ ОБЛИГАЦИИ'
                            And Upper(INSTRUMENT_SOURCE_NAM)LIKE '%ОБЛИГАЦИИ%'
                            And BEGIN_DT<=p_REPORT_DT
                            AND END_DT>p_REPORT_DT) PURPOSE_DESC,
ART_CD,
777 PROCESS_KEY,
sysdate INSERT_DT
from(
select
--филиал
 (select branch_key
 from dwh.org_structure
 where branch_cd='VTB_LEASING'
 and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy'))
as branch_key,
fct.CONTRACT_KEY as CONTRACT_KEY,
cl.client_key as client_key,
cl.member_key as member_key,
IN_GROUP.VTB_MEMBER_FLG,

-- типа инструмента
 (select INSTRUMENT_KEY
  from dwh.INSTRUMENT_TYPES
  where Upper(INSTRUMENT_RU_NAM) like '%ВЫПУЩЕННЫЕ%ОБЛИГАЦИИ%'
  And Upper(INSTRUMENT_TYPE_DESC)='ПРОЦЕНТНЫЙ'
  And BEGIN_DT<=p_REPORT_DT
  AND END_DT>p_REPORT_DT
  )
as INSTRUMENT_KEY,

--статья
 (select INSTRUMENT_KIND_CD
  from dwh.INSTRUMENT_TYPES
  where Upper(INSTRUMENT_RU_NAM) like '%ВЫПУЩЕННЫЕ%ОБЛИГАЦИИ%'
  And Upper(INSTRUMENT_TYPE_DESC)='ПРОЦЕНТНЫЙ'
  And BEGIN_DT<=p_REPORT_DT
  AND END_DT>p_REPORT_DT
  ) 
AS INSTRUMENT_KIND_CD,
fct.CURRENCY_KEY  SRC_CURRENCY_KEY,

--валюта КИС
 case
 when upper(cur.CURRENCY_LETTER_CD) in ('USD','EUR','RUB') 
 then fct.CURRENCY_KEY
 else (select CURRENCY_KEY
       from DWH.CURRENCIES 
       where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
       and CURRENCY_LETTER_CD='OTH')
 end
AS CIS_CURRENCY_KEY,
 --СРОК, срок должен быть больше 1. Если срок=1, то кладем на срок =2.
decode(fct.PAY_DT-p_REPORT_DT, 1, 2,fct.PAY_DT-p_REPORT_DT) AS TERM_CNT,

--тип периода 1
 (select p.PERIOD_KEY
 FROM DWH.PERIODS P, DWH.PERIOD_TYPES PT
 where p.PERIOD_TYPE_KEY=pt.PERIOD_TYPE_KEY
       and pt.PERIOD_TYPE_CD=1
       and (fct.PAY_DT-p_REPORT_DT)> p.DAYS_FROM_CNT
       and (fct.PAY_DT-p_REPORT_DT)<=p.DAYS_TO_CNT
       and p.BEGIN_DT<=p_REPORT_DT       
       and p.END_DT>p_REPORT_DT
       and pt.BEGIN_DT<=p_REPORT_DT
       and pt.END_DT>p_REPORT_DT
       and p.VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
  )
as PERIOD1_TYPE_KEY,

--тип периода 2
 (select p.PERIOD_KEY
 FROM DWH.PERIODS P, DWH.PERIOD_TYPES PT
 where p.PERIOD_TYPE_KEY=pt.PERIOD_TYPE_KEY
       and pt.PERIOD_TYPE_CD=2
       and (fct.PAY_DT-p_REPORT_DT)> p.DAYS_FROM_CNT
       and (fct.PAY_DT-p_REPORT_DT)<=p.DAYS_TO_CNT
       and p.BEGIN_DT<=p_REPORT_DT       
       and p.END_DT>p_REPORT_DT
       and pt.BEGIN_DT<=p_REPORT_DT
       and pt.END_DT>p_REPORT_DT
       and p.VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
           )
as PERIOD2_TYPE_KEY,

--тип периода 3
 (select p.PERIOD_KEY
 FROM DWH.PERIODS P, DWH.PERIOD_TYPES PT
 where p.PERIOD_TYPE_KEY=pt.PERIOD_TYPE_KEY
       and pt.PERIOD_TYPE_CD=3
       and (fct.PAY_DT-p_REPORT_DT)> p.DAYS_FROM_CNT
       and (fct.PAY_DT-p_REPORT_DT)<=p.DAYS_TO_CNT
       and p.BEGIN_DT<=p_REPORT_DT       
       and p.END_DT>p_REPORT_DT
       and pt.BEGIN_DT<=p_REPORT_DT
       and pt.END_DT>p_REPORT_DT
       and p.VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
     )
as PERIOD3_TYPE_KEY,


--сумма в исходной валюте
-- [apolyakov 13.03.2017]: Удален НКД в рамках ЗА 4689
(-1)* (case
when fct.RN=1 then fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1)
ELSE fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) END ) * nvl(IN_GROUP.GROUP_NUMBER,1)
as SRC_AMT,

--сумма в рублях
-- [apolyakov 13.03.2017]: Удален НКД в рамках ЗА 4689
 case when upper(cur.CURRENCY_LETTER_CD) in ('RUB')
 then (-1)* (case
             when fct.RN=1 then fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1)
             else fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) END ) * nvl(IN_GROUP.GROUP_NUMBER,1)
 else
 (-1)* (case
             when fct.rn=1 then fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1)
             else fct.PAY_TERM_AMT  * nvl(dm_port.FACTOR_AMT,1) END ) * nvl(IN_GROUP.GROUP_NUMBER,1)
 *rate.EXCHANGE_RATE
 end 
as RUR_AMT,

--сумма в валюте КИС
-- [apolyakov 13.03.2017]: Удален НКД в рамках ЗА 4689
 case
 when upper(cur.CURRENCY_LETTER_CD) in ('USD','EUR','RUB') then
 (-1)* (case
        when fct.RN=1 then fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1)
        ELSE fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) END ) * nvl(IN_GROUP.GROUP_NUMBER,1)

 else 
 (-1)* (case
             when fct.rn=1 then fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1)
             else fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) END ) * nvl(IN_GROUP.GROUP_NUMBER,1)
 *rate.EXCHANGE_RATE
 end
as CIS_AMT,

--Сумма, взвешенная по ставке
 case when upper(cur.CURRENCY_LETTER_CD) in ('RUB')
 then (-1)* (case
             when fct.RN=1 then fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1)/* +nvl(dm_port.CALC_NCD_AMT,0)*/ -- vklavsut vl222649
             else fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) END ) * nvl(IN_GROUP.GROUP_NUMBER,1)
 else
 (-1)* (case
             when fct.rn=1 then fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1)/* +nvl(dm_port.CALC_NCD_AMT,0)*/ -- vklavsut vl222649
             else fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) END ) * nvl(IN_GROUP.GROUP_NUMBER,1)
 *rate.EXCHANGE_RATE
 end
*fct.RATE
as RATE_W_AMT,

--Сумма, взвешенная по сроку
 case when upper(cur.CURRENCY_LETTER_CD) in ('RUB')
 then (-1)* (case
             when fct.RN=1 then fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) /*+nvl(dm_port.CALC_NCD_AMT,0)*/-- vklavsut vl222649
             else fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) END ) * nvl(IN_GROUP.GROUP_NUMBER,1)
 else
 (-1)* (case
             when fct.rn=1 then fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1)/* +nvl(dm_port.CALC_NCD_AMT,0)*/ -- vklavsut vl222649
             else fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) END ) * nvl(IN_GROUP.GROUP_NUMBER,1)
 *rate.EXCHANGE_RATE
 end
*decode(fct.PAY_DT-p_REPORT_DT, 1, 2,fct.PAY_DT-p_REPORT_DT)
as TERM_W_AMT,

--Сумма Ликвидность, в исходной валюте
(-1)* (fct.PAY_TERM_AMT+ fct.PAY_INT_AMT)*nvl(dm_port.FACTOR_AMT,1) * nvl(IN_GROUP.GROUP_NUMBER,1)
 as SRC_LIQ_AMT,

--сумма Ликвидность в валюте КИС
 case
 when upper(cur.CURRENCY_LETTER_CD) in ('USD','EUR','RUB') then (-1)* (fct.PAY_TERM_AMT+ fct.PAY_INT_AMT)*nvl(dm_port.FACTOR_AMT,1) * nvl(IN_GROUP.GROUP_NUMBER,1)
 else (-1)* (fct.PAY_TERM_AMT+ fct.PAY_INT_AMT)* nvl(dm_port.FACTOR_AMT,1) *rate.EXCHANGE_RATE * nvl(IN_GROUP.GROUP_NUMBER,1)
 end
as CIS_LIQ_AMT,

--сумма MR, в исходной валюте
(-1)* (case
when fct.RN=1 then fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) +nvl(dm_port.CALC_NCD_AMT,0)
ELSE fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) END ) * nvl(IN_GROUP.GROUP_NUMBER,1)
as SRC_MR_AMT,

--сумма  MR,в рублях
 case when upper(cur.CURRENCY_LETTER_CD) in ('RUB')
 then (-1)* (case
             when fct.RN=1 then fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) +nvl(dm_port.CALC_NCD_AMT,0)
             else fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) END ) * nvl(IN_GROUP.GROUP_NUMBER,1)
 else
 (-1)* (case
             when fct.rn=1 then fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) +nvl(dm_port.CALC_NCD_AMT,0)
             else fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) END ) * nvl(IN_GROUP.GROUP_NUMBER,1)
 *rate.EXCHANGE_RATE
 end
as RUR_MR_AMT,

--Сумма MR, взвешенная 
 case when upper(cur.CURRENCY_LETTER_CD) in ('RUB')
 then (-1)* (case
             when fct.RN=1 then fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) +nvl(dm_port.CALC_NCD_AMT,0)
             else fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) END ) * nvl(IN_GROUP.GROUP_NUMBER,1)
 else
 (-1)* (case
             when fct.rn=1 then fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) +nvl(dm_port.CALC_NCD_AMT,0)
             else fct.PAY_TERM_AMT * nvl(dm_port.FACTOR_AMT,1) END ) * nvl(IN_GROUP.GROUP_NUMBER,1)
 *rate.EXCHANGE_RATE
 end
*fct.RATE
as RATE_W_MR_AMT,

fct.PAY_DT as PAY_DT,	
rate.EXCHANGE_RATE as EX_RATE,
'0' as FLOAT_RATE_FLG,
fct.RATE as RATE_AMT,
 (select ART_CD
  from dwh.INSTRUMENT_TYPES
  where Upper(INSTRUMENT_RU_NAM) like '%ВЫПУЩЕННЫЕ%ОБЛИГАЦИИ%'
  And Upper(INSTRUMENT_TYPE_DESC)='ПРОЦЕНТНЫЙ'
  And BEGIN_DT<=p_REPORT_DT
  AND END_DT>p_REPORT_DT
  ) 
AS ART_CD

FROM

--поток по облигациям
(select  fct.CONTRACT_KEY, fct.PAY_DT, nvl(fct.PAY_TERM_AMT,0) as PAY_TERM_AMT ,nvl(fct.PAY_INT_AMT,0) PAY_INT_AMT, fct.CURRENCY_KEY , fct.RATE, fct.CLIENT_KEY,
 ROW_NUMBER () over (partition by fct.CONTRACT_KEY
                           order by fct.PAY_DT ) RN
 from DWH.FACT_KS_FLOW FCT
 where upper(GROUP_CD) like '%ОБЛИГАЦ%'
 and fct.report_dt=p_REPORT_DT
 and fct.VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
 and fct.PAY_DT>p_REPORT_DT
 and ( fct.PAY_TERM_AMT is not null or fct.PAY_INT_AMT is not null)

 )fct
 
--витрина портфеля ЦБ
left join (select BOND_KEY,CONTRACT_KEY,CALC_NCD_AMT, FACTOR_AMT from dm.dm_BOND_PORTFOLIO 
           where SNAPSHOT_DT=p_REPORT_DT
           ) dm_port
on fct.CONTRACT_KEY=dm_port.CONTRACT_KEY

left join (select BOND_CONTRACT_KEY, VTB_MEMBER_FLG from DWH.BONDS_CONTRACT where begin_dt <= p_REPORT_DT and end_dt > p_REPORT_DT) bc
on FCT.CONTRACT_KEY=bc.BOND_CONTRACT_KEY

--справочник клиентов для определения группы ВТБ member_key
left join (select CLIENT_KEY,MEMBER_KEY,SHORT_CLIENT_RU_NAM from dwh.CLIENTS
where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')) cl
on cl.SHORT_CLIENT_RU_NAM = 'ВТБ Лизинг АО'

--справочник групп для определения флага группы
left join (select MEMBER_KEY, MEMBER_CD from DWH.IFRS_VTB_GROUP 
where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
and begin_dt <= p_REPORT_DT 
and end_dt > p_REPORT_DT ) gr
on cl.MEMBER_KEY=gr.MEMBER_KEY
  
--справочник валют для определения валюты КИС
left join (select CURRENCY_KEY, CURRENCY_LETTER_CD from DWH.CURRENCIES 
           where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
           and begin_dt <= p_REPORT_DT 
           and end_dt > p_REPORT_DT ) cur
on fct.CURRENCY_KEY=cur.CURRENCY_KEY

--курс валют
left join (select CURRENCY_KEY, EXCHANGE_RATE
           from DWH.EXCHANGE_RATES 
           where EX_RATE_DT=p_REPORT_DT
           and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
           and BASE_CURRENCY_KEY=(select CURRENCY_KEY from DWH.CURRENCIES 
                                  where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                                  and CURRENCY_LETTER_CD in ('RUB')
                                  and begin_dt <= p_REPORT_DT 
                                  and end_dt > p_REPORT_DT 
                                  )
          )
 rate
on fct.CURRENCY_KEY=rate.CURRENCY_KEY
left join (Select distinct a.report_dt
, b.bond_key
, b.contract_key
, (number_in_group_cnt/(nvl(b.issue_volume_cnt,0)-nvl(b.quantity_cnt,0)-nvl(b.bal_quantity_cnt,0))) GROUP_NUMBER
, 'Y' VTB_MEMBER_FLG
from DWH.FACT_BONDS_GROUP a
      left join (Select distinct bond_key, isin_cd
                from dwh.bonds_portfolio
                where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')) a1 on a.bond_key = a1.bond_key
      left join dwh.bonds_contract a2 on a2.isin_cd = a1.isin_cd
      inner join dm.dm_bond_portfolio b on a2.bond_contract_key = b.contract_key and a.report_dt = b.snapshot_dt
where a.report_dt = p_REPORT_DT
UNION ALL
Select distinct a.report_dt
, b.bond_key
, b.contract_key
, (1-number_in_group_cnt/(nvl(b.issue_volume_cnt,0)-nvl(b.quantity_cnt,0)-nvl(b.bal_quantity_cnt,0))) GROUP_NUMBER
, 'N' VTB_MEMBER_FLG
from DWH.FACT_BONDS_GROUP a
      left join (Select distinct bond_key, isin_cd
                from dwh.bonds_portfolio
                where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')) a1 on a.bond_key = a1.bond_key
      left join dwh.bonds_contract a2 on a2.isin_cd = a1.isin_cd
      inner join dm.dm_bond_portfolio b on a2.bond_contract_key = b.contract_key and a.report_dt = b.snapshot_dt
where a.report_dt = p_REPORT_DT
UNION ALL
Select distinct p_REPORT_DT
, a.bond_key
, b.contract_key
, 1 GROUP_NUMBER
, 'N' VTB_MEMBER_FLG
from DWH.BONDS_PORTFOLIO a
    left join (Select distinct bond_key, contract_key
               from DM.DM_BOND_PORTFOLIO
               where bond_key is not null) b on a.bond_key = b.bond_key
where a.bond_key not in (select bond_key from DWH.FACT_BONDS_GROUP)) IN_GROUP on FCT.CONTRACT_KEY=IN_GROUP.CONTRACT_KEY
      ) a, dwh.reg_group b
where a.branch_key = b.branch_key
and b.reg_group_key = p_reg_group_key
and b.begin_dt <= p_REPORT_DT
and b.end_dt > p_REPORT_DT;
   dm.u_log(p_proc => 'p_DM_REG_BOND',
           p_step => 'insert into DM.DM_REG_BOND',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');                       
                      
                      commit;
  end;
/

