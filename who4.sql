column program format A50
column username format A20
column con_id format 99999 

select username, program , con_id
from v$session 
where username is not null 
order by username
/
