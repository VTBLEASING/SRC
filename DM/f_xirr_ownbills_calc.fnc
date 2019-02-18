CREATE OR REPLACE FUNCTION DM."F_XIRR_OWNBILLS_CALC" (p_bill_key number, p_REPORT_DT date)
RETURN NUMBER IS
xIRR_res NUMBER;

/* Функция рассчитывает XIRR. 
-- В качестве параметров на вход подаются номер векселя (p_bill_key) и дата отчета (p_REPORT_DT).
-- На выходе вычисленный XIRR в переменной xIRR_RES для определенного контракта на определенную отчетную дату...
-- В качестве потока берутся все платежи по векселю
*/

BEGIN
select xIRR INTO xIRR_res FROM
(
with flow as (-- Поток по дисконтам (выбираются по определенным КБК)
select 
b.PAY_DT,
CASE WHEN CBC_DESC = 'ФД.9.1' THEN -PAY_AMT
WHEN CBC_DESC = 'ФД.17.1' THEN NOMINAL_AMT END AS PAY_AMT
from DWH.bills_portfolio a, DWH.fact_bills_plan b where a.own_flg = '1' and a.prc_rate = 0
and a.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
and b.valid_to_dttm = to_date('01.01.2400', 'dd.mm.yyyy')
and a.bill_key = p_bill_key
and b.bill_key = p_bill_key
and b.cbc_desc in ('ФД.17.1', 'ФД.9.1')
UNION ALL
-- добавляем нулевую строку на отчетную дату
select
p_REPORT_DT as PAY_DT,
0 as PAY_AMT from dual
)

select
                 nvl(irr, -1) XIRR
                 from
                    (
                    select * from Flow
                    /* Итерационный метод Ньютона для расчета xIRR с точностью до 10 знака после запятой...
                    */
                     model
                      dimension by (row_number() over (order by PAY_DT) rn)
                      measures(PAY_DT-first_value(PAY_DT) over (order by PAY_DT) dt, pay_amt s, 0 ss, 1 disc_summ, 0 irr, 1 interv/*100%*/, 0 iter)
                      rules iterate(100) until (abs(interv[1])<power(10,-10))
                            (ss[any]=s[CV()]/power(1+IRR[1],dt[CV()]/365),
                            irr[1] = decode(sign(disc_summ[1]),sign(sum(ss)[any]),irr[1]+sign(disc_summ[1])*interv[1],irr[1]-sign(disc_summ[1])*interv[1]/2),
                            interv[1]= decode(sign(disc_summ[1]),sign(sum(ss)[any]),interv[1],interv[1]/2),
                            disc_summ[1]=sum(ss)[any],
                            iter[1]=iteration_number+1
                             )
                    )
      where rn=1
      );
      return xIRR_res;
end;
/

