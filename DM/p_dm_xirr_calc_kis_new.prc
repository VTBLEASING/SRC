CREATE OR REPLACE PROCEDURE DM.p_DM_XIRR_CALC_KIS_NEW(
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


delete from dm_xirr_flow_new where report_dt = p_report_dt;      -- ������� ������� DM_XIRR_FLOW �� ������ �������� ������
   insert into dm_xirr_flow_new (
    
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
                      FLG as
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
                                                  and orig.pay_dt <= case when F.FLG = 1 then p_REPORT_DT else to_date('01.01.2400','dd.mm.yyyy') end
                                                  group by orig.l_key) cs
                                            on cs.l_key = fc.l_key
                                            left join FLG F on F.l_key = fc.l_key
                                            WHERE fc.TP in ('Supply_fact','Supply_plan')
                                              and fc.pay_dt <= case when F.FLG = 1 then p_REPORT_DT else to_date('01.01.2400','dd.mm.yyyy') end
                                             and snapshot_cd = '�������� ���'
                                             and snapshot_dt = p_REPORT_DT
                                             and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
                                            group by  fc.L_key, fc.branch_key, cs.PAY_AMT_CuR_supply
                                      ),    

                  Flow_Underpay_FLG as                                                                              -- �������� ������������� ��������� ��������� (���������� �������� �������)
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
                    /* ��� ������� ������� ��������� �������� ������������� ����� (sum_prev), ������� � ����� ������������ � ������� �������� ��� "������������"
                    */
            
                              FLOW_prev as
                                            (select L_KEY, 
                                                     branch_key, 
                                                     PAY_DT, 
                                                     summ, 
                                                     sum (summ) over (partition by L_KEY order by pay_dt rows between unbounded preceding and current row) sum_prev,
                                                     PAY_AMT 
                                              from  FLOW_prev_v
                                            ),
                              
                              balance as (                                                              -- ������������� �����
                                       
                                        select L_key,
                                        branch_key,
                                               PAY_DT,
                                               sum(summ) over (partition by l_key order by pay_dt) bal1,
                                               sum(pay_amt) over (partition by l_key order by pay_dt) bal2
                                        from FLOW_prev_v
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
   commit;

   --execute immediate 'CREATE INDEX IX_DM_XIRR_FLOW_NEW ON DM.dm_xirr_flow_new (L_KEY, REPORT_DT, EXCPTN_ZERO_DIV)';   -- �������� ������� 

   delete from DM_XIRR_NEW 
   where ODTTM = p_REPORT_DT
   and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
   and snapshot_cd = '�������� ���';  -- ������ ������ �� �������� ������ ��� ������ ������ ����������� � ������� DM_XIRR
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
               dm_xirr_flow_new
               where REPORT_DT = p_REPORT_DT               
               ) a;  
   
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
                                      job_action              => 'begin dm_xirr_chunk_new( to_date('''||to_char(p_REPORT_DT,'DD.MM.YYYY')||''', ''DD.MM.YYYY''),'|| x.lo_rid || ' , ' ||x.hi_rid||'  ); end;',
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
 
   delete from dm_xirr_flow_new where report_dt = p_report_dt;      -- ������� ������� DM_XIRR_FLOW �� ������ �������� ������
   commit;
 
END;
/

