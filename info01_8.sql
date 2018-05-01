

column general_info format A75 
set heading off

SELECT 	'General Information '								   general_info
	,	'--------------------'							   general_info
	,	'Database  :  ' || 	db.name || ' ('|| db.log_mode || ')'		   general_info
	,	'Machine   :  '	||	v1.host_name                                       general_info
	,	'Created   :  '	|| 	to_char ( db.created  , 'DD-MON-YYYY HH24:MI:SS' ) general_info
	,	'Started   :  ' ||	to_char ( startup_time, 'DD-MON-YYYY HH24:MI:SS' ) general_info
 	,  	'Checked   :  ' ||	to_char ( SYSDATE, 'DD-MON-YYYY HH24:MI:SS' ) 	   general_info
FROM 	v$database	db
	,	v$instance	v1
	, 	v$process	p
WHERE p.program LIKE '%(PMON)%'
/

set heading on
