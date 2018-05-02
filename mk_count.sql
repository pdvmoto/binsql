set linesize 160

set pagesize 0
set feedb off

doc
	suggestions:
	owner.table: Count(*), nr-rows, GB-data, GB-index, nr_indexes

might use file segesize_t + this code:

With tsize as ( 
  select owner, segment_name, round ( sum (bytes/1024/1024))as mb 
  from dba_segments 
  group by owner, segment_name)
select t.owner, t.table_name, t.num_rows, tsize.mb 
from dba_tables t
  , tsize 
where t.owner like 'EDW_OL%' 
and tsize.owner = t.owner
and tsize.segment_name = t.table_name 
order by t.owner, t.table_name ; 


#


spool do_count.sql



/*
select 'select '' ' || rpad ( object_name, 25)  
	|| ' :'' || to_char ( count (''x'' ), ''99,999,999'' ) from ' 
      --|| owner || '.' 
	|| object_name || ';'
from sys.user_objects
where object_type in ( 'TABLE', 'VI EW' )
order by object_name
/

*/



select 'select '' ' || rpad ( owner || '.' || table_name, 35)  
	|| ' :'' || to_char ( count (''x'' ), ''9,999,999,999'' ) from ' 
        || owner || '.' 
        || table_name || ';'
from dba_tables 
where 1=1
--and owner in ( 'EDW_BASE3', 'VTL_DATA' )
and owner not in  (
'SYSTEM',
'SYS',
'EXFSYS',
'MDSYS',
'PERFSTAT',
'OJVMSYS ',
'ORACLE_OCM',
'ORDDATA',
'ORDDCM',
'ORDSYS',
'SQL_ADSR',
'WMSYS',
'DBSNMP',
'DIP',
'OUTLN',
'SYSADMIN',
'APPQOSSYS',
'XDB')
order by  owner, table_name
/


spool off


