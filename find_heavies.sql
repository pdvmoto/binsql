
-- use this in sql-dev to find heavies.
select s.parsing_schema_name , s.executions, s.elapsed_time, s.cpu_time, s.first_load_time, s.buffer_gets, s.disk_reads, s.plan_hash_value, s.sql_text , s.* 
from v$sql s
  -- , dba_users u
where 1=1 
-- and u.user_id = s.parsing_schema_id   -- need this when join to sqlarea.
and sql_id = '1qd1c0nkyu9y7' 
order by s.buffer_gets desc, s.first_load_time desc 
; 

select s.parsing_schema_name schema, s.executions execs, s.elapsed_time, s.cpu_time
, s.first_load_time, s.last_load_time 
, s.buffer_gets, s.disk_reads
, round ( s.buffer_gets / decode ( s.executions, 0,1, s.executions), 1)  g_p_exe
, s.plan_hash_value, s.sql_text , s.* 
from v$sql s
  -- , dba_users u
where 1=1 
-- and u.user_id = s.parsing_schema_id   -- need this when join to sqlarea.
and sql_id = '1qd1c0nkyu9y7' 
order by s.buffer_gets desc, s.first_load_time desc 
; 
