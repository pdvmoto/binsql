
set heading off

SELECT count (*) 	|| ' users defined in the database.'
FROM  sys.dba_users
/

set heading on

doc 
	Summary of objects per user
#

break on owner
 
SELECT owner, object_type, count (*)    nr_objects
FROM  sys.dba_objects
GROUP BY owner, object_type
ORDER BY owner, object_type
/

clear breaks
