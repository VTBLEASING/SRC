CREATE OR REPLACE PROCEDURE DM.p_DM_EXPORT_CGP_TO_TXT (
    p_REPORT_DT date
)
is
j number;
v_flag_prev number;
v_flag number;
v_stat varchar (100);
failed_error_message exception;
timeout_message exception;
timeout_message_job_done exception;
v_nls_date_format varchar2(30);
BEGIN
  /* Формирование TXT */
   select value into v_nls_date_format from nls_session_parameters where parameter='NLS_DATE_FORMAT';
 begin
   dbms_session.set_nls('nls_date_format','''dd.mm.yyyy''');
    dm.dump_table_to_csv(p_tname => 'dwhro.v$cgp_form',
                       p_query => Q'~select Client_code, Client_code_crm, Business_category, Subdivision_name, Branch, Borrow_group_name, Interborrowers_gr_code, Interborrowers_gr_code_crm, Borrower_name, Credit_rating_code,Credit_rating, Rating_agency, Risk_coefficient, Industry_code, Reg_country_code, Risk_country_code, Product_type_code, Loan_type, Lend_purp_code, Lend_purpose, Transfer_flg,Contract_id, Loan_agr_num, Contract_start_date, Contract_end_date, On_date, Off_date, Tranche_num, Tranche_issue_date, Tranche_maturity_date, Restructure_date, Restructure_form_code,Restructure_form, Cession_date, Transferer, Contr_currency_code, Tr_currency_code, IAS3_acc, OD_account_num, OD_account_amt, OD_account_avg_amt, Rate_code, Base_rate, Margin_over_amt,Curr_interest_rate, Curr_interest_rate_add, Commisions_amt, Transfer_amt, Margin, Overdue_start_date, IAS3_overdue_acc, Overdue_bal_acc, Overdue_bal_amt, Overdue_avg_amt, Overdue_interest_rate,Overdue_transfer_rate, Overdue_margin, Overdue_debt, Allowance_acc_curr, Allowance_curr, Allowance_acc_overdue, Allowance_overdue, Allowance_rate, Quality_category_code, Quality_category,Problem_indicator_type, Incr_credits, Risk_factor_code, Risk_factor_name, Res_revolving_limit, Res_nonrevolving_limit, Comments, Contr_desc_code, Contr_desc_name, Product_code,Product_name, NonRev_cred_line_limit, Credit_amt, Principal_payments_sum_amt, All_payments_sum_amt, First_princ_pay_date, FIFO_DAYS_CNT, LIFO_DAYS_CNT, Tranche_close_date, Contract_close_date,Reg_office_code, Reg_office_name, Sales_point_code, Sales_point_name, Tranche_status, Contract_status, Last_princ_pay_date, Last_princ_pay_amt, Last_int_pay_date, Last_int_pay_amt,Last_penalty_pay_date, Last_penalty_pay_amt, Mir_code from dwhro.v$cgp_form where snapshot_dt = :p_arg_dt~',
                       p_dir => 'TXT_REPORTS',
                       p_filename => 'form1 '||to_char(p_REPORT_DT,'dd.mm.yyyy')||'.txt',
                       p_header => 'N',
                       p_arg_dt => p_REPORT_DT-1);

    dm.dump_table_to_csv(p_tname => 'dwhro.V$CGP_REPAYMENT_SCHEDULE',
                       p_query => Q'~select contract_id, tranche_num, pay_dt, currency_code, plan_amt from DWHRO.V$CGP_REPAYMENT_SCHEDULE where snapshot_dt = :p_arg_dt~',
                       p_dir => 'TXT_REPORTS',
                       p_filename => 'repayment_schedule '||to_char(p_REPORT_DT,'dd.mm.yyyy')||'.txt',
                       p_header => 'N',
                       p_arg_dt => p_REPORT_DT-1);

    dm.dump_table_to_csv(p_tname => 'dual',
                       p_query => Q'~select :p_arg_dt report_dt from dual~',
                       p_dir => 'TXT_REPORTS',
                       p_filename => 'collateral.txt '||to_char(p_REPORT_DT,'dd.mm.yyyy')||'.txt',
                       p_header => 'N',
                       p_arg_dt => p_REPORT_DT-1);

    dm.dump_table_to_csv(p_tname => 'dual',
                       p_query => Q'~select :p_arg_dt report_dt from dual~',
                       p_dir => 'TXT_REPORTS',
                       p_filename => 'Title.txt '||to_char(p_REPORT_DT,'dd.mm.yyyy')||'.txt',
                       p_header => 'N',
                       p_arg_dt => p_REPORT_DT-1);

   --01.09.2017,2,Банк ВТБ 24 (публичное акционерное общество)
   dbms_session.set_nls('nls_date_format',''''||v_nls_date_format||'''');
 exception when others then
    dbms_session.set_nls('nls_date_format',''''||v_nls_date_format||'''');
    raise;
 end;
   commit;
   return; --Выйти если Excel не нужен
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
          raise timeout_message_job_done;
      END IF;
   END LOOP;
    dm.u_log(p_proc => 'DM.p_DM_EXPORT_CGP_TO_EXCEL',
           p_step => 'JOB FINISH: JOB_EXCEL_CGP_CREATE',
           p_info => 'status:'||v_stat);
EXCEPTION
    WHEN failed_error_message
      THEN RAISE_APPLICATION_ERROR (-20210, 'Creation CGP Excel failed. Please ask your administrator to fix the error');
     WHEN timeout_message
      THEN RAISE_APPLICATION_ERROR (-20209, 'Превышено время ожидания создания Job. Обратитесь к администратору для устранения проблемы(need kill job).');
     WHEN timeout_message_job_done
      THEN RAISE_APPLICATION_ERROR (-20208, 'Превышено время ожидания выполения Job. Обратитесь к администратору для устранения проблемы.');
END;
/

