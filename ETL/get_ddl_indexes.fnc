create or replace function etl.GET_DDL_INDEXES(p_table_name varchar, p_owner  varchar) return ddl_script_tab_type
--authid current_user
as
    v_table_name varchar2(100) := upper(trim(p_table_name));
    v_owner  varchar2(100) := upper(trim(p_owner));
    v_ddl_scripts varchar2(32000) :='';
    v_ddl_scripts_tab ddl_script_tab_type := ddl_script_tab_type();
begin
    case v_owner 
        when 'DWH' then v_ddl_scripts_tab:= dwh.GET_DDL_INDEXES(v_table_name);
        when 'DM' then  v_ddl_scripts_tab:= dm.GET_DDL_INDEXES(v_table_name);
    end case;
    return v_ddl_scripts_tab;
end;
/

