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


column owner       format A15
column nr_objects  format 99999
column object_type format A15

set heading on

select owner, count (*)    nr_objects
from  sys.dba_objects
group by owner
order by owner
/


break on owner
 
select owner, object_type, count (*)    nr_objects
from  sys.dba_objects
group by owner, object_type
order by owner, object_type
/

clear breaks

prompt

doc 
	info05.sql section 2: KB per user and per user-tablespace

#
col username   format a30
col tablespace format a20
col kb_used    format 9999999999

select d.owner                    -- as username
,      sum(blocks*v.value/(1024)) as kb_used
from dba_segments d
,    v$parameter  v
where v.name='db_block_size'
group by d.owner
order by owner
;

select 
       d.tablespace_name          as tablespace
,      sum(blocks*v.value/(1024)) as kb_used
from dba_segments d
,    v$parameter  v
where v.name='db_block_size'
group by d.tablespace_name
order by tablespace_name
;

doc

	The number of Kb per User per Tablespace.
#

col username   format a30
col tablespace format a20
col kb_used    format 9999999999

select d.owner                    -- as username
,      d.tablespace_name          as tablespace
,      sum(blocks*v.value/(1024)) as kb_used
from dba_segments d
,    v$parameter  v
where v.name='db_block_size'
group by d.owner, d.tablespace_name
order by tablespace_name, owner
;

set feedback on
clear columns
prompt

