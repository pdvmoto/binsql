
column sid      format 9999 
column usr      format A8 
column module   format A8  trunc
column sql_id   format A14 
column event    format A20 trunc
column sqltxt   format A20 trunc

select s.sid
, s.username usr
, s.module
, s.event
, s.sql_id
, substr ( sa.sql_text, 1, 19) sqltxt
-- , s.machine, s.terminal, s.program 
-- , s.* 
from v$session  s
   , v$sqlarea sa
where 1=1
and sa.sql_id (+) = s.sql_id 
and s.schemaname <> 'SYS' 
order by s.username, s.sid; 

