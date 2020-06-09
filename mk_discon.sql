
set pagesize 0 
set linesize 120 

spool do_discon

select  ' alter table ' || owner || '.' || table_name 
|| ' disable constraint ' || constraint_name || ';'
from dba_constraints c
where owner in ( 'XXYSS_TMS' ) 
and constraint_type = 'R'
order by table_name ;

prompt and to re-enable

select  ' alter table ' || owner || '.' || table_name 
|| ' enable constraint ' || constraint_name || ';'
from dba_constraints c
where owner in ( 'XXYSS_TMS' ) 
and constraint_type = 'R'
order by table_name ;

spool off



