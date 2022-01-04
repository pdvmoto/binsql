column sql_id        format A14
column total_active  format 9999
column px_cnt        format 999
column sql_text      format A62

set linesize 80
set head on
set feedback on

select s.sql_id, count (*) total_active
-- p.*, s.sql_id, s.*
from v$session s, v$process p
where s.paddr = p.addr
and s.status = 'ACTIVE'
--and p.pname like 'P0%'
having count (*) > 1
group by s.sql_id
 order by 2 desc 
/

with px as 
( select s.sql_id, count (*)  px_cnt
-- p.*, s.sql_id, s.* 
from v$session s, v$process p
where s.paddr = p.addr
and s.status = 'ACTIVE'
and sql_id is not null
--and p.pname like 'P0%'
having count (*) > 1 
group by s.sql_id
)
select px.sql_id, px.px_cnt , substr ( s.sql_text, 1, 60 ) as sql_text 
from px , v$sqlarea s
where s.sql_id = px.sql_id
order by 2 desc 
/

