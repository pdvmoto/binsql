column user_id format 99,999,999,999
column username format A15 
column default_tablespace format A10
column temporary_tablespace format A10
column local_temp_tablespace format A10


select username, user_id
, default_tablespace 
, temporary_tablespace
, local_temp_tablespace
from dba_users 
order by username 
/
