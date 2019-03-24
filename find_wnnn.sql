                                                                                                                         -- the P.I numbers are "AAS", and correspond to AWR-AAS numbers.
-- also find: which file, which object..is being read..
-- abnd how much of 
with wprocs as (
select s.sid, s.serial#, p.pname, s.status
--, s.program, s.type, s.sql_id, s.client_info, s.logon_time, s.event 
--, p.* 
from v$process p, v$session s
where s.paddr = p.addr
and p.pname  like 'W%'
)
select proc.pname, proc.status, ash.sample_time, ash.event, ash.p1, ash.p2
, ash.* 
from dba_hist_active_sess_history  ash
, wprocs proc
where proc.sid = ash.session_id
  and proc.serial# = ash.session_serial#
  and event is not null 
order by ash.snap_id desc, ash.sample_time desc ; 


with wprocs as (
select s.sid, s.serial#, p.pname, s.status, s.event, s.p1, s.p2
--, s.program, s.type, s.sql_id, s.client_info, s.logon_time, s.event 
--, p.* 
from v$process p, v$session s
where s.paddr = p.addr
and p.pname  like 'W%'
)
select * from wprocs p
order by p.pname ;

select * from dba_extents
where file_id = 1
and block_id >= 37270136
and block_id < (37270136 + 10 ); 

