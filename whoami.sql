

set linesize 128

column usrnm		format  A12 trunc
column osusr		format  A8	trunc
column machine		format  A15	trunc
column program		format  A15	trunc
column process		format  A10
column spid		format  A5      head spid
column serial           format 9999     head sernr
column sid              format 999      head sid

column sidser           format A70

column inst_id         format 9999 head inst
column inst            format 9999 head inst
column instance	       format A8   head instance 
column hname	       format A8   head host     
column username        format a15
column logon_time      format a16
column osuser          format a10
column machine         format a10

column sidser          format A10 head sidser 

column failover_type   format A7  head fov_typ    trunc   
column failover_method format A4  head meth       trunc
column fld_over        format A5  head fldov      trunc



select 	nvl ( s.username, 'background' )  			usrnm 
, 		i.instance_name					instance
, 		i.host_name					hname
--,         p.inst_id 					inst	
--, 		s.machine					machine
,		s.osuser					osusr
,		'..' || substr ( s.program, 1, 12 )		program
--,		s.program 					program
,		p.spid						spid
--,          to_char(s.logon_time, 'DD-MON HH24:MI:SS')     logon_time
--,          s.sid
--,          s.serial#						serial
, 	     to_char ( s.sid ) || ',' || to_char ( s.serial#)   sidser
-- , 	   failover_type
-- , 	   failover_method
-- , 	   failed_over fld_over
--,          'exec SYS.DBMS_SYSTEM.SET_EV( '
--	   || to_char ( s.sid ) || ',' || to_char ( s.serial#) 
--	   || ', 12, ''''); 'sidser
from v$session 	s
,	v$process	p
, 	v$instance	i
where	1=1
and 	s.paddr = p.addr
--and     s.inst_id = p.inst_id
and s.sid in ( select sid from v$mystat where rownum < 2)
order by s.username, s.osuser
/


/***

select 
  s.inst_id                                             inst
, nvl ( s.username, 'background' )  			usrnm 
, count (*)                                             nr_connects
from gv$session s
group by inst_id, username
/

-- experiment with CDB
column con_id 		format 999
column con_name		format a10

select 
  s.inst_id                                             inst
, nvl ( s.username, 'background' )  			usrnm 
, s.con_id						con_id
, nvl ( p.name, 'cdb_root')				con_name 
, count (*)                                             nr_connects
from gv$session s
, gv$pdbs p
where p.con_id (+)= s.con_id 
group by s.inst_id, s.username, s.con_id, p.name
/


***/

