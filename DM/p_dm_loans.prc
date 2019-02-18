CREATE OR REPLACE PROCEDURE DM.p_DM_LOANS (
    p_REPORT_DT date
)
is
    v_PROSR_sumr number;  
    v_PROSR_cur number;
    
    v_TEK_sumr number;
    v_TEK_cur number;
    
    v_TEK_PROSR_sumr number;
    v_TEK_PROSR_cur  number;
    
    v_PROSR_REZ_sumr number;
    v_PROSR_REZ_cur number;
    
    v_TEK_REZ_sumr number;
    v_TEK_REZ_cur number;
    
    v_TEK_PROSR_REZ_sumr number;
    v_TEK_PROSR_REZ_cur number;
    
    v_SUM1_sumr number;
    v_SUM1_cur number;
    
    v_SUM2_sumr number;
    v_SUM2_cur number;

    v_SUM3_sumr number;
    v_SUM3_cur number;

    v_SUM4_sumr number;
    v_SUM4_cur number;

    v_SUM5_sumr number;
    v_SUM5_cur number;
    
    v_ZADOLJ_RUB_sumr number;
    v_ZADOLJ_RUB_cur number;

    cursor cur_DM_LOANS is
    select  PROSR, PROSR_R
            ,TEK, TEK_R
            ,TEK_PROSR , TEK_PROSR_R
            ,PROSR_REZ , PROSR_REZ_R
            ,TEK_REZ , TEK_REZ_R
            ,TEK_PROSR_REZ, TEK_PROSR_REZ_R
            ,SUM1, SUM1_R
           ,SUM2, SUM2_R
            ,SUM3, SUM3_R
            ,SUM4, SUM4_R
            ,SUM5, SUM5_R
            ,SUM_VAL,SUM_REZ
            ,ZADOLJ_RUB, ZADOLJ_RUB_R
            ,sum(PROSR) over (order by 1 rows between unbounded preceding and current row) PROSR_sum
            ,sum(TEK) over (order by 1 rows between unbounded preceding and current row) TEK_sum
            ,sum(TEK_PROSR) over (order by 1 rows between unbounded preceding and current row) TEK_PROSR_sum
            ,sum(PROSR_REZ) over (order by 1 rows between unbounded preceding and current row) PROSR_REZ_sum
            ,sum(TEK_REZ) over (order by 1 rows between unbounded preceding and current row) TEK_REZ_sum
            ,sum(TEK_PROSR_REZ) over (order by 1 rows between unbounded preceding and current row) TEK_PROSR_REZ_sum
            ,sum(SUM1) over (order by 1 rows between unbounded preceding and current row) SUM1_sum
            ,sum(SUM2) over (order by 1 rows between unbounded preceding and current row) SUM2_sum
            ,sum(SUM3) over (order by 1 rows between unbounded preceding and current row) SUM3_sum
            ,sum(SUM4) over (order by 1 rows between unbounded preceding and current row) SUM4_sum
            ,sum(SUM5) over (order by 1 rows between unbounded preceding and current row) SUM5_sum
            ,sum(ZADOLJ_RUB) over (order by 1 rows between unbounded preceding and current row) ZADOLJ_RUB_sum
            ,PROVISIONS_RATE
            from DM_LOANS
                where snapshot_dt = p_REPORT_DT
                for update;
                
                
BEGIN
    dm.u_log(p_proc => 'DM.p_DM_LOANS',
           p_step => 'INPUT PARAMS',
           p_info => /*'p_contract_key:'||p_contract_key||*/'p_REPORT_DT:'||p_REPORT_DT); 
    v_PROSR_sumr := 0;
    v_PROSR_sumr := 0;
    v_TEK_sumr := 0;
    v_TEK_PROSR_sumr := 0;
    v_PROSR_REZ_sumr := 0;
    v_TEK_REZ_sumr := 0;
    v_TEK_PROSR_REZ_sumr := 0;
    v_SUM1_sumr := 0;
    v_SUM2_sumr := 0;
    v_SUM3_sumr := 0;
    v_SUM4_sumr := 0;
    v_SUM5_sumr := 0;
    v_ZADOLJ_RUB_sumr := 0;

  /* Процедура расчета витрины DM_LOANS_ORIG полностью.
     В качестве входного параметра подается дата составления отчета 
  */

delete from DM.DM_LOANS
where snapshot_dt = p_REPORT_DT;
  dm.u_log(p_proc => 'DM.p_DM_LOANS',
           p_step => 'delete from DM.DM_LOANS',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted'); 
           
    insert into DM.DM_LOANS
    (      SNAPSHOT_DT,
           CONTRACT_ID_CD,
           CONTRACT_NUM,
           CLIENT_KEY,
           CONTRACT_KEY,
           CLIENT_NAM,
           CLIENT_ID,
           GRF_GROUP_NAM,
           FINAL_GROUP_NAM,
           PROCHIE_GROUP_NAM,
           GROUP_RU_NAM,
           BUSINESS_CATEGORY_KEY,
           BUSINESS_CAT_RU_NAM,
           ACTIVITY_TYPE_CD,
           ACTIVITY_TYPE_RU_DESC,
           ECONOMIC_SECTOR_RU_NAM,
           RF_GOV_TYPE,
           START_DT,
           END_DT,
           OVERDUE_DT,
           OVERDUE_CNT,
           BUCKET_L11,
           BUCKET_L16,
           OBES_FLG,
           NPL_FLG,
           M7_CD,
           INSTRUMENT_RU_NAM,
           MEMBER_KEY,
           TERM_AMT,
           TERM_AMT_RUB,
           OVERDUE_AMT,
           OVERDUE_AMT_RUB,
           PARAM_VAL,
           PAY_AMT_RUB,
           XIRR_RATE,
           CURRENCY_KEY,
           CURRENCY_LETTER_CD,
           LOSS_AMT,
           PROVISIONS_AMT_YEAR,
           PROVISIONS_AMT_YEAR_RUB,
           PROVISIONS_AMT,
           PROVISIONS_AMT_RUB,
           PROVISIONS_RATE_Y,
          PROVISIONS_RATE,
           PL_EFF_M,
           PL_EFF_KV,
           AVG_EXCHANGE_RATE,
           KV_AVG_EXCHANGE_RATE,
           TR_EFF_M,
           COUNTRY_ISO3_CD,
           ZADOLJ_RUB,
           PROSR,
           TEK,
           TEK_PROSR,
           PROSR_REZ,
           TEK_REZ,
           TEK_PROSR_REZ,
           SUM1,
           SUM2,
           SUM3,
           SUM4,
           SUM5,
           PROSR_R,
           TEK_R,
           TEK_PROSR_R,
           PROSR_REZ_R,
           TEK_REZ_R,
           TEK_PROSR_REZ_R,
           SUM1_R,
           SUM2_R,
           SUM3_R,
           SUM4_R,
           SUM5_R,
           SUM_VAL,
           SUM_REZ,
           ZADOLJ_RUB_R,
           INSERT_DT,
           CLIENT_CD,
           INN
    )
       WITH CGP as (Select A.SNAPSHOT_DT, A.CONTRACT_NUM, A.CONTRACT_KEY, A.CLIENT_NAM, A.CLIENT_KEY, A.BUSINESS_CATEGORY_KEY, A.START_DT, A.END_DT, A.OVERDUE_DT, A.XIRR_RATE, A.CURRENCY_KEY, A.TERM_AMT,
                    /*Comment by Zanozin */
                    case when A.CONTRACT_KEY = 111525 then A.OVERDUE_AMT   ----------------------------Исключаем НДС по всем договорам кроме 116/01-11
                    else a.overdue_vat_free_amt--round(A.OVERDUE_AMT/(1+case when VAT_CON.VAT_RATE is not null then VAT_CON.VAT_RATE else VAT.VAT_RATE end),2)
                    end
                      OVERDUE_AMT,
                     A.CLIENT_ID, A.ACTIVITY_TYPE_KEY
                    
                    from DM.DM_CGP A
                        /*Comment by Zanozin left join DWH.VAT VAT on A.BRANCH_KEY = VAT.BRANCH_KEY 
                                              and VAT.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy') 
                                              and p_REPORT_DT >= VAT.begin_dt 
                                              and p_REPORT_DT <= VAT.end_dt
                         left join DWH.VAT_CONTRACT VAT_CON on A.CONTRACT_KEY = VAT_CON.CONTRACT_KEY 
                                                           and VAT_CON.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy') 
                                                           and p_REPORT_DT >= VAT_CON.begin_dt 
                                                           and p_REPORT_DT <= VAT_CON.end_dt
                    where A.snapshot_dt = p_REPORT_DT */),
     PROVISIONS as (Select distinct A.snapshot_dt, A.contract_key, C.client_key, TRANCHE_NUM, IPO_DRIVE_FLG, nvl(BAL_AMT,0)-nvl(LOSS.LOSS_AMT,0) BAL_AMT, CONTRACT_REG_TYPE, IPO_FLG, IPO_TYPE, PROVISIONS_AMT
                         from DWH.FACT_PROVISIONS a
                              inner join DM.DM_CGP C on a.contract_key = C.contract_key and A.snapshot_dt = C.snapshot_dt
                              left join DWH.FACT_PROVISIONS_LOSS LOSS on C.client_key = LOSS.client_key and LOSS.snapshot_dt = A.snapshot_dt and LOSS.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
                         where C.client_key is not null and a.valid_to_dttm = TO_DATE('01.01.2400', 'dd.mm.yyyy')),
    AVG_EXCHANGE_RATE as (Select CURRENCY_KEY, SUM(EXCHANGE_RATE), count(*), SUM(EXCHANGE_RATE)/count(*) AVG_EXCHANGE_RATE
                           from (Select CURRENCY_KEY, EXCHANGE_RATE
                                 from dwh.EXCHANGE_RATES
                                 where VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
                                 and ex_rate_dt >= TRUNC(p_REPORT_DT, 'MONTH')
                                 and ex_rate_dt <= p_REPORT_DT
                                 and BASE_CURRENCY_KEY = 125)
                           group by CURRENCY_KEY),
  KV_AVG_EXCHANGE_RATE as (Select CURRENCY_KEY, SUM(EXCHANGE_RATE), count(*), SUM(EXCHANGE_RATE)/count(*) KV_AVG_EXCHANGE_RATE
                           from (Select CURRENCY_KEY, EXCHANGE_RATE
                                 from dwh.EXCHANGE_RATES
                                 where VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
                                 and ex_rate_dt >= TRUNC(p_REPORT_DT, 'Q')
                                 and ex_rate_dt <= p_REPORT_DT
                                 and BASE_CURRENCY_KEY = 125)
                           group by CURRENCY_KEY),
          NEXT_PAY_AMT as (Select *
                           from (Select contract_key, pay_amt, row_number() OVER (partition BY contract_key ORDER BY pay_dt ASC) AS rn
                                 from DM.DM_REPAYMENT_SCHEDULE
                                 where snapshot_dt = p_REPORT_DT
                                 and pay_dt > p_REPORT_DT)
                           where rn = 1),
              TERM_CGP as (Select contract_key
                           from dm.dm_cgp
                           where snapshot_dt = p_REPORT_DT
                           and TERM_AMT > 0),
                  SUM1 as (Select CONTRACT_KEY, sum(NIL_AMT) SUM1
                           from DM.DM_REPAYMENT_SCHEDULE 
                           where snapshot_dt = p_REPORT_DT
                             and pay_dt <= ADD_MONTHS(p_REPORT_DT, +1)
                             and NIL_AMT > 0 
                             and CONTRACT_KEY in (Select contract_key from TERM_CGP) -- сделано чтобы исключить разницу в сумме nil из RS и срочки из КГП при перенайме
                           group by CONTRACT_KEY),
                  SUM2 as (Select CONTRACT_KEY, sum(NIL_AMT) SUM2
                           from DM.DM_REPAYMENT_SCHEDULE 
                           where snapshot_dt = p_REPORT_DT
                             and pay_dt > ADD_MONTHS(p_REPORT_DT, +1)
                             and pay_dt <= ADD_MONTHS(p_REPORT_DT, +3)
                             and NIL_AMT > 0
                             and CONTRACT_KEY in (Select contract_key from TERM_CGP) -- сделано чтобы исключить разницу в сумме nil из RS и срочки из КГП при перенайме
                           group by CONTRACT_KEY),
                  SUM3 as (Select CONTRACT_KEY, sum(NIL_AMT) SUM3
                           from DM.DM_REPAYMENT_SCHEDULE 
                           where snapshot_dt = p_REPORT_DT
                             and pay_dt > ADD_MONTHS(p_REPORT_DT, +3)
                             and pay_dt <= ADD_MONTHS(p_REPORT_DT, +6)
                             and NIL_AMT > 0
                             and CONTRACT_KEY in (Select contract_key from TERM_CGP) -- сделано чтобы исключить разницу в сумме nil из RS и срочки из КГП при перенайме
                           group by CONTRACT_KEY), 
                  SUM4 as (Select CONTRACT_KEY, sum(NIL_AMT) SUM4
                           from DM.DM_REPAYMENT_SCHEDULE 
                           where snapshot_dt = p_REPORT_DT
                             and pay_dt > ADD_MONTHS(p_REPORT_DT, +6)
                             and pay_dt <= ADD_MONTHS(p_REPORT_DT, +12)
                             and NIL_AMT > 0
                             and CONTRACT_KEY in (Select contract_key from TERM_CGP) -- сделано чтобы исключить разницу в сумме nil из RS и срочки из КГП при перенайме
                           group by CONTRACT_KEY),
                  SUM5 as (Select CONTRACT_KEY, sum(NIL_AMT) SUM5
                           from DM.DM_REPAYMENT_SCHEDULE 
                           where snapshot_dt = p_REPORT_DT
                             and pay_dt > ADD_MONTHS(p_REPORT_DT, +12)
                             and NIL_AMT > 0
                             and CONTRACT_KEY in (Select contract_key from TERM_CGP) -- сделано чтобы исключить разницу в сумме nil из RS и срочки из КГП при перенайме
                           group by CONTRACT_KEY),
             L16_GROUP as (Select case when GR.GRF_GROUP_NAM is not null and GR.GRF_GROUP_NAM <> 'OTHERS' then GR.GRF_GROUP_NAM
                                       when E.GROUP_RU_NAM is not null then E.GROUP_RU_NAM
                                  else to_char(A.CLIENT_KEY) 
                                  end L16_GROUP_NAM, 
                                  sum((A.TERM_AMT+A.OVERDUE_AMT)*M.EXCHANGE_RATE) L16_SUM
                           from dm.dm_cgp A
                                left join DM.DM_CLIENTS C on A.client_key = C.client_key and C.snapshot_dt = p_REPORT_DT
                                left join DWH.GROUPS E on C.GROUP_KEY = E.GROUP_KEY and E.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
                                left join dwh.GRF_GROUPS GR on E.GRF_GROUP_KEY = GR.GRF_GROUP_KEY and GR.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
                                left join DWH.EXCHANGE_RATES M on A.CURRENCY_KEY = M.CURRENCY_KEY 
                                                              and M.ex_rate_dt = p_REPORT_DT
                                                              and M.BASE_CURRENCY_KEY = 125 
                                                              and M.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
                           where A.snapshot_dt = p_REPORT_DT
                           group by case when GR.GRF_GROUP_NAM is not null and GR.GRF_GROUP_NAM <> 'OTHERS' then GR.GRF_GROUP_NAM
                                         when E.GROUP_RU_NAM is not null then E.GROUP_RU_NAM
                                         else to_char(A.CLIENT_KEY) end),
               NIL_AMT as (Select *
                           from (Select contract_key, nil_amt*M.EXCHANGE_RATE nil_amt_rub, row_number() OVER (partition BY contract_key ORDER BY pay_dt ASC) AS rn
                                 from DM.DM_REPAYMENT_SCHEDULE A
                                      left join DWH.EXCHANGE_RATES M on A.CURRENCY_KEY = M.CURRENCY_KEY 
                                                              and M.ex_rate_dt = p_REPORT_DT
                                                              and M.BASE_CURRENCY_KEY = 125 
                                                              and M.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
                                 where snapshot_dt = p_REPORT_DT
                                 and pay_dt > p_REPORT_DT and nvl(A.nil_amt,0) > 0)
                           where rn = 1)
Select distinct 
  A.SNAPSHOT_DT
, B.CONTRACT_ID_CD
, A.CONTRACT_NUM
, A.CLIENT_KEY
, A.CONTRACT_KEY
, A.CLIENT_NAM
-- [apolyakov 1301017]: добавление НСИ по клиентам из КГП
, A.CLIENT_ID
, case when GR.GRF_GROUP_NAM is null then 'OTHERS' else GR.GRF_GROUP_NAM end GRF_GROUP_NAM
, case when GR.GRF_GROUP_NAM is not null and GR.GRF_GROUP_NAM <> 'OTHERS' then GR.GRF_GROUP_NAM
       when (GR.GRF_GROUP_NAM is null or GR.GRF_GROUP_NAM = 'OTHERS') and LG.L16_SUM < 10000000 then 'OTHERS - each less than 10 MRUR'
       else 'OTHERS' end FINAL_GROUP_NAM
, case when (GR.GRF_GROUP_NAM is null or GR.GRF_GROUP_NAM = 'OTHERS') and LG.L16_SUM < 10000000 then null
       when E.GROUP_RU_NAM is not null then E.GROUP_RU_NAM
       else 'OTHERS' end PROCHIE_GROUP_NAM
, E.GROUP_RU_NAM
, A.BUSINESS_CATEGORY_KEY
, F.BUSINESS_CAT_RU_NAM
, J.ACTIVITY_TYPE_CD
, J.ACTIVITY_TYPE_RU_DESC
, D.ECONOMIC_SECTOR_RU_NAM
, case when RP.RELATED_PARTIES_RU_NAM is not null then RP.RELATED_PARTIES_RU_NAM else 'Прочие несвязанные стороны' end RF_GOV_TYPE
, A.START_DT
, A.END_DT
, A.OVERDUE_DT
, A.snapshot_dt - A.OVERDUE_DT OVERDUE_CNT
, case when A.snapshot_dt - A.OVERDUE_DT <= 30 then '01.[1-30]'
       when A.snapshot_dt - A.OVERDUE_DT >= 31 and A.snapshot_dt - A.OVERDUE_DT <= 60 then '02.[31-60]'
       when A.snapshot_dt - A.OVERDUE_DT >= 61 and A.snapshot_dt - A.OVERDUE_DT <= 90 then '03.[61-90]'
       when A.snapshot_dt - A.OVERDUE_DT >= 91 and A.snapshot_dt - A.OVERDUE_DT <= 180 then '04.[91-180]'
       when A.snapshot_dt - A.OVERDUE_DT >= 181 and A.snapshot_dt - A.OVERDUE_DT <= 360 then '05.[181-360]'
       when A.snapshot_dt - A.OVERDUE_DT >= 361 then '06.[360+]' end BUCKET_L11
, case when A.snapshot_dt - A.OVERDUE_DT <= 30 then '01.[1-30]'
       when A.snapshot_dt - A.OVERDUE_DT >= 31 and A.snapshot_dt - A.OVERDUE_DT <= 90 then '02.[31-90]'
       when A.snapshot_dt - A.OVERDUE_DT >= 91 and A.snapshot_dt - A.OVERDUE_DT <= 180 then '03.[91-180]'
       when A.snapshot_dt - A.OVERDUE_DT >= 181 and A.snapshot_dt - A.OVERDUE_DT <= 360 then '04.[181-360]'
       when A.snapshot_dt - A.OVERDUE_DT >= 361 then '05.[360+]' end BUCKET_L16
, case when (case when nvl(L.BAL_AMT,0) = 0 then 0 else nvl(((L.PROVISIONS_AMT/L.BAL_AMT)*100),0) end) >= 20 then 1 else 0 end OBES_FLG_FLG
, case when (case when nvl(L.BAL_AMT,0) = 0 then 0 else nvl(((L.PROVISIONS_AMT/L.BAL_AMT)*100),0) end) >= 20 and A.snapshot_dt - A.OVERDUE_DT > 90 then 1 else 0 end NPL_FLG
, case when F.BUSINESS_CATEGORY_KEY = 1 then '10630'
       when F.BUSINESS_CATEGORY_KEY = 2 then '10630'
      when F.BUSINESS_CATEGORY_KEY = 3 then '10610'
  else 'Не определено' END M7_CD
, case when F.BUSINESS_CATEGORY_KEY = 1 then 'Кредиты малому бизнесу'
       when F.BUSINESS_CATEGORY_KEY = 2 then 'Кредиты среднему бизнесу'
       when F.BUSINESS_CATEGORY_KEY = 3 then 'Кредиты крупному бизнесу'
  else 'Не определено' END INSTRUMENT_RU_NAM
, C.MEMBER_KEY
, A.TERM_AMT
, (A.TERM_AMT*M.EXCHANGE_RATE) TERM_AMT_RUB
, A.OVERDUE_AMT
, (A.OVERDUE_AMT*M.EXCHANGE_RATE) OVERDUE_AMT_RUB
, (Select PARAM_VAL from DWH.REF_PARAMS 
   where PARAM_CD = 'MIN_OVD' 
   and VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
   and begin_dt <= p_REPORT_DT
   and end_dt > p_REPORT_DT
   ) PARAM_VAL
, (O.pay_amt*M.EXCHANGE_RATE) PAY_AMT_RUB
, (A.XIRR_RATE*100) XIRR_RATE
, A.CURRENCY_KEY
, S.CURRENCY_LETTER_CD
, LOSS.LOSS_AMT
, U.PROVISIONS_AMT PROVISIONS_AMT_YEAR
, (U.PROVISIONS_AMT*W.EXCHANGE_RATE) PROVISIONS_AMT_YEAR_RUB
, L.PROVISIONS_AMT
, (L.PROVISIONS_AMT*M.EXCHANGE_RATE) PROVISIONS_AMT_RUB
, case when nvl(U.BAL_AMT,0) = 0 then 0 else nvl(((U.PROVISIONS_AMT/U.BAL_AMT)*100),0) end PROVISIONS_RATE_Y
, case when nvl(L.BAL_AMT,0) = 0 then 0 else nvl(((L.PROVISIONS_AMT/L.BAL_AMT)*100),0) end PROVISIONS_RATE
, (L.PROVISIONS_AMT-T.PROVISIONS_AMT)*P.AVG_EXCHANGE_RATE PL_EFF_M
, (L.PROVISIONS_AMT-T.PROVISIONS_AMT)*R.KV_AVG_EXCHANGE_RATE PL_EFF_KV
, P.AVG_EXCHANGE_RATE
, R.KV_AVG_EXCHANGE_RATE
, (T.PROVISIONS_AMT*Y.EXCHANGE_RATE)+((L.PROVISIONS_AMT-T.PROVISIONS_AMT)*P.AVG_EXCHANGE_RATE)-(L.PROVISIONS_AMT*M.EXCHANGE_RATE) TR_EFF_M
, X.COUNTRY_ISO3_CD
, ((A.TERM_AMT+A.OVERDUE_AMT)*M.EXCHANGE_RATE) ZADOLJ_RUB
-----------------------------------------------------------------------
, case when nvl(A.TERM_AMT, 0) = 0 then nvl(A.OVERDUE_AMT*M.EXCHANGE_RATE, 0)
       else 
           case when case when nvl(NA.nil_amt_rub,0) = 0 then 0 
                          else nvl(A.OVERDUE_AMT*M.EXCHANGE_RATE, 0)/NA.nil_amt_rub 
                     end > (Select PARAM_VAL/100 from DWH.REF_PARAMS 
                            where PARAM_CD = 'MIN_OVD' 
                            and begin_dt <= p_REPORT_DT
                            and end_dt > p_REPORT_DT
                            and VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')) then (A.OVERDUE_AMT*M.EXCHANGE_RATE) 
                else 0
           end 
  end PROSR
-----------------------------------------------------------------------
, case when case when case when nvl(A.TERM_AMT, 0) = 0 then nvl(A.OVERDUE_AMT*M.EXCHANGE_RATE, 0)
                           else 
                               case when case when nvl(NA.nil_amt_rub,0) = 0 then 0 
                                              else nvl(A.OVERDUE_AMT*M.EXCHANGE_RATE, 0)/NA.nil_amt_rub 
                                         end > (Select PARAM_VAL/100 from DWH.REF_PARAMS 
                                                where PARAM_CD = 'MIN_OVD' 
                                                and begin_dt <= p_REPORT_DT
                                                and end_dt > p_REPORT_DT
                                                and VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')) then (A.OVERDUE_AMT*M.EXCHANGE_RATE) 
                                    else 0
                                end 
                      end = 0 then 0 
                 else (A.TERM_AMT*M.EXCHANGE_RATE) 
             end = 0 then (A.TERM_AMT*M.EXCHANGE_RATE) 
      else 0 
  end TEK
-----------------------------------------------------------------------
, case when case when nvl(A.TERM_AMT, 0) = 0 then nvl(A.OVERDUE_AMT*M.EXCHANGE_RATE, 0)
                 else 
                     case when case when nvl(NA.nil_amt_rub,0) = 0 then 0 
                                    else nvl(A.OVERDUE_AMT*M.EXCHANGE_RATE, 0)/NA.nil_amt_rub
                               end > (Select PARAM_VAL/100 from DWH.REF_PARAMS 
                                      where PARAM_CD = 'MIN_OVD' 
                                      and begin_dt <= p_REPORT_DT
                                      and end_dt > p_REPORT_DT
                                      and VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')) then (A.OVERDUE_AMT*M.EXCHANGE_RATE) 
                          else 0
                     end 
            end = 0 then 0 
      else (A.TERM_AMT*M.EXCHANGE_RATE) 
  end TEK_PROSR
---------------------------------------------------------------------
, (case when nvl(L.BAL_AMT,0) = 0 then 0 else nvl((L.PROVISIONS_AMT/L.BAL_AMT),0) end) *
  case when nvl(A.TERM_AMT, 0) = 0 then nvl(A.OVERDUE_AMT*M.EXCHANGE_RATE, 0)
       else 
           case when case when nvl(NA.nil_amt_rub,0) = 0 then 0 
                          else nvl(A.OVERDUE_AMT*M.EXCHANGE_RATE, 0)/NA.nil_amt_rub 
                     end > (Select PARAM_VAL/100 from DWH.REF_PARAMS 
                            where PARAM_CD = 'MIN_OVD' 
                            and begin_dt <= p_REPORT_DT
                            and end_dt > p_REPORT_DT
                            and VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')) then (A.OVERDUE_AMT*M.EXCHANGE_RATE) 
                else 0
           end 
  end PROSR_REZ
----------------------------------------------------------------------
, (case when nvl(L.BAL_AMT,0) = 0 then 0 else nvl((L.PROVISIONS_AMT/L.BAL_AMT),0) end) *
case when case when case when nvl(A.TERM_AMT, 0) = 0 then nvl(A.OVERDUE_AMT*M.EXCHANGE_RATE, 0)
                           else 
                               case when case when nvl(NA.nil_amt_rub,0) = 0 then 0 
                                              else nvl(A.OVERDUE_AMT*M.EXCHANGE_RATE, 0)/NA.nil_amt_rub 
                                         end > (Select PARAM_VAL/100 from DWH.REF_PARAMS 
                                                where PARAM_CD = 'MIN_OVD' 
                                                and begin_dt <= p_REPORT_DT
                                                and end_dt > p_REPORT_DT
                                                and VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')) then (A.OVERDUE_AMT*M.EXCHANGE_RATE) 
                                    else 0
                                end 
                      end = 0 then 0 
                 else (A.TERM_AMT*M.EXCHANGE_RATE) 
             end = 0 then (A.TERM_AMT*M.EXCHANGE_RATE) 
      else 0 
  end TEK_REZ
----------------------------------------------------------------------
, (case when nvl(L.BAL_AMT,0) = 0 then 0 else nvl((L.PROVISIONS_AMT/L.BAL_AMT),0) end) * 
  case when case when nvl(A.TERM_AMT, 0) = 0 then nvl(A.OVERDUE_AMT*M.EXCHANGE_RATE, 0)
                 else 
                     case when case when nvl(NA.nil_amt_rub,0) = 0 then 0 
                                    else nvl(A.OVERDUE_AMT*M.EXCHANGE_RATE, 0)/NA.nil_amt_rub
                               end > (Select PARAM_VAL/100 from DWH.REF_PARAMS 
                                      where PARAM_CD = 'MIN_OVD' 
                                      and begin_dt <= p_REPORT_DT
                                      and end_dt > p_REPORT_DT
                                      and VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')) then (A.OVERDUE_AMT*M.EXCHANGE_RATE) 
                          else 0
                     end 
            end = 0 then 0 
      else (A.TERM_AMT*M.EXCHANGE_RATE) 
  end TEK_PROSR_REZ
----------------------------------------------------------------------
, (SUM1.SUM1*M.EXCHANGE_RATE) SUM1
, (SUM2.SUM2*M.EXCHANGE_RATE) SUM2
, (SUM3.SUM3*M.EXCHANGE_RATE) SUM3
, (SUM4.SUM4*M.EXCHANGE_RATE) SUM4
, (SUM5.SUM5*M.EXCHANGE_RATE) SUM5
, 0 PROSR_R
, 0 TEK_R
, 0 TEK_PROSR_R
, 0 PROSR_REZ_R
, 0 TEK_REZ_R
, 0 TEK_PROSR_REZ_R
, 0 SUM1_R
, 0 SUM2_R
, 0 SUM3_R
, 0 SUM4_R
, 0 SUM5_R
, 0 SUM_VAL
, 0 SUM_REZ
, 0 ZADOLJ_RUB_R
, sysdate
, K.CLIENT_CD
, K.INN
from CGP A
     left join DWH.CONTRACTS B on A.contract_key = B.contract_key and B.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
     left join DM.DM_CLIENTS C on A.client_key = C.client_key and C.snapshot_dt = p_REPORT_DT
     left join DWH.GROUPS E on C.GROUP_KEY = E.GROUP_KEY and E.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
     left join DWH.BUSINESS_CATEGORIES F on A.BUSINESS_CATEGORY_KEY = F.BUSINESS_CATEGORY_KEY and F.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
-- [apolyakov 13012017]: связка с видом деятельности по ключу из КГП     
     left join DWH.ACTIVITY_TYPES J on A.ACTIVITY_TYPE_KEY = J.ACTIVITY_TYPE_KEY and p_REPORT_DT >= J.begin_dt and p_REPORT_DT <= J.end_dt and J.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
     left join DWH.CLIENTS K on A.client_key = K.client_key and K.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
     left join DWH.ECONOMIC_SECTORS D on K.ECONOMIC_SECTOR_KEY = D.ECONOMIC_SECTOR_KEY and D.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
     left join PROVISIONS L on A.contract_key = L.contract_key and A.client_key = L.client_key and L.snapshot_dt = p_REPORT_DT
     left join DWH.EXCHANGE_RATES M on A.CURRENCY_KEY = M.CURRENCY_KEY and M.ex_rate_dt = p_REPORT_DT and M.BASE_CURRENCY_KEY = 125 and M.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
     left join NEXT_PAY_AMT O on A.contract_key = O.contract_key
     left join NIL_AMT NA on A.contract_key = NA.contract_key
     left join AVG_EXCHANGE_RATE P on A.CURRENCY_KEY = P.CURRENCY_KEY
     left join KV_AVG_EXCHANGE_RATE R on A.CURRENCY_KEY = R.CURRENCY_KEY
     left join DWH.CURRENCIES S on A.CURRENCY_KEY = S.CURRENCY_KEY and S.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
     left join PROVISIONS T on A.contract_key = T.contract_key and A.client_key = T.client_key and T.snapshot_dt = add_months(p_REPORT_DT, -1)
     left join PROVISIONS U on A.contract_key = U.contract_key and A.client_key = U.client_key and U.snapshot_dt = trunc(p_REPORT_DT, 'YY')-1
     left join DWH.EXCHANGE_RATES W on A.CURRENCY_KEY = W.CURRENCY_KEY and W.ex_rate_dt = trunc(p_REPORT_DT, 'YY')-1 and W.BASE_CURRENCY_KEY = 125 and W.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
     left join DWH.EXCHANGE_RATES Y on A.CURRENCY_KEY = Y.CURRENCY_KEY and Y.ex_rate_dt = add_months(p_REPORT_DT, -1) and Y.BASE_CURRENCY_KEY = 125 and Y.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
     left join DWH.COUNTRIES X on C.REG_COUNTRY_KEY = X.COUNTRY_KEY and p_REPORT_DT >= X.begin_dt and p_REPORT_DT <= X.end_dt and X.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
     left join SUM1 SUM1 on A.contract_key = SUM1.CONTRACT_KEY
     left join SUM2 SUM2 on A.contract_key = SUM2.CONTRACT_KEY 
     left join SUM3 SUM3 on A.contract_key = SUM3.CONTRACT_KEY 
     left join SUM4 SUM4 on A.contract_key = SUM4.CONTRACT_KEY
     left join SUM5 SUM5 on A.contract_key = SUM5.CONTRACT_KEY
     left join DWH.FACT_PROVISIONS_LOSS LOSS on A.client_key = LOSS.client_key and LOSS.snapshot_dt = p_REPORT_DT and LOSS.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
     left join dwh.GRF_GROUPS GR on E.GRF_GROUP_KEY = GR.GRF_GROUP_KEY and GR.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
     left join dwh.RELATED_PARTIES RP on E.RELATED_PARTIES_KEY = RP.RELATED_PARTIES_KEY and RP.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
     left join L16_GROUP LG on case when GR.GRF_GROUP_NAM is not null and GR.GRF_GROUP_NAM <> 'OTHERS' then GR.GRF_GROUP_NAM
                                    when E.GROUP_RU_NAM is not null then E.GROUP_RU_NAM
                               else to_char(A.CLIENT_KEY) 
                               end = LG.L16_GROUP_NAM;
  dm.u_log(p_proc => 'DM.p_DM_LOANS',
           p_step => 'insert into DM.DM_LOANS',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');  
    -------------------------------------------------------------------------------- 
    -- округление значений
    --------------------------------------------------------------------------------         
      
    for rec_loans in cur_DM_LOANS loop
        if rec_loans.PROSR = 0 
                then v_PROSR_cur := 0;
        elsif round(rec_loans.PROSR_sum/1000000,1) - v_PROSR_sumr < 0  
                then v_PROSR_cur := round(rec_loans.PROSR/1000000,1);
        elsif round(rec_loans.PROSR_sum/1000000,1) <> (v_PROSR_sumr + round(rec_loans.PROSR_sum/1000000,1)) 
                then v_PROSR_cur := round(rec_loans.PROSR_sum/1000000,1) -  v_PROSR_sumr;
        else v_PROSR_cur:= round(rec_loans.PROSR/1000000,1);            
        end if;      
        v_PROSR_sumr := v_PROSR_sumr + v_PROSR_cur;    
        --------------------------------------------------------------------------------
        if rec_loans.TEK = 0 
                then v_TEK_cur := 0;                  
        elsif round(rec_loans.TEK_sum/1000000,1) - v_TEK_sumr < 0  
                then v_TEK_cur := round(rec_loans.TEK/1000000,1);
        elsif round(rec_loans.TEK_sum/1000000,1) <> (v_TEK_sumr + round(rec_loans.TEK_sum/1000000,1)) 
                then v_TEK_cur := round(rec_loans.TEK_sum/1000000,1) -  v_TEK_sumr;
        else v_TEK_cur:= round(rec_loans.TEK/1000000,1);            
        end if;      
        v_TEK_sumr := v_TEK_sumr + v_TEK_cur;   
        --------------------------------------------------------------------------------       
        if rec_loans.TEK_PROSR = 0 
                then v_TEK_PROSR_cur := 0; 
        elsif round(rec_loans.TEK_PROSR_sum/1000000,1) - v_TEK_PROSR_sumr < 0  
                then v_TEK_PROSR_cur := round(rec_loans.TEK_PROSR/1000000,1);
        elsif round(rec_loans.TEK_PROSR_sum/1000000,1) <> (v_TEK_PROSR_sumr + round(rec_loans.TEK_PROSR_sum/1000000,1)) 
                then v_TEK_PROSR_cur := round(rec_loans.TEK_PROSR_sum/1000000,1) -  v_TEK_PROSR_sumr;
        else v_TEK_PROSR_cur:= round(rec_loans.TEK_PROSR/1000000,1);            
        end if;      
        v_TEK_PROSR_sumr := v_TEK_PROSR_sumr + v_TEK_PROSR_cur; 
        --------------------------------------------------------------------------------
        if rec_loans.PROVISIONS_RATE = 100
                then v_PROSR_REZ_cur := v_PROSR_cur;
        elsif rec_loans.PROSR_REZ = 0 
                then v_PROSR_REZ_cur := 0;                 
        elsif round(rec_loans.PROSR_REZ_sum/1000000,1) - v_PROSR_REZ_sumr < 0  
                then v_PROSR_REZ_cur := round(rec_loans.PROSR_REZ/1000000,1);
        elsif round(rec_loans.PROSR_REZ_sum/1000000,1) <> (v_PROSR_REZ_sumr + round(rec_loans.PROSR_REZ_sum/1000000,1)) 
                then v_PROSR_REZ_cur := round(rec_loans.PROSR_REZ_sum/1000000,1) -  v_PROSR_REZ_sumr;
        else v_PROSR_REZ_cur:= round(rec_loans.PROSR_REZ/1000000,1);            
        end if;      
        v_PROSR_REZ_sumr := v_PROSR_REZ_sumr + v_PROSR_REZ_cur; 
        -------------------------------------------------------------------------------- 
        if rec_loans.PROVISIONS_RATE = 100
                then v_TEK_REZ_cur := v_TEK_cur;
        elsif rec_loans.TEK_REZ  = 0 
                then v_TEK_REZ_cur := 0;   
        elsif round(rec_loans.TEK_REZ_sum/1000000,1) - v_TEK_REZ_sumr < 0  
                then v_TEK_REZ_cur := round(rec_loans.TEK_REZ/1000000,1);
       elsif round(rec_loans.TEK_REZ_sum/1000000,1) <> (v_TEK_REZ_sumr + round(rec_loans.TEK_REZ_sum/1000000,1)) 
                then v_TEK_REZ_cur := round(rec_loans.TEK_REZ_sum/1000000,1) -  v_TEK_REZ_sumr;
        else v_TEK_REZ_cur:= round(rec_loans.TEK_REZ/1000000,1);            
        end if;      
        v_TEK_REZ_sumr := v_TEK_REZ_sumr + v_TEK_REZ_cur;    
        --------------------------------------------------------------------------------
        if rec_loans.PROVISIONS_RATE = 100
                then v_TEK_PROSR_REZ_cur := v_TEK_PROSR_cur;
        elsif rec_loans.TEK_PROSR_REZ  = 0 
                then v_TEK_PROSR_REZ_cur := 0;   
        elsif round(rec_loans.TEK_PROSR_REZ_sum/1000000,1) - v_TEK_PROSR_REZ_sumr < 0  
                then v_TEK_PROSR_REZ_cur := round(rec_loans.TEK_PROSR_REZ/1000000,1);
        elsif round(rec_loans.TEK_PROSR_REZ_sum/1000000,1) <> (v_TEK_PROSR_REZ_sumr + round(rec_loans.TEK_PROSR_REZ_sum/1000000,1)) 
                then v_TEK_PROSR_REZ_cur := round(rec_loans.TEK_PROSR_REZ_sum/1000000,1) -  v_TEK_PROSR_REZ_sumr;
        else v_TEK_PROSR_REZ_cur:= round(rec_loans.TEK_PROSR_REZ/1000000,1);            
        end if;      
        v_TEK_PROSR_REZ_sumr := v_TEK_PROSR_REZ_sumr + v_TEK_PROSR_REZ_cur;    
        -------------------------------------------------------------------------------- 
        if rec_loans.SUM1 = 0 
                then v_SUM1_cur := 0;
        elsif round(rec_loans.SUM1_sum/1000000,1) - v_SUM1_sumr < 0  
                then v_SUM1_cur := round(rec_loans.SUM1/1000000,1);
        elsif round(rec_loans.SUM1_sum/1000000,1) <> (v_SUM1_sumr + round(rec_loans.SUM1_sum/1000000,1)) 
                then v_SUM1_cur := round(rec_loans.SUM1_sum/1000000,1) -  v_SUM1_sumr;
        else v_SUM1_cur:= round(rec_loans.SUM1/1000000,1);            
        end if;      
        v_SUM1_sumr := v_SUM1_sumr + v_SUM1_cur;  
        -------------------------------------------------------------------------------- 
        if rec_loans.SUM2 = 0 
                then v_SUM2_cur := 0;
        elsif round(rec_loans.SUM2_sum/1000000,1) - v_SUM2_sumr < 0  
                then v_SUM2_cur := round(rec_loans.SUM2/1000000,1);
        elsif round(rec_loans.SUM2_sum/1000000,1) <> (v_SUM2_sumr + round(rec_loans.SUM2_sum/1000000,1)) 
                then v_SUM2_cur := round(rec_loans.SUM2_sum/1000000,1) -  v_SUM2_sumr;
        else v_SUM2_cur:= round(rec_loans.SUM2/1000000,1);            
        end if;      
        v_SUM2_sumr := v_SUM2_sumr + v_SUM2_cur;    
        -------------------------------------------------------------------------------- 
        if rec_loans.SUM3 = 0 
                then v_SUM3_cur := 0;
        elsif round(rec_loans.SUM3_sum/1000000,1) - v_SUM3_sumr < 0  
                then v_SUM3_cur := round(rec_loans.SUM3/1000000,1);
        elsif round(rec_loans.SUM3_sum/1000000,1) <> (v_SUM3_sumr + round(rec_loans.SUM3_sum/1000000,1)) 
                then v_SUM3_cur := round(rec_loans.SUM3_sum/1000000,1) -  v_SUM3_sumr;
        else v_SUM3_cur:= round(rec_loans.SUM3/1000000,1);            
        end if;      
        v_SUM3_sumr := v_SUM3_sumr + v_SUM3_cur;    
        -------------------------------------------------------------------------------- 
        if rec_loans.SUM4 = 0 
                then v_SUM4_cur := 0;        
        elsif round(rec_loans.SUM4_sum/1000000,1) - v_SUM4_sumr < 0  
                then v_SUM4_cur := round(rec_loans.SUM4/1000000,1);
        elsif round(rec_loans.SUM4_sum/1000000,1) <> (v_SUM4_sumr + round(rec_loans.SUM4_sum/1000000,1)) 
                then v_SUM4_cur := round(rec_loans.SUM4_sum/1000000,1) -  v_SUM4_sumr;
        else v_SUM4_cur:= round(rec_loans.SUM4/1000000,1);            
        end if;      
        v_SUM4_sumr := v_SUM4_sumr + v_SUM4_cur;    
        -------------------------------------------------------------------------------- 
        if rec_loans.SUM5 = 0 
                then v_SUM5_cur := 0; 
        elsif round(rec_loans.SUM5_sum/1000000,1) - v_SUM5_sumr < 0  
                then v_SUM5_cur := round(rec_loans.SUM5/1000000,1);
        elsif round(rec_loans.SUM5_sum/1000000,1) <> (v_SUM5_sumr + round(rec_loans.SUM5_sum/1000000,1)) 
                then v_SUM5_cur := round(rec_loans.SUM5_sum/1000000,1) -  v_SUM5_sumr;
        else v_SUM5_cur:= round(rec_loans.SUM5/1000000,1);            
        end if;      
        v_SUM5_sumr := v_SUM5_sumr + v_SUM5_cur;    
        --------------------------------------------------------------------------------
        if rec_loans.ZADOLJ_RUB  = 0 
                then v_ZADOLJ_RUB_cur := 0; 
        elsif round(rec_loans.ZADOLJ_RUB_sum/1000000,1) - v_ZADOLJ_RUB_sumr < 0  
                then v_ZADOLJ_RUB_cur := round(rec_loans.ZADOLJ_RUB/1000000,1);
        elsif round(rec_loans.ZADOLJ_RUB_sum/1000000,1) <> (v_ZADOLJ_RUB_sumr + round(rec_loans.ZADOLJ_RUB_sum/1000000,1)) 
                then v_ZADOLJ_RUB_cur := round(rec_loans.ZADOLJ_RUB_sum/1000000,1) -  v_ZADOLJ_RUB_sumr;
        else v_ZADOLJ_RUB_cur:= round(rec_loans.ZADOLJ_RUB/1000000,1);            
        end if;      
        v_ZADOLJ_RUB_sumr := v_ZADOLJ_RUB_sumr + v_ZADOLJ_RUB_cur;            
                                                                                           
        update DM_LOANS
            set PROSR_R = v_PROSR_cur,
                TEK_R = v_TEK_cur,
                TEK_PROSR_R = v_TEK_PROSR_cur,
                PROSR_REZ_R = v_PROSR_REZ_cur,
                TEK_REZ_R = v_TEK_REZ_cur,
                TEK_PROSR_REZ_R = v_TEK_PROSR_REZ_cur,
                SUM1_R = v_SUM1_cur,
                SUM2_R = v_SUM2_cur,
                SUM3_R = v_SUM3_cur,
                SUM4_R = v_SUM4_cur,
               SUM5_R = v_SUM5_cur,
                ZADOLJ_RUB_R = v_ZADOLJ_RUB_cur,
                SUM_VAL = v_PROSR_cur + v_TEK_cur + v_TEK_PROSR_cur,
                SUM_REZ = v_PROSR_REZ_cur + v_TEK_REZ_cur + v_TEK_PROSR_REZ_cur
                    where current of cur_DM_LOANS;
     end loop;
  dm.u_log(p_proc => 'DM.p_DM_LOANS',
           p_step => 'update DM.DM_LOANS',
           p_info => SQL%ROWCOUNT|| ' row(s) updated');        
     commit;


END;
/

