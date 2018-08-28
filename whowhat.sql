
/* 


*/

column sid      format 99999
column cmd      format A4 trunc
column machine  format A20 trunc
column program  format A20 trunc
column username format A12 trunc


select sid, username, DECODE(command 
,0,'None', 
'2','Ins', 
'3','Sel', 
'6','upd', 
'7','Del', 
'8','Drop', 
'Other') cmd 
, machine, program
from V$session s
where type <> 'BACKROUND'
  and username like upper ( '&1'||'%' )
order by s.sid;

