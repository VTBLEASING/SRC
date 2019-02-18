CREATE OR REPLACE PROCEDURE DM."P_DM_SWAP_NPV" (p_REPORT_DT in date)
IS

BEGIN

delete from DM_SWAP_NPV where snapshot_dt = p_REPORT_DT;

insert into DM_SWAP_NPV (
            SCENARIO_DESC,
            SNAPSHOT_DT,
            SNAPSHOT_MONTH,
            SNAPSHOT_YEAR,
            BRANCH_KEY,
            CONTRACT_KEY,
            CURRENCY1_KEY,
            CURRENCY2_KEY,
            START_DT,
            BUY1_AMT,
            START_EX_RATE,
            SELL1_AMT,
            END_DT,
            SELL2_AMT,
            FACTOR_K1_RATE,
            SELL2_DISC_AMT,
            END_EX_RATE,
            BUY2_AMT,
            FACTOR_K2_RATE,
            BUY2_DISC_AMT,
            DAYS_CNT,
            BALANCE_AMT,
            MARGIN_RATE,
            PROCESS_KEY,
            INSERT_DT
            )
        
        with all_ccy1 as 
              (
                select 
                      contract_key, 
                      (ac.entry_dt - sw.end_dt) as days_cnt, 
                      ac.entry_amt / (first_value(ac.entry_amt) over (partition by contract_key, ac.currency_key order by ac.entry_dt)) as entry_amt, 
                      ac.entry_dt 
                from 
                      dwh.swap_contracts sw, 
                      
                      dwh.ALL_CCY_CURVES ac 
                where sw.start_dt <= last_day(p_REPORT_DT)
                  and sw.end_dt > p_REPORT_DT--trunc(p_REPORT_DT, 'mm')
                  and sw.currency2_key = ac.currency_key
                  and sw.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                  and ac.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                  and ac.report_period_dt = p_REPORT_DT),
        
             all_ccy2 as 
              (
                select 
                      contract_key, 
                      (ac.entry_dt - sw.end_dt) as days_cnt, 
                      ac.entry_amt / (first_value(ac.entry_amt) over (partition by contract_key, ac.currency_key order by ac.entry_dt)) as entry_amt, 
                      ac.entry_dt 
                from 
                      dwh.swap_contracts sw, 
                      dwh.ALL_CCY_CURVES ac 
                where sw.start_dt <= last_day(p_REPORT_DT)
                  and sw.end_dt >p_REPORT_DT-- trunc(p_REPORT_DT, 'mm')
                  and sw.currency1_key = ac.currency_key
                  and sw.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                  and ac.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                  and ac.report_period_dt = p_REPORT_DT),
        
            k1_dt_1 as
              (
                select 
                      contract_key, 
                      max(entry_amt) keep (dense_rank last order by days_cnt) as k1, 
                      max(entry_dt) keep (dense_rank last order by days_cnt) as dt1 
                from all_ccy1 
                where days_cnt <= 0
                group by contract_key),
        
            k1_dt_2 as 
              (
                select 
                      contract_key, 
                      max(entry_amt) keep (dense_rank first order by days_cnt) as k2, 
                      max(entry_dt) keep (dense_rank first order by days_cnt) as dt2,
                      min(days_cnt) as days2_cnt
                from all_ccy1 
                where days_cnt > =0
                group by contract_key),
        
            k1_calc as
              (
                select 
                      a.contract_key, 
                      case 
                        when (b.dt2 - a.dt1) != 0 
                          then k2 + (k1 - k2) / (b.dt2 - a.dt1) * days2_cnt 
                        else k2 
                      end as k
                from 
                      k1_dt_1 a, 
                      k1_dt_2 b 
                where a.contract_key = b.contract_key),
        
            k2_dt_1 as
              (
                select 
                      contract_key, 
                      max(entry_amt) keep (dense_rank last order by days_cnt) as k1, 
                      max(entry_dt) keep (dense_rank last order by days_cnt) as dt1 
                from all_ccy2 
                where days_cnt <= 0
                group by contract_key),
        
            k2_dt_2 as 
              (
                select 
                      contract_key, 
                      max(entry_amt) keep (dense_rank first order by days_cnt) as k2, 
                      max(entry_dt) keep (dense_rank first order by days_cnt) as dt2,
                      min(days_cnt) as days2_cnt
                from all_ccy2 
                where days_cnt >= 0
                group by contract_key),
        
            k2_calc as
              (
                select 
                      a.contract_key, 
                      case 
                        when (b.dt2 - a.dt1) != 0 
                          then k2 + (k1 - k2) / (b.dt2 - a.dt1) * days2_cnt 
                        else k2 
                      end as k
                from 
                      k2_dt_1 a, 
                      k2_dt_2 b 
                where a.contract_key = b.contract_key)
        
        select 
              null as scenario_desc,
              p_REPORT_DT as snapshot_dt,
              to_char(p_REPORT_DT, 'MM') as snapshot_month,
              to_char(p_REPORT_DT, 'YYYY') as snapshot_year,
              swap.BRANCH_KEY as branch_key,
              swap.CONTRACT_KEY as contract_key,
              swap.CURRENCY1_KEY as currency1_key,
              swap.CURRENCY2_KEY as currency2_key,
              swap.start_dt as start_dt,
              swap.BUY1_AMT as BUY1_amt,
              swap.START_EX_RATE as start_ex_rate,
              swap.SELL1_AMT as sell1_amt,
              swap.end_dt as end_dt,
              swap.SELL2_AMT as sell2_amt,
              k1_calc.k as factor_k1_rate,
              swap.sell2_amt * k1_calc.k as sell2_disc_amt,
              swap.END_EX_RATE as end_ex_rate,
              swap.BUY2_AMT as buy2_amt,
              k2_calc.k as factor_k2_rate,
              swap.buy2_amt * k2_calc.k as buy2_disc_amt,
              swap.end_dt - swap.start_dt as days_cnt,
              swap.buy2_amt - nvl(swap.sell1_amt,0) as balance_amt,
              (swap.buy2_amt - swap.sell1_amt) 
              / (swap.end_dt - swap.start_dt) 
              * 365 
              / (case when swap.CURRENCY1_KEY = (select max(currency_key) from dwh.currencies where currency_letter_cd = 'RUB' and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')and begin_dt <= p_REPORT_DT and end_dt > p_REPORT_DT) then decode (swap.sell1_amt, 0, null, swap.sell1_amt) 
                      when swap.CURRENCY2_KEY = (select max(currency_key) from dwh.currencies where currency_letter_cd = 'RUB' and valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')and begin_dt <= p_REPORT_DT and end_dt > p_REPORT_DT) then decode (swap.sell2_amt, 0, null, swap.sell2_amt) 
                      else null end) as margin_rate,
              777 as process_key,
              sysdate as insert_dt
        from dwh.SWAP_CONTRACTS swap, k1_calc, k2_calc
        where swap.contract_key = k1_calc.contract_key and swap.contract_key = k2_calc.contract_key
        and swap.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
        and swap.end_dt >p_REPORT_DT;


commit;

end;
/

