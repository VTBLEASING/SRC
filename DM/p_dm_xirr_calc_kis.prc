CREATE OR REPLACE PROCEDURE DM.p_DM_XIRR_CALC_KIS(
      p_REPORT_DT IN date,
      p_group_key in number
)

IS
--v_count number;
   v_cnt number;
   v_max_executions number := 120;
   v_cur_ind number := 1;

/* ���������, ����������� ������������� ������� DM_XIRR ������������ ���������� XIRR ��� ������� ���������. 
-- � �������� ���������� �� ���� �������� ���� ������ (p_REPORT_DT) � ����� ������ ����������� (p_group_key).
-- � ��������� ���������� ����� ������ �������� (contract_id), ������������ XIRR, ���� ������ (ODTTM) � ����� ������� (branch_key) � ������� DM_XIRR...
-- � �������� ������ ������� ��� �������� ������� �� �������, ����������� ������� �� �������� ���� �� ��������� � �������� ������� �� ��� ����� �� ���������.
-- ���������� ����� ��������� � ������� DM_XIRR_FLOW, ������������� IX_DM_XIRR_FLOW �� ����� L_KEY (����� ���������), REPORT_DT (�������� ����), EXCPTN_ZERO_DIV (��������� �������� � ����������� ��������).
*/
BEGIN
     dm.u_log(p_proc => 'p_DM_XIRR_CALC_KIS',
           p_step => 'INPUT PARAMS',
           p_info => 'p_group_key:'||p_group_key||'p_REPORT_DT:'||p_REPORT_DT/*||'p_snapshot_cd:'||p_snapshot_cd||'p_contract_key:'||p_contract_key*/); 

   
   delete from dm_xirr_flow_ORIG 
   where SNAPSHOT_dt = p_report_dt
   and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
   and snapshot_cd = '�������� ���';      -- ������� ������� DM_XIRR_FLOW �� ������ �������� ������
     dm.u_log(p_proc => 'p_DM_XIRR_CALC_KIS',
           p_step => 'delete from dm_xirr_flow_ORIG ',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');   
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
                                                              where cgp_group.cgp_group_key = 2
                                                              and cgp_group.begin_dt <= p_REPORT_DT
                                                              and cgp_group.end_dt > p_REPORT_DT)
                                      )
                                        or 
                                      (LC.contract_fin_kind_desc is Null                             -- � ������ �������� ����������� ���������� Null
                                       and cn1.branch_key in (select branch_key 
                                                              from dwh.cgp_group cgp_group 
                                                              where cgp_group.cgp_group_key not in (2)
                                                              and cgp_group.begin_dt <= p_REPORT_DT
                                                              and cgp_group.end_dt > p_REPORT_DT)
                                       ))
                                 and cl.cgp_flg = '1'                                                -- ������� ���
                                 and cgp_group.cgp_group_key = p_group_key                               
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
                                   (
                                         case
                                         when CUR1 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT   --���� �_��� <> �_��� � ��_��� <> �_��� � ���� <= �_����, 
                                            then PAY_AMT*rt1.EXCHANGE_RATE/rt2.EXCHANGE_RATE                                --��    ���� = ���� * ��_���� /  �_����  
                                        
                                         when CUR1 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT > p_REPORT_DT    --���� �_��� <> �_��� � ��_��� <> �_��� � ���� > �_����, 
                                            then PAY_AMT*rt_rp1.EXCHANGE_RATE/rt_rp2.EXCHANGE_RATE                          --��    ���� = ���� * ��_����_�_���� /  �_����_�_���� 
                                         
                                         when CUR1 = s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT    --���� �_��� = �_��� � ��_��� <> �_��� � ���� <= �_����,
                                            then PAY_AMT*rt1.EXCHANGE_RATE                                                   --��    ���� = ���� * ��_����
                                         
                                         when CUR1 = s.base_currency and CUR2 <> s.base_currency and PAY_DT > p_REPORT_DT     --���� �_��� = �_��� � ��_��� <> �_��� � ���� > �_����, 
                                            then PAY_AMT*rt_rp1.EXCHANGE_RATE                                                --��    ���� = ���� * ��_����_�_����
                                         
                                         when CUR2 = s.base_currency and CUR1 <> s.base_currency and PAY_DT <= p_REPORT_DT    --���� �_��� <> �_��� � ��_��� = �_��� � ���� <= �_����,
                                            --then PAY_AMT*round(1/rt2.EXCHANGE_RATE,8)                                                   --��    ���� = ���� / �_����
                                            then PAY_AMT/rt2.EXCHANGE_RATE
                                       
                                         when CUR2 = s.base_currency and CUR1 <> s.base_currency and PAY_DT > p_REPORT_DT     --���� �_��� <> �_��� � ��_��� = �_��� � ���� > �_����,
                                            --then PAY_AMT*round(1/rt_rp2.EXCHANGE_RATE,8)                                                --��    ���� = ���� / �_����_�_����
                                            then PAY_AMT/rt_rp2.EXCHANGE_RATE                                               --��    ���� = ���� / �_����_�_����
                                        
                                         else PAY_AMT                                         --�����, ���� = ����.
                                         
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

      /*    FLOW_S_UNDERPAY_FACT as (
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
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)))                 -- ����� �������� �������� �� ��������� ������� � ����� ������������� ��� 'Leasing'
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
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)))                -- ����� �������� �������� �� ��������� ������� � ����� ������������� ��� 'Leasing'
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
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)))                 -- ����� �������� �������� �� ��������� ������� � ����� ������������� ��� 'Leasing'
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
                                                        and p_REPORT_DT BETWEEN BEGIN_DT and END_DT)))                -- ����� �������� �������� �� ��������� ������� � ����� ������������� ��� 'Leasing'
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
                /*            UNION ALL
                               select * 
                              from Flow_S_cur 
                              where TP = 'Supply_plan' 
                                and CBC_DESC = '��.3.1' and pay_dt > p_REPORT_DT   */                             
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
              /*              UNION ALL
                              select * 
                              from FLOW_S_UNDERPAY_FACT  */                            
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
                                         when CUR1 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT   --���� �_��� <> �_��� � ��_��� <> �_��� � ���� <= �_����, 
                                            then PAY_AMT*rt1.EXCHANGE_RATE/rt2.EXCHANGE_RATE                                --��    ���� = ���� * ��_���� /  �_����  
                                        
                                         when CUR1 <> s.base_currency and CUR2 <> s.base_currency and PAY_DT > p_REPORT_DT    --���� �_��� <> �_��� � ��_��� <> �_��� � ���� > �_����, 
                                            then PAY_AMT*rt_rp1.EXCHANGE_RATE/rt_rp2.EXCHANGE_RATE                          --��    ���� = ���� * ��_����_�_���� /  �_����_�_���� 
                                         
                                         when CUR1 = s.base_currency and CUR2 <> s.base_currency and PAY_DT <= p_REPORT_DT    --���� �_��� = �_��� � ��_��� <> �_��� � ���� <= �_����,
                                            then PAY_AMT*rt1.EXCHANGE_RATE                                                   --��    ���� = ���� * ��_����
                                         
                                         when CUR1 = s.base_currency and CUR2 <> s.base_currency and PAY_DT > p_REPORT_DT     --���� �_��� = �_��� � ��_��� <> �_��� � ���� > �_����, 
                                            then PAY_AMT*rt_rp1.EXCHANGE_RATE                                                --��    ���� = ���� * ��_����_�_����
                                         
                                         when CUR2 = s.base_currency and CUR1 <> s.base_currency and PAY_DT <= p_REPORT_DT    --���� �_��� <> �_��� � ��_��� = �_��� � ���� <= �_����,
                                            --then PAY_AMT*round(1/rt2.EXCHANGE_RATE,8)                                                   --��    ���� = ���� / �_����
                                            then PAY_AMT/rt2.EXCHANGE_RATE
                                       
                                         when CUR2 = s.base_currency and CUR1 <> s.base_currency and PAY_DT > p_REPORT_DT     --���� �_��� <> �_��� � ��_��� = �_��� � ���� > �_����,
                                            --then PAY_AMT*round(1/rt_rp2.EXCHANGE_RATE,8)                                                --��    ���� = ���� / �_����_�_����
                                            then PAY_AMT/rt_rp2.EXCHANGE_RATE  
                                        
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
                                  on rt_rp1.ex_rate_dt  = p_REPORT_DT 
                                  and s.CUR2= rt_rp1.CURRENCY_KEY 
                                  and rt_rp1.BASE_CURRENCY_KEY = s.base_currency
                                  and rt_rp1.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                               
                               left join dwh.EXCHANGE_RATES rt_rp2             -- �������� � ������ ����� �� ��������� ���� ����� �������� ���� � �� ������ ��������
                                  on rt_rp2.ex_rate_dt  = p_REPORT_DT 
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
     dm.u_log(p_proc => 'p_DM_XIRR_CALC_KIS',
           p_step => 'insert into dm_xirr_flow_orig',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted'); 
   commit;
   execute immediate 'drop index IX_DM_XIRR_FLOW';              -- �������� ������� ������� DM_XIRR_FLOW
   delete from dm_xirr_flow where report_dt = p_report_dt;      -- ������� ������� DM_XIRR_FLOW �� ������ �������� ������
     dm.u_log(p_proc => 'p_DM_XIRR_CALC_KIS',
           p_step => 'delete from dm_xirr_flow',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');   
   insert into dm_xirr_flow (
    
                 select * from (           
               
                        /* ��������� ������. ���� ������ ����������� ������ �1 �� �������� �������, �� ������������ "������������" ����� ������� �������
                           �� �������� ��������. ������� �������������� ������� �������� � ������������ ����� �� ������������� ������ �� ��� ���� (min_dt), 
                           ����� ������� �������� �� ������ �� ������ ������ ������������� ����� (��. FLOW). 
                        */
                      with   
                             
                  /* ���������. ������������ �������� �������� �� ���� ���������� ����������� �� ������ ����, ��������� �� ����� 
                     ����������. ��� 1-�� ����� ������, ���������� �� �������� ��������.
                  */            
                                 
                      --���
                                            FLG as  -------[25.01.2016:Savgurov]--��������� ��������� �� �������� ���-274,136
                                            (select l_key, 
                                                      case when sum (case when tp='Supply_fact' then 
                                                                  PAY_AMT_cur 
                                                                when tp='Supply_plan' then 
                                                                  PAY_AMT_cur*-1 
                                                                end) < 0 then 1 else 0 
                                                      end FLG
                                                  from dm_xirr_flow_orig
                                                  WHERE TP in ('Supply_fact','Supply_plan')
                                                  and snapshot_cd = '�������� ���'
                                                  and snapshot_dt = p_REPORT_DT
                                                  and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
                                                  and pay_dt <= p_REPORT_DT
                                                  group by l_key),
                      
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
                                            join ( select orig.l_key, 
                                                      sum (case when tp='Supply_fact' then 
                                                                  PAY_AMT_cur 
                                                                when tp='Supply_plan' then 
                                                                  PAY_AMT_cur*-1 
                                                          end) PAY_AMT_CuR_supply 
                                                  from dm_xirr_flow_orig orig
                                                  left join FLG F on F.l_key = orig.l_key
                                                  WHERE orig.TP in ('Supply_fact','Supply_plan')
                                                  and orig.snapshot_cd = '�������� ���'
                                                  and orig.snapshot_dt = p_REPORT_DT
                                                  and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
                                                  and orig.pay_dt <= case when F.FLG = 1 then p_REPORT_DT else to_date('01.01.2400','dd.mm.yyyy') end -------[25.01.2016:Savgurov]--��������� ��������� �� �������� ���-274,136
                                                  group by orig.l_key) cs
                                            on cs.l_key = fc.l_key
                                            left join FLG F on F.l_key = fc.l_key
                                            WHERE fc.TP in ('Supply_fact','Supply_plan')
                                              and fc.pay_dt <= case when F.FLG = 1 then p_REPORT_DT else to_date('01.01.2400','dd.mm.yyyy') end-------[25.01.2016:Savgurov]--��������� ��������� �� �������� ���-274,136
                                             and snapshot_cd = '�������� ���'
                                             and snapshot_dt = p_REPORT_DT
                                             and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
                                            group by  fc.L_key, fc.branch_key, cs.PAY_AMT_CuR_supply
                                      ),    

                  Flow_Underpay_FLG as                                                                              -- �������� ������������� ��������� ��������� (���������� �������� �������)
                                    ( 
                                      Select  
                                            SUM_FL.L_KEY,  
                                            (case when SUM_FL.PAY_AMT_FACT =  SUM_FL.PAY_AMT_PLAN or SUM_FL.PAY_AMT_CUR_FACT = SUM_FL.PAY_AMT_CUR_PLAN --[asavgurov:06.04.2016] ��������� ��� ����� ������, ����� ����� ����� � ����� �� �������� � ������ �������
                                                then 'N'
                                             else 'Y'
                                             end) FLG_UNDERPAY
                                      from (select l_key, 
                                                      sum (case when tp='Supply_fact' then PAY_AMT_CUR else 0 end) PAY_AMT_CUR_FACT,
                                                      sum (case when tp='Supply_plan' then PAY_AMT_CUR else 0 end) PAY_AMT_CUR_PLAN, 
                                                      sum (case when tp='Supply_fact' then PAY_AMT     else 0 end) PAY_AMT_FACT,
                                                      sum (case when tp='Supply_plan' then PAY_AMT     else 0 end) PAY_AMT_PLAN
                                                from dm_xirr_flow_orig
                                                WHERE TP in ('Supply_fact','Supply_plan')
                                                    and snapshot_cd = '�������� ���'
                                                    and snapshot_dt = p_REPORT_DT
                                                    and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
                                                    and pay_dt <= p_REPORT_DT ----- 26102015 ���������� NIL
                                                  group by L_KEY
                                               ) SUM_FL                                      
                                        ),  
                                        
                              Supply_eq as (select l_key as unpaid_l_key from dm_xirr_flow_orig   ----- 26102015 ����������� ������ ���������� � ���������� ���������
                                              where upper(tp) in ('SUPPLY_PLAN', 'SUPPLY_FACT') 
                                              and snapshot_cd = '�������� ���'
                                              and snapshot_dt = p_REPORT_DT
                                              and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
                                              group by l_key
                                              having sum(case when upper(tp) = 'SUPPLY_PLAN' then pay_amt else -pay_amt end) = 0),
            
                    /* ����������� ������ � ���������. ������������ �������� �������� �� ���� ���������� ����������� �� ������ ����, ��������� �� ����� 
                     ����������. ��� 1-�� ����� ������, ���������� �� �������� ��������.
                    */         
                             Flow_prev_1 as
                                            (
                                           SELECT
                                                    FU.L_KEY,
                                                    FU.branch_key,
                                                    p_REPORT_DT + 1 pay_dt ,
                                                    nvl(PAY_AMT_CuR, 0) summ,
                                                    PAY_AMT_CuR PAY_AMT
                                             FROM Flow_Underpay FU
                                             join Flow_Underpay_FLG FUF
                                             on FU.L_KEY=FUF.L_KEY 
                                             where PAY_AMT_CuR < 0
                                            and FUF.FLG_UNDERPAY in ('Y')
                                  
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
                                             and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
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
                                             FROM dm_xirr_flow_orig a, Supply_eq b
                                             WHERE snapshot_cd = '�������� ���'
                                             and snapshot_dt = p_REPORT_DT
                                             and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
                                             and TP = 'Supply_plan' and PAY_DT > p_REPORT_DT and unpaid_l_key is null
                                             and a.l_key = b.unpaid_l_key (+)-- 10/08/2015 MVV
                                             group by L_KEY, branch_key,  PAY_DT
                                             ),
            
                              FLOW_prev_v as
                                            (select L_KEY, 
                                                     branch_key, 
                                                     PAY_DT, 
                                                     sum (summ) summ, 
                                                     sum (PAY_AMT) pay_amt 
                                              from  Flow_prev_1
                                              where pay_dt = p_REPORT_DT + 1
                                              group by L_KEY, branch_key, PAY_DT
                                              
                                              union all
                                              
                                              select L_KEY, 
                                                     branch_key, 
                                                     PAY_DT, 
                                                     summ, 
                                                     PAY_AMT 
                                              from  Flow_prev_1
                                              where pay_dt != p_REPORT_DT + 1
                                            ),
                                            
                             -- [apolyakov 24.05.2016]: ��� ���������
                             FLOW_PREV_2 as
                                            (
                                              select L_KEY,
                                                   branch_key,
                                                   PAY_DT,
                                                   sum (summ) as summ,
                                                   sum (pay_amt) as pay_amt
                                              from FLOW_prev_v
                                              group by L_KEY,
                                                   branch_key,
                                                   PAY_DT
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
                                              from  FLOW_PREV_2
                                            ),
                              
                              balance as (                                                              -- ������������� �����
                                       
                                        select L_key,
                                        branch_key,
                                               PAY_DT,
                                               sum(summ) over (partition by l_key order by pay_dt) bal1,
                                               sum(pay_amt) over (partition by l_key order by pay_dt) bal2
                                        from FLOW_PREV_2
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
                                                sum (case when summ < 0 then summ else 0 end) as flag,
                                                abs(sum(case when summ >= 0 then summ else 0 end)) / decode (abs(sum(case when summ < 0 then summ else 0 end)), 0, -1, abs(sum(case when summ < 0 then summ else 0 end))) as div 
                                         from flow
                                         group by l_key
                                        ),
                              supply_fact_sum as
                                        (
                                        select 
                                              l_key
                                              from dm.dm_xirr_flow_orig
                                              where TP in ('Supply_fact')
                                                    and snapshot_cd = '�������� ���'
                                                    and snapshot_dt = p_REPORT_DT
                                                    and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
                                                    and pay_dt <= p_REPORT_DT
                                              group by l_key having sum(pay_amt_cur) = 0)
            
                              select 
                                    f.l_key,
                                    branch_key,
                                    PAY_DT,
                                    summ,
                                    sum_prev,
                                    case
                                      when
                                          d.div > 1 and s.l_key is null
                                              then 1
                                          else 0
                                      end,
                                    p_report_dt as report_dt,
                                    case 
                                      when
                                        flag = 0
                                          then -99
                                        else 0
                                      end as flag
                              from 
                                   flow f
                              inner join
                                   excptn_zero_div d
                                on f.l_key = d.l_key
                              left join supply_fact_sum s
                                on f.l_key = s.l_key
                              where 
                               (nvl(summ, 0) != 0 or nvl(sum_prev, 0) != 0)                  -- �� ������, ���� �� �������� �� ����������� �������� ���, ��� �������� �� �� ��������� � �����.
                            --  and d.div > 1
               ));
      dm.u_log(p_proc => 'p_DM_XIRR_CALC_KIS',
           p_step => 'insert into dm_xirr_flow',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');  
 
   commit;

   execute immediate 'CREATE INDEX IX_DM_XIRR_FLOW ON DM.dm_xirr_flow (L_KEY, REPORT_DT, EXCPTN_ZERO_DIV)';   -- �������� ������� 

   delete from DM_XIRR 
   where ODTTM = p_REPORT_DT
   and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
   and snapshot_cd = '�������� ���';  -- ������ ������ �� �������� ������ ��� ������ ������ ����������� � ������� DM_XIRR
     dm.u_log(p_proc => 'p_DM_XIRR_CALC_KIS',
           p_step => 'delete from DM_XIRR',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');   
   commit;
   --------------------------------------------------------------------------------  
   --
   -------------------------------------------------------------------------------- 
   execute immediate 'truncate table dm_xirr_flow_uniq';
   
   insert /*+ append */
   into dm_xirr_flow_uniq
   select rownum rid, a.*
   from (select distinct L_KEY, branch_key, flag 
               from  
               dm_xirr_flow
               where REPORT_DT = p_REPORT_DT               
               ) a;  
      dm.u_log(p_proc => 'p_DM_XIRR_CALC_KIS',
           p_step => '   insert /*+ append */  into dm_xirr_flow_uniq',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');     
   commit;
   
    for x in (
        select * from (
                        select nt, min(rid) lo_rid ,max(rid) hi_rid
                        from
                        (
                            select rid, ntile(100) over (order by rid) nt
                            from dm_xirr_flow_uniq
                        )
                        group by nt
        )
        where nt <= 100                
    ) loop
           DBMS_SCHEDULER.create_job(job_name                 =>'XIRR_JOB_'||x.nt,
                                      job_type                =>'PLSQL_BLOCK',-- UPPER('STORED_PROCEDURE'),
                                      job_action              => 'begin dm_xirr_chunk( to_date('''||to_char(p_REPORT_DT,'DD.MM.YYYY')||''', ''DD.MM.YYYY''),'|| x.lo_rid || ' , ' ||x.hi_rid||'  ); end;',
                                      number_of_arguments     => 0,
                                      enabled                 => TRUE,
                                      auto_drop               => TRUE);     
    end loop; 

 
    

/*     for x in (select distinct -- ���� �� ������� ����������
                      L_KEY, branch_key, flag 
               from  
               kav_dm_xirr_flow
               where REPORT_DT = p_REPORT_DT
             )
      loop
      /* ������� ����� � ����������� XIRR ��� ������� �� ���������� � ������� DM_XIRR
         nvl �� ��� ������, ���� ����� ����������� �������� ������ ����� �������� ��������... 
      */
       --dbms_output.put_line (to_char (x.L_KEY));
--       insert into kav_dm_xirr values (x.L_KEY, nvl(f_xirr_calc(x.L_KEY, p_REPORT_DT), -1), p_REPORT_DT, x.branch_key, '�������� ���', x.flag);
        --kav_p_into_xirr_tracing (x.L_KEY, p_REPORT_DT);
--      end loop;

    v_cur_ind := 1;

    begin
    loop
        select count(*)
            into v_cnt
            from user_objects
            where upper(OBJECT_NAME) like 'XIRR_JOB_%' 
            and rownum < 2;
        if v_cnt = 0 then exit;
        elsif
            v_cur_ind >= v_max_executions 
                then RAISE_APPLICATION_ERROR (-20000, 'Loading DM_XIRR failed. Please ask your administrator to fix the error');
        end if;
        v_cur_ind := v_cur_ind + 1;
        dbms_lock.sleep(5);
    end loop;
    end;    
    
--     for x in (select distinct -- ���� �� ������� ����������
--                      L_KEY, branch_key, flag 
--               from  
--               dm_xirr_flow
--               where REPORT_DT = p_REPORT_DT
--             )
--      loop
--      /* ������� ����� � ����������� XIRR ��� ������� �� ���������� � ������� DM_XIRR
--         nvl �� ��� ������, ���� ����� ����������� �������� ������ ����� �������� ��������... 
--      */
--       --dbms_output.put_line (to_char (x.L_KEY));
--       insert into dm_xirr values (x.L_KEY, nvl(f_xirr_calc(x.L_KEY, p_REPORT_DT), -1), p_REPORT_DT, x.branch_key, '�������� ���', x.flag);
--        p_into_xirr_tracing (x.L_KEY, p_REPORT_DT);
--      end loop;
 
   --delete from dm_xirr_flow where report_dt = p_report_dt;      -- ������� ������� DM_XIRR_FLOW �� ������ �������� ������
   commit;
 
END;
/

