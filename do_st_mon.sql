
rem helpser-script, meant to be called from do_st_mon.sh

set feedb on

-- 
merge into bt_mon_stats u
  using ( select
  o.statistic#
, o.new_val     new_old_val
, s.value       new_val
, ( s.value - o.old_val )  diff
from bt_mon_stats o
   , v$sysstat s
where o.statistic# = s.statistic#
        ) n
  on ( u.statistic# = n.statistic# )
when matched then
  update set u.old_val = n.new_old_val
           , u.new_val = n.new_val
           , u.diff = n.diff
           , u.per_sec = n.diff / ( (sysdate - u.dt_recorded) * 24 * 3600) 
           , u.dt_recorded = sysdate
;

set pagesize 35
set head on 

column database    format A10
column instance    format A8   head curr_inst
column created     format a21
column arch        format a6
column role        format a8
column prot_mode   format A8
column prot_level  format a8  wrap
column hostname    format a20
column started     format a21

column name             format A23 trunc
column datetime         format A20
column diff             format 999,999,999.00
column per_sec          format 999,999.00
column secs             format 9,999.9

rem watch program will do the sleeping.
rem host sleep 5

clear screen 

-- first display DB-Name and sessions (add more.. ?)

set feedb off

select i.instance_name              as instance
, i.host_name                       as hostname
-- , to_char ( i.startup_time, 'YYYY-MON-DD HH24:MI:SS' ) as started
-- , i.status
, count (*)                         as sessions
from gv$instance i
   , gv$session s
where i.inst_id = s.inst_id
group by i.instance_name, i.host_name, i.startup_time, i.status
order by 1, 2, 3 ;

-- differences timings
select name
     , diff
     , per_sec
--     , to_char (dt_recorded, 'HH24:MI:SS') 
from bt_mon_stats
where name like '%tim%'
   or name like 'CPU%'
order by name ;

-- differences, others
select name
     , diff
     , per_sec
--     , to_char (dt_recorded, 'HH24:MI:SS') 
from bt_mon_stats
where name not like '%tim%'
order by name ;

set feedb on

-- no explicit Exit..
