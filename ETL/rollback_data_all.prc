create or replace procedure etl.rollback_data_all(p_file_id number) is
begin

for rec in (select distinct TRG_TABLE_NAME from ctl_input_files ip, ctl_ref_file_trg_table rft 
            where upper(ip.FILE_TYPE_CD) = upper(rft.FILE_TYPE_CD) and ip.file_id = p_file_id    ) loop

    rollback_data(p_file_id => p_file_id, p_table_name => rec.TRG_TABLE_NAME );            

end loop;
end;
/

