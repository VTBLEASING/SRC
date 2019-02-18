CREATE OR REPLACE PROCEDURE DM.p_DM_EXP_NOTA_TO_EXCEL (
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
  /* Формирование Excel-файла КГП */

  j := 0;

  WHILE TRUE

  LOOP
      select count (*) flg
      into v_flag_prev
      FROM user_objects
      where object_name = 'JOB_EXCEL_NOTA_CREATE';

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
  job_name=>'JOB_EXCEL_NOTA_CREATE',
  job_type=>'EXECUTABLE',
  number_of_arguments=>3,
  job_action=>'C:\Windows\System32\cmd.exe',
  enabled=>FALSE);

  DBMS_SCHEDULER.set_job_argument_value('JOB_EXCEL_NOTA_CREATE', 1, '/c');
  DBMS_SCHEDULER.set_job_argument_value('JOB_EXCEL_NOTA_CREATE', 2, 'D:\VTBL\scripts\COPY_TABLE_NOTA.vbs');
  DBMS_SCHEDULER.set_job_argument_value('JOB_EXCEL_NOTA_CREATE', 3, TO_CHAR(p_REPORT_DT, 'DD.MM.YYYY'));
  DBMS_SCHEDULER.enable('JOB_EXCEL_NOTA_CREATE');

     dm.u_log(p_proc => 'DM.p_DM_EXP_NOTA_TO_EXCEL',
           p_step => 'DBMS_SCHEDULER.CREATE_JOB: JOB_EXCEL_NOTA_CREATE',
           p_info => 'p_REPORT_DT:'||p_REPORT_DT||'cmd:'||'D:\VTBL\scripts\COPY_TABLE_NOTA.vbs');
  for i in 1 .. 100
  loop
      select count (*) flg
      into v_flag
      FROM user_objects
      where object_name = 'JOB_EXCEL_NOTA_CREATE';

      select max (status) keep (dense_rank last order by log_date) status
      into v_stat
      from dba_scheduler_job_run_details
      where JOB_NAME = 'JOB_EXCEL_NOTA_CREATE';

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
    dm.u_log(p_proc => 'DM.p_DM_EXP_NOTA_TO_EXCEL',
           p_step => 'JOB FINISH: JOB_EXCEL_NOTA_CREATE',
           p_info => 'status:'||v_stat);
EXCEPTION
    WHEN failed_error_message
      THEN RAISE_APPLICATION_ERROR (-20210, 'Creation NOTA failed. Please ask your administrator to fix the error');
     WHEN timeout_message
      THEN RAISE_APPLICATION_ERROR (-20209, 'Превышено время ожидания загрузки файла. Обратитесь к администратору для устранения проблемы.');

END;
/

