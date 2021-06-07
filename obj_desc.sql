

prompt obj_desc: adhoc description of object, partitioning, iot, lob
prompt .
prompt usage:
prompt SQL> @obj_usage SCOTT DEP%
prompt .
prompt Check if an object has segments, partitions, IOT, Lobs..
prompt .
prompt for more info: copy the sql from the file into sql-dev and uncomment columns
prompt .


column sql_id         format A15
column owner          format A10
column object_name    format A25
column table_name     format A25
column partitioned    format A7 heading PART_YN
column iot_type       format A7 

column lobcol format A25 

column index_name     format A25
column index_type     format A10 trunc
column uniqueness     format A4 trunc 

column partition_name format A25
column operation format A20
column gets format 99999999
column exe  format 99999999
column rows format 999999

prompt ==== tables, partioned y_n ===== 

select table_name, partitioned, iot_type 
from dba_tables 
where table_name like upper ( '&2'||'%' )
  and owner      like upper ( '&1'||'%')
order by owner, table_name
/

prompt ===== table and their lobs ===== 
select owner, table_name
, column_name as lobcol 
-- , segment_name, index_name /* always sys-generated names */ 
, partitioned, securefile
from dba_lobs
where table_name like upper ( '&2'||'%' )
  and owner      like upper ( '&1'||'%')
order by owner, table_name
/


prompt ===== indexes, unique_yn, partitioned yn ===== 
select table_name, index_name, index_type, uniqueness, partitioned 
-- , i.*
from dba_indexes i
where table_name like upper ( '&2'||'%' )
  and owner      like upper ( '&1'||'%')
order by i.owner, i.table_name, i.index_name
;


