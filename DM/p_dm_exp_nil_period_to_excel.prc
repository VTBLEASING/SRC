CREATE OR REPLACE PROCEDURE DM.p_DM_EXP_NIL_PERIOD_TO_EXCEL (
    p_REPORT_DT date
)
is
j number;
v_flag_prev number;
v_flag number;
v_stat varchar (100);
failed_error_message exception;
timeout_message exception;
--v_REPORT_DT date:= p_REPORT_DT+1;

BEGIN
  /* ������������ Excel-����� ��� */
  
  j := 0;
  
  WHILE TRUE
  
  LOOP
      select count (*) flg
      into v_flag_prev
      FROM user_objects
      where object_name = 'JOB_EXCEL_NIL_PERIOD_CREATE';
     
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
  job_name=>'JOB_EXCEL_NIL_PERIOD_CREATE',
  job_type=>'EXECUTABLE',
  number_of_arguments=>3,
  job_action=>'C:\Windows\System32\cmd.exe',
  enabled=>FALSE);
  
  DBMS_SCHEDULER.set_job_argument_value('JOB_EXCEL_NIL_PERIOD_CREATE', 1, '/c');
  DBMS_SCHEDULER.set_job_argument_value('JOB_EXCEL_NIL_PERIOD_CREATE', 2, 'D:\VTBL\scripts\COPY_TABLE_NIL_PERIOD.vbs');
  DBMS_SCHEDULER.set_job_argument_value('JOB_EXCEL_NIL_PERIOD_CREATE', 3, TO_CHAR(p_REPORT_DT, 'DD.MM.YYYY'));
  DBMS_SCHEDULER.enable('JOB_EXCEL_NIL_PERIOD_CREATE');
  
  
  for i in 1 .. 100 
  loop
      select count (*) flg
      into v_flag
      FROM user_objects
      where object_name = 'JOB_EXCEL_NIL_PERIOD_CREATE';
      
      select max (status) keep (dense_rank last order by log_date) status
      into v_stat
      from dba_scheduler_job_run_details 
      where JOB_NAME = 'JOB_EXCEL_NIL_PERIOD_CREATE'; 
      
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
      THEN RAISE_APPLICATION_ERROR (-20209, '��������� ����� �������� �������� �����. ���������� � �������������� ��� ���������� ��������.');
        
END;
/

