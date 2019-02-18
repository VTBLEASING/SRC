CREATE OR REPLACE PROCEDURE ETL."GENERATE_SURROGATE_ALL" (
p_sys varchar2) is
-- GS#DIM_LANGUAGE#01#0
  x_k_table_name etl.t_table_rule.k_table_name%type;
  collist        varchar2(400);
  k_collist      varchar2(400);
  str            varchar2(4000);
  lockid         varchar2(30);
  code           number;
  x_code         char(2);
  x_inst         char(2);
  x_table_name   varchar2(30);
begin

  for x in (select table_name, owner from etl.t_table t where t.actual_flag=1 and t.sys_code=p_sys)
  loop
    begin
        GENERATE_SURROGATE(upper(x.table_name), upper(x.owner), p_sys);
    exception 
        when others  
            then null;
    end;
  end loop;
end;
/

