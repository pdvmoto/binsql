
column namespace format A20
column schema format A15
column package format A20
column type format A10 trunc
column origin_con_id head con format 999

select namespace, schema, package, type, origin_con_id 
from dba_context
order by 1, 2, 3
/

column namespace format A20
column attribute format A20
column value format A20

select namespace, attribute, value
from global_context 
order by 1, 2 ;

