
set linesize 160
set pagesize 100

column table_name 	format A30
column index_name 	format A30
column partition_name 	format A30
column segment_type	format A20
column MB               format A12
column blevel           format 9999
column last_anal	format A20
column leaf_blocks	format 99,999


column database    format A10
column instance    format A8   head curr_inst
column created     format a21
column arch        format a6
column role        format a8
column prot_mode   format A8
column prot_level  format a8  wrap  
column started     format a21


spool chk_blvls

set feedb off

select d.name       				  as database
, i.instance_name 				  as instance
, to_char ( d.created, 'YYYY-MON-DD HH24:MI:SS' ) as created
, substr ( d.log_mode, 1, 5)                      as arch
, substr ( d.database_role, 1, 7 )                as role
,           substr ( d.protection_mode, 1, 3) 
  || ' ' || substr ( d.protection_mode, 9, 4)     as prot_mode
, substr ( d.protection_level, 1, 6 )             as prot_level
from v$database  d
   , v$instance  i ;


column instance    format a8 head instance

select i.instance_name                                 as instance
, to_char ( i.startup_time, 'YYYY-MON-DD HH24:MI:SS' ) as started
, i.status
, count (*) as sessions
from gv$instance i
   , gv$session s
where i.inst_id = s.inst_id
group by i.instance_name, i.startup_time, i.status
order by 1, 2, 3 ;

-- need a blank line...
prompt
-- select '' from dual;

set feedb on



select t.table_name  
, to_char ( t.last_analyzed, 'YYYYMMDD HH24:MI:SS' ) as last_anal
--, t.* 
from dba_tables t
where 1=1
  and table_owner = 'PDS_OWNER' 
order by table_name;

select t.table_name,  t.partition_name
, to_char ( t.last_analyzed, 'YYYYMMDD HH24:MI:SS' ) as last_anal
--, t.* 
from dba_tab_partitions t
where 1=1
  and table_owner = 'PDS_OWNER' 
order by table_name;



select
  i.table_name
, i.index_name
, to_char ( i.last_analyzed, 'YYYYMMDD HH24:MI:SS' ) as last_anal
, i.leaf_blocks 
, i.blevel
from dba_indexes i
where 1=1
 and table_owner = 'PDS_OWNER' 
order by table_name, index_name;

select 
  i.table_name
, i.index_name
, ip.partition_name
, to_char ( i.last_analyzed, 'YYYYMMDD HH24:MI:SS' ) as last_anal
, i.leaf_blocks 
, ip.blevel
from dba_ind_partitions ip
   , dba_indexes i
where 1=1
  and i.index_name = ip.index_name
  and i.owner = ip.index_owner 
  and i.table_owner = 'PDS_OWNER'
order by i.table_name, i.index_name, ip.partition_position;

spool off

host gzip chk_blvls.lst
