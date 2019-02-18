CREATE OR REPLACE PROCEDURE DM.p_EXP_DM_PERIOD_TO_EXCEL (
    P_REPORT_ID number,
    P_REPORT_FILE_NAME varchar2,
    P_SNAPSHOT_CD varchar2
)
is
j number;
v_flag_prev number;
v_flag number;
v_stat varchar (100);
failed_error_message exception;
timeout_message exception;
v_path varchar (100);
v_job_name varchar (100):= 'JOB_EXCEL_PERIOD_CREATE_'||P_REPORT_ID;
v_report_file_name varchar (100):= trim(upper('P_REPORT_FILE_NAME')); 
--v_REPORT_DT date:= p_REPORT_DT+1;

BEGIN
  /* Формирование Excel-файла КГП */
  
  j := 0;
  

  
  DBMS_SCHEDULER.CREATE_JOB(
  job_name=>v_job_name,
  job_type=>'EXECUTABLE',
  number_of_arguments=>5,
  job_action=>'C:\Windows\System32\cmd.exe',
  auto_drop=>true,
  enabled=>FALSE);
  
  DBMS_SCHEDULER.set_job_argument_value(v_job_name, 1, '/c');
  if P_SNAPSHOT_CD like 'SUM_PAYMENT_OL%' then v_path:='D:\VTBL\scripts\COPY_TABLE_DM_PERIOD_OL.vbs';
    else v_path:='D:\VTBL\scripts\COPY_TABLE_DM_PERIOD.vbs'; end if;
  DBMS_SCHEDULER.set_job_argument_value(v_job_name, 2, v_path);
  DBMS_SCHEDULER.set_job_argument_value(v_job_name, 3, to_char(P_REPORT_ID));
  DBMS_SCHEDULER.set_job_argument_value(v_job_name, 4, P_REPORT_FILE_NAME);
  DBMS_SCHEDULER.set_job_argument_value(v_job_name, 5, P_SNAPSHOT_CD);
  DBMS_SCHEDULER.enable(v_job_name);
  

  
  for i in 1 .. 100 
  loop
      select count (*) flg
      into v_flag
      FROM user_objects
      where object_name = v_job_name;
      
      select max (status) keep (dense_rank last order by log_date) status
      into v_stat
      from dba_scheduler_job_run_details 
      where JOB_NAME = v_job_name; 
      
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


  
EXCEPTION
    WHEN failed_error_message
      THEN RAISE_APPLICATION_ERROR (-20210, 'Creation CGP Excel failed. Please ask your administrator to fix the error');
     WHEN timeout_message
      THEN RAISE_APPLICATION_ERROR (-20209, 'Превышено время ожидания загрузки файла. Обратитесь к администратору для устранения проблемы.');
        
END;
/

