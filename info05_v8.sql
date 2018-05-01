doc 
	info05.sql

	Summary of objects per user
#

set heading off
set linesize 100
set pagesize 100
set feedback off
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
order by d.owner, d.tablespace_name
;

prompt
doc 
	info05.sql section 3

	User Profile

        Check the Default and Temporary Tablespace settings, Default profile settings
        User Creation Dates, Account Status all Open or Locked Since?

#

set linesize 112
set pagesize 1000
set feedback on
column	name		format a18
column	def_tab		format a10 head DEFAULT|TABLESPACE
column	temp_tab	format a5 head TEMP|TABLE|SPACE
column	created		format a8
column	profile		format a18
column  account_status  format a16 head ACCOUNT|STATUS
column lock_date        format a8 head LOCK|DATE
col initial_rsrc_consumer_group format a22 head INITIAL_RESOURCE|CONSUMER_GROUP
SELECT username  name
, default_tablespace def_tab
, temporary_tablespace temp_tab
, TO_CHAR ( created, 'DD-MM-YY' ) created
, profile  profile
, initial_rsrc_consumer_group 
, ACCOUNT_STATUS
, TO_CHAR( LOCK_DATE, 'DD-MM-YY' ) lock_date
FROM sys.dba_users
ORDER BY 1;

PROMPT Display Active Resource Plan. If no rows selected then no resource plan is active.
set head on
select * from v$rsrc_plan;

set feedback on
clear columns
prompt

