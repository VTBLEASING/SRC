create or replace procedure etl.LOG_CLOSE_DATE_CONTR_FILE is
    v_file_id number;
begin
    select max(file_id) 
    into v_file_id
    from 
    (
        select file_id from stg_xls.CLOSE_DATE_CONTR
        union 
        select -1 from dual
    );
    
    if (v_file_id <> -1) then
        insert into vtbl.CONTRACTS_LOG
        (
            CONTRACT_KEY, CONTRACT_CD, BRANCH_KEY, CLIENT_KEY, CONTRACT_KIND_KEY, CONTRACT_ID_CD, 
            CONTRACT_NUM, OPEN_DT, OPER_START_DT, CLOSE_DT, CURRENCY_KEY, CONTRACT_AMT, CONTRACT_RATE, 
            FLOAT_FLG, FLOAT_RATE_TYPE_KEY, FLOAT_BASE_AMT, ADD_AMT, IAS3_TERM_AMT, IAS3_OVERDUE_AMT, 
            DQ_CATEGORY_KEY, BAD_FLG, CONTRACT_TYPE_KEY, LENDING_PURPOSE_KEY, RISK_COUNTRY_KEY, 
            REHIRING_FLG, VALID_FROM_DTTM, VALID_TO_DTTM, PROCESS_KEY, CONTRACT_LEASING_KEY, FILE_ID, 
            IS_CLOSED_CONTRACT, EXCLUDE_CGP, USERNAME, OPER_TYPE, CONTRACT_FIN_KIND_DESC, FORCE_CLOSE_DATE
        )      
        select 
            cont.CONTRACT_KEY, cont.CONTRACT_CD, cont.BRANCH_KEY, cont.CLIENT_KEY, cont.CONTRACT_KIND_KEY, cont.CONTRACT_ID_CD, 
            cont.CONTRACT_NUM, cont.OPEN_DT, cont.OPER_START_DT, cont.CLOSE_DT, cont.CURRENCY_KEY, cont.CONTRACT_AMT, cont.CONTRACT_RATE, 
            cont.FLOAT_FLG, cont.FLOAT_RATE_TYPE_KEY, cont.FLOAT_BASE_AMT, cont.ADD_AMT, cont.IAS3_TERM_AMT, cont.IAS3_OVERDUE_AMT, 
            cont.DQ_CATEGORY_KEY, cont.BAD_FLG, cont.CONTRACT_TYPE_KEY, cont.LENDING_PURPOSE_KEY, cont.RISK_COUNTRY_KEY, 
            cont.REHIRING_FLG, cont.VALID_FROM_DTTM, cont.VALID_TO_DTTM, cont.PROCESS_KEY, cont.CONTRACT_LEASING_KEY, cont.FILE_ID, 
            cont.IS_CLOSED_CONTRACT, cont.EXCLUDE_CGP, 'BI', decode(PREV_FLG,1,-1,1), lcont.CONTRACT_FIN_KIND_DESC, cont.FORCE_CLOSE_DATE
        from 
            (
                select a.*
                ,case when lead(file_id) over (partition by CONTRACT_KEY order by VALID_TO_DTTM asc) = v_file_id then 1 else 0 end PREV_FLG 
                from  dwh.CONTRACTS a             
            ) cont 
            inner join dwh.LEASING_CONTRACTS lcont
                on cont.CONTRACT_KEY = lcont.CONTRACT_KEY
                and  lcont.VALID_TO_DTTM = to_date('01.01.2400', 'dd.mm.yyyy') 
        where cont.file_id = v_file_id or PREV_FLG = 1;                     
        
        
    end if; 
    
    commit;
    
end;
/

