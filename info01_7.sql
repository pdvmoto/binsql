

column general_info format A75 
set heading off

SELECT 	'General Information '													general_info
	,	'--------------------'													general_info
	,	'Database  :  '  	|| 	db.name || ' ('|| db.log_mode || ')'			general_info
	,	'Machine   :  '		||	RTRIM(SUBSTR ( p.program 
								, INSTR ( p.program, '@' ) + 1
                        					, INSTR ( p.program, ' ' )
                            -  INSTR ( p.program, '@' )  ) )						general_info
	,	'Created   :  '		|| 	to_char (
								 to_date 	( db.created, 'MM/DD/RR HH24:MI:SS')
								 		,	'DD-MON-YYYY HH24:MI:SS'
								 		) 										general_info
	,	'Started   :  ' 	||	to_char (  	to_date(v1.value,'J') 
 											+   	v2.value /( 24*3600)
 											, 'DD-MON-YYYY HH24:MI:SS' ) 		general_info
 	,  	'Checked   :  ' 	||	to_char ( SYSDATE, 'DD-MON-YYYY HH24:MI:SS' ) 	general_info
FROM 	v$database	db
	,	v$instance	v1
	, 	v$instance 	v2
	, 	v$process	p
WHERE 	v1.key Like '%JULIAN%'
and 	v2.key like '%SECONDS%'
and 	p.program LIKE '%(PMON)%'
/

set heading on
