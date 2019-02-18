CREATE OR REPLACE FUNCTION DM.f_XIRR_CALC_NEW(
      p_contract_key number, 
      p_REPORT_DT date)
RETURN NUMBER IS
xIRR_res NUMBER;

/* Функция рассчитывает XIRR. 
-- В качестве параметров на вход подаются номер контракта (p_contract_key) и дата отчета (p_REPORT_DT).
-- На выходе вычисленный XIRR в переменной xIRR_RES для определенного контракта на определенную отчетную дату...
-- В качестве потока берутся записи таблицы dm_xirr_flow, которая заполняется в процедуре p_DM_XIRR_CALC. 
*/

BEGIN
  select xIRR INTO xIRR_res FROM
  
   (select

                 nvl(irr*100, -1) XIRR
                 from
                    (
                    select 
                    * from dm_xirr_flow_new x
                    where l_key = p_contract_key
                    and report_dt = p_report_dt
                    and excptn_zero_div = 1
                    /* Итерационный метод Ньютона для расчета xIRR с точностью до 10 знака после запятой...
                    */
                     model
                     partition by (x.L_KEY)
                      dimension by (row_number() over (partition by l_key order by PAY_DT) rn)
                      measures(PAY_DT-first_value(PAY_DT) over (partition by L_KEY order by PAY_DT) dt, summ s, 0 ss, 1 disc_summ, 0 irr, 1 interv/*100%*/, 0 iter)
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
END;
/

