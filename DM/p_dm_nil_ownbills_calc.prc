CREATE OR REPLACE PROCEDURE DM."P_DM_NIL_OWNBILLS_CALC" (p_REPORT_DT in date)
IS
v_id_prev pls_integer;
pers number;
nill number;
diff number;
prev_dt date;
p_xirr number;
v_count number;

/* Процедура рассчитывает показатели NIL на основе xIRR и заполняет витрину:
      -- промежуточную витрину DM_NIL_OWNBILLS значениями:
          а) ставкой xIRR
          б) процентной составляющей платежа срочной задолженности на дату NIL_PERS,
          в) идентификатор векселя
          г) отчетная дата
          
-- В качестве параметра на вход подается дата отчета (p_REPORT_DT).
-- В качестве потока берутся данные из FACT_BILLS_PLAN
*/

BEGIN
   delete from DM_NIL_OWNBILLS where ODTTM = p_REPORT_DT;
   
            v_id_prev:=null;
            for rec in (
                        /* Берется поток по договорам лизинга и поставок (см. функцию f_xirr_calc)
                        */ 
                        with flow as (-- Поток по дисконтам (выбираются по определенным КБК)
                        select 
                        a.bill_key as bill_key,
                        b.PAY_DT as pay_dt,
                        CASE WHEN CBC_DESC = 'ФД.9.1' THEN -PAY_AMT
                        WHEN CBC_DESC = 'ФД.17.1' THEN NOMINAL_AMT END AS PAY_AMT
                        from DWH.bills_portfolio a, DWH.fact_bills_plan b where a.own_flg = '1' and a.prc_rate = 0
                        and a.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                        and b.begin_dt <= p_REPORT_DT
                        and b.end_dt > p_REPORT_DT
                        and b.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                        and a.bill_key = b.bill_key
                        and b.cbc_desc in ('ФД.17.1', 'ФД.9.1')
                        UNION ALL
                        -- добавляем нулевую строку на отчетную дату
                        select
                        bill_key,
                        p_REPORT_DT as PAY_DT,
                        0 as PAY_AMT from dwh.bills_portfolio
                        where valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
                        and own_flg = '1' and prc_rate = 0
                        group by BILL_KEY
                        )
                      
                          Select * from FLOW 
                          order by bill_key, PAY_DT
                          --where L_KEY in (32, 33, 41, 52)
                          
    )
loop
              if rec.bill_key != v_id_prev or v_id_prev is null                      -- после сортировки при первом появлении векселя в потоке
                then
                  if v_id_prev is not null then
                  insert into dm_nil_ownbills (bill_key, xirr, nil, odttm)
                  values(v_id_prev, p_XIRR, pers, p_REPORT_DT);
                  end if;
                  pers := null;
                  nill := null;
                  diff := round(rec.pay_amt,2)*(-1);
                  v_id_prev := rec.bill_key;
                  prev_dt := rec.pay_dt;
                  select f_XIRR_OWNBILLS_CALC(rec.bill_key, p_REPORT_DT) into p_XIRR from dual;                  
                else                                                                              -- после сортировки при повторном появлении векселя в потоке
                  pers := round(diff*power((1+p_XIRR),(rec.pay_dt-prev_dt)/365)-diff,2);
                  nill := round(rec.pay_amt-pers,2);
                  prev_dt := rec.pay_dt;
                  diff := round(diff-nill,2);
              end if;
end loop;
insert into dm_nil_ownbills (bill_key, xirr, nil, odttm)
                  values(v_id_prev, p_XIRR, pers, p_REPORT_DT);
commit;


end;
/

