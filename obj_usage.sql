

prompt obj_usage: which stmnts use one or more objects
prompt .
prompt usage:
prompt SQL> @obj_usage SCOTT DEP%
prompt .
prompt Find which SQL_ids have used an object..
prompt initially only from shared_pool, need to adjust for dba_hist or stats$
prompt .
prompt for more info: copy the sql from the file into sql-dev and uncomment columns
prompt .


column sql_id format A14
column owner format A10
column object_name format A25
column operation format A20
column gets format 99999999
column exe  format 99999999
column rows format 999999

with obj_usage as (
select sql_id, object_owner as owner, object_name
, Operation, options, cost, cpu_cost, bytes --, p.* 
from v$sql_plan p
where p.object_owner like '&1'
  and p.object_name  like '&2' 
)
select 
  u.owner, u.object_name
  -- u.*
, s.sql_id, s.buffer_gets gets, s.executions exe
--, s.rows_processed as rows
, u.operation || ' ' || u.options as operation
, substr ( s.sql_text, 1, 20 ) as stmnt
from obj_usage u
, v$sqlarea s
where u.sql_id = s.sql_id
;
