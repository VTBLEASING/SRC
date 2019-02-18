create or replace force view dm.v$dm_ol_flow_supply as
select "REP_DT","CONTRACT_KEY","S_KEY","CUR","BRANCH_KEY","SNAPSHOT_CD","SNAPSHOT_DT","S_AMT","S_AMT_F","S_AMT_F_R","S_EX_RATE"  from (
                select
                  S.snapshot_dt + 1 REP_DT,
                  S.L_KEY Contract_key,
                  S.S_KEY,
                  co.CURRENCY_KEY CUR,
                  S.BRANCH_KEY,
                  S.snapshot_cd,
                  S.snapshot_dt,
                  sum (case
                        when tp = 'Supply_plan'
                          Then S.PAY_AMT*-1
                         else 0
                        end ) as S_AMT,
                  sum (
                           case
                            when tp = 'Supply_fact'
                              Then S.PAY_AMT*rt2.EXCHANGE_RATE/rt1.EXCHANGE_RATE*-1
                             else 0
                            end
                        ) as S_AMT_F,
                  sum (
                       case
                        when tp = 'Supply_fact' and S.PAY_AMT > 0
                          Then S.PAY_AMT_CUR*-1
                        else
                       case
                        when tp = 'Supply_fact'
                          Then S.PAY_AMT*rt2.EXCHANGE_RATE*-1
                         else 0
                        end
                        end) as S_AMT_F_R,
                  rt3.EXCHANGE_RATE  s_ex_rate
                from dm.dm_ol_flow_orig S
                INNER join dwh.contracts co
                    on s.s_key = co.CONTRACT_KEY
                    and co.valid_to_dttm = to_date('01.01.2400','dd.mm.yyyy')
                left join dwh.EXCHANGE_RATES rt1             --valuta contract
                    on co.CURRENCY_KEY = rt1.CURRENCY_KEY
                    and S.pay_dt = rt1.ex_rate_dt
                    and rt1.BASE_CURRENCY_KEY = 125
                    and rt1.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                left join dwh.EXCHANGE_RATES rt2
                    on S.CUR2 = rt2.CURRENCY_KEY             --valuta cur2
                    and S.pay_dt = rt2.ex_rate_dt
                    and rt2.BASE_CURRENCY_KEY = 125
                    and rt2.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                left join dwh.EXCHANGE_RATES rt3
                    on co.CURRENCY_KEY = rt3.CURRENCY_KEY    ---valuta contacts
                    and S.snapshot_dt = rt3.ex_rate_dt       ---
                    and rt3.BASE_CURRENCY_KEY = 125
                    and rt3.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                where TP Like 'Supply%' -- and CBC_DESC = 'IA.3.1'
                group by
                  S.snapshot_dt + 1,
                  S.L_KEY,
                  S.S_KEY,
                  co.CURRENCY_KEY,
                  S.BRANCH_KEY,
                  S.snapshot_cd,
                  S.snapshot_dt,
                  rt3.EXCHANGE_RATE
 ) where  (S_AMT<>0 or S_AMT_F<>0)
;

