rem The following fires the correct database (7 or 8 or 9 or 10 or 11) 
rem and OS version (Windows or Unix/Linux = Lunix) of the db_info script.
rem 
rem Possible combinations: db_info_v7windows.sql
rem                        db_info_v7lunix.sql
rem                        db_info_v8windows.sql
rem                        db_info_v8lunix.sql
rem                        db_info_v9windows.sql
rem                        db_info_v9lunix.sql
rem                        db_info_v10windows.sql
rem                        db_info_v10lunix.sql
rem                        db_info_v11windows.sql
rem                        db_info_v11lunix.sql
rem                        db_info_vo.sql        -- other => Report back to ORC.
rem                        db_info_volunix.sql   -- other => Report back to ORC.
rem                        db_info_vowindows.sql -- other => Report back to ORC.
rem

set heading off
set feedback off

spool vdb_info.lst

select '@db_info_'||decode (substr(v.banner, (instr(v.banner,'.') -1), 1)
		   , '7', 'v7'
                   , '8', 'v8'
                   , '9', 'v9'
                   , '0', 'v10'
                   , '1', 'v11'
                   , '2', 'v11'
		   , 'vo' )
                 ||decode ( decode (sign (instr(F.file_name,'/',-1) ), 1, 3, 0)
                            +      
                            decode (sign (instr(F.file_name,'\',-1) ), 1, 2, 0)
                           , 3 , 'lunix.sql'
                           , 2 , 'windows.sql'
                               , '.sql' )
from v$version v
,    sys.dba_data_files F
where rownum <2; 

spool off

@vdb_info.lst

set heading on
set feedback on
