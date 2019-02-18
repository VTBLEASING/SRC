create or replace procedure etl.CHECK_NEW_INPUT_FILES
as
    j number;
    i number := 1;
    v_flag_prev number;
    v_flag number;
    v_stat varchar (100);
    v_last_refresh_ts timestamp;
    v_job_name varchar2(100);
begin
   
  select max(refresh_ts)
  into v_last_refresh_ts
  from ctl_refresh_input_files_log;
  
--  select 'JOB_REFRESH_INPUT_FILES_'||sid 
--  into  v_job_name
--  from v$mystat
--  where rownum =1;
  

--startscen.bat WF_REFRESH_CTL_INPUT_FILES 001 GLOBAL
--  
--  DBMS_SCHEDULER.CREATE_JOB(
--  job_name=>v_job_name,
--  job_type=>'EXECUTABLE',
--  number_of_arguments=>5,
--  job_action=>'C:\Windows\System32\cmd.exe',
--  enabled=>FALSE,
--  auto_drop=>TRUE);
--  
--  DBMS_SCHEDULER.set_job_argument_value(v_job_name, 1, '/c');
--  DBMS_SCHEDULER.set_job_argument_value(v_job_name, 2, 'd: '||'&'||' D:\app\sys\product\11.2.0\Oracle_ODI_2\oracledi\agent\bin\startscen.bat');
--  DBMS_SCHEDULER.set_job_argument_value(v_job_name, 3, 'WF_REFRESH_CTL_INPUT_FILES');
--  DBMS_SCHEDULER.set_job_argument_value(v_job_name, 4, '001');
--  DBMS_SCHEDULER.set_job_argument_value(v_job_name, 5, 'GLOBAL');    
--  DBMS_SCHEDULER.enable(v_job_name);
  

    insert into CTL_REFRESH_INPUT_FILE_FLG(i) values ('1');
    commit;

  
  while i <= 6 
  loop
      select count (*) flg
      into v_flag
      FROM CTL_REFRESH_INPUT_FILE_FLG;
      
--      select max (status) keep (dense_rank last order by log_date) status
--      into v_stat
--      from dba_scheduler_job_run_details 
--      where JOB_NAME = v_job_name; 
--      
      IF v_flag >= 1
        THEN 
          DBMS_LOCK.SLEEP (10);
         ELSE 
          EXIT;         
      END IF;          
--      ELSIF  
--         v_stat = 'SUCCEEDED' 
--        THEN EXIT;
--      ELSIF
--         v_stat = 'FAILED'
--        THEN
--          --return 1; --job_error;
--          raise_application_error (-20925,'Check files error: job failed');
--      ELSE 
----          return 2; --tyme_out;
--          raise_application_error (-20926,'Check files error: check timeout period has expired');
--      END IF;
   i := i + 1;

   END LOOP;
   
   if i >= 1000
        then raise_application_error (-20926,'Check files error: check timeout period has expired');
   end if;        
   
   v_flag :=0; 


   select count(*)
   into v_flag
   from ctl_refresh_input_files_log
   where refresh_ts > v_last_refresh_ts;
   
   if v_flag = 0 then
        raise_application_error (-20928,'Check files error: can''t refresh input files folder');
   end if;         
        
   

end;
/

