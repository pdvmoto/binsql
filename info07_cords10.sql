doc
	info07.sql

	All Non Default init.ora parameters 
	
#

set head on
set pages 60
set lines 112
column num   format 9999 heading ' Num'
column name  format a35  heading 'Parameter Name' 
column value format a70  heading 'Parameter Value'


select num , name , value
 from v$parameter
where isdefault='FALSE'
/

set pagesize 14
set feedback on
clear columns
prompt

