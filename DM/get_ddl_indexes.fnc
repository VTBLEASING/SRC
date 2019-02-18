create or replace function dm.GET_DDL_INDEXES(p_table_name varchar) return etl.ddl_script_tab_type  authid current_user
as
    v_table_name varchar2(100) := upper(trim(p_table_name));
    v_ddl_scripts varchar2(32000) :='';
    v_ddl_scripts_tab etl.ddl_script_tab_type := etl.ddl_script_tab_type();
begin
    for rec_ddl in (select * from user_indexes where TABLE_NAME = p_table_name) loop
--        v_ddl_scripts := v_ddl_scripts || dbms_metadata.get_ddl('INDEX', rec_ddl.INDEX_NAME, v_owner)||';';
        v_ddl_scripts_tab.extend;
        v_ddl_scripts_tab(v_ddl_scripts_tab.count) := dbms_metadata.get_ddl('INDEX', rec_ddl.INDEX_NAME);
    end loop; 
    return v_ddl_scripts_tab;
end;
/

