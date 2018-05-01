doc 
	info05.sql

	Summary of objects per user
#

set heading off
set pagesize 100
set feedback off

select count (*) 	|| ' users defined in the database.'
from  sys.dba_users
/

set heading on
break on owner
 
select owner, object_type, count (*)    nr_objects
from  sys.dba_objects
group by owner, object_type
order by owner, object_type
/

clear breaks

prompt

doc 
	info05.sql section 2

	The number of Kb per User per Tablespace.
#

col username   format a30
col tablespace format a30
col kb_used    format 9999999999

select d.owner                    username
,      d.tablespace_name          tablespace
,      sum(blocks*v.value/(1024)) kb_used
from dba_segments d
,    v$parameter  v
where v.name='db_block_size'
group by d.owner, d.tablespace_name
;

set feedback on
clear columns
prompt

