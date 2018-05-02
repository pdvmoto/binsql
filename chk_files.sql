SET doc off
rem 
rem Script: chk_files.sql
rem
rem Usage : This file generates the database files + redo files + controlfiles
rem         off the current database and gives the total amount off space used.
rem
rem         It spools it to the file /oracle/admin/list/chk_files.lst
rem

SET pagesize 64
SET feedback off
SET heading off

/* ------------------------------------------------------------------
** Display header information.
**
** Containing SID, unix box name, timestamp and archive mode.
** ------------------------------------------------------------------
*/

SPOOL /oracle/admin/list/chk_files.lst

prompt  title: /oracle/admin/list/chk_files.lst

SELECT  'Check of: '||db.name||' on '||rtrim(SUBSTR((program),8,6))
||' at '||to_char(sysdate,'DD-MON-YY HH24:MI:SS')||' running in '||
lower(db.log_mode)||' mode.'
FROM    v$database      db
,       global_name     gn
,       v$process       p
WHERE   p.program LIKE '%(PMON)%'
/


column TABLESPACE_NAME      FORMAT A15
column DIR_NAME             FORMAT A30
column DATAFILE_NAME        FORMAT A20
column LOGFILE_NAME         FORMAT A20
column CONTROLFILE_NAME     FORMAT A20
column SIZE                 FORMAT A10

SET heading on

SELECT  substr(file_name,   1,  instr(file_name,'/',-1,1) - 1)  dir_name
    ,   substr(file_name,       instr(file_name,'/',-1,1) + 1)  datafile_name
    ,   ' = '||lpad(bytes/(1024*1024),4)||' MB' "SIZE" 
    ,   tablespace_name
FROM dba_data_files
ORDER BY tablespace_name
, datafile_name
/

SET heading off

SELECT '                               Total off datafiles   = '
||sum(bytes/(1024*1024))||' MB' 
FROM v$datafile
/

SET heading on

SELECT  substr(member,  1,  instr(member,'/',-1,1) -    1)      dir_name
	,   substr(member,      instr(member,'/',-1,1) +    1)      logfile_name
    ,   ' = '||lpad((v$log.bytes/(1024*1024)),4)||' MB' "SIZE"
	,   v$logfile.group#
FROM v$logfile, v$log
WHERE v$log.group# = v$logfile.group#
/

SET heading off

SELECT '                               Total off logfiles    = '
||lpad(sum(members*bytes/(1024*1024)),4)||' MB' 
FROM v$log
/

SET heading on

SELECT  substr(name,    1,  instr(name,'/',-1,1) -  1)  		dir_name
    ,   substr(name,        instr(name,'/',-1,1) +  1)  		controlfile_name
    ,   status
from v$controlfile
/

SPOOL OFF
NEWPAGE
exit
