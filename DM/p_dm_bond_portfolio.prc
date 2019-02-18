CREATE OR REPLACE PROCEDURE DM.p_DM_BOND_PORTFOLIO (p_REPORT_DT in date)
IS

    v_CALC_NCD_AMT_sumr number;  
    v_CALC_NCD_AMT_cur number;
    
    v_FCT_SUM_FLOW_sumr number;
    v_FCT_SUM_FLOW_cur number;

    cursor cur_DM_BOND_PORTFOLIO is
    select  CALC_NCD_AMT, CALC_NCD_AMT_R
            ,FCT_SUM_FLOW, FCT_SUM_FLOW_R
            ,sum(CALC_NCD_AMT) over (order by 1 rows between unbounded preceding and current row) CALC_NCD_AMT_sum
            ,sum(FCT_SUM_FLOW) over (order by 1 rows between unbounded preceding and current row) FCT_SUM_FLOW_sum
            from DM_BOND_PORTFOLIO
                where snapshot_dt = p_REPORT_DT
                for update;

BEGIN

    v_CALC_NCD_AMT_sumr := 0;
    v_FCT_SUM_FLOW_sumr := 0;

delete from DM_BOND_PORTFOLIO where SNAPSHOT_DT = p_REPORT_DT;

insert into DM_BOND_PORTFOLIO (
                                SNAPSHOT_DT,
                                BOND_KEY,
                                CONTRACT_KEY,
                                ISSUE_VOLUME_NUM,
                                ISSUE_VOLUME_CNT,
                                BAL_AMT,
                                FAIR_VAL_AMT,
                                BUY_AMT,
                                NCD_AMT,
                                NCD_RATE,
                                QUANTITY_CNT,
                                BAL_QUANTITY_CNT,
                                FACTOR_AMT,
                                CALC_NCD_AMT,
                                PROCESS_KEY,
                                INSERT_DT,
                                FCT_SUM_FLOW,
                                CALC_NCD_AMT_R,
                                FCT_SUM_FLOW_R) 
                                
 --поток платежей для расчета НКД                 
 with fct_cur as 
(select CONTRACT_KEY, sum(nvl(fct.PAY_TERM_AMT,0)) sum_flow , max(fct.rate) keep(dense_rank first order by fct.pay_dt) as   rate 
                               from DWH.FACT_KS_FLOW FCT
                               where upper(GROUP_CD) like '%ОБЛИГАЦ%'
                               and fct.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                               and fct.pay_dt>p_REPORT_DT  
                               and fct.report_dt=p_REPORT_DT
                               --and fct.begin_dt <= p_REPORT_DT 
                               --and fct.end_dt > p_REPORT_DT 
                               group by CONTRACT_KEy),
                               
                               
     fct_prev  as (select CONTRACT_KEy,
                               max(fct.pay_dt) keep(dense_rank last order by fct.pay_dt) prev_pay_dt,
                               (p_REPORT_DT-max(fct.pay_dt) keep(dense_rank last order by fct.pay_dt)) term_dt,
                               max(fct.pay_dt) keep (dense_rank last order by fct.pay_dt) as last_pay_dt
                               from DWH.FACT_KS_FLOW FCT  
                               where upper(GROUP_CD) like '%ОБЛИГАЦ%' and fct.pay_dt<=p_REPORT_DT  
                               and fct.report_dt=p_REPORT_DT
                               and nvl(fct.PAY_INT_AMT,fct.PAY_IN_AMT) is not null
                               and fct.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                               --and fct.begin_dt <= p_REPORT_DT 
                               --and fct.end_dt > p_REPORT_DT                                
                               group by CONTRACT_KEy)
                               
                               
                               
                    --расчет промежуточной витрины по ценным бумагам BOND_PORTFOLIO
                    select 
                    p_REPORT_DT SNAPSHOT_DT,
                    BOND_KEY,
                    CONTRACT_KEY,
                    ISSUE_VOLUME_NUM,
                    ISSUE_VOLUME_CNT,
                    BAL_AMT,
                    FAIR_VAL_AMT,
                    BUY_AMT,
                    NCD_AMT,
                    NCD_RATE,
                    QUANTITY_CNT,
                    BAL_QUANTITY_CNT,
                    FACTOR_AMT,
                    CALC_NCD_AMT,
                    777 PROCESS_KEY,
                    sysdate INSERT_DT,
                    FCT_SUM_FLOW,
                    0 CALC_NCD_AMT_R,
                    0 FCT_SUM_FLOW_R
                    from 
                    (
                    
                    (select 
                    trade.BOND_KEY as BOND_KEY,
                    contr.ISSUE_VOLUME_NUM as ISSUE_VOLUME_NUM,
                    contr.BOND_CONTRACT_KEY as  CONTRACT_KEY,
                    port.ISSUE_VOLUME_CNT as ISSUE_VOLUME_CNT,
                    trade.BAL_AMT as BAL_AMT,
                    trade.FAIR_VAL_AMT as FAIR_VAL_AMT,
                    trade.BUY_AMT as BUY_AMT,
                    trade.NCD_AMT as NCD_AMT,
                    trade.NCD_RATE as NCD_RATE,
                    repo.QUANTITY_CNT as QUANTITY_CNT,
                    trade.QUANTITY_CNT BAL_QUANTITY_CNT,
                    --расчет коэффициента
                    case when (port.ISSUE_VOLUME_CNT -trade.QUANTITY_CNT - NVL(repo.QUANTITY_CNT,0))/ port.ISSUE_VOLUME_CNT is null then 1 
                         else (port.ISSUE_VOLUME_CNT -trade.QUANTITY_CNT - NVL(repo.QUANTITY_CNT,0))/ port.ISSUE_VOLUME_CNT 
                    end as FACTOR_AMT,
                    fct.CALC_NCD_AMT*(case when (port.ISSUE_VOLUME_CNT -trade.QUANTITY_CNT - NVL(repo.QUANTITY_CNT,0))/ port.ISSUE_VOLUME_CNT is null then 1 
                                           else (port.ISSUE_VOLUME_CNT -trade.QUANTITY_CNT - NVL(repo.QUANTITY_CNT,0))/ port.ISSUE_VOLUME_CNT 
                                      end) CALC_NCD_AMT,
                    FCT.sum_flow*(case when (port.ISSUE_VOLUME_CNT -trade.QUANTITY_CNT - NVL(repo.QUANTITY_CNT,0))/ port.ISSUE_VOLUME_CNT is null then 1 
                                       else (port.ISSUE_VOLUME_CNT -trade.QUANTITY_CNT - NVL(repo.QUANTITY_CNT,0))/ port.ISSUE_VOLUME_CNT 
                                  end) +
                    fct.CALC_NCD_AMT*(case when (port.ISSUE_VOLUME_CNT -trade.QUANTITY_CNT - NVL(repo.QUANTITY_CNT,0))/ port.ISSUE_VOLUME_CNT is null then 1 
                                           else (port.ISSUE_VOLUME_CNT -trade.QUANTITY_CNT - NVL(repo.QUANTITY_CNT,0))/ port.ISSUE_VOLUME_CNT 
                                      end) FCT_SUM_FLOW
                    from
                    (select 
                               FCT_CUR.CONTRACT_KEY,
                               FCT_CUR.sum_flow,
                               case when to_char(last_pay_dt, 'yyyy') = to_char(p_REPORT_DT, 'yyyy') 
                                    then (case when mod(to_number(to_char(last_pay_dt, 'yyyy')), 4) = 0 
                                          then FCT_CUR.sum_flow*FCT_CUR.rate*fct_prev.term_dt/366 
                                          else FCT_CUR.sum_flow*FCT_CUR.rate*fct_prev.term_dt/365 end) 
                                    else (case when mod(to_number(to_char(last_pay_dt, 'yyyy')), 4) = 0
                                          then (FCT_CUR.sum_flow*FCT_CUR.rate*(trunc(p_REPORT_DT, 'yyyy') - 1 - last_pay_dt)/366) 
                                                  + (FCT_CUR.sum_flow*FCT_CUR.rate*(p_REPORT_DT - trunc(p_REPORT_DT, 'yyyy') + 1)/365)
                                          else (case when mod(to_number(to_char(p_REPORT_DT, 'yyyy')), 4) = 0 
                                                      then (FCT_CUR.sum_flow*FCT_CUR.rate*(trunc(p_REPORT_DT, 'yyyy') - 1 - last_pay_dt)/365) 
                                                            + (FCT_CUR.sum_flow*FCT_CUR.rate*(p_REPORT_DT - trunc(p_REPORT_DT, 'yyyy') + 1)/366) 
                                                      else FCT_CUR.sum_flow*FCT_CUR.rate*fct_prev.term_dt/365 end)
                                          end)
                                    end as CALC_NCD_AMT
                               --FCT_CUR.sum_flow*FCT_CUR.rate*fct_prev.term_dt/365 as CALC_NCD_AMT
                               from   fct_cur,fct_prev   
                               where fct_cur.CONTRACT_KEy=fct_prev.CONTRACT_KEy(+)
                               ) fct
                    left join 
                    --справочник соответствия сделок и бумаг для опр.номера выпуска
                    (select BOND_CONTRACT_KEY,CONTRACT_cd, ISIN_CD, ISSUE_VOLUME_NUM from dwh.BONDS_CONTRACT 
                               where BEGIN_DT<=p_REPORT_DT
                               AND END_DT>p_REPORT_DT
                               ) contr
                     on contr.BOND_CONTRACT_KEY=fct.CONTRACT_KEY  
                     
                    --справочник портфель ЦБ для определения объема выпуска
                    left join 
                    (select BOND_KEY, ISSUE_VOLUME_CNT, 
                    ISIN_CD from dwh.BONDS_PORTFOLIO
                    where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')) port                    
                    on port.ISIN_CD=contr.ISIN_CD                    
                    
                    left join                                       
                    (select BOND_KEY, BAL_AMT, FAIR_VAL_AMT,
                      BUY_AMT,
                      NCD_AMT,
                      NCD_RATE,
                      QUANTITY_CNT
                      from dwh.BONDS_TRADE bt
                      where VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                      and bt.status_dt=p_REPORT_DT
                UNION ALL
                     Select BOND_KEY, null, null, null, null, null, QUANTITY_CNT  
                     from dwh.BONDS_TRADE_BO
                      )
                    trade
                    on trade.BOND_KEY=port.BOND_KEY
   
                    --справочник РЕПО
                    left join
                    (select BOND_KEY, QUANTITY_CNT from dwh.BONDS_REPO
                               where START_DT<=p_REPORT_DT
                               AND END_DT>p_REPORT_DT
                               and VALID_TO_DTTM=to_date('01.01.2400','dd.mm.yyyy')
                               ) repo
                    on  trade.BOND_KEY=repo.BOND_KEY
                    )
                    ) 
                    ;            

    -------------------------------------------------------------------------------- 
    -- округление значений
    --------------------------------------------------------------------------------         
      
    for rec_DM_BOND in cur_DM_BOND_PORTFOLIO loop
        if rec_DM_BOND.CALC_NCD_AMT = 0 
                then v_CALC_NCD_AMT_cur := 0;
        elsif round(rec_DM_BOND.CALC_NCD_AMT_sum/1000000,1) - v_CALC_NCD_AMT_sumr < 0  
                then v_CALC_NCD_AMT_cur := round(rec_DM_BOND.CALC_NCD_AMT/1000000,1);
        elsif round(rec_DM_BOND.CALC_NCD_AMT_sum/1000000,1) <> (v_CALC_NCD_AMT_sumr + round(rec_DM_BOND.CALC_NCD_AMT_sum/1000000,1)) 
                then v_CALC_NCD_AMT_cur := round(rec_DM_BOND.CALC_NCD_AMT_sum/1000000,1) -  v_CALC_NCD_AMT_sumr;
        else v_CALC_NCD_AMT_cur:= round(rec_DM_BOND.CALC_NCD_AMT/1000000,1);            
        end if;      
        v_CALC_NCD_AMT_sumr := v_CALC_NCD_AMT_sumr + v_CALC_NCD_AMT_cur;    
        --------------------------------------------------------------------------------
        if rec_DM_BOND.FCT_SUM_FLOW = 0 
                then v_FCT_SUM_FLOW_cur := 0;                  
        elsif round(rec_DM_BOND.FCT_SUM_FLOW_sum/1000000,1) - v_FCT_SUM_FLOW_sumr < 0  
                then v_FCT_SUM_FLOW_cur := round(rec_DM_BOND.FCT_SUM_FLOW/1000000,1);
        elsif round(rec_DM_BOND.FCT_SUM_FLOW_sum/1000000,1) <> (v_FCT_SUM_FLOW_sumr + round(rec_DM_BOND.FCT_SUM_FLOW_sum/1000000,1)) 
                then v_FCT_SUM_FLOW_cur := round(rec_DM_BOND.FCT_SUM_FLOW_sum/1000000,1) -  v_FCT_SUM_FLOW_sumr;
        else v_FCT_SUM_FLOW_cur:= round(rec_DM_BOND.FCT_SUM_FLOW/1000000,1);            
        end if;      
        v_FCT_SUM_FLOW_sumr := v_FCT_SUM_FLOW_sumr + v_FCT_SUM_FLOW_cur;   

        update DM_BOND_PORTFOLIO
            set CALC_NCD_AMT_R = v_CALC_NCD_AMT_cur,
                FCT_SUM_FLOW_R = v_FCT_SUM_FLOW_cur
                    where current of cur_DM_BOND_PORTFOLIO;
     end loop;

                  
                  commit;
end;
/

