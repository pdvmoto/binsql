
column sid format 9999
column username format A20
column opname format A20
column perc format 99999.99
column sql_text format A42

set linesize 120

/* 
select sid, username, opname, round ( sofar / (totalwork) , 2 ) * 100 as perc
--, l.*
from v$session_longops l
where sofar <> totalwork
and totalwork > 0 ;
*/

select l.sid, l.username, l.opname, round ( l.sofar / (l.totalwork) , 2 ) * 100 as perc
, l.sql_id, substr ( s.sql_text, 1, 40 ) as sql_text
--, l.*
from v$session_longops l
, v$sqlarea s
where s.sql_id = l.sql_id  
and l.sofar <> l.totalwork
and totalwork > 0 ;


