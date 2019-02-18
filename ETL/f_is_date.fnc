create or replace function etl.f_is_date(p_date varchar2, p_format varchar2)
return number
is 
  v_test date;
begin
  v_test := to_date(p_date, p_format);
  return 1;
exception
  when others then return 0;
end;
/

