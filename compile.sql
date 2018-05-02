/*
** find all invalid objects
** compile all invalid objects
** display invalid objects that can't be recompiled
*/
set heading off
set feedback off
spool /oracle/admin/binsql/alt_invalid.sql
SELECT 'alter '
||decode(object_type,'PACKAGE BODY','PACKAGE',object_type)
||' '
||owner
||'.'
||object_name
||' compile;'
FROM  sys.dba_objects 
WHERE  status = 'INVALID'
/
spool off
set feedback on
@/oracle/admin/binsql/alt_invalid.sql

/*
** invalid objects
*/
COLUMN  owner       FORMAT A12
COLUMN  name        FORMAT A26
COLUMN  created     FORMAT A9
COLUMN  last_ddl    FORMAT A9
COLUMN  type        FORMAT A12
COLUMN  status      FORMAT A7
set heading on
SELECT 	  owner
		, object_type		type
		, object_name		name
     , created						created
     , last_ddl_time				last_ddl
		, status 
FROM  sys.dba_objects 
WHERE  status = 'INVALID'
ORDER BY owner, object_type, object_name
/

