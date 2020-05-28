
set linesize 128
set verify off

column usrnm		format  A12	trunc
column osusr		format   A8	trunc
column machine		format  A15	trunc
column program		format  A12	trunc
column process		format  A10
column logon_time 	format  A20
column spid		format 99999
column inst             format 999
column serial           format 9999
column sid              format 999
column sidser           format  A70

column total_conn new_value total_conn

column relative         format A22      

select 
  count (*)             total_conn
from gv$session s
/

-- full list of connections
select 	        p.inst_id 					inst	
,  		nvl ( s.username, 'background' )  		usrnm 
, 		s.machine					machine
,		s.osuser					osusr
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
order by p.inst_id, s.username, s.osuser
/

-- connects per user and per machine
select 	
  p.inst_id 					inst	
, count (*)					nr_connects
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


-- connects per user
select 
  s.inst_id                                             inst
, count (*)                                             nr_connects
, nvl ( s.username, 'background' )  			usrnm 
, '|' || rpad ( 'x', ( count (*) * 20 / &total_conn ), 'x')    relative
from gv$session s
group by inst_id, username
order by inst_id, username
/

select 
  s.inst_id                                             inst
, count (*)                                             nr_connects
, '|' || rpad ( 'x', ( count (*) * 20 / &total_conn ), 'x')    relative
from gv$session s
group by inst_id
order by inst_id
/

select 
  count (*)                                             nr_connects
from gv$session s
;
