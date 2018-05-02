
set feedb  off 
set ver    off
set timing off
set head   off

prompt 
prompt statement and explain-plan from sh-pool....
prompt


column operation format A20
column options format A10
column on_object format A30
column cost format 999999


spool do_expl_hash.sql

prompt
prompt spool explained
prompt 

prompt
prompt @date
prompt

prompt
prompt @where
prompt



select  '@expl_hash10 ' || to_char ( a.sql_id ) as hash
from v$sql a
, dba_users u
where u.user_id = a.parsing_user_id
and username not in ( 'SYS', 'SYSTEM', 'SYSMAN', 'DBSNMP' , 'PERFSTAT'
		    , 'PIDEV', 'DBA01', 'PELYO', 'PHDEN', 'CSDRD' )
--and sql_text like '%BUS_ENT%' 
and buffer_gets > 100
and (buffer_gets / decode ( executions, 0, 1, executions ) ) > 100
and executions is not null
and executions >= 1
order by --first_load_time, 
  -- a.executions desc ,
  a.buffer_gets desc
/

prompt
prompt spool off

spool off

set head on

prompt
prompt if needed, execute by running the spoolfile:
prompt
prompt rem @do_expl_hash
prompt 



