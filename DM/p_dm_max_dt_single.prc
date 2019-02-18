CREATE OR REPLACE PROCEDURE DM.P_DM_MAX_DT_SINGLE (p_REPORT_DT IN date, p_contract_key in number default 1) IS


v_reh_flg varchar2(1);
--execute immediate
--truncate table dm_max_dt;
/* Процедура рассчитывает поле FACT_CLOSE_DT в витрине DM_CGP, заполняя промежуточную 
   витрину DM_MAX_DT. 
   На вход в качестве параметра подается отчетная дата p_REPORT_DT. Процедура запускается один раз.
*/

BEGIN
    dm.u_log(p_proc => 'P_DM_MAX_DT_SINGLE',
           p_step => 'INPUT PARAMS',
           p_info => 'p_REPORT_DT:'||p_REPORT_DT||'p_contract_key:'||p_contract_key); 
select max(nvl(rehiring_flg, '0')) into v_reh_flg from dwh.contracts where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') and contract_key = p_contract_key;
if v_reh_flg = 0 then 
delete from dm_max_dt
where ODDTM = p_REPORT_DT
and CONTRACT_ID = p_contract_key;
  dm.u_log(p_proc => 'P_DM_MAX_DT_SINGLE',
           p_step => 'delete from dm_max_dt',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted'); 
       insert into dm_max_dt (
                   contract_id,
                   max_dt,
                   ODDTM,
                   branch_key,
                   insert_dt)

       with old_c as (select contract_key, branch_key, contract_id_cd from dwh.contracts where nvl(rehiring_flg, 0) != 1 and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')),
       new_c as (select contract_key, branch_key, contract_id_cd from dwh.contracts where rehiring_flg = 1 and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')),
       cess_c as (select a.contract_key as old_contract_key, b.contract_key as new_contract_key from old_c a, new_c b where a.contract_id_cd = b.contract_id_cd and a.branch_key = b.branch_key)
       
       select
       nvl(cess_c.old_contract_key, fact_pp.contract_key),
       max (fact_pp.pay_dt),
       p_report_dt,
       ccc.branch_key as branch_key,
       sysdate
       from  dwh.fact_plan_payments fact_pp 
       inner join dwh.contracts ccc on fact_pp.contract_key = ccc.contract_key and ccc.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
       left join cess_c on fact_pp.contract_key = cess_c.new_contract_key
       where (fact_pp.CBC_DESC in (
                                                        select CBC_DESC 
                                                        from DWH.CLS_CBC_TYPE_CALC 
                                                        where TYPE_CALC = 'Leasing' 
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                                                        or (fact_pp.contract_key in (select contract_key from dwh.leasing_contracts where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy') and SUBSIDIZATION_FLG = 1)
                                                        and fact_pp.CBC_DESC in (
                                                        select CBC_DESC 
                                                        from DWH.CLS_CBC_TYPE_CALC 
                                                        where TYPE_CALC = 'Subsidization' 
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)))                 -- выбор плановых платежей по договорам лизинга с типом классификации КБК 'Leasing'
       and fact_pp.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
       and p_REPORT_DT between fact_pp.BEGIN_DT and fact_pp.END_DT
       and nvl(cess_c.old_contract_key, fact_pp.contract_key) =  p_contract_key
       group by nvl(cess_c.old_contract_key, fact_pp.contract_key), ccc.branch_key;



  dm.u_log(p_proc => 'P_DM_MAX_DT_SINGLE',
           p_step => 'insert into dm_max_dt',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted'); 
   commit;
   
   else 
    null;
end if;

end;
/

