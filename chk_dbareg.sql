
column comp_id format A10
column modified format A22
column comp_name format A30


select comp_id
, modified
, comp_name  
, status
from dba_registry
order by comp_id ; 

select * 
from dba_registry
where 1=0
order by modified ; 

