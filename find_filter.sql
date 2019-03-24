
-- use this (in SQLDEV..) to find filter-preciates on an object or query


select p.options, p.filter_predicates, p.access_predicates, p.cost, p.cpu_cost, p.sql_id
, p.* 
from v$sql_plan p
where 1=1 -- 
and object_name like 'PIL_SERVICE_PROCESSES'
and p.filter_predicates is not null
--and sql_id = 'g59s8dj44w454'
--and plan_hash_value = '153669527'
order by p.cost desc ;

