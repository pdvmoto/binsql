
doc
	File overview: datafiles, logfiles, controlfiles and sizes.
#
column TABLESPACE_NAME      FORMAT A15
column DATAFILE_NAME        FORMAT A50
column LOGFILE_NAME         FORMAT A50
column CONTROLFILE_NAME     FORMAT A50
column SIZE                 FORMAT A10

SET heading on

SELECT  file_name									datafile_name
    ,   lpad(bytes/(1024*1024),4)||' MB' 			"SIZE" 
    ,   tablespace_name
FROM dba_data_files
/

SET heading off

SELECT '                                Total of datafiles   '
||sum(bytes/(1024*1024))||' MB' 
FROM v$datafile
/

SET heading on

SELECT  member										      	logfile_name
    ,   lpad((v$log.bytes/(1024*1024)),4)||' MB' 			"SIZE"
	,   v$logfile.group#
FROM v$logfile, v$log
WHERE v$log.group# = v$logfile.group#
/

SET heading off

SELECT '                               Total of logfiles    '
||lpad(sum(members*bytes/(1024*1024)),4)||' MB' 
FROM v$log
/

SET heading on

SELECT  name	 		controlfile_name
    ,   status
from v$controlfile
/
