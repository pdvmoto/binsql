
/* 


*/

set linesize 128
set pagesize 50

column usrnm		format  A12 trunc
column osusr		format  A12	trunc
column machine		format  A20	trunc
column program		format  A12	trunc
column process		format  A10
column logon_time 	format A20
column spid		format 99999
column inst             format 999
column serial           format 9999
column sid              format 99999
column sidser           format A70
column status           format A15

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



select 	
  count (*)					nr_sessions
, p.inst_id 					inst	
, nvl ( s.username, 'background' ) 		usrnm 
, s.osuser					osusr
, s.machine					machine
--,		'...' || substr ( s.program, 1, 10 )		program
--,		s.program 					program
--,		p.spid						spid
--,       	to_char(s.logon_time, 'DD-MON-YYYY HH24:MI:SS')     logon_time
--,          s.sid
--,          s.serial#
--,          'exec SYS.DBMS_SYSTEM.SET_EV( '
--	   || to_char ( s.sid ) || ',' || to_char ( s.serial#) 
--	   || ', 12, ''''); 'sidser
from gv$session 	s
,	gv$process	p
where	1=1
and     s.username like upper ( '&1'||'%' )
and 	s.paddr = p.addr
and     s.inst_id = p.inst_id
group by s.username, p.inst_id, s.machine, s.osuser
order by p.inst_id, s.username, s.machine, s.osuser
/


select 	
  count (*)					nr_sessions
, p.inst_id 					inst	
, nvl ( s.username, 'background' ) 		usrnm 
, s.osuser					osusr
from gv$session 	s
,	gv$process	p
where	1=1
and     s.username like upper ( '&1'||'%' )
and 	s.paddr = p.addr
and     s.inst_id = p.inst_id
group by s.username, p.inst_id, s.machine, s.osuser
order by p.inst_id, s.username, s.osuser
/

prompt ordered by machine/server/container
break on machine skip

select 
  s.machine					                    machine
, count (*)                                     nr_connects
, nvl ( s.username, 'background' )  			usrnm 
-- , s.inst_id                                     inst
from gv$session s
where     s.username like upper ( '&1'||'%' )
group by inst_id, machine, username
order by machine, username -- , inst_id
/
-- better summary of active sessions

column rsc_grp format A10 trunc

column act format 9999
column inact format 9999
column total format 9999

select
nvl ( s.username, 'background' )  as usrnm
, s.inst_id
,sum ( case s.status when 'ACTIVE' then 1 else 0 end ) as act
,sum ( case s.status when 'ACTIVE' then 0 else 1 end ) as inact
, count (*) as total
, resource_consumer_group rsc_grp
from gv$session s
group by s.username, s.inst_id, resource_consumer_group
order by s.inst_id, s.username ;


select 
  count (*)                                             nr_connects
from gv$session s
/
