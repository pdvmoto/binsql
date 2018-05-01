rem info01_v10.sql
rem 
rem Info01 script for Oracle 10
rem

column general_info format A90
set linesize 90 
set heading off
set feedback off

select 	'General Information ' general_info
,	'--------------------' general_info
,	'Database: '||db.name||' ('||db.log_mode||'; FORCE_LOGGING: '||force_logging||'; FLASHBACK_ON: '||flashback_on||') '||'DBID:'||db.dbid general_info
,       'Version : '||vv.banner general_info
,	'Created : '||to_char(db.created,'DD-MON-YYYY HH24:MI:SS') general_info
,	'Started : '||to_char(v1.startup_time,'DD-MON-YYYY HH24:MI:SS')||' PLATFORM_NAME: '||db.platform_name general_info
,  	'Checked : '||to_char(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'     HOST_NAME: '||v1.host_name general_info
,       'Run By  : '||USER general_info
from 	v$database	db
,	v$instance	v1
,       v$version       vv
where rownum < 2;

set heading on
set feedback on
clear columns
prompt
