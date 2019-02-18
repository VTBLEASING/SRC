create or replace force view dm.v$v_dre_writeoff as
select A.CLIENT_INN
       ,A.CLIENT_KEY AS CLIENT_ID
       ,C.CONTRACT_KEY AS CONTRACT_ID
       ,C.CONTRACT_NUM||' от '|| TO_CHAR(C.OPER_START_DT) AS CONTRACT_NUM_FULL
       ,C.CONTRACT_NUM AS CONTRACT_NUM
       ,E.PRESENTATION as APP_NAME
       ,SUBSTR(E.PRESENTATION,1, 34) as APP_NAME_SHRT
       ,A.APP_1C_NUM AS APP_1C_NUM
       ,D.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
       ,C.REHIRING_DT AS REHIRING_DT
       ,D.GROUP_KEY AS GROUP_KEY
       ,C.REHIRING_FLG AS REHIRING_FLG
       ,A.DATE_WRITEOFF AS DATE_DEFAULT--change
       ,B.DATE_WRITEOFF_CNCL AS DATE_DEFAULT_CNCL--change
       ,'Списание' AS DEFAULT_EVENT--change
       ,A.CONTRACT_APP_KEY AS CONTRACT_APP_KEY
       ,'' AS SOURCE_ITEM
FROM
       (select 'N_'||row_number() over(ORDER BY DATE_WRITEOFF) as ANUM--change
               ,contract_num_shrt AS CONTRACT_NUM_SHRT
               ,CLIENT_INN AS CLIENT_INN
               ,APP_1C_NUM as APP_1C_NUM
               ,CONTRACT_KEY AS CONTRACT_KEY
               ,CONTRACT_APP_KEY AS CONTRACT_APP_KEY
               ,DATE_WRITEOFF
               ,REPORT_DT AS REPORT_DT
               ,CLIENT_KEY AS CLIENT_KEY
               from dwh.default_base_table
               where DATE_WRITEOFF is null and
               VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')--change
        ) A
left join
        (select 'N_'||row_number() over(ORDER BY DATE_WRITEOFF_CNCL) as ANUM--change
                ,contract_num_shrt AS CONTRACT_NUM_SHRT
                ,CLIENT_INN AS CLIENT_INN
                ,CAST(APP_1C_NUM AS VARCHAR2(100)) as APP_1C_NUM
                ,CLIENT_KEY AS CLIENT_KEY
                ,CONTRACT_KEY AS CONTRACT_KEY
                ,DATE_WRITEOFF_CNCL
                ,REPORT_DT AS REPORT_DTB--change
                ,CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                from dwh.default_base_table
                where
              --  DATE_WRITEOFF_CNCL is not null and
                VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')--change
         ) B
         on
         a.CONTRACT_APP_KEY=b.CONTRACT_app_KEY
LEFT JOIN
         (select distinct CONTRACT_NUM AS CONTRACT_NUM
                          ,CLIENT_KEY AS CLIENT_KEY, CONTRACT_KEY AS CONTRACT_KEY
                          ,REHIRING_DT AS REHIRING_DT
                          ,REHIRING_FLG AS REHIRING_FLG
                          ,OPER_START_DT AS OPER_START_DT
                          from DWH.CONTRACTS
                          WHERE  VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')
          ) C
          ON A.CONTRACT_KEY = C.CONTRACT_KEY
LEFT JOIN
         (select distinct CLIENT_KEY AS CLIENT_KEY
                          ,FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
                          ,GROUP_KEY AS GROUP_KEY
                          from DWH.CLIENTS
                          WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')
         ) D
         ON A.CLIENT_KEY=D.CLIENT_KEY
LEFT JOIN
         (select distinct PRESENTATION AS PRESENTATION
                          ,contract_app_key as CONTRACT_APP_KEY
                          from DWH.LEASING_CONTRACTS_APPLS
                          WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')
         ) E
         ON A.CONTRACT_APP_KEY=E.CONTRACT_APP_KEY
;

