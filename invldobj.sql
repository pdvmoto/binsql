
doc

    invldobj.sql
    Invalid objects. Need explanations.

#

COLUMN  owner       FORMAT A12
COLUMN  name        FORMAT A24
COLUMN  created     FORMAT A18
COLUMN  last_ddl    FORMAT A18
COLUMN  type        FORMAT A3
COLUMN  status      FORMAT A7
COLUMN  nr_nonvalid FORMAT 9999

set heading on

SELECT 	  owner
		, substr ( object_type, 1, 3 )		                    type
		, object_name		                                    name
        , to_char ( created, 'DD-MON-YY HH24:MI:SS' )	        created
        , to_char ( last_ddl_time, 'DD-MON-YY HH24:MI:SS' )     last_ddl
FROM  sys.dba_objects 
WHERE  status <> 'VALID' -- = 'INVALID'
ORDER BY owner, object_type, object_name
/

SELECT owner
     , substr ( object_type, 1, 3 )     type
     , status
     , count (*)                        nr_nonvalid
FROM sys.dba_objects 
WHERE  status <> 'VALID' -- = 'INVALID'
GROUP BY owner, substr ( object_type, 1, 3 ), status
ORDER BY owner, type, status desc     ;

