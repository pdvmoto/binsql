rem info01_v8.sql
rem 
rem Info01 script for Oracle 8
rem

column general_info format A75 
set heading off

select 	'General Information ' general_info
,	'--------------------' general_info
,	'Database  :  ' ||db.name||' ('|| db.log_mode || ')        '||'DBID: '||db.dbid general_info
,       'Version   :  ' ||vv.banner                                 general_info
,	'Created   :  '	||to_char(db.created,'DD-MON-YYYY HH24:MI:SS') general_info
,	'Started   :  ' ||to_char(v1.startup_time, 'DD-MON-YYYY HH24:MI:SS' ) general_info
,  	'Checked   :  ' ||to_char(SYSDATE,'DD-MON-YYYY HH24:MI:SS' )||'     HOST_NAME: '||v1.host_name general_info
,       'Run By    :  '||USER                                                   general_info
from 	v$database	db
,	v$instance	v1
,       v$version       vv
where rownum < 2
/

set heading on
clear columns
prompt
