CREATE OR REPLACE PROCEDURE DM."P_DM_CLIENTS" (P_REPORT_DT in date)
IS
BEGIN

/* Процедура расчета витрины клиентских данных DM_CLIENTS
   
   В качестве входного параметра подается дата составления отчета
*/

delete from DM.DM_CLIENTS where snapshot_dt = p_REPORT_DT;

   dm.u_log(p_proc => 'P_DM_CLIENTS',
           p_step => 'delete from DM_CLIENTS',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');

  INSERT INTO DM_CLIENTS
              (
                SNAPSHOT_CD,
                SNAPSHOT_DT,
                SNAPSHOT_MONTH,
                SNAPSHOT_YEAR,
                CLIENT_KEY,
                CLIENT_CD,
                CLIENT_ID,
                CLIENT_CRM_CD,
                SHORT_CLIENT_RU_NAM,
                INN,
                BUSINESS_CATEGORY_KEY,
                CREDIT_RATING_KEY,
                ACTIVITY_TYPE_KEY,
                REG_COUNTRY_KEY,
                RISK_COUNTRY_KEY,
                PARTIES_TYPE_KEY,
                LAUNDERING_RISK_FLG,
                ORG_TYPE_KEY,
                GRF_GROUP_KEY,
                GROUP_KEY,
                MEMBER_KEY,
                FAILURE_FLG,
                BRANCH_OFFICE_CD,
                CLIENT_SRC_KEY,
                CLIENT_ACTIVE_KEY,
                PROCESS_KEY,
                INSERT_DT
              )
  SELECT  SNAPSHOT_CD,
          SNAPSHOT_DT,
          SNAPSHOT_MONTH,
          SNAPSHOT_YEAR,
          CL.CLIENT_KEY,
          CLIENT_CD,
          CLIENT_ID,
          CLIENT_CRM_CD,
          SHORT_CLIENT_RU_NAM,
          INN,
          BUSINESS_CATEGORY_KEY,
          CREDIT_RATING_KEY,
          ACTIVITY_TYPE_KEY,
          REG_COUNTRY_KEY,
          RISK_COUNTRY_KEY,
          PARTIES_TYPE_KEY,
          LAUNDERING_RISK_FLG,
          ORG_TYPE_KEY,
          GRF_GROUP_KEY,
          GROUP_KEY,
          MEMBER_KEY,
          FAILURE_FLG,
          BRANCH_OFFICE_CD,
          CLIENT_SRC_KEY,
          case when CURR = 1 and PREV = 1 then 2
               when CURR = 1 and PREV = 0 then 1
               when CURR = 0 and PREV = 1 then 0 
          end  CLIENT_ACTIVE_KEY,
          PROCESS_KEY,
          INSERT_DT
  FROM (
        (
        select 
        SNAPSHOT_CD,
        CLIENT_KEY
        ,max(case when SNAPSHOT_DT = p_REPORT_DT then 1 else 0 end) CURR
        ,max(case when SNAPSHOT_DT = ADD_MONTHS(p_REPORT_DT ,-1) then 1 else 0 end) PREV
        from DM.DM_CGP
        where SNAPSHOT_DT in (ADD_MONTHS(p_REPORT_DT ,-1), p_REPORT_DT )
        group by CLIENT_KEY,SNAPSHOT_CD
        ) CGP
        LEFT JOIN
          (SELECT 
            p_REPORT_DT                       AS SNAPSHOT_DT,
            EXTRACT (MONTH FROM p_REPORT_DT ) AS SNAPSHOT_MONTH,
            EXTRACT (YEAR FROM p_REPORT_DT )  AS SNAPSHOT_YEAR,
            CLIENT_KEY,
            CLIENT_CD,
            CLIENT_ID,
            CLIENT_CRM_CD,
            SHORT_CLIENT_RU_NAM,
            INN,
            BUSINESS_CATEGORY_KEY,
            CREDIT_RATING_KEY,
            ACTIVITY_TYPE_KEY,
            REG_COUNTRY_KEY,
            RISK_COUNTRY_KEY,
            PARTIES_TYPE_KEY,
            LAUNDERING_RISK_FLG,
            ORG_TYPE_KEY,
            GRF_GROUP_KEY,
            GROUP_KEY,
            MEMBER_KEY,
            FAILURE_FLG,
            BRANCH_OFFICE_CD,
            1 CLIENT_SRC_KEY,
            PROCESS_KEY,
            SYSDATE INSERT_DT
          FROM DWH.CLIENTS CL
          WHERE CL.VALID_TO_DTTM = TO_DATE('01.01.2400','DD.MM.YYYY')
          ) CL
        ON CL.CLIENT_KEY = CGP.CLIENT_KEY );
 ---
  dm.u_log(p_proc => 'P_DM_CLIENTS',
           p_step => 'insert into DM_CLIENTS',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');
 --- 
  commit;
  
  
  end;
/

