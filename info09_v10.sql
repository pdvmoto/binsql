doc
	info09.sql

	10g specific info

#

set head on
set feedback off
set pages 60
set lines 112
col job_name format a24
col owner format a20
col repeat_interval format a52
col start_date format a17
col log_date format a17
PROMPT
PROMPT Current Scheduler Jobs:
select job_name, state, to_char(start_date, 'DD-MON-YYYY HH24:MI') start_date, repeat_interval 
from dba_scheduler_jobs;

PROMPT
PROMPT Current Scheduler Windows:
select window_name, resource_plan from dba_scheduler_windows;

PROMPT
PROMPT Scheduler Job Run Details ordered by log_date - last 50 lines:
select log_id, job_name, status , to_char(log_date, 'DD-MON-YYYY HH24:MI') log_date, owner
from dba_scheduler_job_run_details
where rownum < 51
order by 4;

col property_value format a40
col property_name format a28
col description format a36
select * from database_properties;

PROMPT
PROMPT AWR (Automatic Workload Repository) setting.
set feedback off
col snap_interval format a30
col retention format a30
select snap_interval, retention from dba_hist_wr_control;

set pagesize 14
set feedback on
clear columns
prompt

