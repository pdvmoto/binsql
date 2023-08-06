-- use this as exmaple QRY
-- find the SQL_id
-- find the objects: table/index
-- get the last_analyzed, the num_rows and dist-values 
-- from dba_tables and dba_indexes.
-- generate the count-qries on tables - to verify counts
select /* probqry */ e.employee_id, e.last_name, d.department_name
--, j.job_title
, l.street_address, l.city
, e.* 
from employees e
, jobs j
, departments d
, locations l
where 1=1
and e.job_id = j.job_id
and e.department_id = d.department_id
and d.location_id = l.location_id
order by e.last_name desc
;

select * from v$sqlarea 
where sql_text like '%probqry%';

select p.object_type, p.object_owner, p.object_name  
, p.* from v$sql_plan p 
where sql_id = '8kdr2bpvkzq6v'
and object_type like '%'
order by position ; 


