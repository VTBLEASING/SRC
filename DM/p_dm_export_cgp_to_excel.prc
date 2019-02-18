CREATE OR REPLACE PROCEDURE DM.p_DM_EXPORT_CGP_TO_EXCEL (
    p_REPORT_DT date
)
is
j number;
v_flag_prev number;
v_flag number;
v_stat varchar (100);
failed_error_message exception;
timeout_message exception;
v_nls_date_format varchar2(30);
l_file_cgp blob;
l_file_rch blob;
l_file_Title blob;
l_zip blob;
v_time date;
BEGIN
  
  /* Формирование TXT */
   select value into v_nls_date_format from nls_session_parameters where parameter='NLS_DATE_FORMAT';
   begin
   dbms_session.set_nls('nls_date_format','''dd.mm.yyyy''');
    --dm.dump_table_to_csv
    v_time :=sysdate;
    l_file_cgp:=dm.table_to_csv_blob(p_tname => 'dwhro.v$cgp_form',
                       p_query => Q'~select Client_code, Client_code_crm, Business_category, Subdivision_name, Branch, Borrow_group_name, Interborrowers_gr_code, Interborrowers_gr_code_crm, Borrower_name, Credit_rating_code,Credit_rating, Rating_agency, Risk_coefficient, Industry_code, Reg_country_code, Risk_country_code, Product_type_code, Loan_type, Lend_purp_code, Lend_purpose, Transfer_flg,Contract_id, Loan_agr_num, Contract_start_date, Contract_end_date, On_date, Off_date, Tranche_num, Tranche_issue_date, Tranche_maturity_date, Restructure_date, Restructure_form_code,Restructure_form, Cession_date, Transferer, Contr_currency_code, Tr_currency_code, IAS3_acc, OD_account_num, OD_account_amt, OD_account_avg_amt, Rate_code, Base_rate, Margin_over_amt,Curr_interest_rate, Curr_interest_rate_add, Commisions_amt, Transfer_amt, Margin, Overdue_start_date, IAS3_overdue_acc, Overdue_bal_acc, Overdue_bal_amt, Overdue_avg_amt, Overdue_interest_rate,Overdue_transfer_rate, Overdue_margin, Overdue_debt, Allowance_acc_curr, Allowance_curr, Allowance_acc_overdue, Allowance_overdue, Allowance_rate, Quality_category_code, Quality_category,Problem_indicator_type, Incr_credits, Risk_factor_code, Risk_factor_name, Res_revolving_limit, Res_nonrevolving_limit, Comments, Contr_desc_code, Contr_desc_name, Product_code,Product_name, NonRev_cred_line_limit, Credit_amt, Principal_payments_sum_amt, All_payments_sum_amt, First_princ_pay_date, FIFO_DAYS_CNT, LIFO_DAYS_CNT, Tranche_close_date, Contract_close_date,Reg_office_code, Reg_office_name, Sales_point_code, Sales_point_name, Tranche_status, Contract_status, Last_princ_pay_date, Last_princ_pay_amt, Last_int_pay_date, Last_int_pay_amt,Last_penalty_pay_date, Last_penalty_pay_amt, Mir_code from dwhro.v$cgp_form where snapshot_dt = :p_arg_dt~',
                       p_dir => 'TXT_REPORTS',
                       p_filename => 'form1 '||to_char(p_REPORT_DT,'dd.mm.yyyy')||'.txt',
                       p_header => 'N',
                       p_arg_dt => p_REPORT_DT-1);
    dm.u_log(p_proc => 'DM.p_DM_EXPORT_CGP_TO_EXCEL',
           p_step => 'blob form1 CREATED',
           p_info => 'elapsed:'||(sysdate-v_time)*24*60||' min');   
    v_time :=sysdate;
           
    l_file_rch:=dm.table_to_csv_blob(p_tname => 'dwhro.V$CGP_REPAYMENT_SCHEDULE',
                       p_query => Q'~select contract_id, tranche_num, pay_dt, currency_code, plan_amt from DWHRO.V$CGP_REPAYMENT_SCHEDULE where snapshot_dt = :p_arg_dt~',
                       p_dir => 'TXT_REPORTS',
                       p_filename => 'repayment_schedule '||to_char(p_REPORT_DT,'dd.mm.yyyy')||'.txt',
                       p_header => 'N',
                       p_arg_dt => p_REPORT_DT-1);
    dm.u_log(p_proc => 'DM.p_DM_EXPORT_CGP_TO_EXCEL',
           p_step => 'blob repayment_schedule CREATED',
           p_info => 'elapsed:'||(sysdate-v_time)*24*60||' min');   
    v_time :=sysdate; 
        l_file_Title:=dm.table_to_csv_blob(p_tname => 'dual',
                       p_query => Q'~select to_char(:p_arg_dt,'dd.mm.yyyy') report_dt,32 id, 'ВТБ Лизинг (акционерное общество)' bank_nam from dual~',
                       p_dir => 'TXT_REPORTS',
                       p_filename => 'Title '||to_char(p_REPORT_DT,'dd.mm.yyyy')||'.txt',
                       p_header => 'N',
                       p_arg_dt => p_REPORT_DT-1);
   dbms_session.set_nls('nls_date_format',''''||v_nls_date_format||'''');
   --dbms_output.put_line(dbms_lob.getlength(l_file_cgp));
      --dbms_output.put_line(dbms_lob.getlength(l_file_Title));
   if dbms_lob.getlength(l_file_cgp)>0  then
    alexandria.zip_util_pkg.add_file (l_zip, 'form1.txt', l_file_cgp);
    --dbms_lob.freetemporary(l_file_cgp);   
   end if;
   if dbms_lob.getlength(l_file_rch)>0  then
     alexandria.zip_util_pkg.add_file (l_zip, 'repayment_schedule.txt', l_file_rch);
     --dbms_lob.freetemporary(l_file_rch);   
   end if;

 --     dbms_output.put_line('after1:'||dbms_lob.istemporary(l_file_Title));
   alexandria.zip_util_pkg.add_file (l_zip, 'Title.txt', l_file_Title);
   dbms_output.put_line('before:'||dbms_lob.istemporary(l_file_Title));
   --dbms_lob.freetemporary(l_file_Title);
   dbms_output.put_line(dbms_lob.istemporary(l_file_Title));
   alexandria.zip_util_pkg.add_file (l_zip, 'Collate.txt',utl_raw.cast_to_raw(' '));
   alexandria.zip_util_pkg.save_zip (l_zip, 'TXT_REPORTS', 'cgp_'||to_char(p_REPORT_DT,'dd.mm.yyyy')||'.zip');
   --dbms_lob.freetemporary(l_zip);
    dm.u_log(p_proc => 'DM.p_DM_EXPORT_CGP_TO_EXCEL',
           p_step => 'blobs  zipped',
           p_info => 'elapsed:'||(sysdate-v_time)*24*60||' min');   
    v_time :=sysdate;
  
 /*exception when others then
    dbms_session.set_nls('nls_date_format',''''||v_nls_date_format||'''');
    raise; */
 end;                        
  -- return; --Выйти если Excel не нужен
 /* Формирование Excel-файла КГП */

  j := 0;
  
  WHILE TRUE
  
  LOOP
      select count (*) flg
      into v_flag_prev
      FROM user_objects
      where object_name = 'JOB_EXCEL_CGP_CREATE';
     
     IF v_flag_prev = 1
        THEN 
            DBMS_LOCK.SLEEP (10);
        ELSIF v_flag_prev = 0
        THEN EXIT;
        END IF;
     
     IF j = 100
         THEN raise timeout_message;
     ELSE 
     j := j + 1; 
     END IF;
     
  END LOOP;

  DBMS_SCHEDULER.CREATE_JOB(
  job_name=>'JOB_EXCEL_CGP_CREATE',
  job_type=>'EXECUTABLE',
  number_of_arguments=>3,
  job_action=>'C:\Windows\System32\cmd.exe',
  enabled=>FALSE);
  
  DBMS_SCHEDULER.set_job_argument_value('JOB_EXCEL_CGP_CREATE', 1, '/c');
  DBMS_SCHEDULER.set_job_argument_value('JOB_EXCEL_CGP_CREATE', 2, 'D:\VTBL\scripts\COPY_TABLE_CGP.vbs');
  DBMS_SCHEDULER.set_job_argument_value('JOB_EXCEL_CGP_CREATE', 3, TO_CHAR(p_REPORT_DT, 'DD.MM.YYYY'));
  DBMS_SCHEDULER.enable('JOB_EXCEL_CGP_CREATE');
    dm.u_log(p_proc => 'DM.p_DM_EXPORT_CGP_TO_EXCEL',
           p_step => 'DBMS_SCHEDULER.CREATE_JOB: JOB_EXCEL_CGP_CREATE',
           p_info => 'p_REPORT_DT:'||p_REPORT_DT||'cmd:'||'D:\VTBL\scripts\COPY_TABLE_CGP.vbs');     
  
  for i in 1 .. 100 
  loop
      select count (*) flg
      into v_flag
      FROM user_objects
      where object_name = 'JOB_EXCEL_CGP_CREATE';
      
      select max (status) keep (dense_rank last order by log_date) status
      into v_stat
      from dba_scheduler_job_run_details 
      where JOB_NAME = 'JOB_EXCEL_CGP_CREATE'; 
      
      IF v_flag = 1
        THEN 
          DBMS_LOCK.SLEEP (10);
      ELSIF  
         v_stat = 'SUCCEEDED' 
        THEN EXIT;
      ELSIF
         v_stat = 'FAILED'
        THEN
          raise failed_error_message;
      ELSE 
          raise timeout_message;
      END IF;
   END LOOP;
    dm.u_log(p_proc => 'DM.p_DM_EXPORT_CGP_TO_EXCEL',
           p_step => 'JOB FINISH: JOB_EXCEL_CGP_CREATE',
           p_info => 'status:'||v_stat);        
/*EXCEPTION
    WHEN failed_error_message
      THEN RAISE_APPLICATION_ERROR (-20210, 'Creation CGP Excel failed. Please ask your administrator to fix the error');
     WHEN timeout_message
      THEN RAISE_APPLICATION_ERROR (-20209, 'Превышено время ожидания загрузки файла. Обратитесь к администратору для устранения проблемы.');
  */      
END;
/

