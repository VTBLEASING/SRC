create or replace procedure dm.p_dm_nill_chunk(p_REPORT_DT date, p_lo_rid in number, p_hi_rid in number) is
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
    -------------------------------------------------------------------------------------- 
    sid_n number;
    -------------------------------------------------------------------------------------- 
begin
--    select sid 
--    into sid_n
--     from v$mystat where rownum =1;

    v_id_prev:=null;
    for rec in (select L_KEY, branch_key, PAY_DT, summ, sum_prev,LEASING_PAY,SUPPLY_PAY,PAY_AMT,UNDER_L_PAY
                from dm_flow where rid >= p_lo_rid and rid <= p_hi_rid order by rid, pay_dt)
    loop
      if rec.L_KEY != v_id_prev or v_id_prev is null                      -- после сортировки при первом появлении договора в потоке
        then
          pers := null;
          nill := null;
          diff := round(rec.SUMM,2)*(-1);
          v_id_prev := rec.L_KEY;
          prev_dt := rec.pay_dt;
          select XIRR into p_XIRR from DM_XIRR_TMP where
          contract_id = rec.L_KEY
          and ODTTM= p_REPORT_DT
          and snapshot_cd = 'Основной КИС';
          p_xirr := p_xirr/100;
          diff_prev2 := diff_prev;
          diff_prev := diff;
          ka_prev2 := ka_prev;
          ka_prev := ka;
                  if rec.pay_dt > p_REPORT_DT and diff_prev2 is null then ka := 1;
                  elsif rec.pay_dt <= p_REPORT_DT then ka := 1;
                  elsif diff_prev = 0 then ka := nvl(ka_prev, 1);
                  elsif ka_prev = 0 then ka := diff_prev2 * ka_prev2 / diff_prev; -- падало на нуле
                  elsif nill > 0 then ka := ka_prev;
                  else ka := 0;
                  end if;
          nil_ka := round(ka * nill, 2);
          if nil_ka < 0 and rec.pay_dt > p_REPORT_DT then nil_ka := 0;
          end if;
          insert into DM_NIL_TMP (contract_id,contract_date, fact_amt, plan_amt, leasing_amt, supply_amt,nil_pers,nil,nil_diff,ODTTM,ka, nil_ka, PAY_AMT, branch_key, snapshot_cd, UNDERPAY_LEAS)
          values(rec.L_KEY,rec.pay_dt,(case when rec.summ < 0 then rec.summ else 0 end), (case when rec.summ > 0 then rec.summ else 0 end), rec.leasing_pay, rec.supply_pay, pers,nill,diff,p_REPORT_DT,round(ka, 2), nil_ka, rec.summ, rec.branch_key, 'Основной КИС', rec.UNDER_L_PAY);
-------------------------------------------------------------------------------------- 
--          insert into kav_dm_nil_tarce (contract_id,contract_date, fact_amt, plan_amt, leasing_amt, supply_amt, nil_pers,nil,nil_diff,ODTTM, ka, nil_ka, PAY_AMT, branch_key, snapshot_cd, UNDERPAY_LEAS,sid)
--          values(rec.L_KEY,rec.pay_dt,(case when rec.summ < 0 then rec.summ else 0 end), (case when rec.summ > 0 then rec.summ else 0 end), rec.leasing_pay, rec.supply_pay, pers,nill,diff,p_REPORT_DT,round(ka, 2), nil_ka, rec.PAY_AMT, rec.branch_key, 'Основной КИС', rec.UNDER_L_PAY,sid_n);
                    
        else                                                                              -- после сортировки при повторном появлении договора в потоке
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
                  elsif ka_prev = 0 then ka := diff_prev2 * ka_prev2 / diff_prev; -- падало на нуле                          
                  elsif nill > 0 then ka := ka_prev;
                  else ka := 0;
                  end if;
          v_id_prev := rec.L_KEY;
          prev_dt := rec.pay_dt;
          nil_ka := round(ka * nill, 2);
          if nil_ka < 0 and rec.pay_dt > p_REPORT_DT then nil_ka := 0;
          end if;
          insert into DM_NIL_TMP (contract_id,contract_date, fact_amt, plan_amt, leasing_amt, supply_amt, nil_pers,nil,nil_diff,ODTTM, ka, nil_ka, PAY_AMT, branch_key, snapshot_cd, UNDERPAY_LEAS)
          values(rec.L_KEY,rec.pay_dt,(case when rec.summ < 0 then rec.summ else 0 end), (case when rec.summ > 0 then rec.summ else 0 end), rec.leasing_pay, rec.supply_pay, pers,nill,diff,p_REPORT_DT,round(ka, 2), nil_ka, rec.PAY_AMT, rec.branch_key, 'Основной КИС', rec.UNDER_L_PAY);
-------------------------------------------------------------------------------------- 
--          insert into kav_dm_nil_tarce (contract_id,contract_date, fact_amt, plan_amt, leasing_amt, supply_amt, nil_pers,nil,nil_diff,ODTTM, ka, nil_ka, PAY_AMT, branch_key, snapshot_cd, UNDERPAY_LEAS,sid)
--          values(rec.L_KEY,rec.pay_dt,(case when rec.summ < 0 then rec.summ else 0 end), (case when rec.summ > 0 then rec.summ else 0 end), rec.leasing_pay, rec.supply_pay, pers,nill,diff,p_REPORT_DT,round(ka, 2), nil_ka, rec.PAY_AMT, rec.branch_key, 'Основной КИС', rec.UNDER_L_PAY,sid_n);
          commit;
      end if;
    end loop;
--   insert into kav_nil_trace1 values(sid_n, sysdate);
   commit;
end;
/

