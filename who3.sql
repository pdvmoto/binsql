column username	format  A12
column sid	format  999
column serial	format  99999
column osusr	format  A12
column machine	format  A8
column program	format  A30
set pagesize 24
select 	s.username 
,		s.sid					
,		s.serial#					serial
,		p.spid					unix_id
,		s.osuser					osusr
,		substr ( s.program,1, 30)		program
from v$session 	s
,    v$process  p
where s.paddr = p.addr
and s.sid >= 6
order by unix_id
/

