CREATE OR REPLACE PROCEDURE DM.P_DM_EUROPE_REPORT(
p_REPORT_DT IN date
)
is
BEGIN
  /* ѕроцедура расчета витрины DM_EUROPE_REPORT полностью.
     ¬ качестве входного параметра подаетс€ дата составлени€ отчета
  */

  dm.u_log(p_proc => 'DM.P_DM_EUROPE_REPORT',
           p_step => 'INPUT PARAMS',
           p_info => 'p_REPORT_DT: '||p_REPORT_DT);

 delete from DM_EUROPE_REPORT
 where snapshot_dt = p_REPORT_DT;

  dm.u_log(p_proc => 'DM.P_DM_EUROPE_REPORT',
           p_step => 'delete from DM_EUROPE_REPORT',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');

  commit;

  INSERT INTO DM.DM_EUROPE_REPORT
  select
      p_REPORT_DT AS SNAPSHOT_DT
      ,c.contract_num
      ,c.contract_id_cd
      ,D.presentation
      ,c.contract_id_cd || ' ' || D.presentation as concat_pril
      ,B.full_client_ru_nam
       ,K.col_mircode 
       ,B.branch_nam
      ,A.startdate
      ,A.maturitydate
       ,C.currency_en_nam 
      ,A.xirr
      ,G.NIL_REPORT_DT--NIL на дату отчета
      ,F.GIL_REPORT_DT --GIL на дату отчета
      ,H.ULI_REPORT_DT --ULI на дату отчета
      ,J.FLI_REPORT_DT --FLI на отчетный период (с 01.01.18 по отчетную дату включительно)
       ,I.FLI_REPORT_MNTH  --FLI на отчетный мес€ц (с 01 по 31 число отчетного мес€ца)
      ,E.DATE_ 
      ,E.PMNT_AMT
      ,A.contract_key
from  (SELECT DISTINCT contract_key, xirr, startdate, maturitydate, client_key
      ,CONTRACT_APP_KEY FROM dwh.reportloanportfolio
       WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')
       and reportingdate=TO_DATE(p_REPORT_DT,'DD.MM.YYYY')
      ) A
       LEFT JOIN
      (SELECT DISTINCT A1.CLIENT_KEY, A1.FULL_CLIENT_RU_NAM,A1.BRANCH_KEY
      ,B1.BRANCH_NAM FROM
                         (SELECT DISTINCT CLIENT_KEY, FULL_CLIENT_RU_NAM,BRANCH_KEY
                          FROM DWH.CLIENTS
                          WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')
                          ) A1
                          LEFT JOIN
                          (SELECT DISTINCT BRANCH_KEY, BRANCH_NAM
                           FROM DWH.ORG_STRUCTURE
                           WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')
                          ) B1 ON A1.BRANCH_KEY=B1.BRANCH_KEY
                          ) B
          ON A.CLIENT_KEY=B.CLIENT_KEY
          LEFT JOIN 
          (
          SELECT DISTINCT   A.contract_num,A.contract_id_cd, A.CONTRACT_KEY,B.CURRENCY_EN_NAM
          FROM dwh.contracts A
          LEFT JOIN 
          dwh.currencies B
          ON A.currency_key = B.currency_key
          WHERE A.VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')
          AND B.VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')
          ) C ON A.CONTRACT_KEY=C.CONTRACT_KEY 
left join (select distinct contract_APP_key, presentation FROM  dwh.leasing_contracts_appls
          where VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY')
          ) D
          on A.contract_APP_key = D.contract_APP_key
left join (
          select contract_APP_key, date_ AS DATE_, SUM(sum_) AS PMNT_AMT 
          from dwh.PaymentScheduleIFRS
          WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YYYY') 
          GROUP BY contract_app_key, date_
          ) E
          on A.contract_APP_key = E.contract_APP_key
left join     (
              select SUM(sum_) AS GIL_REPORT_DT, contract_key,contract_app_key 
              from dwh.paymentscheduleifrs
              where payment_item_key in (48, 50)
              and valid_to_dttm = TO_DATE('01.01.2400','DD.MM.YYYY')
              and date_ > TO_DATE(p_REPORT_DT,'DD.MM.YYYY')
              GROUP BY contract_key,contract_app_key
              ) F
              on A.contract_APP_key = F.contract_APP_key
       --AND GIL.CONTRACT_APP_KEY ????? - VALIDE AS JOIN ITEM
              ---GIL на дату отчета--
              --NIL на дату отчета--
left join     (select SUM(sum_) AS NIL_REPORT_DT, contract_key, CONTRACT_APP_KEY 
              from dwh.accrualscheduleifrs
              where valid_to_dttm = TO_DATE('01.01.2400','DD.MM.YYYY')
              and date_ <= TO_DATE(p_REPORT_DT,'DD.MM.YYYY')
              and payment_item_key = 79
              GROUP BY contract_key,contract_app_key
              ) G
              on A.contract_APP_key = G.contract_APP_key
              -- NIL на дату отчета --
              --ULI на дату отчета--
left join     (
              select SUM(A.sum_) AS ULI_REPORT_DT, A.contract_key AS CONTRACT_KEY
              ,A.CONTRACT_APP_KEY,B.CLOSE_DT
              from dwh.accrualscheduleifrs A
              LEFT JOIN DWH.CONTRACTS B 
              ON A.CONTRACT_KEY=B.CONTRACT_KEY
              where A.payment_item_key = 49
              and A.valid_to_dttm = TO_DATE('01.01.2400','DD.MM.YYYY')
              and B.valid_to_dttm = TO_DATE('01.01.2400','DD.MM.YYYY')
              and date_ BETWEEN TO_DATE(p_REPORT_DT,'DD.MM.YYYY') AND B.CLOSE_DT
              GROUP BY  A.contract_key,A.CONTRACT_APP_KEY,B.CLOSE_DT
              ) H
              on A.contract_APP_key = H.contract_APP_key
              --ULI на дату отчета --
              --FLI на отчетный период --
left join     (
              select SUM(sum_) AS FLI_REPORT_DT, contract_key,CONTRACT_APP_KEY
              from dwh.accrualscheduleifrs
              where payment_item_key = 49
              and valid_to_dttm = TO_DATE('01.01.2400','DD.MM.YYYY')
              and date_ BETWEEN TRUNC(TO_DATE(p_REPORT_DT,'DD.MM.YYYY'),'YEAR')
                                      AND
                                     LAST_DAY(TO_DATE(P_REPORT_DT,'DD.MM.YYYY'))
               GROUP BY  contract_key,CONTRACT_APP_KEY
              ) J
              on A.contract_APP_key = J.contract_APP_key
              --FLI на отчетный период --
              --FLI на отчетный мес€ц --
left join     (
              select SUM(sum_) AS FLI_REPORT_MNTH, contract_key, CONTRACT_APP_KEY 
              from dwh.accrualscheduleifrs 
              where payment_item_key = 49
              and valid_to_dttm = TO_DATE('01.01.2400','DD.MM.YYYY')
              and date_ BETWEEN TRUNC(TO_DATE(p_REPORT_DT,'DD.MM.YYYY'),'MONTH')
                         AND
                  TO_DATE(P_REPORT_DT,'DD.MM.YYYY')
              GROUP BY contract_key, CONTRACT_APP_KEY
               ) I
               on A.contract_APP_key = I.contract_APP_key
              --FLI на отчетный мес€ц --
left join ( SELECT B2.COL_MIRCODE, A2.CONTRACT_APP_KEY FROM
            (select DISTINCT A.contract_key, A.mircode_key,B.CONTRACT_APP_KEY
            from dwh.leasing_contracts A 
            LEFT JOIN
            DWH.LEASING_CONTRACTS_APPLS B
            ON 
            A.CONTRACT_KEY=B.CONTRACT_KEY
            WHERE A.valid_to_dttm = TO_DATE('01.01.2400','DD.MM.YYYY')
            AND  B.valid_to_dttm = TO_DATE('01.01.2400','DD.MM.YYYY') 
            ) A2
          LEFT JOIN
          (select DISTINCT mircode_key, col_mircode from dwh.mircode
          WHERE valid_to_dttm = TO_DATE('01.01.2400','DD.MM.YYYY')) B2
          ON A2.mircode_key = B2.mircode_key
          ) K
         on A.contract_APP_key = K.contract_APP_key;
  --       where a.reportingdate=TO_DATE(p_REPORT_DT,'DD.MM.YYYY');
         COMMIT;
          dm.u_log(p_proc => 'DM.P_DM_EUROPE_REPORT',
           p_step => 'INSERT INTO DM_EUROPE_REPORT',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');
           etl.P_DM_LOG('DM_EUROPE_REPORT');
          END;
/

