create or replace procedure dm.analyze_table(p_table_name in varchar2,
                                            p_schema     in varchar2 default null) is
    c_proc constant varchar2(30) := 'analyze_table';
    l_current_schema varchar2(100);
  begin
    l_current_schema := p_schema;
   -- if p_schema is null then
    --  select user into l_current_schema from dual;
   -- end if;
    --execute immediate 'ANALYZE TABLE '||p_table_name||' COMPUTE STATISTICS';
    DBMS_STATS.GATHER_TABLE_STATS(ownname    => l_current_schema,
                                  tabname    => p_table_name,
                                  method_opt => 'FOR ALL COLUMNS SIZE 1',
                                  CASCADE    => true);
  end;
/

