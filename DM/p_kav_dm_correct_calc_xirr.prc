CREATE OR REPLACE PROCEDURE DM.p_KAV_DM_CORRECT_CALC_XIRR(
      p_contract_key in number,
      p_REPORT_DT IN date,
      p_PAY_DT IN date
)

IS

v_cnt number;
v_new_dnil_amt  NUMBER;

BEGIN

--------------------------------------------------------------------------------------------------------------------------------------------
--  [asavgurov 02.11.2015] ���� ����� ���� ��������� ���� �� ��������� p_dm_xirr_calc_kis_single.
--------------------------------------------------------------------------------------------------------------------------------------------

   delete from dm_xirr_flow_ORIG 
   where SNAPSHOT_dt = p_report_dt
   and l_key = p_contract_key
   and snapshot_cd = '�������� ���';      -- ������� ������� DM_XIRR_FLOW_ORIG �� ������ �������� ������
   
   v_cnt:= SQL%ROWCOUNT;
   
   -- [aapolyakov 12.01.2016]: ���������� ��������� ��� ������������ ��������� ���������
   
   P_INTO_XIRR_CORRECT_TRACING (p_contract_key, p_REPORT_DT, 'DELETE XIRR_FLOW_ORIG', v_cnt);
   
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
                                                              where cgp_group.cgp_group_key = 2
                                                              and cgp_group.begin_dt <= p_REPORT_DT
                                                              and cgp_group.end_dt > p_REPORT_DT)
                                      )
                                        or 
                                      (LC.contract_fin_kind_desc is Null                             -- � ������ �������� ����������� ���������� Null
                                       and cn1.branch_key in (select branch_key 
                                                              from dwh.cgp_group cgp_group 
                                                              where cgp_group.cgp_group_key not in (1, 2)
                                                              and cgp_group.begin_dt <= p_REPORT_DT
                                                              and cgp_group.end_dt > p_REPORT_DT)
                                       ))
                                 and cl.cgp_flg = '1'                                                -- ������� ���
                                 and cn1.contract_key = p_contract_key                             
                                 and cn1.open_dt <= p_REPORT_DT
                                 and nvl(cn1.rehiring_flg, 0) != 1
                                 --and cn1.EXClUDE_CGP IS NULL
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
                            and cn2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                            and cn1.branch_key = cn2.branch_key
                        left join dwh.contracts cn3
                            ON cn2.CONTRACT_ID_CD = cn3.CONTRACT_ID_CD        -- �������� �� Id ���������� ��� ������� ���� ���������...
                              and cn3.contract_key <> cn2.contract_key 
                              -- and cn3.IS_CLOSED_CONTRACT = 1                  -- ��� �������� �������� ������� ��� ����� ������� ������.
                              and cn3.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                              and cn3.branch_key = cn2.branch_key
                     --         and nvl(cn3.rehiring_flg, 0) = 1
                        Left join dwh.contracts cn4
                              ON cn3.contract_key = cn4.contract_leasing_key  
                              and cn4.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
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
                                 Contr.flag,
                                 Contr.L_KEY L_KEY_DOP,
                                 Contr.L_KEY S_KEY,                                 
                                 abs(fact_rp1.EXCHANGE_RATE) ex_rate
                          from (select distinct 
                                        L_KEY,
                           --             L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                           --             L_CUR S_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces) Contr
                          inner join dwh.fact_real_payments fact_rp1
                              ON Contr.L_Key = fact_rp1.contract_key                                -- ������ ������ ��������� � ����������� �������� �� ����� �������� ������� 
                          where fact_rp1.CBC_DESC in (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Supply'                    -- ����� ����������� �������� �� ��������� �������� � ����� ��� 'Supply'
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_rp1.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
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
                                 Contr.flag,
                                 Contr.L_KEY L_KEY_DOP,
                                 Contr.S_KEY S_KEY,
                                 abs(fact_rp2.EXCHANGE_RATE) ex_rate
                          from (select distinct 
                                        L_Key,
                                        S_KEY,
                              --          L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        S_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces) Contr
                          inner join dwh.fact_real_payments fact_rp2
                              ON Contr.S_Key = fact_rp2.contract_key                              -- ������ ������ ��������� � ����������� �������� �� ����� �������� �������� 
                          where fact_rp2.CBC_DESC in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply'                   -- ����� ����������� �������� �� ��������� �������� � ����� ��� 'Supply'
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_rp2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
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
                                 Contr.flag,
                                 Contr.L_KEY L_KEY_DOP,
                                 Contr.S_KEY S_KEY,
                                 Null ex_rate 
                          from (select distinct 
                                        L_Key,
                                        S_KEY,
                                 --       L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        S_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces) Contr
                          inner join dwh.fact_plan_payments fact_pp
                             ON Contr.S_Key = fact_pp.contract_key
                          where fact_pp.CBC_DESC in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_pp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          and p_REPORT_DT between fact_pp.BEGIN_DT and fact_pp.END_DT
--                          and fact_pp.PAY_DT > p_REPORT_DT
              
      
                           
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
                                 Contr.flag,
                                 Contr.L_Key_DOP L_KEY_DOP,
                                 Contr.L_Key_DOP S_KEY,
                                 abs(fact_rp1.EXCHANGE_RATE) ex_rate    
                          from(select distinct 
                                        L_KEY,
                                        L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces) Contr
                          inner join dwh.fact_real_payments fact_rp1
                              ON Contr.L_Key_DOP = fact_rp1.contract_key
                          inner join dwh.contracts L_DOP_CO
                              on Contr.L_Key_DOP = L_DOP_CO.contract_key
                              and L_DOP_CO.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          where fact_rp1.CBC_DESC  in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_rp1.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
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
                                 Contr.flag,
                                 Contr.L_Key L_KEY_DOP,
                                 Contr.S_KEY_DOP S_KEY,
                                 abs(fact_rp2.EXCHANGE_RATE) ex_rate   
                          from   (select distinct 
                                        L_KEY,
                                        S_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        S_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces) Contr                          

                          inner join dwh.fact_real_payments fact_rp2
                              ON Contr.S_Key_DOP = fact_rp2.contract_key
                          inner join dwh.contracts co 
                              on Contr.S_Key_DOP = co.contract_key
                              and co.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          where fact_rp2.CBC_DESC  in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_rp2.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
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
                                 Contr.flag,
                                 Contr.L_Key L_KEY_DOP,
                                 Contr.S_KEY_DOP S_KEY, 
                                 Null ex_rate  
                          from(select distinct 
                                        L_KEY,
                                        S_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        S_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces) Contr                          
                          inner join dwh.fact_plan_payments fact_pp
                              ON Contr.S_Key_DOP = fact_pp.contract_key
                          inner join dwh.contracts co 
                              on Contr.S_Key_DOP = co.contract_key
                              and co.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          where fact_pp.CBC_DESC  in (
                                                     select CBC_DESC 
                                                     from DWH.CLS_CBC_TYPE_CALC 
                                                     where TYPE_CALC = 'Supply' 
                                                     and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)
                          and fact_pp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                          and p_REPORT_DT between fact_pp.BEGIN_DT and fact_pp.END_DT                        
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
                                   CUR3,
                                   CUR2,
                                   base_currency,
                                   flag,
                                   L_KEY_DOP,
                                   S_KEY,
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
                                   end) as PAY_AMT_cur_supply,
                                   ex_rate
                                 
                            from Flow_S s
                               
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
                                  on rt_rp2.ex_rate_dt = p_REPORT_DT 
                                  and s.CUR1= rt_rp2.CURRENCY_KEY 
                                  and rt_rp2.BASE_CURRENCY_KEY = s.base_currency
                                  and rt_rp2.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                                                                    
                          ),
                          
                FLOW_S_UNDERPAY_1 as (                         
                            select  
                                    f1.L_Key,
                                    f1.branch_key,
                                    f1.CBC_DESC,
                                    (case 
                                        when f1.pay_amt2 >= nvl(f2.pay_amt_sum,0)
                                         and pay_dt > p_REPORT_DT
                                            then p_REPORT_DT 
                                        else pay_dt 
                                    end) pay_dt, 
                                    f1.PAY_AMT,
                                    f1.TP,                                 
                                    f1.CUR1,
                                    f1.CUR3,
                                    f1.CUR2,
                                    f1.base_currency,
                                    f1.flag,                                    
                                    f1.L_KEY_DOP,
                                    f1.S_KEY,
                                    f1.PAY_AMT_cur_supply,
                                    f1.ex_rate
                              from 
                                    (select                                 
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
                                              flag,
                                              L_KEY_DOP,
                                              S_KEY,
                                              ex_rate  
                                        from flow_s_cur
                                        where TP = 'Supply_plan') f1 
                                  left join
                                        (
                                          select 
                                              L_Key,
                                              CBC_DESC,
                                              sum(PAY_AMT_cur_supply) pay_amt_sum
                                          from flow_s_cur 
                                          where TP = 'Supply_fact' and CBC_DESC ='��.3.1'
                                          group by L_Key,CBC_DESC) f2 
                                                                                                    
                                  on f1.L_Key = f2.L_Key and f1.CBC_DESC = f2.CBC_DESC
                      
                        ),

     /*     FLOW_S_UNDERPAY_FACT as (
                                    select                                     
                                    PL.L_Key,
                                    PL.branch_key,
                                    '��.3.1' CBC_DESC,
                                    PL.pay_dt, 
                                    s2-s1 PAY_AMT,
                                    'Supply_plan' TP,                                 
                                    PL.CUR1,
                                    PL.CUR1 CUR3,
                                    PL.CUR1 CUR2,
                                    PL.base_currency,
                                    PL.flag,                                                                        
                                    PL.L_KEY_DOP,
                                    PL.S_KEY,
                                    s2-s1 PAY_AMT_cur_supply,
                                    null ex_rate 
                                    from (
                                         select * from  Flow_S_CUR 
                                         where TP = 'Supply_plan' and  pay_dt > p_REPORT_DT) PL
                                         
                                    inner join  (
                                          select sum(PAY_AMT_cur_supply)*-1 s1, TP, L_key from Flow_S_CUR 
                                          where  TP Like 'Supply_plan' and pay_dt<=p_REPORT_DT group by TP,  L_key) SP
                                    on  PL.L_KEY = SP.L_KEY     
                                    inner join  (
                                          select sum(PAY_AMT_cur_supply)*-1 s2, TP, L_key from Flow_S_CUR 
                                          where  TP Like 'Supply_fact' and pay_dt<=p_REPORT_DT group by TP,  L_key) SF  
                                    on  PL.L_KEY = SF.L_KEY 
                                    where s2-s1>0),*/
                          
               Flow_L as             
                          (
                           SELECT Contr.L_KEY,                      -- ���������� ����������� � ������, ���� ������ ��������� ������� ������������� ��������� ��������� �������� (flag = 1)
                                  contr.branch_key,                                                           
                                  fact_pp.CBC_DESC,
                                  PAY_DT,
                                  PAY_AMT, 
                                  'LEASING' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.L_CUR CUR3, 
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag,
                                  Contr.L_Key L_KEY_DOP,
                                  Null S_KEY
                           from (select distinct 
                                        L_KEY,
                                        branch_key,
                                        L_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces) Contr
                           inner join dwh.fact_plan_payments fact_pp
                              ON Contr.L_Key = fact_pp.contract_key
                           where fact_pp.CBC_DESC in  (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Leasing' 
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)                 -- ����� �������� �������� �� ��������� ������� � ����� ������������� ��� 'Leasing'
                           and fact_pp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                           and p_REPORT_DT between fact_pp.BEGIN_DT and fact_pp.END_DT
                           
                           UNION ALL
       
                          -- �������������� ����� �� ������ 
       
                           SELECT Contr.L_KEY,                          -- ���������� ����������� � ������, ���� ������ ��������� ������� ������������� ��������� ��������� �������� (flag = 1)
                                  contr.branch_key,
                                  fact_pp.CBC_DESC,
                                 PAY_DT,
                                  PAY_AMT, 
                                  'LEASING' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.L_CUR CUR3, 
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag,
                                  Contr.L_KEY_DOP L_KEY_DOP,
                                  Null S_KEY 
                           from dwh.fact_plan_payments fact_pp
                           INNER join (select distinct 
                                        L_KEY,
                                        L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        base_currency,
                                        flag
                                        from Contr_ces) Contr
                              ON Contr.L_Key_dop = fact_pp.contract_key
                           where fact_pp.CBC_DESC in  (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Leasing' 
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)                -- ����� �������� �������� �� ��������� ������� � ����� ������������� ��� 'Leasing'
                           and fact_pp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                           and p_REPORT_DT between fact_pp.BEGIN_DT and fact_pp.END_DT
                           
                           UNION ALL
                           
                           SELECT Contr.L_KEY,                      -- ���������� ����������� � ������, ���� ������ ��������� ������� ������������� ��������� ��������� �������� (flag = 1)
                                  contr.branch_key,                                                           
                                  fact_pp.CBC_DESC,
                                  PAY_DT,
                                  PAY_AMT, 
                                  'LEASING_FACT' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.L_CUR CUR3, 
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag,
                                  Contr.L_KEY L_KEY_DOP,
                                  Null S_KEY 
                           from (select distinct 
                                        L_KEY,
                                        branch_key,
                                        L_CUR,
                                        base_currency,
                                        flag
                                  from Contr_ces) Contr
                           inner join dwh.fact_real_payments fact_pp
                              ON Contr.L_Key = fact_pp.contract_key
                           where fact_pp.CBC_DESC in  (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Leasing' 
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)                 -- ����� �������� �������� �� ��������� ������� � ����� ������������� ��� 'Leasing'
                           and fact_pp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                           
                           UNION ALL
       
                          -- �������������� ����� �� ������ 
       
                           SELECT Contr.L_KEY,                          -- ���������� ����������� � ������, ���� ������ ��������� ������� ������������� ��������� ��������� �������� (flag = 1)
                                  contr.branch_key,
                                  fact_pp.CBC_DESC,
                                 PAY_DT,
                                  PAY_AMT, 
                                  'LEASING_FACT' TP, 
                                  Contr.L_CUR CUR1,
                                  Contr.L_CUR CUR3, 
                                  fact_pp.CURRENCY_KEY CUR2,
                                  Contr.base_currency,
                                  Contr.flag,
                                  Contr.L_KEY_DOP L_KEY_DOP,
                                  Null S_KEY 
                           from dwh.fact_real_payments fact_pp
                           INNER join (select distinct 
                                        L_KEY,
                                        L_KEY_DOP,
                                        branch_key,
                                        L_CUR,
                                        base_currency,
                                        flag
                                        from Contr_ces) Contr
                              ON Contr.L_Key_dop = fact_pp.contract_key
                           where fact_pp.CBC_DESC in  (
                                                      select CBC_DESC 
                                                      from DWH.CLS_CBC_TYPE_CALC 
                                                      where TYPE_CALC = 'Leasing' 
                                                      and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)                -- ����� �������� �������� �� ��������� ������� � ����� ������������� ��� 'Leasing'
                           and fact_pp.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                           
                           ),
           
          /* ����������� �������� �� ��������� �������, �������� � ���������� ������ � �������� ����� 
             � ������ 0 ��� ������� ���������� ���� �� ���������� ������� �� �������� ����.
          */
                 Flow_Cur as(                   
                              select 
                                    fl.*, 
                                    0 PAY_AMT_cur_supply,                                  
                                    Null  ex_rate 
                              from Flow_L fl
                            UNION ALL
                              select * 
                              from Flow_S_cur 
                              where TP = 'Supply_fact'
                            UNION ALL 
                              select * 
                              from FLOW_S_UNDERPAY_1 
                              where TP = 'Supply_plan' 
                                and CBC_DESC = '��.3.1'
                            UNION ALL
                              select * 
                              from Flow_S_cur 
                              where TP = 'Supply_plan' 
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
                                    0 Flow_S_cur,
                                    L_key as L_KEY_DOP,
                                    S_KEY,
                                    null ex_rate 
                              from Contr
                   /*         UNION ALL
                              select * 
                              from FLOW_S_UNDERPAY_FACT     */                          
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
                                  
                                   WHEN ex_rate is not Null and ex_rate = 0 and cur1 != cur2 
                                      then 0
                                   WHEN ex_rate is not Null and ex_rate <> 0 and cur1 != cur2   
                                      then PAY_AMT/ex_rate/rt2.EXCHANGE_RATE 
                                      
                                   else
                                         case
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
                                         end
                                   end) as PAY_AMT_cur,
                                   PAY_AMT,
                                   TP,
                                   CUR1,
                                   CUR2, 
                                   CUR3,
                                   PAY_AMT_cur_supply,
                                   L_KEY_DOP,
                                   S_KEY 
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
                L_KEY,
                branch_key,
                CBC_DESC,
                PAY_DT, 
                PAY_AMT_cur,
                PAY_AMT,
                TP,
                CUR1,
                CUR2, 
                CUR3,
                PAY_AMT_cur_supply,
                p_REPORT_DT as snapshot_dt, 
                '�������� ���' as snapshot_cd,
                L_KEY_DOP,
                S_KEY 
         from flow_L_CUR l
         ));
         
         v_cnt:= SQL%ROWCOUNT;
   
   -- [aapolyakov 12.01.2016]: ���������� ��������� ��� ������������ ��������� ���������
   
   P_INTO_XIRR_CORRECT_TRACING (p_contract_key, p_REPORT_DT, 'INSERT XIRR_FLOW_ORIG', v_cnt);

------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------

-- ������� dm_xirr_flow �� ��������
   delete from dm_xirr_flow where report_dt = p_report_dt;      -- ������� ������� DM_XIRR_FLOW �� ������ �������� ������
-- ��������� ���. ������ �� ������������������ ��������.
commit;

v_cnt:= SQL%ROWCOUNT;
   
   -- [aapolyakov 12.01.2016]: ���������� ��������� ��� ������������ ��������� ���������
   
   P_INTO_XIRR_CORRECT_TRACING (p_contract_key, p_REPORT_DT, 'DELETE XIRR_FLOW', v_cnt);

DELETE DM_XIRR_CORRECT_TEMP;


SELECT dnil
INTO v_new_dnil_amt
FROM (select a.dnil_amt + b.CORRECT_AMT as dnil
              from dm.dm_repayment_schedule a, dwh.nil_corrects b 
              where a.contract_key = p_contract_key 
                and a.contract_key = b.contract_key 
                and a.snapshot_dt = p_PAY_DT 
                and a.pay_dt = p_PAY_DT
                and b.snapshot_dt = p_PAY_DT
                and b.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
                and b.actual_flg = 1
              );

--insert into dm.DM_XIRR_CORRECT_TEMP (l_key, branch_key, pay_dt, summ, sum_prev, excptn_zero_div, report_dt, flag, NUM_UNION, ZERO_DIV_FLG)
--WITH

delete TEMP_CORR_FLOW_UNDERPAY;
delete TEMP_CORR_Flow_Underpay_FLG;
delete TEMP_CORR_Supply_eq;
delete TEMP_CORR_Flow_prev_1;
delete TEMP_CORR_FLOW_prev_v;
delete TEMP_CORR_FLOW_prev;
delete TEMP_CORR_balance;
delete TEMP_CORR_min_dt;
delete TEMP_CORR_FLOW;
delete TEMP_CORR_excptn_zero_div;
delete TEMP_CORR_fff;
delete TEMP_CORR_FINALL;


insert into TEMP_CORR_FLOW_UNDERPAY 
          with                 Flow_Underpay as
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
                                                  and snapshot_cd = '�������� ���'
                                                  and snapshot_dt = p_REPORT_DT
                                                  and l_key = p_contract_key
                                                  -- and pay_dt <= p_REPORT_DT -- 10/08/2015 MVV
                                                  group by l_key) cs
                                            on cs.l_key = fc.l_key
                                            WHERE fc.TP in ('Supply_fact','Supply_plan')
                                             -- and fc.pay_dt <= p_REPORT_DT -- 10/08/2015 MVV
                                             and snapshot_cd = '�������� ���'
                                             and snapshot_dt = p_REPORT_DT
                                             and fc.l_key = p_contract_key
                                            group by  fc.L_key, fc.branch_key, cs.PAY_AMT_CuR_supply
                                            )
select * from   Flow_Underpay;                                          
                                                        
insert into TEMP_CORR_Flow_Underpay_FLG                                            
         with        Flow_Underpay_FLG as                                                                              -- �������� ������������� ��������� ��������� (���������� �������� �������)
                                    ( 
                                      Select  
                                            SUM_FL.L_KEY,  
                                            (case when SUM_FL.PAY_AMT_FACT =  SUM_FL.PAY_AMT_PLAN 
                                                then 'N'
                                             else 'Y'
                                             end) FLG_UNDERPAY
                                      from (select l_key, 
                                                      sum (case when tp='Supply_fact' then 
                                                                  PAY_AMT
                                                                else 0
                                                           end) PAY_AMT_FACT,
                                                       sum (case when tp='Supply_plan' then 
                                                                  PAY_AMT 
                                                          end) PAY_AMT_PLAN
                                                from dm_xirr_flow_orig
                                                WHERE TP in ('Supply_fact','Supply_plan')
                                                    and snapshot_cd = '�������� ���'
                                                    and snapshot_dt = p_REPORT_DT
                                                    and L_KEY = p_contract_key
                                                    and pay_dt <= p_REPORT_DT ----- 26102015 ���������� NIL
                                                  group by L_KEY
                                               ) SUM_FL                                       
                                        )
select * from Flow_Underpay_FLG;

insert into TEMP_CORR_Supply_eq                                         
              with                Supply_eq as (select l_key as unpaid_l_key from dm_xirr_flow_orig   ----- 26102015 ����������� ������ ���������� � ���������� ���������
                                              where upper(tp) in ('SUPPLY_PLAN', 'SUPPLY_FACT') 
                                              and snapshot_cd = '�������� ���'
                                              and snapshot_dt = p_REPORT_DT
                                              and L_KEY = p_contract_key
                                              group by l_key
                                              having sum(case when upper(tp) = 'SUPPLY_PLAN' then pay_amt else -pay_amt end) = 0)
select * from  Supply_eq;                                         
                      
                             /* ����������� ������ � ���������. ������������ �������� �������� �� ���� ���������� ����������� �� ������ ����, ��������� �� ����� 
                     ����������. ��� 1-�� ����� ������, ���������� �� �������� ��������.*/
insert into TEMP_CORR_Flow_prev_1
                 with            Flow_prev_1 as
                                            (
                     /*                        SELECT
                                                    L_KEY,
                                                    branch_key,
                                                    p_REPORT_DT + 1 pay_dt ,
                                                    nvl(PAY_AMT_CuR, 0) summ,
                                                    PAY_AMT_CuR PAY_AMT
                                             FROM Flow_Underpay
                                             where PAY_AMT_CuR < 0
                       */
                                            SELECT
                                                    FU.L_KEY,
                                                    FU.branch_key,
                                                    p_REPORT_DT + 1 pay_dt ,
                                                    nvl(PAY_AMT_CuR, 0) summ,
                                                    PAY_AMT_CuR PAY_AMT
                                             FROM TEMP_CORR_Flow_Underpay FU
                                             join TEMP_CORR_Flow_Underpay_FLG FUF
                                             on FU.L_KEY=FUF.L_KEY 
                                             where PAY_AMT_CuR < 0
                                            and FUF.FLG_UNDERPAY='Y'
                       
                                             UNION ALL
                                  
                                  
                                             SELECT ----- 26102015 ���������� ������� NIL
                                                    L_KEY, 
                                                    branch_key,  
                                                    PAY_DT, 
                                                    SUM(nvl(PAY_AMT_CUR, 0)) summ, 
                                                    SUM(PAY_AMT) PAY_AMT
                                             FROM dm_xirr_flow_orig
                                             WHERE snapshot_cd = '�������� ���'
                                             and snapshot_dt = p_REPORT_DT
                                             and l_key = p_contract_key
                                             and (TP <> 'Supply_plan')
                                              and TP <> 'LEASING_FACT'
                                             group by L_KEY, branch_key,  PAY_DT
                                             
                                             UNION ALL
                                  
                                  
                                             SELECT ----- 26102015 ����� ������ ��� ������� �������� �������� �� ��������, ������� ��� �� ��������
                                                    L_KEY, 
                                                    branch_key,  
                                                    PAY_DT, 
                                                    SUM(nvl(PAY_AMT_CUR, 0)) summ, 
                                                    SUM(PAY_AMT) PAY_AMT
                                             FROM dm_xirr_flow_orig a, TEMP_CORR_Supply_eq b
                                             WHERE snapshot_cd = '�������� ���'
                                             and snapshot_dt = p_REPORT_DT
                                             and l_key = p_contract_key
                                             and TP = 'Supply_plan' and PAY_DT > p_REPORT_DT and unpaid_l_key is null
                                             and a.l_key = b.unpaid_l_key (+)-- 10/08/2015 MVV
                                             group by L_KEY, branch_key,  PAY_DT
                                             )
select * from   Flow_prev_1;                                           
                                            
insert into TEMP_CORR_FLOW_prev_v 
                with              FLOW_prev_v as
                                            (select L_KEY, 
                                                     branch_key, 
                                                     PAY_DT, 
                                                     sum (summ) summ, 
                                                     sum (PAY_AMT) pay_amt 
                                              from  TEMP_CORR_Flow_prev_1
                                              where pay_dt = p_REPORT_DT + 1
                                              group by L_KEY, branch_key, PAY_DT
                                              
                                              union all
                                              
                                              select L_KEY, 
                                                     branch_key, 
                                                     PAY_DT, 
                                                     summ, 
                                                     PAY_AMT 
                                              from  TEMP_CORR_Flow_prev_1
                                              where pay_dt != p_REPORT_DT + 1
                                            )
select * from  FLOW_prev_v;                                           
            
                    /* ��� ������� ������� ��������� �������� ������������� ����� (sum_prev), ������� � ����� ������������ � ������� �������� ��� "������������"
                    */
            
insert into TEMP_CORR_FLOW_prev
                   with           FLOW_prev as
                                            (select L_KEY, 
                                                     branch_key, 
                                                     PAY_DT, 
                                                     summ, 
                                                     sum (summ) over (partition by L_KEY order by pay_dt rows between unbounded preceding and current row) sum_prev,
                                                     PAY_AMT 
                                              from  TEMP_CORR_FLOW_prev_v
                                            )
select * from FLOW_prev;
                                 
insert into TEMP_CORR_balance           
               with               balance as (                                                              -- ������������� �����
                                       
                                        select L_key,
                                        branch_key,
                                               PAY_DT,
                                               sum(summ) over (partition by l_key order by pay_dt) bal1,
                                               sum(pay_amt) over (partition by l_key order by pay_dt) bal2
                                        from TEMP_CORR_FLOW_prev_v
                                       )
select * from balance;                                        
              
insert into TEMP_CORR_min_dt
               with              min_dt as                                                                -- ����, ����� ������������� ������ �� ������ ��������� ������������� ������
                                        (
                                            select 
                                                  L_KEY,
                                                  
                                                  min(case 
                                                          when bal1 < 0
                                                            then pay_dt
                                                          else null
                                                      end) min_dt
                                            from TEMP_CORR_balance 
                                            group by L_KEY
                                            )
select * from min_dt;                                            
            
insert into TEMP_CORR_FLOW
                  with            FLOW as
                                             (select                                        -- ����� ������������� �������� �� min_dt 
                                                     f.L_KEY, 
                                                     branch_key, 
                                                     PAY_DT, 
                                                     summ, 
                                                     sum_prev
                                              from  
                                                     TEMP_CORR_FLOW_prev f
                                              inner join TEMP_CORR_min_dt min_dt
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
                                                     TEMP_CORR_FLOW_prev f
                                              inner join TEMP_CORR_min_dt min_dt
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
                                                      TEMP_CORR_FLOW_prev f
                                              inner join TEMP_CORR_min_dt min_dt
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
                                                      TEMP_CORR_FLOW_prev f
                                              left join TEMP_CORR_min_dt min_dt
                                                 on min_dt.l_key = f.l_key 
                                              where min_dt is null
                                      )
select * from FLOW;
                                      
--[asavgurov 03.11.2015]: ������� ������ excptn_zero_div. ���� ������ ���������� ����, ����� ������ ������ ���� flag. ����� supply_fact_sum, �.� ��� ��� �� �����
insert into TEMP_CORR_excptn_zero_div
                   with           excptn_zero_div as   
                                        (
                                         select 
                                                l_key,
                                                sum (case when summ < 0 then summ else 0 end) as flag
                                         from TEMP_CORR_flow
                                         group by l_key
                                        )
select * from excptn_zero_div;
                            
insert into TEMP_CORR_fff            
                    with                       fff as   -----������-----------��������(������ �����������, � �� ������) ��� ����, ����� �������� ������� ��������� ��� ��������� ������    
                                        (                    
SELECT f.l_key,
  branch_key,
  PAY_DT,
  summ,
  sum_prev,
  1 excptn_zero_div,
  p_REPORT_DT AS report_dt,
  CASE WHEN flag = 0 THEN -99 ELSE 0
  END AS flag,
  nvl2 (d.l_key, 1, 0) ZERO_DIV_FLG
FROM TEMP_CORR_flow f
LEFT JOIN TEMP_CORR_excptn_zero_div d
ON f.l_key = d.l_key
--WHERE (NVL(summ, 0) != 0
--OR NVL(sum_prev, 0) != 0) -- �� ������, ���� �� �������� �� ����������� �������� ���, ��� �������� �� �� ��������� � �����.
  --  and d.div > 1
                                        ) 
select * from fff;                                        
                                        
insert into TEMP_CORR_FINALL
                      with               FINALL as (
        SELECT l_key
              , branch_key
              , pay_dt
              , summ
              , case when pay_dt = p_PAY_DT and summ = 0 then -v_new_dnil_amt else 0 end as sum_prev
              , excptn_zero_div
              , report_dt
              , flag
              , 2 as NUM_UNION
              , ZERO_DIV_FLG 
  from  TEMP_CORR_fff b where b.pay_dt >= p_PAY_DT
  union all
  select p_contract_key as l_key
       , (select branch_key from dwh.contracts where contract_key = p_contract_key and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')) as branch_key
       , p_PAY_DT as pay_dt
       , -v_new_dnil_amt as summ
       , 0 as sum_prev
       , 1 as excptn_zero_div
       , p_REPORT_DT as report_dt
       , 0 as flag
       , 1 as NUM_UNION
       , -11 as ZERO_DIV_FLG
       from dual
                                         )
select * from FINALL;
         
insert into dm.DM_XIRR_CORRECT_TEMP (l_key, branch_key, pay_dt, summ, sum_prev, excptn_zero_div, report_dt, flag, NUM_UNION, ZERO_DIV_FLG)                                
       select l_key
       , branch_key
       , pay_dt
       , summ
       , sum(summ + sum_prev) over (partition by l_key, branch_key, excptn_zero_div, report_dt, flag order by pay_dt, abs(summ) rows between unbounded preceding and current row) as sum_prev                                   
--[asavgurov 03.11.2015]: ������� ������ excptn_zero_div. ����� �� ��������� �������� 1.
       , case when sum(summ) over (partition by l_key, branch_key, report_dt, flag) > 0 then 1 else 0 end as excptn_zero_div
       , report_dt
       , flag
       , NUM_UNION
       , ZERO_DIV_FLG
from TEMP_CORR_FINALL;   --------------------------------------�����-----------�������� ��� ����, ����� �������� ������� ��������� ��� ��������� ������

insert into dm.DM_XIRR_FLOW (l_key, branch_key, pay_dt, summ, sum_prev, excptn_zero_div, report_dt, flag)

select l_key, branch_key, pay_dt, summ, sum_prev, excptn_zero_div, report_dt, flag
from DM_XIRR_CORRECT_TEMP
where  NUM_UNION = 1
      OR (NUM_UNION = 2
          AND ((NVL(summ, 0) != 0 OR NVL(sum_prev, 0) != 0))
          );
  
v_cnt:= SQL%ROWCOUNT;
   
   -- [aapolyakov 12.01.2016]: ���������� ��������� ��� ������������ ��������� ���������
   
   P_INTO_XIRR_CORRECT_TRACING (p_contract_key, p_REPORT_DT, 'INSERT XIRR_FLOW', v_cnt);

commit;
   
-- ������ xIRR

delete from dm_xirr where contract_id = p_contract_key and odttm = p_REPORT_DT;

v_cnt:= SQL%ROWCOUNT;
   
   -- [aapolyakov 12.01.2016]: ���������� ��������� ��� ������������ ��������� ���������
   
   P_INTO_XIRR_CORRECT_TRACING (p_contract_key, p_REPORT_DT, 'DELETE DM_XIRR', v_cnt);
   
commit;
insert into dm_xirr
select distinct p_contract_key, nvl(f_xirr_calc(p_contract_key, p_REPORT_DT), -1) as xirr, p_REPORT_DT as odttm, branch_key, '�������� ���' as snapshot_cd, flag as err_flag 
from dm.dm_xirr_flow where l_key = p_contract_key and report_dt = p_REPORT_DT and pay_dt = p_REPORT_DT;

v_cnt:= SQL%ROWCOUNT;
   
   -- [aapolyakov 12.01.2016]: ���������� ��������� ��� ������������ ��������� ���������
   
   P_INTO_XIRR_CORRECT_TRACING (p_contract_key, p_REPORT_DT, 'INSERT DM_XIRR', v_cnt);
   
commit;

end;
/

