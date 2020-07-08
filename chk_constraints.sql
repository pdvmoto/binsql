
column owner format A20 
column constraint_name format A30
column triggering_event format A20
column table_name format A25
column validated format A6 trunc
column constraint_type format A2 heading tp

set linesize 130 
set pagesize 50

select owner, constraint_type, status , validated, count (*)
from dba_constraints
group by owner, status, validated, constraint_type
order by owner, status, validated, constraint_type ; 

prompt 'list of constraints that seem DISABLED '

select owner, status, table_name, constraint_type, constraint_name 
from dba_constraints
where 1=1-- owner not in ('SYS', 'SYSTEM' )
and status <> 'ENABLED' 
and owner not in ( 'SYS', 'SYSTEM' )
order by owner, table_name, constraint_name ; 

prompt 'list of constraints that are enabled, but NOT VALIDATED'

select owner, status, table_name, constraint_type, constraint_name 
from dba_constraints
where owner not in ('CTXSYS', 'SYS', 'SYSTEM' , 'WMSYS' )
and constraint_type not in ('V', 'O' )
and status = 'ENABLED' 
and validated = 'NOT VALIDATED'
and owner not in ( 'SYS', 'SYSTEM' )
order by owner, table_name, constraint_name ; 

