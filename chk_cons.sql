
doc

	chk_cons.sql
	count constraints

#

select owner, count (*) total_constraints
from dba_constraints c
where 1=1 
group by owner
/


select owner, constraint_type, count (*) per_type
from sys.dba_constraints
group by owner, constraint_type
order by owner, constraint_type
/



select c.owner
     , c.constraint_type
     , c.deferrable
     , c.deferred
     , count (*)
from dba_constraints c
where 1=1 
group by c.owner, c.deferrable, c.deferred, c.constraint_type
order by 1, 2, 3
/
