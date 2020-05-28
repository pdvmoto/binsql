
-- show users for cdb/pdb

column username format a15
column con_id   format 999

select username, con_id, common 
from cdb_users
order by 1;

