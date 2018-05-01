rem info01_v7.sql
rem 
rem Info01 script for Oracle 7
rem
column general_info format A75 
set heading off

select 	'General Information '													general_info
,	'--------------------'													general_info
,	'Database  :  '||db.name||' ('|| db.log_mode || ')'                     general_info
,       'Version   :  '||vv.banner						general_info
,	'Created   :  '||to_char(to_date(db.created,'MM/DD/RR HH24:MI:SS')
                    ,'DD-MON-YYYY HH24:MI:SS')					general_info
,	'Started   :  '||to_char(to_date(v1.value,'J')+	v2.value /( 24*3600)
                    , 'DD-MON-YYYY HH24:MI:SS')	                                general_info
,  	'Checked   :  '||to_char( SYSDATE, 'DD-MON-YYYY HH24:MI:SS' )           general_info
,       'Run By    :  '||USER                                                   general_info
from 	v$database	db
,	v$instance	v1
, 	v$instance 	v2
,       v$version       vv
where 	v1.key Like '%JULIAN%'
and 	v2.key like '%SECONDS%'
and     rownum < 2
/

set heading on
clear columns
prompt

