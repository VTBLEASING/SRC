CREATE OR REPLACE PROCEDURE DM.p_DM_XIRR_CALC_TEST_SINGLE(
      p_contract_key in number,
      p_REPORT_DT IN date
)

IS
--v_count number;

/* ���������, ����������� ������������� ������� DM_XIRR ������������ ���������� XIRR ��� ������� ���������. 
-- � �������� ���������� �� ���� �������� ���� ������ (p_REPORT_DT) � ����� ������ ����������� (p_group_key).
-- � ��������� ���������� ����� ������ �������� (contract_id), ������������ XIRR, ���� ������ (ODTTM) � ����� ������� (branch_key) � ������� DM_XIRR...
-- � �������� ������ ������� ��� �������� ������� �� �������, ����������� ������� �� �������� ���� �� ��������� � �������� ������� �� ��� ����� �� ���������.
-- ���������� ����� ��������� � ������� DM_XIRR_FLOW, ������������� IX_DM_XIRR_FLOW �� ����� L_KEY (����� ���������), REPORT_DT (�������� ����), EXCPTN_ZERO_DIV (��������� �������� � ����������� ��������).
*/
BEGIN
   
   delete from dm_xirr_flow_ORIG 
   where SNAPSHOT_dt = p_report_dt
   and l_key = p_contract_key
   and snapshot_cd = '����';      -- ������� ������� DM_XIRR_FLOW �� ������ �������� ������
   
   insert into dm_xirr_flow_orig (
   select * from (
           with
   /* ������� ����������� ���������� ������� � ��������������� �� ��������� ��������, ��������� �� ���� CONTRACT_LEASING_KEY � ���������� �������:
   -- ���� ������ �������� <= ���� ��������� ��������� �������
   -- ���� ��������� �������� >= ���� ������ ��������� �������                  
   */
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
                                                              where cgp_group.cgp_group_key = 1)
                                      )
                                        or 
                                      (LC.contract_fin_kind_desc is Null                             -- � ������ �������� ����������� ���������� Null
                                       and cn1.branch_key in (select branch_key 
                                                              from dwh.cgp_group cgp_group 
                                                              where cgp_group.cgp_group_key not in (1))
                                       ))
                                 and cl.cgp_flg = '1'                                                -- ������� ���
                                 and cn1.contract_key = p_contract_key                             
                                 and cn1.open_dt <= p_REPORT_DT
                                 --  and cn1.EXClUDE_CGP IS NULL
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
                                                      and To_date(p_REPORT_DT) BETWEEN BEGIN_DT and END_DT)
                          and fact_rp1.valid_to_dttm = '01.01.2400'
                          and fact_rp1.PAY_DT <= To_date(p_REPORT_DT)
              
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
                                                     and To_date(p_REPORT_DT) BETWEEN BEGIN_DT and END_DT)
                          and fact_rp2.valid_to_dttm = '01.01.2400'
                          and fact_rp2.PAY_DT <= To_date(p_REPORT_DT)
              
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
                                                     and To_date(p_REPORT_DT) BETWEEN BEGIN_DT and END_DT)
                          and fact_pp.valid_to_dttm = '01.01.2400'
--                          and fact_pp.PAY_DT > To_date(p_REPORT_DT)
              
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
                                                     and To_date(p_REPORT_DT) BETWEEN BEGIN_DT and END_DT)
                          and fact_rp1.valid_to_dttm = '01.01.2400'
                          and fact_rp1.PAY_DT <= To_date(p_REPORT_DT)
              
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
                                                     and To_date(p_REPORT_DT) BETWEEN BEGIN_DT and END_DT)
                          and fact_rp2.valid_to_dttm = '01.01.2400'
                          and fact_rp2.PAY_DT <= To_date(p_REPORT_DT)
              
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
                                                     and To_date(p_REPORT_DT) BETWEEN BEGIN_DT and END_DT)
                          and fact_pp.valid_to_dttm = '01.01.2400'
  --                        and fact_pp.PAY_DT > To_date(p_REPORT_DT)
              
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
                          )
         select 
                l.*, 
                p_REPORT_DT as snapshot_dt, 
                '����' as snapshot_cd
         from flow_L_CUR l
         ));
   
  
   delete from dm_xirr_flow where report_dt = p_report_dt;      -- ������� ������� DM_XIRR_FLOW �� ������ �������� ������
   insert into dm_xirr_flow (
    
                 select * from (           
               
                        /* ��������� ������. ���� ������ ����������� ������ �1 �� �������� �������, �� ������������ "������������" ����� ������� �������
                           �� �������� ��������. ������� �������������� ������� �������� � ������������ ����� �� ������������� ������ �� ��� ���� (min_dt), 
                           ����� ������� �������� �� ������ �� ������ ������ ������������� ����� (��. FLOW). 
                        */
                      with   balance as (                                                              -- ������������� �����
                                       
                                        select L_key,
                                        branch_key,
                                               PAY_DT,
                                               sum(pay_amt_cur) over (partition by l_key order by pay_dt) bal1,
                                               sum(pay_amt) over (partition by l_key order by pay_dt) bal2
                                        from dm_xirr_flow_orig
                                        where snapshot_cd = '����'
                                        and l_key = p_contract_key
                                        and (TP <> 'Supply_plan' or
                                        (TP = 'Supply_plan' and PAY_DT > p_REPORT_DT))
                                       ),
              
                             min_dt as                                                                -- ����, ����� ������������� ������ �� ������ ��������� ������������� ������
                                        (
                                            select 
                                                  L_KEY,
                                                  
                                                  min(case 
                                                          when bal1 < 0
                                                            then pay_dt
                                                          else null
                                                      end) min_dt
                                            from balance 
                                            group by L_KEY
                                            ),
                             
                  /* ���������. ������������ �������� �������� �� ���� ���������� ����������� �� ������ ����, ��������� �� ����� 
                     ����������. ��� 1-�� ����� ������, ���������� �� �������� ��������.
                  */            
                                 
                      --���
                            Flow_Underpay as
                                            (
                                            SELECT  fc.L_key,
                                                    fc.branch_key,                                        
                                                    sum(case when cs.PAY_AMT_CuR_supply > 0 and tp='Supply_fact' 
                                                                then fc.PAY_AMT_CuR*-1
                                                              when cs.PAY_AMT_CuR_supply > 0 and tp='Supply_plan'    
                                                                then fc.PAY_AMT_CuR
                                                        else 0 end) PAY_AMT_CuR,
                                                    cs.PAY_AMT_CuR_supply
                                            from 
                                                    dm_xirr_flow_orig fc
                                            join (select l_key, 
                                                      sum (case when tp='Supply_fact' then 
                                                                  PAY_AMT_cur 
                                                                when tp='Supply_plan' then 
                                                                  PAY_AMT_cur*-1 
                                                          end) PAY_AMT_CuR_supply 
                                                  from dm_xirr_flow_orig
                                                  WHERE TP in ('Supply_fact','Supply_plan')
                                                  and snapshot_cd = '����'
                                                   and pay_dt <= To_date(p_REPORT_DT)
                                                   and l_key = p_contract_key
                                                  group by l_key) cs
                                            on cs.l_key = fc.l_key
                                            WHERE fc.TP in ('Supply_fact','Supply_plan')
                                             and fc.pay_dt <= To_date(p_REPORT_DT)
                                             and snapshot_cd = '����'
                                            group by  fc.L_key, fc.branch_key, cs.PAY_AMT_CuR_supply
                                          
                                            
                                      ),                       
            
                    /* ����������� ������ � ���������. ������������ �������� �������� �� ���� ���������� ����������� �� ������ ����, ��������� �� ����� 
                     ����������. ��� 1-�� ����� ������, ���������� �� �������� ��������.
                    */         
                             Flow_prev_1 as
                                            (
                                             SELECT
                                                    L_KEY,
                                                    branch_key,
                                                    p_REPORT_DT + 1 pay_dt ,
                                                    nvl(PAY_AMT_CuR, 0) summ,
                                                    PAY_AMT_CuR PAY_AMT
                                             FROM Flow_Underpay
                                             where PAY_AMT_CuR < 0
                                  
                                             UNION ALL
                                  
                                  
                                             SELECT 
                                                    L_KEY, 
                                                    branch_key,  
                                                    PAY_DT, 
                                                    SUM(nvl(PAY_AMT_CUR, 0)) summ, 
                                                    SUM(PAY_AMT) PAY_AMT
                                             FROM dm_xirr_flow_orig
                                             WHERE l_key = p_contract_key
                                             and (TP <> 'Supply_plan' or 
                                              (TP = 'Supply_plan' and PAY_DT > p_REPORT_DT))
                                             group by L_KEY, branch_key,  PAY_DT
                                             ),
            
                    /* ��� ������� ������� ��������� �������� ������������� ����� (sum_prev), ������� � ����� ������������ � ������� �������� ��� "������������"
                    */
            
                              FLOW_prev as
                                            (select L_KEY, 
                                                     branch_key, 
                                                     PAY_DT, 
                                                     summ, 
                                                     sum (summ) over (partition by L_KEY order by pay_dt rows between unbounded preceding and current row) sum_prev,
                                                     PAY_AMT 
                                              from  Flow_prev_1
                                            ),
            
                              FLOW as
                                             (select                                        -- ����� ������������� �������� �� min_dt 
                                                     f.L_KEY, 
                                                     branch_key, 
                                                     PAY_DT, 
                                                     summ, 
                                                     sum_prev
                                              from  
                                                     FLOW_prev f
                                              inner join min_dt min_dt
                                                 on min_dt.l_key = f.l_key
                                              where summ < 0
                                                and pay_dt <= min_dt
                                                            
                                            
                                             union all
                                            
                                              select                                        -- "������������" �������������� ������� �� �������������, � ������ ���������� ������ ��������,                                
                                                      f.L_KEY,                              -- ������ �� ������ �������������, � �������� ������ �� min_dt.
                                                      branch_key, 
                                                      PAY_DT, 
                                                      (case when 
                                                         sum_prev >= 0                      -- ����� ������� ������ ������������� ������, ������������� �� ������ ������� (sum_prev), ��� �������������� ������������� �������.
                                                           then abs (summ)
                                                         else sum_prev - summ
                                                      end) as summ,
                                                      sum_prev    
                                              from 
                                                     FLOW_prev f
                                              inner join min_dt min_dt
                                                on min_dt.l_key = f.l_key
                                              where summ < 0
                                                and pay_dt <= min_dt
                                                    
                                            union all
                                            
                                              select                                        -- ����� ��������� �������� �� min_dt
                                                      f.L_KEY, 
                                                      branch_key, 
                                                      PAY_DT, 
                                                      summ,
                                                      sum_prev
                                              from 
                                                      FLOW_prev f
                                              inner join min_dt min_dt
                                                 on min_dt.l_key = f.l_key 
                                              where pay_dt > min_dt
                                            
                                            union all
                                            
                                              select                                        -- ����� ��������� ��������, � ������� ��� min_dt
                                                      f.L_KEY, 
                                                      branch_key, 
                                                      PAY_DT, 
                                                      summ,
                                                      sum_prev
                                              from 
                                                      FLOW_prev f
                                              left join min_dt min_dt
                                                 on min_dt.l_key = f.l_key 
                                              where min_dt is null
                                      ),
              /* ���� ����� ����������� �������� ������ ����� �������� (div < 1), �� xirr �� �������, ���������� -1...
              */
                              excptn_zero_div as   
                                        (
                                         select 
                                                l_key,
                                                abs(sum(case when summ >= 0 then summ else 0 end)) / decode (abs(sum(case when summ < 0 then summ else 0 end)), 0, -1, abs(sum(case when summ < 0 then summ else 0 end))) as div 
                                         from flow
                                         group by l_key
                                        )
            
                              select 
                                    f.l_key,
                                    branch_key,
                                    PAY_DT,
                                    summ,
                                    sum_prev,
                                    case
                                      when
                                          d.div > 1 
                                              then 1
                                          else 0
                                      end,
                                    p_report_dt as report_dt
                              from 
                                   flow f
                              inner join
                                   excptn_zero_div d
                                on f.l_key = d.l_key
                              where 
                               (nvl(summ, 0) != 0 or nvl(sum_prev, 0) != 0)                  -- �� ������, ���� �� �������� �� ����������� �������� ���, ��� �������� �� �� ��������� � �����.
                            --  and d.div > 1
               ));

   
   delete from DM_XIRR 
   where ODTTM = p_REPORT_DT
   and contract_id = p_contract_key
   and snapshot_cd = '����';  -- ������ ������ �� �������� ������ ��� ������ ������ ����������� � ������� DM_XIRR
  
     for x in (select distinct -- ���� �� ������� ����������
                      L_KEY, branch_key 
               from  
               dm_xirr_flow
               where REPORT_DT = p_REPORT_DT
               and L_KEY = p_contract_key
             )
      loop
      /* ������� ����� � ����������� XIRR ��� ������� �� ���������� � ������� DM_XIRR
         nvl �� ��� ������, ���� ����� ����������� �������� ������ ����� �������� ��������... 
      */
       --dbms_output.put_line (to_char (x.L_KEY));
       insert into dm_xirr values (x.L_KEY, nvl(f_xirr_calc(x.L_KEY, p_REPORT_DT), -1), p_REPORT_DT, x.branch_key, '����');
        p_into_xirr_tracing (x.L_KEY, p_REPORT_DT);
      end loop;
 


   commit;
 
END;
/

