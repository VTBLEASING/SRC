CREATE OR REPLACE PROCEDURE DM.P_DWH_FACTS_UAL IS
V_FACTS_UAL VARCHAR2(50) :='fINISHED ';
--FACTS_UAL  VARCHAR2(50) := 'DWH.facts_ual';
BEGIN
  
/* Процедура загрузки данных в витрину DWH.FACTS_UAL
       */
    
--execute immediate ('truncate table DWH.FACTS_UAL');
--TRUNCATE TABLE DWH.FACTS_UAL;
DELETE FROM DWH.FACTS_UAL;

dm.u_log(p_proc => 'DM.P_DWH_FACTS_UAL',
           p_step => 'TRUNCATE TARGET TABLE DWH.FACTS_UAL',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
           
commit;    

EXECUTE IMMEDIATE ('insert into DWH.FACTS_UAL
select * from DWH.V_FACTS_UAL');

dm.u_log(p_proc => 'DM.P_DWH_FACTS_UAL',
           p_step => 'INSERT DATA INTO TABLE DWH.FACTS_UAL',
           p_info => SQL%ROWCOUNT|| ' row(s) INSERTED');
           
commit;
etl.P_DM_LOG('FACTS_UAL');

DBMS_OUTPUT.PUT_LINE(V_FACTS_UAL);
COMMIT;

END;
/

