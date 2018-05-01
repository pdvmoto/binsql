

SELECT 	db.name || ', '		||  db.log_mode
	|| 	', created : ' 	|| 	db.created
	||  ', check : ' 		||	TO_CHAR ( SYSDATE, 'DD-MON-YYYY HH24:MI:SS' ) 
		"Genral info"  
FROM 	v$database	db
/
