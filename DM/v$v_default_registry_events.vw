CREATE OR REPLACE FORCE VIEW DM.V$V_DEFAULT_REGISTRY_EVENTS AS
WITH S1 AS
(select DISTINCT R.CONTRACT_ID AS CONTRACT_ID,R.CONTRACT_NUM_FULL AS CONTRACT_NUM_FULL
                  ,R.CONTRACT_NUM AS CONTRACT_NUM,E.PRESENTATION as APP_NAME,SUBSTR(E.PRESENTATION,1, 34) as APP_NAME_SHRT
                  ,R.APP_1C_NUM AS APP_1C_NUM, R.CLIENT_KEY AS CLIENT_ID, R.CLIENT_INN AS CLIENT_INN
                  ,R.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM , R.REHIRING_DT AS REHIRING_DT, R.GROUP_KEY AS GROUP_KEY
                  ,R.REHIRING_FLG AS REHIRING_FLG,R.DATE_DEFAULT AS DATE_DEFAULT
                  ,R.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,R.DEFAULT_EVENT AS DEFAULT_EVENT
                  ,R.CONTRACT_APP_KEY AS CONTRACT_APP_KEY,R.CLIENT_KEY AS CLIENT_KEY from
(SELECT DISTINCT
                  M.CONTRACT_KEY AS CONTRACT_ID
                  ,M.REHIRING_DT AS REHIRING_DT
                  ,M.REHIRING_FLG AS REHIRING_FLG
                  ,M.CONTRACT_NUM AS CONTRACT_NUM
                  ,case
when M.CONTRACT_NUM IS NOT NULL AND M.OPER_START_DT IS NOT NULL THEN M.CONTRACT_NUM||' от '|| TO_CHAR(M.OPER_START_DT)
  when  M.CONTRACT_NUM IS NOT NULL AND M.OPER_START_DT IS NULL THEN M.CONTRACT_NUM||' от '|| '(даты начала договора нет)'
    when  M.CONTRACT_NUM IS NULL AND M.OPER_START_DT IS NOT NULL THEN '(Номера контракта нет)'||' от '|| TO_CHAR (M.OPER_start_dt)
  ELSE NULL END AS CONTRACT_NUM_FULL
                  ,M.OPER_START_DT AS OPER_START_DT
                  ,M.CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                  ,D.CLIENT_KEY AS CLIENT_KEY
                  ,D.GROUP_KEY AS GROUP_KEY
                  ,D.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
                  ,M.CLIENT_INN AS CLIENT_INN
                  ,M.APP_1C_NUM AS APP_1C_NUM
                  ,M.ANUMA as ANUMA, M.ANUMB as ANUMB
                  ,M.REPORT_DTB AS REPORT_DTB
                  ,M.DATE_DEFAULT AS DATE_DEFAULT
                  ,M.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,M.DEFAULT_EVENT as DEFAULT_EVENT
                  ,M.REPORT_DTA AS REPORT_DTA
                  FROM (SELECT DISTINCT
                  C.REHIRING_DT AS REHIRING_DT
                  ,C.REHIRING_FLG AS REHIRING_FLG
                  ,C.CONTRACT_NUM AS CONTRACT_NUM
                  ,C.CONTRACT_KEY AS CONTRACT_KEY
                  ,C.OPER_START_DT AS OPER_START_DT
                  ,k.contract_app_key as CONTRACT_APP_KEY
                  ,K.APP_1C_NUM AS APP_1C_NUM
                  ,K.CLIENT_KEY AS CLIENT_KEY
                  ,K.CLIENT_INN AS CLIENT_INN
                  ,K.DATE_DEFAULT AS DATE_DEFAULT
                  ,K.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,K.ANUMA as ANUMA, K.ANUMB as ANUMB
                  ,K.REPORT_DTA AS REPORT_DTA
                  ,K.REPORT_DTB AS REPORT_DTB
                  ,K.DEFAULT_EVENT as DEFAULT_EVENT from
		  (SELECT DISTINCT   A.CLIENT_INN AS CLIENT_INN, A.DATE_TERMINATION AS DATE_DEFAULT,A.CONTRACT_NUM_SHRT AS CONTRACT_NUM_SHRT
                  ,A.CONTRACT_APP_KEY AS CONTRACT_APP_KEY,A.APP_1C_NUM AS APP_1C_NUM
                  ,A.CONTRACT_KEY AS CONTRACT_KEY, A.CLIENT_KEY AS CLIENT_KEY
                  ,a.ANUM as ANUMA, b.ANUM as ANUMB,A.REPORT_DT AS REPORT_DTA
                  ,B.DATE_TERMINATION_CNCL AS DATE_DEFAULT_CNCL,B.REPORT_DTB AS REPORT_DTB
                  ,'Расторжение' as DEFAULT_EVENT FROM
                                  (select 'N_'||row_number() over(ORDER BY date_termination) as ANUM
                                          , contract_num_shrt AS CONTRACT_NUM_SHRT
                                          ,CLIENT_INN AS CLIENT_INN, APP_1C_NUM as APP_1C_NUM
                                          ,CONTRACT_KEY AS CONTRACT_KEY,CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                                          ,date_termination AS DATE_TERMINATION, REPORT_DT AS REPORT_DT
                                          ,CLIENT_KEY AS CLIENT_KEY
                                    from dwh.default_base_table
                                    where date_termination is not null and VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) A
                                    left join (select 'N_'||row_number() over(ORDER BY date_termination_cncl) as ANUM
                                    , contract_num_shrt AS CONTRACT_NUM_SHRT
                                    ,CLIENT_INN AS CLIENT_INN, CAST(APP_1C_NUM AS VARCHAR2(100)) as APP_1C_NUM
                                    , CLIENT_KEY AS CLIENT_KEY,CONTRACT_KEY AS CONTRACT_KEY
                                    ,date_termination_cncl AS DATE_TERMINATION_cncl, REPORT_DT AS REPORT_DTB
                                    , CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                                    from dwh.default_base_table
                                    where date_termination_cncl is not null AND VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) B on
                                    a.CONTRACT_APP_KEY=b.CONTRACT_app_KEY) K
                  INNER JOIN (select distinct CONTRACT_NUM AS CONTRACT_NUM,CLIENT_KEY AS CLIENT_KEY, CONTRACT_KEY AS CONTRACT_KEY
                  ,REHIRING_DT AS REHIRING_DT,REHIRING_FLG AS REHIRING_FLG, OPER_START_DT AS OPER_START_DT from DWH.CONTRACTS
                  WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) C
                  ON K.CONTRACT_KEY = C.CONTRACT_KEY) M
                  LEFT JOIN (select distinct CLIENT_KEY AS CLIENT_KEY,FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
                  ,GROUP_KEY AS GROUP_KEY from DWH.CLIENTS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) D
                  ON M.CLIENT_KEY=D.CLIENT_KEY) R
                  LEFT JOIN (select distinct PRESENTATION AS PRESENTATION, contract_app_key as CONTRACT_APP_KEY
                  from DWH.LEASING_CONTRACTS_APPLS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) E
				  ON R.CONTRACT_APP_KEY=E.CONTRACT_APP_KEY )
				  ,S2 AS (select DISTINCT   R.CONTRACT_ID AS CONTRACT_ID,R.CONTRACT_NUM_FULL AS CONTRACT_NUM_FULL
                  ,R.CONTRACT_NUM AS CONTRACT_NUM,E.PRESENTATION as APP_NAME,SUBSTR(E.PRESENTATION,1, 34) as APP_NAME_SHRT
                  ,R.APP_1C_NUM AS APP_1C_NUM, R.CLIENT_KEY AS CLIENT_ID, R.CLIENT_INN AS CLIENT_INN
                  ,R.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM , R.REHIRING_DT AS REHIRING_DT, R.GROUP_KEY AS GROUP_KEY
                  ,R.REHIRING_FLG AS REHIRING_FLG,R.DATE_DEFAULT AS DATE_DEFAULT
                  ,R.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,R.DEFAULT_EVENT AS DEFAULT_EVENT
                  ,R.CONTRACT_APP_KEY AS CONTRACT_APP_KEY,R.CLIENT_KEY AS  CLIENT_KEY FROM
(SELECT DISTINCT   M.CONTRACT_KEY AS CONTRACT_ID
                  ,M.REHIRING_DT AS REHIRING_DT
                  ,M.REHIRING_FLG AS REHIRING_FLG
                  ,M.CONTRACT_NUM AS CONTRACT_NUM
                  ,case when M.CONTRACT_NUM IS NOT NULL AND M.OPER_START_DT IS NOT NULL THEN M.CONTRACT_NUM||' от '|| TO_CHAR(M.OPER_START_DT)
  when  M.CONTRACT_NUM IS NOT NULL AND M.OPER_START_DT IS NULL THEN M.CONTRACT_NUM||' от '|| '(даты начала договора нет)'
    when  M.CONTRACT_NUM IS NULL AND M.OPER_START_DT IS NOT NULL THEN '(Номера контракта нет)'||' от '|| TO_CHAR (M.OPER_start_dt)
  ELSE NULL END AS CONTRACT_NUM_FULL
                  ,M.OPER_START_DT AS OPER_START_DT
                  ,M.CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                  ,D.CLIENT_KEY AS CLIENT_KEY
                  ,D.GROUP_KEY AS GROUP_KEY
                  ,D.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
                  ,M.CLIENT_INN AS CLIENT_INN
                  ,M.APP_1C_NUM AS APP_1C_NUM
                  ,M.ANUMA as ANUMA, M.ANUMB as ANUMB
                  ,M.REPORT_DTB AS REPORT_DTB
                  ,M.DATE_DEFAULT AS DATE_DEFAULT
                  ,M.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,M.DEFAULT_EVENT as DEFAULT_EVENT
                  ,M.REPORT_DTA AS REPORT_DTA FROM
(SELECT DISTINCT   C.REHIRING_DT AS REHIRING_DT
                  ,C.REHIRING_FLG AS REHIRING_FLG
                  ,C.CONTRACT_NUM AS CONTRACT_NUM
                  ,C.CONTRACT_KEY AS CONTRACT_KEY
                  ,C.OPER_START_DT AS OPER_START_DT
                  ,k.contract_app_key as CONTRACT_APP_KEY
                  ,K.APP_1C_NUM AS APP_1C_NUM
                  ,K.CLIENT_KEY AS CLIENT_KEY
                  ,K.CLIENT_INN AS CLIENT_INN
                  ,K.DATE_DEFAULT AS DATE_DEFAULT
                  ,K.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,K.ANUMA as ANUMA, K.ANUMB as ANUMB
                  ,K.REPORT_DTA AS REPORT_DTA
                  ,K.REPORT_DTB AS REPORT_DTB
                  ,K.DEFAULT_EVENT as DEFAULT_EVENT from
(SELECT DISTINCT   A.CLIENT_INN AS CLIENT_INN, A.DATE_ITEM_LOSS_CLIENT AS DATE_DEFAULT
                  ,A.CONTRACT_APP_KEY AS CONTRACT_APP_KEY,A.APP_1C_NUM AS APP_1C_NUM
                  ,A.CONTRACT_KEY AS CONTRACT_KEY, A.CLIENT_KEY AS CLIENT_KEY
                  ,a.ANUM as ANUMA, b.ANUM as ANUMB,A.REPORT_DT AS REPORT_DTA
                  ,B.DATE_ITEM_LOSSCNCL_CLIENT AS DATE_DEFAULT_CNCL,B.REPORT_DTB AS REPORT_DTB
                  ,'Риск потери ПЛ - неправомерные действия контрагентов' as DEFAULT_EVENT FROM
                                  (select 'N_'||row_number() over(ORDER BY DATE_ITEM_LOSS_CLIENT) as ANUM
                                          , contract_num_shrt AS CONTRACT_NUM_SHRT
                                          ,CLIENT_INN AS CLIENT_INN, APP_1C_NUM as APP_1C_NUM
                                          ,CONTRACT_KEY AS CONTRACT_KEY,CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                                          ,DATE_ITEM_LOSS_CLIENT AS DATE_ITEM_LOSS_CLIENT, REPORT_DT AS REPORT_DT
                                          ,CLIENT_KEY AS CLIENT_KEY
                                    from dwh.default_base_table
                                    where DATE_ITEM_LOSS_CLIENT is not null and VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) A
                                    left join (select 'N_'||row_number() over(ORDER BY DATE_ITEM_LOSSCNCL_CLIENT) as ANUM
                                    , contract_num_shrt AS CONTRACT_NUM_SHRT
                                    ,CLIENT_INN AS CLIENT_INN, CAST(APP_1C_NUM AS VARCHAR2(100)) as APP_1C_NUM
                                    , CLIENT_KEY AS CLIENT_KEY,CONTRACT_KEY AS CONTRACT_KEY
                                    ,DATE_ITEM_LOSSCNCL_CLIENT AS DATE_ITEM_LOSSCNCL_CLIENT, REPORT_DT AS REPORT_DTB
                                    , CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                                    from dwh.default_base_table
                                    where DATE_ITEM_LOSSCNCL_CLIENT is not null and VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) B
                                    on a.CONTRACT_APP_KEY=b.CONTRACT_app_KEY) K
                  LEFT JOIN (select distinct CONTRACT_NUM AS CONTRACT_NUM,CLIENT_KEY AS CLIENT_KEY, CONTRACT_KEY AS CONTRACT_KEY
                  ,REHIRING_DT AS REHIRING_DT,REHIRING_FLG AS REHIRING_FLG, OPER_START_DT AS OPER_START_DT
				  from DWH.CONTRACTS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) C
                  ON K.CONTRACT_KEY = C.CONTRACT_KEY) M
                  LEFT JOIN (select distinct CLIENT_KEY AS CLIENT_KEY,FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM, GROUP_KEY AS GROUP_KEY
				  from DWH.CLIENTS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) D
                  ON M.CLIENT_KEY=D.CLIENT_KEY) R
                  LEFT JOIN (select distinct PRESENTATION AS PRESENTATION, contract_app_key as CONTRACT_APP_KEY
                  from DWH.LEASING_CONTRACTS_APPLS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) E
				  ON R.CONTRACT_APP_KEY=E.CONTRACT_APP_KEY)
,S3 AS (select DISTINCT   R.CONTRACT_ID AS CONTRACT_ID,R.CONTRACT_NUM_FULL AS CONTRACT_NUM_FULL
                  ,R.CONTRACT_NUM AS CONTRACT_NUM,E.PRESENTATION as APP_NAME,SUBSTR(E.PRESENTATION,1, 34) as APP_NAME_SHRT
                  ,R.APP_1C_NUM AS APP_1C_NUM, R.CLIENT_KEY AS CLIENT_ID, R.CLIENT_INN AS CLIENT_INN
                  ,R.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM , R.REHIRING_DT AS REHIRING_DT, R.GROUP_KEY AS GROUP_KEY
                  ,R.REHIRING_FLG AS REHIRING_FLG,R.DATE_DEFAULT AS DATE_DEFAULT
                  ,R.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,R.DEFAULT_EVENT AS DEFAULT_EVENT
                  ,R.CONTRACT_APP_KEY AS CONTRACT_APP_KEY,R.CLIENT_KEY AS  CLIENT_KEY FROM
(SELECT DISTINCT   M.CONTRACT_KEY AS CONTRACT_ID
                  ,M.REHIRING_DT AS REHIRING_DT
                  ,M.REHIRING_FLG AS REHIRING_FLG
                  ,M.CONTRACT_NUM AS CONTRACT_NUM
                  ,case when M.CONTRACT_NUM IS NOT NULL AND M.OPER_START_DT IS NOT NULL THEN M.CONTRACT_NUM||' от '|| TO_CHAR(M.OPER_START_DT)
  when  M.CONTRACT_NUM IS NOT NULL AND M.OPER_START_DT IS NULL THEN M.CONTRACT_NUM||' от '|| '(даты начала договора нет)'
    when  M.CONTRACT_NUM IS NULL AND M.OPER_START_DT IS NOT NULL THEN '(Номера контракта нет)'||' от '|| TO_CHAR (M.OPER_start_dt)
  ELSE NULL END AS CONTRACT_NUM_FULL
                  ,M.OPER_START_DT AS OPER_START_DT
                  ,M.CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                  ,D.CLIENT_KEY AS CLIENT_KEY
                  ,D.GROUP_KEY AS GROUP_KEY
                  ,D.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
                  ,M.CLIENT_INN AS CLIENT_INN
                  ,M.APP_1C_NUM AS APP_1C_NUM
                  ,M.ANUMA as ANUMA, M.ANUMB as ANUMB
                  ,M.REPORT_DTB AS REPORT_DTB
                  ,M.DATE_DEFAULT AS DATE_DEFAULT
                  ,M.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,M.DEFAULT_EVENT as DEFAULT_EVENT
                  ,M.REPORT_DTA AS REPORT_DTA
                  FROM (SELECT DISTINCT C.REHIRING_DT AS REHIRING_DT
                  ,C.REHIRING_FLG AS REHIRING_FLG
                  ,C.CONTRACT_NUM AS CONTRACT_NUM
                  ,C.CONTRACT_KEY AS CONTRACT_KEY
                  ,C.OPER_START_DT AS OPER_START_DT
                  ,k.contract_app_key as CONTRACT_APP_KEY
                  ,K.APP_1C_NUM AS APP_1C_NUM
                  ,K.CLIENT_KEY AS CLIENT_KEY
                  ,K.CLIENT_INN AS CLIENT_INN
                  ,K.DATE_DEFAULT AS DATE_DEFAULT
                  ,K.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,K.ANUMA as ANUMA, K.ANUMB as ANUMB
                  ,K.REPORT_DTA AS REPORT_DTA
                  ,K.REPORT_DTB AS REPORT_DTB
                  ,K.DEFAULT_EVENT as DEFAULT_EVENT
				  from(SELECT DISTINCT   A.CLIENT_INN AS CLIENT_INN, A.DATE_ITEM_LOSS_INSURCOMP AS DATE_DEFAULT
                  ,A.CONTRACT_APP_KEY AS CONTRACT_APP_KEY,A.APP_1C_NUM AS APP_1C_NUM
                  ,A.CONTRACT_KEY AS CONTRACT_KEY, A.CLIENT_KEY AS CLIENT_KEY
                  ,a.ANUM as ANUMA, b.ANUM as ANUMB,A.REPORT_DT AS REPORT_DTA
                  ,B.DATE_ITEM_LOSSCNCL_INSURCOMP AS DATE_DEFAULT_CNCL,B.REPORT_DTB AS REPORT_DTB
                  ,'Риск потери ПЛ - отказ СК' as DEFAULT_EVENT FROM
                                  (select 'N_'||row_number() over(ORDER BY DATE_ITEM_LOSS_INSURCOMP) as ANUM
                                          , contract_num_shrt AS CONTRACT_NUM_SHRT
                                          ,CLIENT_INN AS CLIENT_INN, APP_1C_NUM as APP_1C_NUM
                                          ,CONTRACT_KEY AS CONTRACT_KEY,CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                                          ,DATE_ITEM_LOSS_INSURCOMP AS DATE_ITEM_LOSS_INSURCOMP, REPORT_DT AS REPORT_DT
                                          ,CLIENT_KEY AS CLIENT_KEY
                                    from dwh.default_base_table
                                    where DATE_ITEM_LOSS_INSURCOMP is not null and VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) A
                                    left join (select 'N_'||row_number() over(ORDER BY DATE_ITEM_LOSSCNCL_INSURCOMP) as ANUM
                                    , contract_num_shrt AS CONTRACT_NUM_SHRT
                                    , CLIENT_INN AS CLIENT_INN, CAST(APP_1C_NUM AS VARCHAR2(100)) as APP_1C_NUM
                                    , CLIENT_KEY AS CLIENT_KEY,CONTRACT_KEY AS CONTRACT_KEY
                                    , DATE_ITEM_LOSSCNCL_INSURCOMP AS DATE_ITEM_LOSSCNCL_INSURCOMP, REPORT_DT AS REPORT_DTB
                                    , CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                                    from dwh.default_base_table
                                    where DATE_ITEM_LOSSCNCL_INSURCOMP is not null and VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) B
                                    on a.CONTRACT_APP_KEY=b.CONTRACT_app_KEY) K
                  LEFT JOIN (select distinct CONTRACT_NUM AS CONTRACT_NUM,CLIENT_KEY AS CLIENT_KEY, CONTRACT_KEY AS CONTRACT_KEY
                  ,REHIRING_DT AS REHIRING_DT,REHIRING_FLG AS REHIRING_FLG, OPER_START_DT AS OPER_START_DT from DWH.CONTRACTS
                  WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) C
                  ON K.CONTRACT_KEY = C.CONTRACT_KEY) M
                  LEFT JOIN (select distinct CLIENT_KEY AS CLIENT_KEY,FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
                  ,GROUP_KEY AS GROUP_KEY from DWH.CLIENTS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) D
                  ON M.CLIENT_KEY=D.CLIENT_KEY) R
                  LEFT JOIN (select distinct PRESENTATION AS PRESENTATION, contract_app_key as CONTRACT_APP_KEY
                  from DWH.LEASING_CONTRACTS_APPLS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) E
				  ON R.CONTRACT_APP_KEY=E.CONTRACT_APP_KEY)
,S4 AS (select DISTINCT   R.CONTRACT_ID AS CONTRACT_ID,R.CONTRACT_NUM_FULL AS CONTRACT_NUM_FULL
                  ,R.CONTRACT_NUM AS CONTRACT_NUM,E.PRESENTATION as APP_NAME,SUBSTR(E.PRESENTATION,1, 34) as APP_NAME_SHRT
                  ,R.APP_1C_NUM AS APP_1C_NUM, R.CLIENT_KEY AS CLIENT_ID, R.CLIENT_INN AS CLIENT_INN
                  ,R.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM , R.REHIRING_DT AS REHIRING_DT, R.GROUP_KEY AS GROUP_KEY
                  ,R.REHIRING_FLG AS REHIRING_FLG,R.DATE_DEFAULT AS DATE_DEFAULT
                  ,R.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,R.DEFAULT_EVENT AS DEFAULT_EVENT
                  ,R.CONTRACT_APP_KEY AS CONTRACT_APP_KEY,R.CLIENT_KEY AS  CLIENT_KEY FROM
(SELECT DISTINCT   M.CONTRACT_KEY AS CONTRACT_ID
                  ,M.REHIRING_DT AS REHIRING_DT
                  ,M.REHIRING_FLG AS REHIRING_FLG
                  ,M.CONTRACT_NUM AS CONTRACT_NUM
                  ,case when M.CONTRACT_NUM IS NOT NULL AND M.OPER_START_DT IS NOT NULL THEN M.CONTRACT_NUM||' от '|| TO_CHAR(M.OPER_START_DT)
  when  M.CONTRACT_NUM IS NOT NULL AND M.OPER_START_DT IS NULL THEN M.CONTRACT_NUM||' от '|| '(даты начала договора нет)'
    when  M.CONTRACT_NUM IS NULL AND M.OPER_START_DT IS NOT NULL THEN '(Номера контракта нет)'||' от '|| TO_CHAR (M.OPER_start_dt)
  ELSE NULL END AS CONTRACT_NUM_FULL
                  ,M.OPER_START_DT AS OPER_START_DT
                  ,M.CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                  ,D.CLIENT_KEY AS CLIENT_KEY
                  ,D.GROUP_KEY AS GROUP_KEY
                  ,D.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
                  ,M.CLIENT_INN AS CLIENT_INN
                  ,M.APP_1C_NUM AS APP_1C_NUM
                  ,M.ANUMA as ANUMA, M.ANUMB as ANUMB
                  ,M.REPORT_DTB AS REPORT_DTB
                  ,M.DATE_DEFAULT AS DATE_DEFAULT
                  ,M.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,M.DEFAULT_EVENT as DEFAULT_EVENT
                  ,M.REPORT_DTA AS REPORT_DTA
                  FROM (SELECT DISTINCT C.REHIRING_DT AS REHIRING_DT
                  ,C.REHIRING_FLG AS REHIRING_FLG
                  ,C.CONTRACT_NUM AS CONTRACT_NUM
                  ,C.CONTRACT_KEY AS CONTRACT_KEY
                  ,C.OPER_START_DT AS OPER_START_DT
                  ,k.contract_app_key as CONTRACT_APP_KEY
                  ,K.APP_1C_NUM AS APP_1C_NUM
                  ,K.CLIENT_KEY AS CLIENT_KEY
                  ,K.CLIENT_INN AS CLIENT_INN
                  ,K.DATE_DEFAULT AS DATE_DEFAULT
                  ,K.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,K.ANUMA as ANUMA, K.ANUMB as ANUMB
                  ,K.REPORT_DTA AS REPORT_DTA
                  ,K.REPORT_DTB AS REPORT_DTB
                  ,K.DEFAULT_EVENT as DEFAULT_EVENT from
                  (SELECT DISTINCT A.CLIENT_INN AS CLIENT_INN, A.DATE_90 AS DATE_DEFAULT
                  ,A.CONTRACT_APP_KEY AS CONTRACT_APP_KEY,A.APP_1C_NUM AS APP_1C_NUM
                  ,A.CONTRACT_KEY AS CONTRACT_KEY, A.CLIENT_KEY AS CLIENT_KEY
                  ,a.ANUM as ANUMA, b.ANUM as ANUMB,A.REPORT_DT AS REPORT_DTA
                  ,B.DATE_90_CNCL AS DATE_DEFAULT_CNCL,B.REPORT_DTB AS REPORT_DTB
                  ,'90+' as DEFAULT_EVENT
                    FROM (select 'N_'||row_number() over(ORDER BY DATE_90) as ANUM
                                          , contract_num_shrt AS CONTRACT_NUM_SHRT
                                          ,CLIENT_INN AS CLIENT_INN, APP_1C_NUM as APP_1C_NUM
                                          ,CONTRACT_KEY AS CONTRACT_KEY,CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                                          ,DATE_90 AS DATE_90, REPORT_DT AS REPORT_DT
                                          ,CLIENT_KEY AS CLIENT_KEY
                                    from dwh.default_base_table
                                    where DATE_90 is not null and VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) A
                                    left join (select 'N_'||row_number() over(ORDER BY DATE_90_CNCL) as ANUM
                                    , contract_num_shrt AS CONTRACT_NUM_SHRT
                                    , CLIENT_INN AS CLIENT_INN, CAST(APP_1C_NUM AS VARCHAR2(100)) as APP_1C_NUM
                                    , CLIENT_KEY AS CLIENT_KEY,CONTRACT_KEY AS CONTRACT_KEY
                                    , DATE_90_CNCL AS DATE_90_CNCL, REPORT_DT AS REPORT_DTB
                                    , CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                                    from dwh.default_base_table
                                    where DATE_90_CNCL is not null and VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) B
                                    on a.CONTRACT_APP_KEY=b.CONTRACT_app_KEY) K
                  LEFT JOIN (select distinct CONTRACT_NUM AS CONTRACT_NUM,CLIENT_KEY AS CLIENT_KEY, CONTRACT_KEY AS CONTRACT_KEY
                  ,REHIRING_DT AS REHIRING_DT,REHIRING_FLG AS REHIRING_FLG, OPER_START_DT AS OPER_START_DT from DWH.CONTRACTS
                  WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) C
                  ON K.CONTRACT_KEY = C.CONTRACT_KEY)M
                  LEFT JOIN (select distinct CLIENT_KEY AS CLIENT_KEY,FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
                  ,GROUP_KEY AS GROUP_KEY from DWH.CLIENTS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) D
                  ON M.CLIENT_KEY=D.CLIENT_KEY) R
                  LEFT JOIN (select distinct PRESENTATION AS PRESENTATION, contract_app_key as CONTRACT_APP_KEY
                  from DWH.LEASING_CONTRACTS_APPLS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) E
				  ON R.CONTRACT_APP_KEY=E.CONTRACT_APP_KEY)
	,S5 AS (select DISTINCT   R.CONTRACT_ID AS CONTRACT_ID,R.CONTRACT_NUM_FULL AS CONTRACT_NUM_FULL
                  ,R.CONTRACT_NUM AS CONTRACT_NUM,E.PRESENTATION as APP_NAME,SUBSTR(E.PRESENTATION,1, 34) as APP_NAME_SHRT
                  ,R.APP_1C_NUM AS APP_1C_NUM, R.CLIENT_KEY AS CLIENT_ID, R.CLIENT_INN AS CLIENT_INN
                  ,R.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM , R.REHIRING_DT AS REHIRING_DT, R.GROUP_KEY AS GROUP_KEY
                  ,R.REHIRING_FLG AS REHIRING_FLG,R.DATE_DEFAULT AS DATE_DEFAULT
                  ,R.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,R.DEFAULT_EVENT AS DEFAULT_EVENT
                  ,R.CONTRACT_APP_KEY AS CONTRACT_APP_KEY,R.CLIENT_KEY AS  CLIENT_KEY FROM
(SELECT DISTINCT   M.CONTRACT_KEY AS CONTRACT_ID
                  ,M.REHIRING_DT AS REHIRING_DT
                  ,M.REHIRING_FLG AS REHIRING_FLG
                  ,M.CONTRACT_NUM AS CONTRACT_NUM
                  ,case when M.CONTRACT_NUM IS NOT NULL AND M.OPER_START_DT IS NOT NULL THEN M.CONTRACT_NUM||' от '|| TO_CHAR(M.OPER_START_DT)
  when  M.CONTRACT_NUM IS NOT NULL AND M.OPER_START_DT IS NULL THEN M.CONTRACT_NUM||' от '|| '(даты начала договора нет)'
    when  M.CONTRACT_NUM IS NULL AND M.OPER_START_DT IS NOT NULL THEN '(Номера контракта нет)'||' от '|| TO_CHAR (M.OPER_start_dt)
  ELSE NULL END AS CONTRACT_NUM_FULL
                  ,M.OPER_START_DT AS OPER_START_DT
                  ,M.CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                  ,D.CLIENT_KEY AS CLIENT_KEY
                  ,D.GROUP_KEY AS GROUP_KEY
                  ,D.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
                  ,M.CLIENT_INN AS CLIENT_INN
                  ,M.APP_1C_NUM AS APP_1C_NUM
                  ,M.ANUMA as ANUMA, M.ANUMB as ANUMB
                  ,M.REPORT_DTB AS REPORT_DTB
                  ,M.DATE_DEFAULT AS DATE_DEFAULT
                  ,M.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,M.DEFAULT_EVENT as DEFAULT_EVENT
                  ,M.REPORT_DTA AS REPORT_DTA
                  FROM (SELECT DISTINCT C.REHIRING_DT AS REHIRING_DT
                  ,C.REHIRING_FLG AS REHIRING_FLG
                  ,C.CONTRACT_NUM AS CONTRACT_NUM
                  ,C.CONTRACT_KEY AS CONTRACT_KEY
                  ,C.OPER_START_DT AS OPER_START_DT
                  ,k.contract_app_key as CONTRACT_APP_KEY
                  ,K.APP_1C_NUM AS APP_1C_NUM
                  ,K.CLIENT_KEY AS CLIENT_KEY
                  ,K.CLIENT_INN AS CLIENT_INN
                  ,K.DATE_DEFAULT AS DATE_DEFAULT
                  ,K.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,K.ANUMA as ANUMA, K.ANUMB as ANUMB
                  ,K.REPORT_DTA AS REPORT_DTA
                  ,K.REPORT_DTB AS REPORT_DTB
                  ,K.DEFAULT_EVENT as DEFAULT_EVENT
				  from (SELECT DISTINCT   A.CLIENT_INN AS CLIENT_INN, A.DATE_RESERVE_ESTB AS DATE_DEFAULT
                  ,A.CONTRACT_APP_KEY AS CONTRACT_APP_KEY,A.APP_1C_NUM AS APP_1C_NUM
                  ,A.CONTRACT_KEY AS CONTRACT_KEY, A.CLIENT_KEY AS CLIENT_KEY
                  ,a.ANUM as ANUMA, b.ANUM as ANUMB,A.REPORT_DT AS REPORT_DTA
                  ,B.DATE_RESERVE_ESTB_CNCL AS DATE_DEFAULT_CNCL,B.REPORT_DTB AS REPORT_DTB
                  ,'Резерв по требованию (наличие ИПО)' as DEFAULT_EVENT
                    FROM (select 'N_'||row_number() over(ORDER BY DATE_RESERVE_ESTB) as ANUM
                                          ,contract_num_shrt AS CONTRACT_NUM_SHRT
                                          ,CLIENT_INN AS CLIENT_INN, APP_1C_NUM as APP_1C_NUM
                                          ,CONTRACT_KEY AS CONTRACT_KEY,CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                                          ,DATE_RESERVE_ESTB AS DATE_RESERVE_ESTB, REPORT_DT AS REPORT_DT
                                          ,CLIENT_KEY AS CLIENT_KEY
                                    from dwh.default_base_table
                                    where DATE_RESERVE_ESTB is not null and VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) A
                                    left join (select 'N_'||row_number() over(ORDER BY DATE_RESERVE_ESTB_CNCL) as ANUM
                                    , contract_num_shrt AS CONTRACT_NUM_SHRT
                                    , CLIENT_INN AS CLIENT_INN, CAST(APP_1C_NUM AS VARCHAR2(100)) as APP_1C_NUM
                                    , CLIENT_KEY AS CLIENT_KEY,CONTRACT_KEY AS CONTRACT_KEY
                                    , DATE_RESERVE_ESTB_CNCL AS DATE_RESERVE_ESTB_CNCL, REPORT_DT AS REPORT_DTB
                                    , CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                                    from dwh.default_base_table
                                    where DATE_RESERVE_ESTB_CNCL is not null and VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) B
                                    on a.CONTRACT_APP_KEY=b.CONTRACT_app_KEY) K
                  LEFT JOIN (select distinct CONTRACT_NUM AS CONTRACT_NUM,CLIENT_KEY AS CLIENT_KEY, CONTRACT_KEY AS CONTRACT_KEY
                  ,REHIRING_DT AS REHIRING_DT,REHIRING_FLG AS REHIRING_FLG, OPER_START_DT AS OPER_START_DT from DWH.CONTRACTS
                  WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) C
                  ON K.CONTRACT_KEY = C.CONTRACT_KEY) M
                  LEFT JOIN (select distinct CLIENT_KEY AS CLIENT_KEY,FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
                  ,GROUP_KEY AS GROUP_KEY from DWH.CLIENTS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) D
                  ON M.CLIENT_KEY=D.CLIENT_KEY) R
                  LEFT JOIN (select distinct PRESENTATION AS PRESENTATION, contract_app_key as CONTRACT_APP_KEY
                  from DWH.LEASING_CONTRACTS_APPLS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) E
				  ON R.CONTRACT_APP_KEY=E.CONTRACT_APP_KEY)
        ,S6 AS (select DISTINCT   R.CONTRACT_ID AS CONTRACT_ID,R.CONTRACT_NUM_FULL AS CONTRACT_NUM_FULL
                  ,R.CONTRACT_NUM AS CONTRACT_NUM,E.PRESENTATION as APP_NAME,SUBSTR(E.PRESENTATION,1, 34) as APP_NAME_SHRT
                  ,R.APP_1C_NUM AS APP_1C_NUM, R.CLIENT_KEY AS CLIENT_ID, R.CLIENT_INN AS CLIENT_INN
                  ,R.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM , R.REHIRING_DT AS REHIRING_DT, R.GROUP_KEY AS GROUP_KEY
                  ,R.REHIRING_FLG AS REHIRING_FLG,R.DATE_DEFAULT AS DATE_DEFAULT
                  ,R.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,R.DEFAULT_EVENT AS DEFAULT_EVENT
                  ,R.CONTRACT_APP_KEY AS CONTRACT_APP_KEY,R.CLIENT_KEY AS  CLIENT_KEY FROM
                  (SELECT DISTINCT M.CONTRACT_KEY AS CONTRACT_ID
                  ,M.REHIRING_DT AS REHIRING_DT
                  ,M.REHIRING_FLG AS REHIRING_FLG
                  ,M.CONTRACT_NUM AS CONTRACT_NUM
                  ,case when M.CONTRACT_NUM IS NOT NULL AND M.OPER_START_DT IS NOT NULL THEN M.CONTRACT_NUM||' от '|| TO_CHAR(M.OPER_START_DT)
  when  M.CONTRACT_NUM IS NOT NULL AND M.OPER_START_DT IS NULL THEN M.CONTRACT_NUM||' от '|| '(даты начала договора нет)'
    when  M.CONTRACT_NUM IS NULL AND M.OPER_START_DT IS NOT NULL THEN '(Номера контракта нет)'||' от '|| TO_CHAR (M.OPER_start_dt)
  ELSE NULL END AS CONTRACT_NUM_FULL
                  ,M.OPER_START_DT AS OPER_START_DT
                  ,M.CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                  ,D.CLIENT_KEY AS CLIENT_KEY
                  ,D.GROUP_KEY AS GROUP_KEY
                  ,D.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
                  ,M.CLIENT_INN AS CLIENT_INN
                  ,M.APP_1C_NUM AS APP_1C_NUM
                  ,M.ANUMA as ANUMA, M.ANUMB as ANUMB
                  ,M.REPORT_DTB AS REPORT_DTB
                  ,M.DATE_DEFAULT AS DATE_DEFAULT
                  ,M.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,M.DEFAULT_EVENT as DEFAULT_EVENT
                  ,M.REPORT_DTA AS REPORT_DTA
                  FROM (SELECT DISTINCT C.REHIRING_DT AS REHIRING_DT
                  ,C.REHIRING_FLG AS REHIRING_FLG
                  ,C.CONTRACT_NUM AS CONTRACT_NUM
                  ,C.CONTRACT_KEY AS CONTRACT_KEY
                  ,C.OPER_START_DT AS OPER_START_DT
                  ,k.contract_app_key as CONTRACT_APP_KEY
                  ,K.APP_1C_NUM AS APP_1C_NUM
                  ,K.CLIENT_KEY AS CLIENT_KEY
                  ,K.CLIENT_INN AS CLIENT_INN
                  ,K.DATE_DEFAULT AS DATE_DEFAULT
                  ,K.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,K.ANUMA as ANUMA, K.ANUMB as ANUMB
                  ,K.REPORT_DTA AS REPORT_DTA
                  ,K.REPORT_DTB AS REPORT_DTB
                  ,K.DEFAULT_EVENT as DEFAULT_EVENT
				  from (SELECT DISTINCT   A.CLIENT_INN AS CLIENT_INN, A.DATE_WRITEOFF AS DATE_DEFAULT
                  ,A.CONTRACT_APP_KEY AS CONTRACT_APP_KEY,A.APP_1C_NUM AS APP_1C_NUM
                  ,A.CONTRACT_KEY AS CONTRACT_KEY, A.CLIENT_KEY AS CLIENT_KEY
                  ,a.ANUM as ANUMA, b.ANUM as ANUMB,A.REPORT_DT AS REPORT_DTA
                  ,B.DATE_WRITEOFF_CNCL AS DATE_DEFAULT_CNCL,B.REPORT_DTB AS REPORT_DTB
                  ,'Списание' as DEFAULT_EVENT
                    FROM (select 'N_'||row_number() over(ORDER BY DATE_WRITEOFF) as ANUM
                                          , contract_num_shrt AS CONTRACT_NUM_SHRT
                                          ,CLIENT_INN AS CLIENT_INN, APP_1C_NUM as APP_1C_NUM
                                          ,CONTRACT_KEY AS CONTRACT_KEY,CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                                          ,DATE_WRITEOFF AS DATE_WRITEOFF, REPORT_DT AS REPORT_DT
                                          ,CLIENT_KEY AS CLIENT_KEY
                                    from dwh.default_base_table
                                    where DATE_WRITEOFF is not null and VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) A
                                    left join (select 'N_'||row_number() over(ORDER BY DATE_WRITEOFF_CNCL) as ANUM
                                    , contract_num_shrt AS CONTRACT_NUM_SHRT
                                    , CLIENT_INN AS CLIENT_INN, CAST(APP_1C_NUM AS VARCHAR2(100)) as APP_1C_NUM
                                    , CLIENT_KEY AS CLIENT_KEY,CONTRACT_KEY AS CONTRACT_KEY
                                    , DATE_WRITEOFF_CNCL AS DATE_WRITEOFF_CNCL, REPORT_DT AS REPORT_DTB
                                    , CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                                    from dwh.default_base_table
                                    where DATE_WRITEOFF_CNCL is not null and VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) B
                                    on a.CONTRACT_APP_KEY=b.CONTRACT_app_KEY) K
                  LEFT JOIN (select distinct CONTRACT_NUM AS CONTRACT_NUM,CLIENT_KEY AS CLIENT_KEY, CONTRACT_KEY AS CONTRACT_KEY
                  ,REHIRING_DT AS REHIRING_DT,REHIRING_FLG AS REHIRING_FLG, OPER_START_DT AS OPER_START_DT from DWH.CONTRACTS
                  WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) C
                  ON K.CONTRACT_KEY = C.CONTRACT_KEY)M
                  LEFT JOIN (select distinct CLIENT_KEY AS CLIENT_KEY,FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
                  ,GROUP_KEY AS GROUP_KEY from DWH.CLIENTS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) D
                  ON M.CLIENT_KEY=D.CLIENT_KEY) R
                  LEFT JOIN (select distinct PRESENTATION AS PRESENTATION, contract_app_key as CONTRACT_APP_KEY
                  from DWH.LEASING_CONTRACTS_APPLS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) E
				  ON R.CONTRACT_APP_KEY=E.CONTRACT_APP_KEY)
        ,S7 AS (select DISTINCT   R.CONTRACT_ID AS CONTRACT_ID,R.CONTRACT_NUM_FULL AS CONTRACT_NUM_FULL
                  ,R.CONTRACT_NUM AS CONTRACT_NUM,E.PRESENTATION as APP_NAME,SUBSTR(E.PRESENTATION,1, 34) as APP_NAME_SHRT
                  ,R.APP_1C_NUM AS APP_1C_NUM, R.CLIENT_KEY AS CLIENT_ID, R.CLIENT_INN AS CLIENT_INN
                  ,R.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM , R.REHIRING_DT AS REHIRING_DT, R.GROUP_KEY AS GROUP_KEY
                  ,R.REHIRING_FLG AS REHIRING_FLG,R.DATE_DEFAULT AS DATE_DEFAULT
                  ,R.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,R.DEFAULT_EVENT AS DEFAULT_EVENT
                  ,R.CONTRACT_APP_KEY AS CONTRACT_APP_KEY,R.CLIENT_KEY AS  CLIENT_KEY
				  FROM(SELECT DISTINCT M.CONTRACT_KEY AS CONTRACT_ID
                  ,M.REHIRING_DT AS REHIRING_DT
                  ,M.REHIRING_FLG AS REHIRING_FLG
                  ,M.CONTRACT_NUM AS CONTRACT_NUM
                  ,case when M.CONTRACT_NUM IS NOT NULL AND M.OPER_START_DT IS NOT NULL THEN M.CONTRACT_NUM||' от '|| TO_CHAR(M.OPER_START_DT)
  when  M.CONTRACT_NUM IS NOT NULL AND M.OPER_START_DT IS NULL THEN M.CONTRACT_NUM||' от '|| '(даты начала договора нет)'
    when  M.CONTRACT_NUM IS NULL AND M.OPER_START_DT IS NOT NULL THEN '(Номера контракта нет)'||' от '|| TO_CHAR (M.OPER_start_dt)
  ELSE NULL END AS CONTRACT_NUM_FULL
                  ,M.OPER_START_DT AS OPER_START_DT
                  ,M.CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                  ,D.CLIENT_KEY AS CLIENT_KEY
                  ,D.GROUP_KEY AS GROUP_KEY
                  ,D.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
                  ,M.CLIENT_INN AS CLIENT_INN
                  ,M.APP_1C_NUM AS APP_1C_NUM
                  ,M.ANUMA as ANUMA, M.ANUMB as ANUMB
                  ,M.REPORT_DTB AS REPORT_DTB
                  ,M.DATE_DEFAULT AS DATE_DEFAULT
                  ,M.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,M.DEFAULT_EVENT as DEFAULT_EVENT
                  ,M.REPORT_DTA AS REPORT_DTA
                  FROM (SELECT DISTINCT REHIRING_DT AS REHIRING_DT
                  ,C.REHIRING_FLG AS REHIRING_FLG
                  ,C.CONTRACT_NUM AS CONTRACT_NUM
                  ,C.CONTRACT_KEY AS CONTRACT_KEY
                  ,C.OPER_START_DT AS OPER_START_DT
                  ,k.contract_app_key as CONTRACT_APP_KEY
                  ,K.APP_1C_NUM AS APP_1C_NUM
                  ,K.CLIENT_KEY AS CLIENT_KEY
                  ,K.CLIENT_INN AS CLIENT_INN
                  ,K.DATE_DEFAULT AS DATE_DEFAULT
                  ,K.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,K.ANUMA as ANUMA, K.ANUMB as ANUMB
                  ,K.REPORT_DTA AS REPORT_DTA
                  ,K.REPORT_DTB AS REPORT_DTB
                  ,K.DEFAULT_EVENT as DEFAULT_EVENT
        from (SELECT DISTINCT A.CLIENT_INN AS CLIENT_INN, A.DATE_BANCRUPTCY AS DATE_DEFAULT
                  ,A.CONTRACT_APP_KEY AS CONTRACT_APP_KEY,A.APP_1C_NUM AS APP_1C_NUM
                  ,A.CONTRACT_KEY AS CONTRACT_KEY, A.CLIENT_KEY AS CLIENT_KEY
                  ,a.ANUM as ANUMA, b.ANUM as ANUMB,A.REPORT_DT AS REPORT_DTA
                  ,B.DATE_BANCRUPTCY_CNCL AS DATE_DEFAULT_CNCL,B.REPORT_DTB AS REPORT_DTB
                  ,'Банкротство/ликвидация контрагента' as DEFAULT_EVENT
                    FROM (select 'N_'||row_number() over(ORDER BY DATE_WRITEOFF) as ANUM
                                          , contract_num_shrt AS CONTRACT_NUM_SHRT
                                          ,CLIENT_INN AS CLIENT_INN, APP_1C_NUM as APP_1C_NUM
                                          ,CONTRACT_KEY AS CONTRACT_KEY,CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                                          ,DATE_BANCRUPTCY AS DATE_BANCRUPTCY, REPORT_DT AS REPORT_DT
                                          ,CLIENT_KEY AS CLIENT_KEY
                                    from dwh.default_base_table
                                    where DATE_BANCRUPTCY is not null and VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) A
                                    left join (select 'N_'||row_number() over(ORDER BY DATE_BANCRUPTCY_CNCL) as ANUM
                                    , contract_num_shrt AS CONTRACT_NUM_SHRT
                                    , CLIENT_INN AS CLIENT_INN, CAST(APP_1C_NUM AS VARCHAR2(100)) as APP_1C_NUM
                                    , CLIENT_KEY AS CLIENT_KEY,CONTRACT_KEY AS CONTRACT_KEY
                                    , DATE_BANCRUPTCY_CNCL AS DATE_BANCRUPTCY_CNCL, REPORT_DT AS REPORT_DTB
                                    , CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                                    from dwh.default_base_table
                                    where DATE_BANCRUPTCY_CNCL is not null and VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) B
                                    on a.CONTRACT_APP_KEY=b.CONTRACT_app_KEY) K
                  LEFT JOIN (select distinct CONTRACT_NUM AS CONTRACT_NUM,CLIENT_KEY AS CLIENT_KEY, CONTRACT_KEY AS CONTRACT_KEY
                  ,REHIRING_DT AS REHIRING_DT,REHIRING_FLG AS REHIRING_FLG, OPER_START_DT AS OPER_START_DT from DWH.CONTRACTS
                  WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) C
                  ON K.CONTRACT_KEY = C.CONTRACT_KEY)M
                  LEFT JOIN (select distinct CLIENT_KEY AS CLIENT_KEY,FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
                  ,GROUP_KEY AS GROUP_KEY from DWH.CLIENTS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) D
                  ON M.CLIENT_KEY=D.CLIENT_KEY) R
                  LEFT JOIN (select distinct PRESENTATION AS PRESENTATION, contract_app_key as CONTRACT_APP_KEY
                  from DWH.LEASING_CONTRACTS_APPLS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) E
				  ON R.CONTRACT_APP_KEY=E.CONTRACT_APP_KEY)
        ,S8 AS (select DISTINCT   R.CONTRACT_ID AS CONTRACT_ID,R.CONTRACT_NUM_FULL AS CONTRACT_NUM_FULL
                  ,R.CONTRACT_NUM AS CONTRACT_NUM,E.PRESENTATION as APP_NAME,SUBSTR(E.PRESENTATION,1, 34) as APP_NAME_SHRT
                  ,R.APP_1C_NUM AS APP_1C_NUM, R.CLIENT_KEY AS CLIENT_ID, R.CLIENT_INN AS CLIENT_INN
                  ,R.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM , R.REHIRING_DT AS REHIRING_DT, R.GROUP_KEY AS GROUP_KEY
                  ,R.REHIRING_FLG AS REHIRING_FLG,R.DATE_DEFAULT AS DATE_DEFAULT
                  ,R.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,R.DEFAULT_EVENT AS DEFAULT_EVENT
                  ,R.CONTRACT_APP_KEY AS CONTRACT_APP_KEY,R.CLIENT_KEY AS  CLIENT_KEY FROM
            (SELECT DISTINCT   M.CONTRACT_KEY AS CONTRACT_ID
                  ,M.REHIRING_DT AS REHIRING_DT
                  ,M.REHIRING_FLG AS REHIRING_FLG
                  ,M.CONTRACT_NUM AS CONTRACT_NUM
                  ,case when M.CONTRACT_NUM IS NOT NULL AND M.OPER_START_DT IS NOT NULL THEN M.CONTRACT_NUM||' от '|| TO_CHAR(M.OPER_START_DT)
  when  M.CONTRACT_NUM IS NOT NULL AND M.OPER_START_DT IS NULL THEN M.CONTRACT_NUM||' от '|| '(даты начала договора нет)'
    when  M.CONTRACT_NUM IS NULL AND M.OPER_START_DT IS NOT NULL THEN '(Номера контракта нет)'||' от '|| TO_CHAR (M.OPER_start_dt)
  ELSE NULL END AS CONTRACT_NUM_FULL
                  ,M.OPER_START_DT AS OPER_START_DT
                  ,M.CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                  ,D.CLIENT_KEY AS CLIENT_KEY
                  ,D.GROUP_KEY AS GROUP_KEY
                  ,D.FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
                  ,M.CLIENT_INN AS CLIENT_INN
                  ,M.APP_1C_NUM AS APP_1C_NUM
                  ,M.ANUMA as ANUMA, M.ANUMB as ANUMB
                  ,M.REPORT_DTB AS REPORT_DTB
                  ,M.DATE_DEFAULT AS DATE_DEFAULT
                  ,M.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,M.DEFAULT_EVENT as DEFAULT_EVENT
                  ,M.REPORT_DTA AS REPORT_DTA
                  FROM (SELECT DISTINCT C.REHIRING_DT AS REHIRING_DT
                  ,C.REHIRING_FLG AS REHIRING_FLG
                  ,C.CONTRACT_NUM AS CONTRACT_NUM
                  ,C.CONTRACT_KEY AS CONTRACT_KEY
                  ,C.OPER_START_DT AS OPER_START_DT
                  ,k.contract_app_key as CONTRACT_APP_KEY
                  ,K.APP_1C_NUM AS APP_1C_NUM
                  ,K.CLIENT_KEY AS CLIENT_KEY
                  ,K.CLIENT_INN AS CLIENT_INN
                  ,K.DATE_DEFAULT AS DATE_DEFAULT
                  ,K.DATE_DEFAULT_CNCL AS DATE_DEFAULT_CNCL
                  ,K.ANUMA as ANUMA, K.ANUMB as ANUMB
                  ,K.REPORT_DTA AS REPORT_DTA
                  ,K.REPORT_DTB AS REPORT_DTB
                  ,K.DEFAULT_EVENT as DEFAULT_EVENT
            from (SELECT DISTINCT A.CLIENT_INN AS CLIENT_INN, A.DATE_OTHER_DEFAULT AS DATE_DEFAULT
                  ,A.CONTRACT_APP_KEY AS CONTRACT_APP_KEY,A.APP_1C_NUM AS APP_1C_NUM
                  ,A.CONTRACT_KEY AS CONTRACT_KEY, A.CLIENT_KEY AS CLIENT_KEY
                  ,a.ANUM as ANUMA, b.ANUM as ANUMB,A.REPORT_DT AS REPORT_DTA
                  ,B.DATE_OTHER_DEFAULT_CNCL AS DATE_DEFAULT_CNCL,B.REPORT_DTB AS REPORT_DTB
                  ,'Прочие дефолты' as DEFAULT_EVENT
                    FROM (select 'N_'||row_number() over(ORDER BY DATE_OTHER_DEFAULT) as ANUM
                                          , contract_num_shrt AS CONTRACT_NUM_SHRT
                                          ,CLIENT_INN AS CLIENT_INN, APP_1C_NUM as APP_1C_NUM
                                          ,CONTRACT_KEY AS CONTRACT_KEY,CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                                          ,DATE_OTHER_DEFAULT AS DATE_OTHER_DEFAULT, REPORT_DT AS REPORT_DT
                                          ,CLIENT_KEY AS CLIENT_KEY
                                    from dwh.default_base_table
                                    where DATE_OTHER_DEFAULT is not null and VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) A
                                    left join (select 'N_'||row_number() over(ORDER BY DATE_OTHER_DEFAULT_CNCL) as ANUM
                                    , contract_num_shrt AS CONTRACT_NUM_SHRT
                                    , CLIENT_INN AS CLIENT_INN, CAST(APP_1C_NUM AS VARCHAR2(100)) as APP_1C_NUM
                                    , CLIENT_KEY AS CLIENT_KEY,CONTRACT_KEY AS CONTRACT_KEY
                                    , DATE_OTHER_DEFAULT_CNCL AS DATE_OTHER_DEFAULT_CNCL, REPORT_DT AS REPORT_DTB
                                    , CONTRACT_APP_KEY AS CONTRACT_APP_KEY
                                    from dwh.default_base_table
                                    where DATE_OTHER_DEFAULT_CNCL is not null and VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) B
                                    on
                                    a.CONTRACT_APP_KEY=b.CONTRACT_app_KEY) K
                  LEFT JOIN (select distinct CONTRACT_NUM AS CONTRACT_NUM,CLIENT_KEY AS CLIENT_KEY, CONTRACT_KEY AS CONTRACT_KEY
                  ,REHIRING_DT AS REHIRING_DT,REHIRING_FLG AS REHIRING_FLG, OPER_START_DT AS OPER_START_DT from DWH.CONTRACTS
                  WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) C
                  ON K.CONTRACT_KEY = C.CONTRACT_KEY) M
                  LEFT JOIN (select distinct CLIENT_KEY AS CLIENT_KEY,FULL_CLIENT_RU_NAM AS FULL_CLIENT_RU_NAM
                  ,GROUP_KEY AS GROUP_KEY from DWH.CLIENTS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) D
                  ON M.CLIENT_KEY=D.CLIENT_KEY) R
                  LEFT JOIN (select distinct PRESENTATION AS PRESENTATION, contract_app_key as CONTRACT_APP_KEY
                  from DWH.LEASING_CONTRACTS_APPLS WHERE VALID_TO_DTTM=TO_DATE('01.01.2400','DD.MM.YY')) E
				  ON R.CONTRACT_APP_KEY=E.CONTRACT_APP_KEY)
SELECT "CONTRACT_ID","CONTRACT_NUM_FULL","CONTRACT_NUM","APP_NAME","APP_NAME_SHRT","APP_1C_NUM","CLIENT_ID","CLIENT_INN","FULL_CLIENT_RU_NAM","REHIRING_DT","GROUP_KEY","REHIRING_FLG","DATE_DEFAULT","DATE_DEFAULT_CNCL","DEFAULT_EVENT","CONTRACT_APP_KEY","CLIENT_KEY" FROM S1
UNION ALL
SELECT "CONTRACT_ID","CONTRACT_NUM_FULL","CONTRACT_NUM","APP_NAME","APP_NAME_SHRT","APP_1C_NUM","CLIENT_ID","CLIENT_INN","FULL_CLIENT_RU_NAM","REHIRING_DT","GROUP_KEY","REHIRING_FLG","DATE_DEFAULT","DATE_DEFAULT_CNCL","DEFAULT_EVENT","CONTRACT_APP_KEY","CLIENT_KEY" FROM S2
UNION ALL
SELECT "CONTRACT_ID","CONTRACT_NUM_FULL","CONTRACT_NUM","APP_NAME","APP_NAME_SHRT","APP_1C_NUM","CLIENT_ID","CLIENT_INN","FULL_CLIENT_RU_NAM","REHIRING_DT","GROUP_KEY","REHIRING_FLG","DATE_DEFAULT","DATE_DEFAULT_CNCL","DEFAULT_EVENT","CONTRACT_APP_KEY","CLIENT_KEY" FROM S3
UNION ALL
SELECT "CONTRACT_ID","CONTRACT_NUM_FULL","CONTRACT_NUM","APP_NAME","APP_NAME_SHRT","APP_1C_NUM","CLIENT_ID","CLIENT_INN","FULL_CLIENT_RU_NAM","REHIRING_DT","GROUP_KEY","REHIRING_FLG","DATE_DEFAULT","DATE_DEFAULT_CNCL","DEFAULT_EVENT","CONTRACT_APP_KEY","CLIENT_KEY" FROM S4
UNION ALL
SELECT "CONTRACT_ID","CONTRACT_NUM_FULL","CONTRACT_NUM","APP_NAME","APP_NAME_SHRT","APP_1C_NUM","CLIENT_ID","CLIENT_INN","FULL_CLIENT_RU_NAM","REHIRING_DT","GROUP_KEY","REHIRING_FLG","DATE_DEFAULT","DATE_DEFAULT_CNCL","DEFAULT_EVENT","CONTRACT_APP_KEY","CLIENT_KEY" FROM S5
UNION ALL
SELECT "CONTRACT_ID","CONTRACT_NUM_FULL","CONTRACT_NUM","APP_NAME","APP_NAME_SHRT","APP_1C_NUM","CLIENT_ID","CLIENT_INN","FULL_CLIENT_RU_NAM","REHIRING_DT","GROUP_KEY","REHIRING_FLG","DATE_DEFAULT","DATE_DEFAULT_CNCL","DEFAULT_EVENT","CONTRACT_APP_KEY","CLIENT_KEY" FROM S6
UNION ALL
SELECT "CONTRACT_ID","CONTRACT_NUM_FULL","CONTRACT_NUM","APP_NAME","APP_NAME_SHRT","APP_1C_NUM","CLIENT_ID","CLIENT_INN","FULL_CLIENT_RU_NAM","REHIRING_DT","GROUP_KEY","REHIRING_FLG","DATE_DEFAULT","DATE_DEFAULT_CNCL","DEFAULT_EVENT","CONTRACT_APP_KEY","CLIENT_KEY" FROM S7
UNION ALL
SELECT "CONTRACT_ID","CONTRACT_NUM_FULL","CONTRACT_NUM","APP_NAME","APP_NAME_SHRT","APP_1C_NUM","CLIENT_ID","CLIENT_INN","FULL_CLIENT_RU_NAM","REHIRING_DT","GROUP_KEY","REHIRING_FLG","DATE_DEFAULT","DATE_DEFAULT_CNCL","DEFAULT_EVENT","CONTRACT_APP_KEY","CLIENT_KEY" FROM S8;

