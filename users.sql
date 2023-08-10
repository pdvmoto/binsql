column user_id format 99,999,999,999
column username format A15 
column default_tablespace format A10
column temporary_tablespace format A10
column local_temp_tablespace format A10
column account_status format A17


select username, user_id
, default_tablespace 
, temporary_tablespace
-- , local_temp_tablespace
, account_status
from dba_users 
order by username 
/

column expires format A20

prompt List of users about to expire

-- list of users about to expire or grace
select username
-- , local_temp_tablespace
, account_status
, to_char ( expiry_date, 'YYYY-MON-DD' ) expires
from dba_users
where expiry_date < (sysdate + 64 ) 
--and   expiry_date > sysdate 
order by username
/

-- list of users locked or expired
select username
, account_status
, to_char ( expiry_date, 'YYYY-MON-DD' ) expires
from dba_users
where account_status != 'OPEN'
order by username
/
