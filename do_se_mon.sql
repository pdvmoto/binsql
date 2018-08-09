
set timing on
set feedb on
 
merge into bt_mon_se u
using (
select e.event_id as event_id
     , sum ( e.time_waited_micro )                 as tim
     , sum ( e.time_waited_micro ) - o.old_tim     as diff
 from v$session_event e
    , bt_mon_se      o
where e.event_id = o.event_id
group by e.event_id, o.old_tim
) n
on ( u.event_id = n.event_id )
when matched then
  update set
    u.old_tim       = u.new_tim     -- the old is overwritten with previous/new
  , u.new_tim       = n.tim         -- the new is filled from the using-clause
  , u.diff          = n.diff        -- the diff was calculated in the using-clause
  , u.dt_recorded   = sysdate
;

-- add the db-time

merge into bt_mon_se u
using (
select s.statistic#                 as event_id
     , s.value                      as tim
     , s.value      - o.old_tim     as diff
 from v$sysstat   s
    , bt_mon_se    o
where s.statistic# = o.event_id
) n
on ( u.event_id = n.event_id )
when matched then
  update set
    u.old_tim       = u.new_tim     -- the old is overwritten with previous/new
  , u.new_tim       = n.tim         -- the new is filled from the using-clause
  , u.diff          = n.diff        -- the diff was calculated in the using-clause
  , u.dt_recorded  = sysdate
;

set timing off

set verify off
set feedb off
set pagesize 50

column database    format A10
column instance    format A8   head curr_inst
column created     format a21
column arch        format a6
column role        format a8
column prot_mode   format A8
column prot_level  format a8  wrap
column hostname    format a20
column started     format a21

column event    format A30 trunc
column wclass   format A10 trunc
column diff     format 999,999,999,999
column diff_fg  format 999,999,999,999
clear screen

set feedb off
set head on

-- now display
select i.instance_name              as instance
, i.host_name                       as hostname
-- , to_char ( i.startup_time, 'YYYY-MON-DD HH24:MI:SS' ) as started
-- , i.status
, count (*)                         as sessions
from v$instance i
   , v$session s
where 1=1 -- i.inst_id = s.inst_id
group by i.instance_name, i.host_name, i.startup_time, i.status
order by 1, 2, 3 ;

set feedb on

-- now present the diffs...
select event
     , wait_class as wclass
     , diff
from bt_mon_se e
where wait_class <> 'Idle'
  and (diff ) > 0 
order by e.diff desc;

-- no explicit exit

