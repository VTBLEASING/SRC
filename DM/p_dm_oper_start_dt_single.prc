CREATE OR REPLACE PROCEDURE DM.p_DM_OPER_START_DT_SINGLE (
      p_contract_key in number,
      p_REPORT_DT date
)

is 

BEGIN
    dm.u_log(p_proc => 'DM.p_DM_OPER_START_DT_SINGLE',
           p_step => 'INPUT PARAMS',
           p_info => 'p_contract_key:'||p_contract_key||'p_REPORT_DT:'||p_REPORT_DT); 
delete from DM.DM_OPER_START_DT 
where snapshot_dt = p_REPORT_DT
and contract_key = p_contract_key;
  dm.u_log(p_proc => 'DM.p_DM_OPER_START_DT_SINGLE',
           p_step => 'delete from DM.DM_OPER_START_DT',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');   
INSERT INTO 
DM.DM_OPER_START_DT (
                      CONTRACT_KEY,
                      CONTRACT_ID_CD,
                      OPER_START_DT,
                      SNAPSHOT_DT,
                      BRANCH_KEY,
                      INSERT_DT,
                      SRC_CD
                    )
-- aapolyakov [21.10.2015]:выбираем все договоры лизинга с соответствующими договорами поставки 
WITH contr
        AS (
                SELECT c.contract_key,
                       sup.contract_key S_KEY,
                       c.close_dt,
                       c.open_dt,
                       c.oper_start_dt,
                       c.rehiring_flg,
                       c.contract_id_cd,
                       c.branch_key
                FROM  dwh.leasing_contracts lc
                INNER JOIN dwh.contracts c
                       ON    lc.contract_key = c.contract_key
                           AND lc.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                -- aapolyakov [20.10.2015]: Для договоров лизинга определяем договор поставки)
                LEFT JOIN dwh.contracts sup
                       ON     c.contract_key = sup.contract_leasing_key
                           AND sup.valid_to_dttm =
                                  TO_DATE ('01.01.2400', 'DD.MM.YYYY')      
                WHERE c.valid_to_dttm =
                                  TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                AND   c.contract_key = p_contract_key 
            ),
-- aapolyakov [21.10.2015]: выбираем среди актов передачи минимальную дату для каждого договора
-- aapolyakov [05.04.2017]: выбираем среди приложений по договору самый "свежий" акт по snapshot_dt, а затем среди всех актов передачи минимальную дату для каждого договора
      contr_transmit
          AS (            
                select    
                        act_dt,
                        contract_key,
                        rehiring_flg,
                        contract_id_cd
                from  (    
                            SELECT 
                                   act_dt,
                                   contract_key,
                                   contract_num,
                                   rehiring_flg,
                                   contract_id_cd,
                                   ROW_NUMBER ()
                                           OVER (PARTITION BY CONTRACT_ID_CD
                                                 ORDER BY act_dt asc)
                                              rn1
                            FROM (
                                      SELECT 
                                             t.act_dt,
                                             c.contract_key,
                                             c.rehiring_flg,
                                             c.contract_id_cd,
                                             ap.contract_num,
                                             ROW_NUMBER ()
                                             OVER (PARTITION BY c.CONTRACT_ID_CD, ap.contract_num
                                                   ORDER BY t.snapshot_dt desc)
                                                rn
                                      FROM dwh.leasing_subject_transmit t
                                             INNER JOIN dwh.leasing_contracts_appls ap
                                                ON     t.contract_app_key = ap.contract_app_key
                                                   AND ap.valid_to_dttm =
                                                          TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                                             INNER JOIN (select distinct 
                                                              contract_key,
                                                              close_dt,
                                                              open_dt,
                                                              oper_start_dt,
                                                              rehiring_flg,
                                                              contract_id_cd,
                                                              branch_key
                                                        from contr
                                                        ) c 
                                                ON c.contract_key = ap.contract_key
                                      WHERE     1 = 1
                                             AND t.valid_to_dttm =
                                                    TO_DATE ('01.01.2400', 'DD.MM.YYYY')
                                             AND t.act_dt <>
                                                    TO_DATE ('01.01.0001', 'DD.MM.YYYY')
                                             AND t.act_num IS NOT NULL
                                             AND t.contract_app_key IS NOT NULL
                                  )
                            WHERE rn = 1 
                    )
                WHERE rn1 = 1
            ),
            
-- aapolyakov [21.10.2015]: выбираем минимальную дату оплаты поставки в рамках ID сделки            
      fct_supply_cur
          AS (
                 SELECT
                        contract_key,
                        S_KEY,
                        rehiring_flg,
                        contract_id_cd,
                        pay_dt as min_pay_dt
                 FROM (
                        select 
                               contr.contract_key,
                               contr.S_KEY,
                               contr.rehiring_flg,
                               contr.contract_id_cd,
                               fact_rp.pay_dt,
                               ROW_NUMBER () 
                               OVER (partition by contr.contract_id_cd
                                     ORDER BY fact_rp.pay_dt asc) as rn
                        FROM contr contr
                        LEFT JOIN dwh.fact_real_payments fact_rp
                            ON contr.s_key = fact_rp.contract_key
                           AND fact_rp.valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy')
                        )
                 WHERE rn = 1
               ),
-- aapolyakov [21.10.2015]: выбираем минимальную дату из двух дат в рамках договора 
      fin 
          AS (
                 SELECT 
                        c.contract_key,
                        c.branch_key,
                        c.oper_start_dt,
                        c.contract_id_cd,
                        least (nvl(act_dt, to_date ('31.12.3999', 'dd.mm.yyyy')), nvl(min_pay_dt, to_date ('31.12.3999', 'dd.mm.yyyy'))) as oper_start_dt_new
                 FROM (select distinct 
                                      contract_key,
                                      close_dt,
                                      open_dt,
                                      oper_start_dt,
                                      rehiring_flg,
                                      contract_id_cd,
                                      branch_key
                       from contr
                       ) c
                 LEFT JOIN contr_transmit tt
                      ON c.contract_id_cd = tt.contract_id_cd
                 LEFT JOIN fct_supply_cur fct
                      ON fct.contract_id_cd = c.contract_id_cd
             ),
-- aapolyakov [21.10.2015]: выбираем дату из предыдущего периода КГП 
      oper_start_dt_prev 
          AS (
                 SELECT 
                        CONTRACT_KEY,
                        CONTRACT_ID_CD,
                        OPER_START_DT,
                        SNAPSHOT_DT,
                        BRANCH_KEY
                 FROM dm.dm_oper_start_dt
                 WHERE snapshot_dt = trunc (p_REPORT_DT, 'mm') - 1
                 and contract_key = p_contract_key
                   )

      SELECT 
            c.contract_key,
            c.contract_id_cd,
            CASE
                WHEN prev.oper_start_dt is not null  -- aapolyakov [21.10.2015]: выбираем дату из предыдущего периода КГП 
                  and prev.oper_start_dt != to_date ('31.12.3999', 'dd.mm.yyyy')  -- aapolyakov [30.11.2015]: если в прошлом месяце ошибочно поситался, не брать его.
                      THEN prev.oper_start_dt
                WHEN (prev.oper_start_dt is null      -- aapolyakov [21.10.2015]: выбираем дату из DWH
                  OR prev.oper_start_dt = to_date ('31.12.3999', 'dd.mm.yyyy'))  -- aapolyakov [30.11.2015]: если в прошлом месяце ошибочно поситался, не брать его.
                  and c.oper_start_dt is not null
                  and c.oper_start_dt != to_date ('01.01.0001', 'dd.mm.yyyy')
                      THEN c.oper_start_dt
                ELSE c.oper_start_dt_new             -- aapolyakov [21.10.2015]: выбираем рассчитанную дату
            END as oper_start_dt,
            p_REPORT_DT,
            c.branch_key,
            sysdate,
            CASE
                WHEN prev.oper_start_dt is not null  -- aapolyakov [21.10.2015]: выбираем дату из предыдущего периода КГП 
                  and prev.oper_start_dt != to_date ('31.12.3999', 'dd.mm.yyyy')  -- aapolyakov [30.11.2015]: если в прошлом месяце ошибочно поситался, не брать его.
                      THEN 'PREV_CGP'
                WHEN (prev.oper_start_dt is null      -- aapolyakov [21.10.2015]: выбираем дату из DWH
                  OR prev.oper_start_dt = to_date ('31.12.3999', 'dd.mm.yyyy'))  -- aapolyakov [30.11.2015]: если в прошлом месяце ошибочно поситался, не брать его.
                  and c.oper_start_dt is not null
                  and c.oper_start_dt != to_date ('01.01.0001', 'dd.mm.yyyy')
                      THEN 'CONTR'
                ELSE 'CALC'             -- aapolyakov [21.10.2015]: выбираем рассчитанную дату
            END as src_cd
      FROM fin c
      LEFT JOIN oper_start_dt_prev prev
          ON c.contract_key = prev.contract_key;
  dm.u_log(p_proc => 'DM.p_DM_OPER_START_DT_SINGLE',
           p_step => 'insert into DM.DM_OPER_START_DT',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');            
COMMIT;

END;
/

