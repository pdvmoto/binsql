
-- the P.I numbers are "AAS", and correspond to AWR-AAS numbers.
-- also find: which file, which object..is being read..
-- abnd how much of 
with wprocs as (
select s.sid, s.serial#, p.pname
--, s.program, s.type, s.sql_id, s.client_info, s.logon_time, s.event 
--, p.* 
from v$process p, v$session s
where s.paddr = p.addr
and p.pname like 'W%'
)
select proc.pname, ash.* from dba_hist_active_sess_history  ash
, wprocs proc
where proc.sid = ash.session_id
  and proc.serial# = ash.session_serial#
; 

