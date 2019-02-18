CREATE OR REPLACE PROCEDURE DM.p_DM_NIL_CALC_TEST (
      p_REPORT_DT in date,
      p_group_key in number
)
IS
v_id_prev pls_integer;
pers number;
nill number;
diff number;
prev_dt date;
p_xirr number;
v_count number;
diff_prev number;
diff_prev2 number;
ka number;
nil_ka number;
ka_prev number;
ka_prev2 number;

/* ��������� ������������ ���������� NIL �� ������ xIRR � ��������� �������:
      -- ������������� ������� DM_NIL ����������:
          �) ���������� ������������ ������� ������� ������������� �� ���� NIL_PERS,
          �) ��������� ����� ������� ������� ������������� �� ���� NIL
          �) ������� ������������� ��������� ����� �� ���� NIL_DIFF
          �) �����������/�������� ��������, �������� �������/�������� �� ������ (��. ��������� p_dm_xirr_calc) � ���� �������
          �) ������������� ka � kb
          �) NIL*ka*kb �� ������� ���
          �) �������� ����
      -- ������� �� �������� ���������� DM_REPAYMENT_SCHEDULE ����������:
          �) �����������/�������� ��������, �������� �������/�������� �� ������ (��. ��������� p_dm_xirr_calc) � ���� �������
          �) ���������� ������������ ������� ������� ������������� �� ���� INTEREST_AMT
          �) ��������� ����� ������� ������� ������������� �� ���� PRINCIPAL_AMT
          �) ������� ������������� ��������� ����� �� ���� DNIL_AMT
          �) NIL*ka*kb �� ������� ��� NIL_AMT.
          
-- � �������� ���������� �� ���� �������� ���� ������ (p_REPORT_DT) � ����� ������ ����������� (p_group_key).
-- � �������� ������ ������� ��� �������� ������� �� �������, ����������� ������� �� �������� ���� �� ��������� � �������� ������� �� ��� ����� �� ���������.
*/

BEGIN
   
   delete from DM_NIL 
   where ODTTM = p_REPORT_DT 
   and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
   and snapshot_cd = '����';
   
   delete from DM_repayment_schedule 
   where snapshot_dt = p_REPORT_DT 
   and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
   and snapshot_cd = '����';
    --execute immediate
   --'truncate table NIL reuse storage where ODTTM=p_REPORT_DT';
--select count(*) into v_count from DM_NIL;
   --if (v_count = 0)then
            v_id_prev:=null;
            for rec in (
                        /* ������� ����� �� ��������� ������� � �������� (��. ��������� p_dm_xirr_calc)
                        */ 
                        with
                Contr_prev as (
                          SELECT cn1.contract_key L_key,
                                 cn2.contract_key S_key,
                                 cn1.branch_key,
                                 cn1.Currency_Key L_CUR,                                      -- ������ �������� �������
                                 cn2.Currency_key S_CUR,                                      -- ������ �������� ��������
                                 OS.base_currency_key base_currency,
                                 cn1.valid_to_dttm
                          from dwh.contracts cn1
                          left join dwh.contracts cn2
                              ON cn1.contract_key = cn2.contract_leasing_key
                              and cn2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                              and cn2.open_dt <= p_REPORT_DT
                          inner join dwh.ORG_STRUCTURE OS                                      -- ��� ��������� �������� ��� ������� ������ ������� �� ����������� ��������� ��������
                              ON OS.BRANCH_KEY = cn1.BRANCH_KEY
                          inner join dwh.cgp_group cgp_group                                   -- ������� � ������ ������������ ����� ����������� ��� ������� ������ ��� ������ ������ �����������
                              ON cn1.branch_key = cgp_group.branch_key
                              and cgp_group.begin_dt <= p_REPORT_DT
                              and cgp_group.end_dt > p_REPORT_DT
                          inner join dwh.clients cl
                              ON cl.client_key = cn1.client_key
                          inner join DWH.LEASING_CONTRACTS LC                                  -- ������� �� ������������ ���������� ���������� ��� ����, ����� ������� ��� "���������� ������"
                              ON cn1.contract_key = LC.contract_key
                          where  cn1.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                                 and cl.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                                 and LC.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                                 and ((LC.contract_fin_kind_desc <> '������������������' 
                                       and cn1.branch_key in (                                       -- � ������ ��������� ����� ���������� '����������������'
                                                              select branch_key 
                                                              from dwh.cgp_group cgp_group 
                                                              where cgp_group.cgp_group_key = 1
                                                              and cgp_group.begin_dt <= p_REPORT_DT
                                                              and cgp_group.end_dt > p_REPORT_DT)
                                      )
                                        or 
                                      (LC.contract_fin_kind_desc is Null                             -- � ������ �������� ����������� ���������� Null
                                       and cn1.branch_key in (select branch_key 
                                                              from dwh.cgp_group cgp_group 
                                                              where cgp_group.cgp_group_key not in (1)
                                                              and cgp_group.begin_dt <= p_REPORT_DT
                                                              and cgp_group.end_dt > p_REPORT_DT)
                                       ))
                                 and cl.cgp_flg = '1'                                                -- ������� ���
                                 and cgp_group.cgp_group_key = p_group_key                               
                                 and cn1.open_dt <= p_REPORT_DT
                                -- and cn1.close_dt >= trunc (p_REPORT_DT, 'mm')
                                 /*and ( ( cn1.IS_CLOSED_CONTRACT <> 0 
                                       and cn1.branch_key in (
                                                              select branch_key 
                                                              from dwh.cgp_group cgp_group 
                                                              where cgp_group.cgp_group_key = 1)
                                       and cn1.close_dt <= p_REPORT_DT ) 
                                      or (cn1.IS_CLOSED_CONTRACT = 0                                       --
                                       and cn1.branch_key in (
                                                              select branch_key 
                                                              from dwh.cgp_group cgp_group 
                                                              where cgp_group.cgp_group_key = 1)
                                       and cn1.close_dt > p_REPORT_DT )
                                      or (cn1.IS_CLOSED_CONTRACT is null)                                --
                                           and cn1.branch_key in (select branch_key 
                                                              from dwh.cgp_group cgp_group 
                                                              where cgp_group.cgp_group_key not in (1, 4))  -- �������� ����������� ���������� ��������
                                      ) */ 
                                     --   and cn1.EXClUDE_CGP IS NULL
                          ),
                
                /* � ������, ����� ������ �������� ������� ������������� ����� ������ �������� ��������, � ������ �������� ������� (Flow_L) ������������ distinct ��� �������� ������ ��������.
                      ��� ��������� ����� ������ ������������ ����, ������� = 1 � ���� ������.
                   � ������, ����� ������ �������� ������� ������������� ���� ������� ��������, � ������ �������� ������� (Flow_L) ������� ��� �������.
                      ��� ��������� ����� ������ ������������ ����, ������� = 0.
                  
                */
                countt as (
                            select l_key, 
                                   count (L_KEY) countt
                            from contr_prev
                            group by l_KEY
                            ),
                            
                 Contr as (                           
                            select 
                                  contr.l_key l_key,
                                  s_key,
                                  branch_key,
                                  l_cur,
                                  s_cur,
                                  base_currency,
                                  case
                                    when countt.countt > 1
                                       then 1
                                    else 0
                                  end as flag                     -- ����, ������������ ��� ������� ������ ���������� �������� (Flow_L)
                            from contr_prev contr
                            inner join countt countt 
                                on contr.l_key = countt.l_key
                        ),

                /* ������������ �������� ������ ��� ����� ������� ������
                */
                Contr_ces as (                                
                        SELECT 
                            cn1.L_key L_key,
                            cn1.S_key S_key,
                            cn3.contract_key L_key_dop,
                            cn4.contract_key S_key_dop,
                            cn1.branch_key,
                            cn1.L_CUR,
                            cn1.S_CUR,
                            cn1.base_currency base_currency,
                            cn1.flag
                        From Contr cn1
                        join dwh.contracts cn2 
                            ON cn1.l_key = cn2.contract_key
                            and cn2.valid_to_dttm = '01.01.2400'
                        left join dwh.contracts cn3
                            ON cn2.CONTRACT_ID_CD = cn3.CONTRACT_ID_CD        -- �������� �� Id ���������� ��� ������� ���� ���������...
                              and cn3.contract_key <> cn2.contract_key 
                              -- and cn3.IS_CLOSED_CONTRACT = 1                  -- ��� �������� �������� ������� ��� ����� ������� ������.
                              and cn3.valid_to_dttm = '01.01.2400'
                        Left join dwh.contracts cn4
                              ON cn3.contract_key = cn4.contract_leasing_key  
                              and cn4.valid_to_dttm = '01.01.2400'
                          ),

/* ������� ����������� � �������� �������� �� ��������� �������� ( � ����� ��� 3.1 - 3.5 � ����� ��� = 'Supply'). 
    - ����������� ������� ���������� �� ���������� �������:
         ���� ������������ ������� <= ���� ��������� ��������� �������.

    - �������� ������� ���������� �� ��� ����� �������� ��������
    
   ����������� ������� �� ��������� ������ 
 */
               Flow_S as
                        (
                          SELECT Contr.L_KEY,
                                 Contr.branch_key,
                                 fact_rp1.CBC_DESC,
                                 fact_rp1.PAY_DT,
                                 fact_rp1.PAY_AMT,
                                 'Supply_fact' TP,
                                 Contr.L_CUR CUR1,
                                 fact_rp1.CURRENCY_KEY CUR3,
                                 fact_rp1.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag
                          from Contr Contr
                          inner join dwh.fact_real_payments fact_rp1
                              ON Contr.L_Key = fact_rp1.contract_key                                -- ������ ������ ��������� � ����������� �������� �� ����� �������� ������� 
                          where fact_rp1.CBC_DESC in (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Supply'                    -- ����� ����������� �������� �� ��������� �������� � ����� ��� 'Supply'
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_rp1.valid_to_dttm = '01.01.2400'
                          and fact_rp1.PAY_DT <= p_REPORT_DT
              
                      UNION ALL
              
                          SELECT Contr.L_KEY,
                                 Contr.branch_key,
                                 fact_rp2.CBC_DESC,
                                 fact_rp2.PAY_DT,
                                 fact_rp2.PAY_AMT,
                                 'Supply_fact' TP,
                                 Contr.L_CUR CUR1,
                                 Contr.S_CUR CUR3,
                                 fact_rp2.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag
                          from Contr Contr
                          inner join dwh.fact_real_payments fact_rp2
                              ON Contr.S_Key = fact_rp2.contract_key                              -- ������ ������ ��������� � ����������� �������� �� ����� �������� �������� 
                          where fact_rp2.CBC_DESC in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply'                   -- ����� ����������� �������� �� ��������� �������� � ����� ��� 'Supply'
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_rp2.valid_to_dttm = '01.01.2400'
                          and fact_rp2.PAY_DT <= p_REPORT_DT
              
                      UNION ALL
              
                          SELECT Contr.L_key,
                                 Contr.branch_key,
                                 fact_pp.CBC_DESC,
                                 fact_pp.PAY_DT,
                                 fact_pp.PAY_AMT*-1,                                              -- ��������� �� EXCEL ����� ����������.xls ������� ����������� �� ������ (+), �� ������ ���� �� (-)
                                 'Supply_plan' TP,
                                 Contr.L_CUR CUR1,
                                 Contr.S_CUR CUR3,
                                 fact_pp.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag
                          from Contr Contr
                          inner join dwh.fact_plan_payments fact_pp
                             ON Contr.S_Key = fact_pp.contract_key
                          where fact_pp.CBC_DESC in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_pp.valid_to_dttm = '01.01.2400'
--                          and fact_pp.PAY_DT > p_REPORT_DT
              
/*                       UNION ALL
              
                         SELECT Contr.L_key,
                               Contr.branch_key,
                               fact_pp.CBC_DESC,
                               fact_pp.PAY_DT,
                               fact_pp.PAY_AMT PAY_AMT,
                               'Supply_PLAN' TP,
                               Contr.L_CUR CUR1,
                               Contr.S_CUR CUR3,
                               fact_pp.CURRENCY_KEY CUR2,
                               Contr.base_currency,
                               Contr.flag
                           from Contr Contr
                                  inner join dwh.fact_plan_payments fact_pp
                          ON Contr.S_Key = fact_pp.contract_key
                          and fact_pp.valid_to_dttm = '01.01.2400'
                                  where fact_pp.CBC_DESC in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply'                   -- ����� �������� �������� �� ��������� �������� � ����� ������������� ��� 'Supply'
                                                     and To_date(:p_REPORT_DT) BETWEEN BEGIN_DT and END_DT)
                                  and fact_pp.PAY_DT <= To_date(:p_REPORT_DT)
                   */        
                           
                         UNION ALL  

-- ���������� ������ �� ������ �� ������ ���������        
                                  
                          SELECT Contr.L_KEY,
                                 Contr.branch_key,
                                 fact_rp1.CBC_DESC,
                                 fact_rp1.PAY_DT,
                                 fact_rp1.PAY_AMT,
                                 'Supply_fact' TP,
                                 Contr.L_CUR CUR1,
                                 L_DOP_CO.CURRENCY_KEY CUR3,
                                 fact_rp1.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag
                          from Contr_ces Contr
                          inner join dwh.fact_real_payments fact_rp1
                              ON Contr.L_Key_DOP = fact_rp1.contract_key
                          inner join dwh.contracts L_DOP_CO
                              on Contr.L_Key_DOP = L_DOP_CO.contract_key
                              and L_DOP_CO.valid_to_dttm = '01.01.2400'
                          where fact_rp1.CBC_DESC  in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_rp1.valid_to_dttm = '01.01.2400'
                          and fact_rp1.PAY_DT <= p_REPORT_DT
              
                      UNION ALL
              
                          SELECT Contr.L_KEY,
                                 Contr.branch_key,
                                 fact_rp2.CBC_DESC,
                                 fact_rp2.PAY_DT,
                                 fact_rp2.PAY_AMT,
                                 'Supply_fact' TP,
                                 Contr.L_CUR CUR1,
                                 Co.CURRENCY_KEY CUR3,
                                 fact_rp2.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag
                          from Contr_ces Contr
                          inner join dwh.fact_real_payments fact_rp2
                              ON Contr.S_Key_DOP = fact_rp2.contract_key
                          inner join dwh.contracts co 
                              on Contr.S_Key_DOP = co.contract_key
                              and co.valid_to_dttm='01.01.2400'
                          where fact_rp2.CBC_DESC  in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_rp2.valid_to_dttm = '01.01.2400'
                          and fact_rp2.PAY_DT <= p_REPORT_DT
              
                      UNION ALL
              
                          SELECT Contr.L_key,
                                 Contr.branch_key,
                                 fact_pp.CBC_DESC,
                                 fact_pp.PAY_DT,
                                 fact_pp.PAY_AMT*-1,
                                 'Supply_plan' TP,
                                 Contr.L_CUR CUR1,
                                 co.CURRENCY_KEY CUR3,
                                 fact_pp.CURRENCY_KEY CUR2,
                                 Contr.base_currency,
                                 Contr.flag
                          from Contr_ces Contr
                          inner join dwh.fact_plan_payments fact_pp
                              ON Contr.S_Key_DOP = fact_pp.contract_key
                          inner join dwh.contracts co 
                              on Contr.S_Key_DOP = co.contract_key
                              and co.valid_to_dttm='01.01.2400'
                          where fact_pp.CBC_DESC  in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_pp.valid_to_dttm = '01.01.2400'
  --                        and fact_pp.PAY_DT > p_REPORT_DT
              
  /*                     UNION ALL
              
                         SELECT Contr.L_key,
                           Contr.branch_key,
                           fact_pp.CBC_DESC,
                           fact_pp.PAY_DT,
                           fact_pp.PAY_AMT PAY_AMT,
                           'Supply_PLAN' TP,
                           Contr.L_CUR CUR1,
                           Contr.S_CUR CUR3,
                           fact_pp.CURRENCY_KEY CUR2,
                           Contr.base_currency,
                           Contr.flag
                           from Contr_ces Contr
                                  inner join dwh.fact_plan_payments fact_pp
                          ON Contr.S_Key_DOP = fact_pp.contract_key
                          and fact_pp.valid_to_dttm = '01.01.2400'
                                  where fact_pp.CBC_DESC  in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and To_date(:p_REPORT_DT) BETWEEN BEGIN_DT and END_DT)
                                  and fact_pp.PAY_DT <= To_date(:p_REPORT_DT)    */                          
 -- ����� ���. ������                             
                                ),

                                
                Flow_S_CUR as                  
                          (
                            select L_KEY,
                                   branch_key,
                                   CBC_DESC,
                                   PAY_DT,
                                   PAY_AMT,
                                   TP,
                                   CUR1,
                                   CUR2,
                                   CUR3,
                                   base_currency,
                                   flag,                                    
                                   (case
                                   when CUR3 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT  --���� �_��� <> �_��� � ��_��� <> �_��� � ���� <= �_����, 
                                      then PAY_AMT*rt1.EXCHANGE_RATE/rt3.EXCHANGE_RATE                                 --��    ���� = ���� * ��_���� /  �_����                                    
                                                                      
                                   when CUR3 = s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT   --���� �_��� = �_��� � ��_��� <> �_��� � ���� <= �_����,
                                      then PAY_AMT*rt1.EXCHANGE_RATE                                                   --��    ���� = ���� * ��_����                                   
                                   
                                   when CUR2 = s.base_currency and CUR3 <> s.base_currency and PAY_DT <= p_REPORT_DT   --���� �_��� <> �_��� � ��_��� = �_��� � ���� <= �_����,
                                     then PAY_AMT/rt3.EXCHANGE_RATE                                                   --��    ���� = ���� / �_����                                 
                                  
                                   else PAY_AMT                                                                        --�����, ���� = ����.
                                   end) as PAY_AMT_cur_supply
                                 
                            from Flow_S s
                               
                               left join dwh.EXCHANGE_RATES rt1               -- �������� � ������ ����� �� ��������� ���� �����  ���� ������� � �� ������ �����/�����
                                  on s.PAY_DT = rt1.ex_rate_dt 
                                  and s.CUR2= rt1.CURRENCY_KEY 
                                  and rt1.BASE_CURRENCY_KEY = s.base_currency
                                  and rt1.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
  
                               left join dwh.EXCHANGE_RATES rt3                -- �������� � ������ ����� �� ��������� ���� ����� ���� ������� � �� ������ ��������
                                  on s.PAY_DT = rt3.ex_rate_dt 
                                  and s.CUR3= rt3.CURRENCY_KEY 
                                  and rt3.BASE_CURRENCY_KEY = s.base_currency
                                  and rt3.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                                                                    
                          ),
                          
                FLOW_S_UNDERPAY_1 as (                         
                            select  
    --                                f2.pay_amt_sum,
    --                                f1.pay_amt2,
                                    f1.L_Key,
                                    f1.branch_key,
                                    f1.CBC_DESC,
                                    (case 
                                        when f1.pay_amt2 <= f2.pay_amt_sum 
                                         and pay_dt > p_REPORT_DT
                                            then p_REPORT_DT 
                                        else pay_dt 
                                    end) pay_dt, 
                                    f1.PAY_AMT,
                                    f1.TP,                                
    --                                f1.PAY_AMT_cur_supply, 
                                    f1.CUR1,
                                    f1.CUR3,
                                    f1.CUR2,
                                    f1.base_currency,
                                    f1.flag,
                                    f1.PAY_AMT_cur_supply
      --                      from Flow_S_CUR f1
                              from (
                                    select 
                                        L_Key,
                                        CBC_DESC,
                                        sum(PAY_AMT_cur_supply) pay_amt_sum
                                    from flow_s_cur 
                                    where TP = 'Supply_fact' and CBC_DESC ='��.3.1'
                                    group by L_Key,CBC_DESC) f2 
                              inner join (select                                 
                                              --f2.pay_amt_sum,
                                              L_Key, 
                                              branch_key,
                                              CBC_DESC,
                                              pay_dt, 
                                              TP,
                                              PAY_AMT,
                                              PAY_AMT_cur_supply, 
                                              sum(PAY_AMT_cur_supply) over (partition by L_KEY  order by pay_dt rows between unbounded preceding and current row) pay_amt2,
                                              CUR1,
                                              CUR3,
                                              CUR2,
                                              base_currency,
                                              flag 
                                        from flow_s_cur
                                        where TP = 'Supply_plan') f1                                                            
                                  on f1.L_Key = f2.L_Key and f1.CBC_DESC = f2.CBC_DESC
                        
                        ),
                          
                Flow_L as             
                          (
                           SELECT distinct Contr.L_KEY,                      -- ���������� ����������� � ������, ���� ������ ��������� ������� ������������� ��������� ��������� �������� (flag = 1)
                                  contr.branch_key,                                                           
                                  fact_pp.CBC_DESC,
                                  PAY_DT,
                                  PAY_AMT, 
                                  'LEASING' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.S_CUR CUR3, 
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag
                           from Contr Contr
                           inner join dwh.fact_plan_payments fact_pp
                              ON Contr.L_Key = fact_pp.contract_key
                          -- inner join mindt m on Contr.L_Key = m.L_key
                           where fact_pp.CBC_DESC in  (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Leasing' 
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)                 -- ����� �������� �������� �� ��������� ������� � ����� ������������� ��� 'Leasing'
                           and fact_pp.valid_to_dttm = '01.01.2400'
                           and contr.flag = 1
                           
                           UNION ALL
                           
                           SELECT Contr.L_KEY,
                                  contr.branch_key,
                                  fact_pp.CBC_DESC,
                                  PAY_DT,
                                  PAY_AMT, 
                                  'LEASING' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.S_CUR CUR3,
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag
                           from Contr Contr
                           inner join dwh.fact_plan_payments fact_pp
                              ON Contr.L_Key = fact_pp.contract_key
                          -- inner join mindt m on Contr.L_Key = m.L_key
                           where fact_pp.CBC_DESC in  (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Leasing' 
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)                 -- ����� �������� �������� �� ��������� ������� � ����� ������������� ��� 'Leasing'
                           and fact_pp.valid_to_dttm = '01.01.2400'
                           and contr.flag = 0                                                         -- � ������ ������������ ������ �������� ������� ������ �������� ��������, ������� ��� ��� ����.  
                           
                           UNION ALL
       
                          -- �������������� ����� �� ������ 
       
                           SELECT distinct Contr.L_KEY,                          -- ���������� ����������� � ������, ���� ������ ��������� ������� ������������� ��������� ��������� �������� (flag = 1)
                                  contr.branch_key,
                                  fact_pp.CBC_DESC,
                                 PAY_DT,
                                  PAY_AMT, 
                                  'LEASING' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.S_CUR CUR3, 
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag
                           from dwh.fact_plan_payments fact_pp
                           INNER join (select distinct 
                                        L_KEY,
                                        L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        S_CUR,
                                        base_currency,
                                        flag
                                        from Contr_ces) Contr
                              ON Contr.L_Key_dop = fact_pp.contract_key
                          -- inner join mindt m on Contr.L_Key = m.L_key
                           where fact_pp.CBC_DESC in  (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Leasing' 
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)                -- ����� �������� �������� �� ��������� ������� � ����� ������������� ��� 'Leasing'
                           and fact_pp.valid_to_dttm = '01.01.2400'
                           and contr.flag = 1
                           
                           UNION ALL
                           
                           SELECT Contr.L_KEY,
                                  contr.branch_key,
                                  fact_pp.CBC_DESC,
                                 PAY_DT,
                                  PAY_AMT, 
                                  'LEASING' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.S_CUR CUR3, 
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag
                           from dwh.fact_plan_payments fact_pp
                           INNER join (select distinct 
                                        L_KEY,
                                        L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        S_CUR,
                                        base_currency,
                                        flag
                                        from Contr_ces) Contr 
                              ON Contr.L_Key_dop = fact_pp.contract_key
                          -- inner join mindt m on Contr.L_Key = m.L_key
                           where fact_pp.CBC_DESC in  (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Leasing' 
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)                -- ����� �������� �������� �� ��������� ������� � ����� ������������� ��� 'Leasing'
                           and fact_pp.valid_to_dttm = '01.01.2400'
                           and contr.flag = 0                                                             -- � ������ ������������ ������ �������� ������� ������ �������� ��������, ������� ��� ��� ����. 
                        
                           ),
           
          /* ����������� �������� �� ��������� �������, �������� � ���������� ������ � �������� ����� 
             � ������ 0 ��� ������� ���������� ���� �� ���������� ������� �� �������� ����.
          */
                 Flow_Cur as(                   
                              select 
                                    fl.*, 
                                    0 PAY_AMT_cur_supply 
                              from Flow_L fl
                            UNION ALL
                              select * 
                              from Flow_S_cur 
                              where TP = 'Supply_fact'
                            UNION ALL 
                              select * 
                              from FLOW_S_UNDERPAY_1 
                              where TP = 'Supply_plan' 
                  --              and pay_dt> p_REPORT_DT
                                and CBC_DESC = '��.3.1'
                            UNION ALL
                              select * 
                              from Flow_S_cur 
                              where TP = 'Supply_plan' 
                   --             and pay_dt> p_REPORT_DT
                                and CBC_DESC <> '��.3.1'
                            UNION ALL
                              select 
                                    L_key as L_key, 
                                    branch_key, 
                                    '��.1.1' as CBC_DESC, 
                                    p_REPORT_DT as PAY_DT, 
                                    0 as PAY_AMT, 
                                    'TEH'  as TP,
                                    Contr.L_CUR as CUR1, 
                                    Contr.L_CUR as CUR3, 
                                    Contr.L_CUR as CUR2, 
                                    Contr.base_currency, 
                                    0 flag, 
                                    0 Flow_S_cur
                              from Contr 
                 ) ,                  
              
          /* �������� ���������� ����� � ������/������ � ������ �������� ������� ����� ��������� �� ������ 
             ����� �� ����������� "����� �����" � ����������� �� �����������, �� ������� ����������� ������ xIRR. 
             ������ ������������ � ����������� �� ������� ������ � ���� �������: �� �������� ���� ��� ����� �������� ����...
          */
                 Flow_L_CUR as                  
                          (
                            select L_KEY,
                            branch_key,
                                   CBC_DESC,
                                   PAY_DT,
                                  /* � ������, ���� 
                                             -- ������ �����-�����/�������� �����/�� ����� ������� ������;
                                             -- ���� ������� ��/����� ���� ������,
                                     ����� ������� ����������/�� ���������� �� ���� ������ �����/����� � �������/�� ������� �� ���� ������ ��������
                                  
                                  �������� �����������: -- �_��� - ������ �������� 
                                                        -- �_��� - ������� ������ ����������� 
                                                        -- ��_��� - ������ �����/�����,
                                                        -- ���� - ���� ������� 
                                                        -- �_���� - �������� ����
                                                        -- ���� - ����� �������
                                                        -- ��_���� - ���� ������ �����/����� �� �������� ���� 
                                                        -- �_���� - ���� ������ �������� �� �������� ����
                                                        -- ��_����_�_���� - ���� ������ �����/����� �� �������� ����
                                                        -- �_����_�_���� - ���� ������ �������� �� �������� ����
                                  */
                                   (case
                                   when CUR1 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT  --���� �_��� <> �_��� � ��_��� <> �_��� � ���� <= �_����, 
                                      then PAY_AMT*rt1.EXCHANGE_RATE/rt2.EXCHANGE_RATE                                 --��    ���� = ���� * ��_���� /  �_����  
                                  
                                   when CUR1 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT > p_REPORT_DT   --���� �_��� <> �_��� � ��_��� <> �_��� � ���� > �_����, 
                                      then PAY_AMT*rt_rp1.EXCHANGE_RATE/rt_rp2.EXCHANGE_RATE                           --��    ���� = ���� * ��_����_�_���� /  �_����_�_���� 
                                   
                                   when CUR1 = s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT   --���� �_��� = �_��� � ��_��� <> �_��� � ���� <= �_����,
                                      then PAY_AMT*rt1.EXCHANGE_RATE                                                   --��    ���� = ���� * ��_����
                                   
                                   when CUR1 = s.base_currency and CUR2 <> s.base_currency and PAY_DT > p_REPORT_DT    --���� �_��� = �_��� � ��_��� <> �_��� � ���� > �_����, 
                                      then PAY_AMT*rt_rp1.EXCHANGE_RATE                                                --��    ���� = ���� * ��_����_�_����
                                   
                                   when CUR2 = s.base_currency and CUR1 <> s.base_currency and PAY_DT <= p_REPORT_DT   --���� �_��� <> �_��� � ��_��� = �_��� � ���� <= �_����,
                                      then PAY_AMT/rt2.EXCHANGE_RATE                                                   --��    ���� = ���� / �_����
                                 
                                   when CUR2 = s.base_currency and CUR1 <> s.base_currency and PAY_DT > p_REPORT_DT    --���� �_��� <> �_��� � ��_��� = �_��� � ���� > �_����,
                                      then PAY_AMT/rt_rp2.EXCHANGE_RATE                                                --��    ���� = ���� / �_����_�_����
                                  
                                   else PAY_AMT                                                                        --�����, ���� = ����.
                                   end) as PAY_AMT_cur,
                                   PAY_AMT,
                                   TP,
                                   CUR1,
                                   CUR2, 
                                   CUR3,
                                   PAY_AMT_cur_supply
                            from Flow_CUR s
                               
                               left join dwh.EXCHANGE_RATES rt1               -- �������� � ������ ����� �� ��������� ���� �����  ���� ������� � �� ������ �����/�����
                                  on s.PAY_DT = rt1.ex_rate_dt 
                                  and s.CUR2= rt1.CURRENCY_KEY 
                                  and rt1.BASE_CURRENCY_KEY = s.base_currency
                                  and rt1.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                               
                               left join dwh.EXCHANGE_RATES rt2                -- �������� � ������ ����� �� ��������� ���� ����� ���� ������� � �� ������ ��������
                                  on s.PAY_DT = rt2.ex_rate_dt 
                                  and s.CUR1= rt2.CURRENCY_KEY 
                                  and rt2.BASE_CURRENCY_KEY = s.base_currency
                                  and rt2.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                               
                               left join dwh.EXCHANGE_RATES rt_rp1             -- �������� � ������ ����� �� ��������� ���� ����� �������� ���� � �� ������ �����/�����
                                  on rt_rp1.ex_rate_dt = p_REPORT_DT 
                                  and s.CUR2= rt_rp1.CURRENCY_KEY 
                                  and rt_rp1.BASE_CURRENCY_KEY = s.base_currency
                                  and rt_rp1.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                               
                               left join dwh.EXCHANGE_RATES rt_rp2             -- �������� � ������ ����� �� ��������� ���� ����� �������� ���� � �� ������ ��������
                                  on rt_rp2.ex_rate_dt= p_REPORT_DT 
                                  and s.CUR1= rt_rp2.CURRENCY_KEY 
                                  and rt_rp2.BASE_CURRENCY_KEY = s.base_currency
                                  and rt_rp2.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                          ),
                                
                        balance as (
             
                                  select L_key,
                                  branch_key,
                                         PAY_DT,
                                         sum(pay_amt_cur) over (partition by l_key order by pay_dt) bal1,
                                         sum(pay_amt) over (partition by l_key order by pay_dt) bal2,
                                         first_value (pay_dt) over (partition by l_key order by pay_dt) fv -- ��� ����, ����� ��������� "������������ ����������, ��� ���� ������� ������� ����� ����������� ����
                                  from flow_L_cur
                                  where TP <> 'Supply_plan' or
                                 (TP = 'Supply_plan' and PAY_DT > p_REPORT_DT)
                                 ),
  
                       min_dt as
                                  (
                                  select 
                                        L_KEY,
                                        fv, -- ��� ����, ����� ��������� ������������ ����������, ��� ���� ������� ������� ����� ����������� ����
                                        min(case 
                                                when bal1 < 0
                                                  then pay_dt
                                                else null
                                            end) min_dt
                                  from balance 
                                  group by L_KEY, fv
                                  ),        
                                
                         --����
                            Flow_Underpay as
                                (
                                    SELECT  fc.L_key,
                                            fc.branch_key,
                                            fc.cbc_desc,
                                            sum(case when cs.PAY_AMT_CuR_supply > 0 and tp='Supply_fact' 
                                                        then fc.PAY_AMT_CuR*-1
                                                      when cs.PAY_AMT_CuR_supply > 0 and tp='Supply_plan'    
                                                        then fc.PAY_AMT_CuR
                                                else 0 end) PAY_AMT_CuR,
                                            cs.PAY_AMT_CuR_supply
                                    from 
                                            Flow_L_CUR fc
                                    join (select l_key, 
                                              sum (case when tp='Supply_fact' then 
                                                          PAY_AMT_cur_supply 
                                                        when tp='Supply_plan' then 
                                                          PAY_AMT_cur_supply*-1 
                                                  end) PAY_AMT_CuR_supply 
                                          from Flow_L_CUR 
                                          WHERE TP in ('Supply_fact','Supply_plan')
                                           and pay_dt <= To_date(p_REPORT_DT)
                                          group by l_key) cs
                                    on cs.l_key = fc.l_key
                                    WHERE fc.TP in ('Supply_fact','Supply_plan')
                                     and fc.pay_dt <= To_date(p_REPORT_DT)
                                    group by  fc.L_key, fc.branch_key, cs.PAY_AMT_CuR_supply, fc.cbc_desc
                              
                                
                          ),
                                
                        Flow_prev as
                                (
                                 SELECT
                                        L_KEY,
                                        branch_key,
                                        CBC_DESC,
                                        p_REPORT_DT + 1 pay_dt ,
                                        PAY_AMT_CuR summ,
                                        PAY_AMT_CuR PAY_AMT
                                 FROM Flow_Underpay
                                 where PAY_AMT_CuR < 0
                      
                                UNION ALL
                      
                      
                                  SELECT 
                                         L_KEY, 
                                         branch_key, 
                                         CBC_DESC, 
                                         PAY_DT, 
                                         SUM(PAY_AMT_CUR) summ, 
                                         SUM(PAY_AMT) PAY_AMT
                                  FROM FLOW_L_CUR
                                  WHERE TP <> 'Supply_plan' or 
                                  (TP = 'Supply_plan' and PAY_DT > p_REPORT_DT)
                                  group by L_KEY, branch_key, CBC_DESC, PAY_DT
                                 ),
                                 
                          Flow_prev_1 as 
                                (
                                  Select L_KEY,
                                         branch_key,
                                         PAY_DT,
                                         sum(case
                                            when cbc_desc in (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Leasing' 
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT) 
                                              then summ 
                                              else 0
                                              end
                                         ) LEASING_PAY,
                                         sum(case
                                          when cbc_desc in (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Supply'                    -- ����� ����������� �������� �� ��������� �������� � ����� ��� 'Supply'
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT) 
                                            then summ 
                                            else 0
                                          end
                                        ) SUPPLY_PAY,
                                        sum (summ) summ,
                                        sum (pay_amt) pay_amt
                                        from FLOW_prev
                                        group by L_KEY, branch_key, PAY_DT
                                ),
                            
                          FLOW_prev_2 as
                                    (select L_KEY, 
                                       branch_key,
                                       PAY_DT, 
                                       summ ,
                                       sum(summ) over (partition by L_KEY order by pay_dt rows between unbounded preceding and current row) sum_prev, 
                                       LEASING_PAY,
                                       SUPPLY_PAY,
                                       PAY_AMT
                                    from  Flow_prev_1 
                                    ),
                        
                          FLOW as
                                    (select f.L_KEY, 
                                             branch_key,
                                             PAY_DT, 
                                             summ, 
                                             sum_prev,
                                             LEASING_PAY,
                                             SUPPLY_PAY,
                                             PAY_AMT
                                    from  FLOW_prev_2 f
                                    inner join min_dt min_dt
                                        on min_dt.l_key = f.l_key
                                    where summ < 0
                                    and pay_dt <= min_dt
                
               
                                
                
                                  union all
                
                                    select   f.L_KEY, 
                                             branch_key,
                                             
                                             PAY_DT, 
                                             (case when 
                                                sum_prev >= 0
                                                   then abs (summ)
                                               else sum_prev - summ
                                             end) as summ,
                                             sum_prev,
                                             (case when 
                                                sum_prev >= 0
                                                   then abs (supply_pay)
                                               else sum_prev - supply_pay
                                             end) LEASING_PAY,
                                             0 as SUPPLY_PAY,
                                             (case when 
                                                  sum_prev >= 0 or pay_dt <= min_dt
                                                     then abs (PAY_AMT)
                                                 else PAY_AMT
                                               end) PAY_AMT
                        
                                             from 
                                             FLOW_prev_2 f
                                             inner join min_dt min_dt
                                        on min_dt.l_key = f.l_key
                                            where summ < 0
                                           -- and pay_dt != p_report_dt -- ��� ����, ����� �� ���������� ��� �������� ������������ ������
                                            and pay_dt <= min_dt
                                            and min_dt != fv -- ��� ����, ����� ��������� ������������ ����������, ��� ���� ������� ������� ����� ����������� ����
                                            
                                     
                                            
                                    union all
                                    
                                    select   f.L_KEY, 
                                             branch_key, 
                                             
                                             PAY_DT, 
                                             summ,
                                             sum_prev,
                                             LEASING_PAY,
                                             SUPPLY_PAY,
                                             PAY_AMT
                                             from 
                                             FLOW_prev_2 f
                                             inner join min_dt min_dt
                                              on min_dt.l_key = f.l_key 
                                            where pay_dt > min_dt
                                    
                                    union all
                                    
                                    select   f.L_KEY, 
                                             branch_key,
                                             
                                             PAY_DT, 
                                             summ,
                                             sum_prev,
                                             LEASING_PAY,
                                             SUPPLY_PAY, 
                                             PAY_AMT
                                             from 
                                             FLOW_prev_2 f
                                             left join min_dt min_dt
                                              on min_dt.l_key = f.l_key 
                                            where min_dt is null
                                            )
                                             
                                              Select f.L_KEY, 
                                                     f.branch_key,
                                                     PAY_DT, 
                                                     sum (summ) summ,
                                                     sum (sum_prev) sum_prev,
                                                     sum (LEASING_PAY) LEASING_PAY,
                                                     sum (SUPPLY_PAY) SUPPLY_PAY, 
                                                     sum (PAY_AMT) PAY_AMT 
                                              from FLOW f, dm_xirr x
                                              where f.l_key = x.contract_id
                                              and x.odttm = p_REPORT_DT
                                              and x.snapshot_cd = '����'
                                              group by f.l_key, f.branch_key, pay_dt -- �������
                                              order by f.l_key, f.PAY_DT
                          --where L_KEY in (32, 33, 41, 52)
    )
loop
              if rec.L_KEY != v_id_prev or v_id_prev is null                      -- ����� ���������� ��� ������ ��������� �������� � ������
                then
                  pers := null;
                  nill := null;
                  diff := round(rec.SUMM,2)*(-1);
                  --dbms_output.put_line ('dt:'||rec.pay_dt||' pers:'||pers||' nill:'||nill||' diff:'||diff);
                  v_id_prev := rec.L_KEY;
                  prev_dt := rec.pay_dt;
                 -- XIRR := xirr_calc_new(rec.contract_id)/100;
                  select XIRR into p_XIRR from DM_XIRR where
                  contract_id = rec.L_KEY
                  and ODTTM= p_REPORT_DT
                  and snapshot_cd = '����';
                  p_xirr := p_xirr/100;
                  diff_prev2 := diff_prev;
                  diff_prev := diff;
                  ka_prev2 := ka_prev;
                  ka_prev := ka;
                          if rec.pay_dt > p_REPORT_DT and diff_prev2 is null then ka := 1;
                          elsif rec.pay_dt <= p_REPORT_DT then ka := 1;
                          elsif diff_prev = 0 then ka := nvl(ka_prev, 1);
                          elsif ka_prev = 0 then ka := round(diff_prev2 * ka_prev2 / diff_prev, 2); -- ������ �� ����
                          --elsif ka_prev = 0 and diff_prev != 0 then ka := round(diff_prev2 * ka_prev2 / -1, 2); -- ������ �� ����
                          elsif nill > 0 then ka := ka_prev;
                          else ka := 0;
                          end if;
                  --ka := 1;
                  nil_ka := round(ka * nill, 2);
                  if nil_ka < 0 and rec.pay_dt > p_REPORT_DT then nil_ka := 0;
                  end if;
                  insert into dm_nil (contract_id,contract_date, fact_amt, plan_amt, leasing_amt, supply_amt,nil_pers,nil,nil_diff,ODTTM,ka, nil_ka, PAY_AMT, branch_key, snapshot_cd)
                  values(rec.L_KEY,rec.pay_dt,(case when rec.summ < 0 then rec.summ else 0 end), (case when rec.summ > 0 then rec.summ else 0 end), rec.leasing_pay, rec.supply_pay, pers,nill,diff,p_REPORT_DT,round(ka, 2), nil_ka, rec.summ, rec.branch_key, '����');
                
                else                                                                              -- ����� ���������� ��� ��������� ��������� �������� � ������
                  pers := round(diff*power((1+p_XIRR),(rec.pay_dt-prev_dt)/365)-diff,2);
                  nill := round(rec.summ-pers,2);
                  diff_prev2 := diff_prev;
                  diff_prev := diff;
                  diff := round(diff-nill,2);
                  ka_prev2 := ka_prev;
                  ka_prev := ka;
                          if rec.pay_dt > p_REPORT_DT and diff_prev2 is null then ka := 1;
                          elsif rec.pay_dt <= p_REPORT_DT then ka := 1;
                          elsif diff_prev = 0 then ka := nvl(ka_prev, 1);
                          elsif ka_prev = 0 then ka := round(diff_prev2 * ka_prev2 / diff_prev, 2); -- ������ �� ����                          
                         -- elsif ka_prev = 0 and diff_prev != 0 then ka := round(diff_prev2 * ka_prev2 / -1, 2); -- ������ �� ����
                          elsif nill > 0 then ka := ka_prev;
                          else ka := 0;
                          end if;
                  v_id_prev := rec.L_KEY;
                  prev_dt := rec.pay_dt;
                  nil_ka := round(ka * nill, 2);
                  if nil_ka < 0 and rec.pay_dt > p_REPORT_DT then nil_ka := 0;
                  end if;
                  --dbms_output.put_line ('dt:'||rec.payment_date||' pers:'||pers||' nill:'||nill||' diff:'||diff);
                  insert into dm_nil (contract_id,contract_date, fact_amt, plan_amt, leasing_amt, supply_amt, nil_pers,nil,nil_diff,ODTTM, ka, nil_ka, PAY_AMT, branch_key, snapshot_cd)
                  values(rec.L_KEY,rec.pay_dt,(case when rec.summ < 0 then rec.summ else 0 end), (case when rec.summ > 0 then rec.summ else 0 end), rec.leasing_pay, rec.supply_pay, pers,nill,diff,p_REPORT_DT,round(ka, 2), nil_ka, rec.PAY_AMT, rec.branch_key, '����');
                  commit;
              end if;
            end loop;
           -- end if;
commit;


delete dm_stg_kb;
commit;
insert into dm_stg_kb (contract_id, kb)
with t as
(select contract_id, sum(nil_ka) sum_nil
    from dm_nil
   where contract_date > p_REPORT_DT
     and odttm = p_REPORT_DT
     and snapshot_cd = '����'
   group by contract_id),
t2 as
(select contract_id, nil_diff
    from dm_nil
   where contract_date = p_REPORT_DT
     and odttm = p_REPORT_DT
     and snapshot_cd = '����'),
t3 as 
(select t.contract_id, round(decode(t.sum_nil, 0, -1, t2.nil_diff / t.sum_nil), 2) as kb from t, t2
where t.contract_id = t2.contract_id)
select contract_id, kb from t3;
commit;
update dm_nil a set a.kb = (select b.kb from dm_stg_kb b where b.contract_id = a.contract_id),
nil_ka_kb = round(nil_ka  * (select b.kb from dm_stg_kb b where b.contract_id = a.contract_id), 2)
where a.contract_date >= p_REPORT_DT and odttm = p_REPORT_DT;
commit;
update dm_nil set kb = 0, nil_ka_kb = 0 where kb is null or nil_ka_kb is null;
commit;

insert into dm_repayment_schedule
(SNAPSHOT_DT,SNAPSHOT_CD,SNAPSHOT_MONTH,CONTRACT_KEY,TRANCHE_NUM,PAY_DT,CURRENCY_KEY,
FACT_PAY_AMT,PLAN_PAY_AMT,LEASING_PAY_AMT,SUPPLY_PAY_AMT,PAY_AMT,NIL_AMT,INTEREST_AMT,
PRINCIPAL_AMT,DNIL_AMT,KA,KB,PROCESS_KEY,INSERT_DT,BRANCH_KEY,NIL_ORIG_AMT)
select p_REPORT_DT, 
'����', 
to_char(p_REPORT_DT, 'MM'), 
a.contract_id, 
null, 
a.contract_date, 
b.currency_key,
a.fact_amt, 
a.plan_amt,
a.leasing_amt,
a.supply_amt,
a.PAY_AMT, 
round (a.NIL_KA_KB * (100 / (100 + v.vat_rate*100)), 2),                                        -- ���� ���
a.NIL_PERS, 
a.NIL, 
a.NIL_DIFF, 
a.KA, 
a.KB, 
77, 
sysdate,
a.branch_key,
a.NIL_KA_KB 
from dm_nil a, dwh.contracts b, dwh.vat v 
where a.contract_id = b.contract_key
and a.branch_key = v.branch_key
and b.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
and a.odttm = p_REPORT_DT
and a.branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
and a.snapshot_cd = '����'
and v.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
and v.begin_dt <= p_REPORT_DT
and v.end_dt >= p_REPORT_DT;
commit;

/*exception
  WHEN NO_DATA_FOUND THEN
       NULL;
  WHEN OTHERS THEN
  rollback;
  raise;*/
end;
/

