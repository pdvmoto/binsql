
set doc on
set heading off
set feedback off
set verify off
column listfile heading "Listfile"  new_value listfile format a40;

spool db_info_spool.lst
select 'spool db_valid_'||name||'_'||to_char(sysdate,'YYYYMMDD_HH24MI') listfile 
from v$database;

spool off
@db_info_spool.lst


doc 
    
    chk_rcntmod.sql
	Check recently modyfied objects  ( < 2 days, non sys )
	check invalid objects (any, non-sys)

# 

COLUMN  owner       FORMAT A12
COLUMN  name        FORMAT A24
COLUMN  created     FORMAT A18
COLUMN  last_ddl    FORMAT A18
COLUMN  type        FORMAT A3
COLUMN  status      FORMAT A7

set heading on

SELECT  sys.dba_objects.owner       owner
     , object_name                  name
     , substr ( object_type, 1, 3 ) type
        , to_char ( created, 'DD-MON-YY HH24:MI:SS' )	        created
        , to_char ( last_ddl_time, 'DD-MON-YY HH24:MI:SS' )     last_ddl
--     , status
FROM
    sys.dba_objects
WHERE last_ddl_time > sysdate - 2
and owner not like 'SYS%'   -- prevent false alerts.
ORDER BY last_ddl_time desc, owner
/


select               owner
, object_name        name
, substr ( object_type, 1, 3 ) type
, status 
, last_ddl_time  last_ddl
from dba_objects where status <> 'VALID'
order by last_ddl_time desc 
/

spool off
