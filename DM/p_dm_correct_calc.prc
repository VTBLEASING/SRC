CREATE OR REPLACE PROCEDURE DM.p_DM_CORRECT_CALC(
      p_REPORT_DT IN date,
      p_type_calc     varchar2,
      p_group_key     number, 
      p_contract_key  number default null
)

IS
CORRECTION_NUMBER number;
begin
    -------------------------------------------------------------------------------------- 
    -- Заполняем таблицу, которая содержит данные для расчета XIRR и NILL с учетом корректировок
    -- в цикле(на каждой итерации применяется одна корректировка по каждому договору)
    -- Данные, относящиеся к одной итерации определятся значением столбца CORRECTION_NUMBER  
    --------------------------------------------------------------------------------------
    execute immediate 'truncate table DM_CORRECT_DNIL';
     
    
    insert into DM_CORRECT_DNIL(CONTRACT_KEY,CORRECT_AMT,CORRECT_DT,CORRECTION_NUMBER,dnil,DELETE_DT_1,DELETE_DT_2)
    select CONTRACT_KEY,CORRECT_AMT,CORRECT_DT,CORRECTION_NUMBER,dnil,DELETE_DT_1,DELETE_DT_2
    from 
    (
        with tt as
        (
            select a.contract_key
                ,a.snapshot_dt
                ,a.pay_dt
                ,a.dnil_amt
                ,dcr.CORRECT_AMT
                ,dcr.SNAPSHOT_DT CORRECT_DT
                ,dcr.CORRECTION_NUMBER
                ,dcr.DELETE_DT_1
                ,dcr.DELETE_DT_2
                ,row_number() OVER (partition BY a.contract_key, a.snapshot_dt ORDER BY a.pay_dt ASC) AS rn
                from dm.dm_repayment_schedule a
                    inner join 
                    (
                       Select a.*, 
                       case when CORRECTION_NUMBER = 1 then to_date('01.01.1900', 'dd.mm.yyyy')
                       else SNAPSHOT_DT end DELETE_DT_1,
                       case when CORRECTION_NUMBER = 1 and GROUP_NUMBER = 1 then to_date('01.01.1900', 'dd.mm.yyyy')
                       else SNAPSHOT_DT end DELETE_DT_2
                       from (Select a.*,
                             row_number() OVER (partition BY a.CONTRACT_KEY ORDER BY a.SNAPSHOT_DT ASC) AS CORRECTION_NUMBER,
                             count(*) OVER (partition BY a.CONTRACT_KEY) AS GROUP_NUMBER
                             from DWH.NIL_CORRECTS a
                                  left join DWH.CONTRACTS b on a.CONTRACT_KEY = b.CONTRACT_KEY and b.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy')
                                  left join DWH.CGP_GROUP c on b.BRANCH_KEY = c.BRANCH_KEY and c.BEGIN_DT <= p_REPORT_DT and c.END_DT > p_REPORT_DT
                             where c.CGP_GROUP_KEY = p_group_key and a.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy') and a.ACTUAL_FLG = 1
                             order by a.CONTRACT_KEY, a.SNAPSHOT_DT
                             ) a                        
                    )
                            dcr
                        on a.contract_key = dcr.contract_key
                        and a.SNAPSHOT_DT = dcr.SNAPSHOT_DT
        )
        select 
        a.CONTRACT_KEY,a.CORRECT_AMT,a.CORRECT_DT,a.CORRECTION_NUMBER
        ,a.dnil_amt + case when a.rn = 1 then 0 else a.CORRECT_AMT end as dnil
        ,DELETE_DT_1,DELETE_DT_2
        from tt a
        where pay_dt = CORRECT_DT
        and contract_key = decode(p_type_calc, 'contract',p_contract_key, contract_key )
    );        
--   P_TO_TRACE('NEW_CORRECT_START', 'CGP');        
   dm.u_log(p_proc => 'DM.p_DM_CORRECT_CALC',
           p_step => 'insert into DM_CORRECT_DNIL',
           p_info => SQL%ROWCOUNT|| ' row(s) inserted');  

    for rec in (select distinct CORRECTION_NUMBER from DM_CORRECT_DNIL) loop

        p_DM_CORRECT_CALC_XIRR(rec.CORRECTION_NUMBER,p_REPORT_DT);
        
--        P_TO_TRACE('NEW_CORRECT_START', 'XIRR');

        p_DM_CORRECT_CALC_NIL(rec.CORRECTION_NUMBER, p_REPORT_DT);
        
--        P_TO_TRACE('NEW_CORRECT_START', 'NIL');

    end loop;
    
    case p_type_calc
        when 'contract' then 
            p_dm_cgp_single(p_contract_key, p_REPORT_DT, 'Основной КИС');
        when 'branch'   then
            p_dm_cgp(p_REPORT_DT,p_group_key, 'Основной КИС');
    end case;        
        
    
commit;

end;
/

