
column username format A15 
column sid format 99999
column sql_id format A15
column sql_exec_start  format A20
column module format A20
column sql_fulltext format A70  

select s.username, s.sid, s.sql_id, sql_exec_start
--, s.prev_sql_id
, s.module
, t.sql_fulltext
-- , t.*
-- , s.*
from v$session s
, v$sqlarea t
where t.sql_id = s.sql_id
and s.status = 'ACTIVE'
and s.sid <> SYS_CONTEXT ('USERENV', 'SID')
-- and s.username not like 'PEV%'
-- and s.username not like 'SYS'
and s.username is not null
/

