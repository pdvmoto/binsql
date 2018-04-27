
set linesize 128

column usrnm		format  A12 trunc
column osusr		format  A12	trunc
column machine		format  A20	trunc
column program		format  A12	trunc
column process		format  A10
column logon_time 	format A20
column spid		format 99999
column inst             format 999
column serial           format 9999
column sid              format 999
column sidser           format A70
column status           format A15

select 	nvl ( s.username, 'background' )  			usrnm 
, 		s.machine					machine
,		s.osuser					osusr
,               p.inst_id 					inst	
,		'...' || substr ( s.program, 1, 10 )		program
--,		s.program 					program
,		p.spid						spid
-- ,       to_char(s.logon_time, 'DD-MON-YYYY HH24:MI:SS')     logon_time
,          s.sid
,          s.serial#
--,          'exec SYS.DBMS_SYSTEM.SET_EV( '
--	   || to_char ( s.sid ) || ',' || to_char ( s.serial#) 
--	   || ', 12, ''''); 'sidser
from gv$session 	s
,	gv$process	p
where	1=1
and 	s.paddr = p.addr
and     s.inst_id = p.inst_id
order by s.username, s.osuser
/


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
and 	s.paddr = p.addr
and     s.inst_id = p.inst_id
group by s.username, p.inst_id, s.machine, s.osuser
order by p.inst_id, s.username, s.osuser
/


select 
  count (*)                                             nr_connects
, s.inst_id                                             inst
, nvl ( s.username, 'background' )  			usrnm 
, s.machine					machine
from gv$session s
group by inst_id, username, machine
/

select 	
  count (*)					nr_sessions
, nvl ( s.username, 'background' ) 		usrnm 
,		'...' || substr ( s.program, 1, 10 )		program
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
and 	s.paddr = p.addr
and     s.inst_id = p.inst_id
group by s.username,  s.program
order by  s.username, s.program
/


select 
  count (*)                                             nr_connects
, s.inst_id                                             inst
, nvl ( s.username, 'background' )  			usrnm 
, status						status
from gv$session s
group by inst_id, username, status
/

select 
  count (*)                                             nr_connects
, s.inst_id                                             inst
from gv$session s
group by inst_id
/

select 
  count (*)                                             nr_connects
from gv$session s
/