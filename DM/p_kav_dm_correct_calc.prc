CREATE OR REPLACE PROCEDURE DM.p_KAV_DM_CORRECT_CALC(
      p_REPORT_DT IN date,
      p_type_calc     varchar2,
      p_group_key     number, 
      p_contract_key  number 
)

IS
CORRECTION_NUMBER number;

BEGIN
IF (p_type_calc = 'branch') THEN
            for CORRECTION in (Select a.*, 
                               case when CORRECTION_NUMBER = 1 then to_date('01.01.1900', 'dd.mm.yyyy')
                               else SNAPSHOT_DT end DELETE_DT
                               from (Select a.*,
                                     row_number() OVER (partition BY a.CONTRACT_KEY ORDER BY a.SNAPSHOT_DT ASC) AS CORRECTION_NUMBER,
                                     count(*) OVER (partition BY a.CONTRACT_KEY) AS GROUP_NUMBER
                                     from DWH.NIL_CORRECTS a
                                          left join DWH.CONTRACTS b on a.CONTRACT_KEY = b.CONTRACT_KEY and b.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
                                          left join DWH.CGP_GROUP c on b.BRANCH_KEY = c.BRANCH_KEY and c.BEGIN_DT <= p_REPORT_DT and c.END_DT > p_REPORT_DT
                                     where c.CGP_GROUP_KEY = p_group_key and a.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy') and a.ACTUAL_FLG = '1'
                                     order by a.CONTRACT_KEY, a.SNAPSHOT_DT) a
                                )
loop
DBMS_OUTPUT.PUT_LINE(CORRECTION.SNAPSHOT_DT);  
    if CORRECTION.CORRECTION_NUMBER = 1 and CORRECTION.GROUP_NUMBER = 1
    then
  p_DM_CORRECT_CALC_XIRR(p_contract_key, p_REPORT_DT, CORRECTION.SNAPSHOT_DT);
  p_DM_CORRECT_CALC_NIL_SINGLE (p_contract_key, p_REPORT_DT, CORRECTION.SNAPSHOT_DT);
  p_dm_cgp_single(p_contract_key, p_REPORT_DT, 'Основной КИС');
    else
  p_DM_CORRECT_CALC_XIRR(p_contract_key, p_REPORT_DT, CORRECTION.SNAPSHOT_DT);
  p_DM_CORRECT_CALC_NIL(p_contract_key, p_REPORT_DT, CORRECTION.SNAPSHOT_DT, CORRECTION.DELETE_DT);
  p_dm_cgp_single(p_contract_key, p_REPORT_DT, 'Основной КИС');
  commit;
    end if;
end loop;
END IF;
IF (p_type_calc = 'contract') THEN
            for CORRECTION in (Select a.*, 
                               case when CORRECTION_NUMBER = 1 then to_date('01.01.1900', 'dd.mm.yyyy')
                               else SNAPSHOT_DT end DELETE_DT
                               from (Select a.*,
                                     row_number() OVER (partition BY a.CONTRACT_KEY ORDER BY a.SNAPSHOT_DT ASC) AS CORRECTION_NUMBER,
                                     count(*) OVER (partition BY a.CONTRACT_KEY) AS GROUP_NUMBER
                                     from DWH.NIL_CORRECTS a
                                     where a.CONTRACT_KEY = p_contract_key and a.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy') and a.ACTUAL_FLG = '1'
                                     order by a.CONTRACT_KEY, a.SNAPSHOT_DT) a
                                )
loop
DBMS_OUTPUT.PUT_LINE(CORRECTION.SNAPSHOT_DT);  
    if CORRECTION.CORRECTION_NUMBER = 1 and CORRECTION.GROUP_NUMBER = 1
    then
  p_DM_CORRECT_CALC_XIRR(p_contract_key, p_REPORT_DT, CORRECTION.SNAPSHOT_DT);
  p_DM_CORRECT_CALC_NIL_SINGLE (p_contract_key, p_REPORT_DT, CORRECTION.SNAPSHOT_DT);
  p_dm_cgp_single(p_contract_key, p_REPORT_DT, 'Основной КИС');
    else
  p_DM_CORRECT_CALC_XIRR(p_contract_key, p_REPORT_DT, CORRECTION.SNAPSHOT_DT);
  p_DM_CORRECT_CALC_NIL(p_contract_key, p_REPORT_DT, CORRECTION.SNAPSHOT_DT, CORRECTION.DELETE_DT);
  p_dm_cgp_single(p_contract_key, p_REPORT_DT, 'Основной КИС');
  commit;
    end if;
end loop;

END IF;

commit;

end;
/

