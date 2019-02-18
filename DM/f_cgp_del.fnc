CREATE OR REPLACE FUNCTION DM."F_CGP_DEL" -- создана для матрицы
(
    p_REPORT_DT     date,
    p_type_calc     varchar2,
    p_group_key     number,        
    p_contract_key  number,
    p_excel boolean default true     
)
RETURN NUMBER is
BEGIN
  
        IF  p_type_calc = 'branch' THEN
            
            delete from DM.DM_XIRR 
            where ODTTM = p_REPORT_DT
            and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
            and snapshot_cd = 'Основной КИС';
            
              dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_XIRR',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted'); 
            
            delete from DM.DM_NIL 
            where ODTTM = p_REPORT_DT 
            and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
            and snapshot_cd = 'Основной КИС';
           
              dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_NIL',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
           
            delete from DM.DM_repayment_schedule 
            where snapshot_dt = p_REPORT_DT 
            and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
            and snapshot_cd = 'Основной КИС';
            
               dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_repayment_schedule',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
            
            -- [apolyakov 06.09.2016]: Доработка по обратному КГП
            delete from DM.DM_repayment_schedule_hist 
            where snapshot_dt = p_REPORT_DT 
            and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
            and snapshot_cd = 'Основной КИС'
            and valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy');
            
               dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_repayment_schedule_hist',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
            
            delete from DM.DM_overdue_amt 
            where ODDTM = p_REPORT_DT
            and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
            and snapshot_cd = 'Основной КИС';
            
           dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_overdue_amt',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
            
            delete from DM.DM_avg_overdue_amt 
            where ODDTM = p_REPORT_DT
            and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and begin_dt <= p_REPORT_DT and end_dt > p_REPORT_DT)
            and snapshot_cd = 'Основной КИС';
            
           dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_avg_overdue_amt',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');            
            
            delete from DM.DM_overdue_dt 
            where ODDTM = p_REPORT_DT
            and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
            and snapshot_cd = 'Основной КИС';
            
           dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_overdue_dt',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');   
            
            delete from DM.DM_max_dt 
            where ODDTM = p_REPORT_DT
            and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT);
            
           dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_max_dt',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');   
            
            delete from DM.DM_cgp 
            where snapshot_dt = p_REPORT_DT
            and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
            and snapshot_cd = 'Основной КИС';
            
           dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_cgp',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted'); 
            
            -- [apolyakov 06.09.2016]: Доработка по обратному КГП
            delete from DM.DM_cgp_hist 
            where snapshot_dt = p_REPORT_DT
            and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT)
            and snapshot_cd = 'Основной КИС'
            and valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy');
            
          dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_cgp_hist',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted'); 
            
        ELSIF p_type_calc = 'contract' THEN
            
            delete from DM.DM_XIRR 
            where ODTTM = p_REPORT_DT
            and contract_id = p_contract_key
            and snapshot_cd = 'Основной КИС';
            
           dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_XIRR',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
            
            delete from DM.DM_NIL 
            where ODTTM = p_REPORT_DT 
            and contract_id = p_contract_key
            and snapshot_cd = 'Основной КИС';
            
           dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_NIL',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
             
            delete from DM.DM_repayment_schedule 
            where snapshot_dt = p_REPORT_DT 
            and contract_key = p_contract_key
            and snapshot_cd = 'Основной КИС';
            
           dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_repayment_schedule',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
            
            -- [apolyakov 06.09.2016]: Доработка по обратному КГП
            delete from DM.DM_repayment_schedule_hist 
            where snapshot_dt = p_REPORT_DT 
            and contract_key = p_contract_key
            and snapshot_cd = 'Основной КИС'
            and valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy');
            
           dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_repayment_schedule_hist',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
            
            delete from DM.DM_overdue_amt 
            where ODDTM = p_REPORT_DT
            and contract_id = p_contract_key
            and snapshot_cd = 'Основной КИС';
            
           dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_overdue_amt',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
            
            delete from DM.DM_avg_overdue_amt 
            where ODDTM = p_REPORT_DT
            and contract_id = p_contract_key
            and snapshot_cd = 'Основной КИС';
            
           dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_avg_overdue_amt',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
            
            delete from DM.DM_overdue_dt 
            where ODDTM = p_REPORT_DT
            and contract_id = p_contract_key
            and snapshot_cd = 'Основной КИС'; 
            
           dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_overdue_dt',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
            
            delete from DM.DM_max_dt  
            where ODDTM = p_REPORT_DT
            and contract_id = p_contract_key;
            
           dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_max_dt',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
            
            delete from DM.DM_cgp 
            where snapshot_dt = p_REPORT_DT
            and contract_key = p_contract_key
            and snapshot_cd = 'Основной КИС';
            
           dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_cgp',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');
            
            -- [apolyakov 06.09.2016]: Доработка по обратному КГП
            delete from DM.DM_cgp_hist 
            where snapshot_dt = p_REPORT_DT
            and contract_key = p_contract_key
            and snapshot_cd = 'Основной КИС'
            and valid_to_dttm = to_date ('01.01.2400', 'dd.mm.yyyy');

           dm.u_log(p_proc => 'F_CGP_FORM_DEL_N',
           p_step => 'delete from DM.DM_cgp_hist',
           p_info => SQL%ROWCOUNT|| ' row(s) deleted');

        END IF;
        
        commit;
        
        IF p_excel then 
        
        dm.p_dm_export_cgp_to_excel (p_REPORT_DT + 1);
        
        -- [apolyakov 08.07.2016] : добавление расчета файла адаптированного КГП
        dm.P_DM_EXP_CGP_ADAPT_TO_EXCEL (p_REPORT_DT + 1);
        
        END IF;
        
        delete from DM.DM_REG_CGP 
        where snapshot_dt = p_REPORT_DT 
        and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT); 
        
        delete from DM.DM_REG_REPAYMENT_SCHEDULE 
        where snapshot_dt = p_REPORT_DT 
        and branch_key in (select branch_key from dwh.cgp_group where cgp_group_key = p_group_key and cgp_group.begin_dt <= p_REPORT_DT and cgp_group.end_dt > p_REPORT_DT);
        
        commit;
        
        -- [apolyakov 13.09.2016] : добавление расчета регистра с блокировками в рамках задачи обратного КГП
        dm.p_dm_reg_run (p_REPORT_DT);
        
      --  dm.p_dm_export_mr_to_excel (p_REPORT_DT + 1);
        
    RETURN 1;
END F_CGP_DEL;
/

