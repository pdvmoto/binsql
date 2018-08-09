
set echo off

-- connection needed.

set feedb on

merge into bt_mon_ev u
using (
select e.event_id as event_id
     , e.time_waited_micro                      as tim
     , e.time_waited_micro_fg                   as tim_fg
     , e.time_waited_micro      - o.old_tim     as diff
     , e.time_waited_micro_fg   - o.old_tim_fg  as diff_fg
 from v$system_event e
    , bt_mon_ev      o
where e.event_id = o.event_id
) n
on ( u.event_id = n.event_id )
when matched then
  update set
    u.old_tim       = u.new_tim     -- the old is overwritten with previous/new
  , u.old_tim_fg    = u.new_tim_fg
  , u.new_tim       = n.tim         -- the new is filled from the using-clause
  , u.new_tim_fg    = n.tim_fg
  , u.diff          = n.diff        -- the diff was calculated in the using-clause
  , u.diff_fg       = n.diff_fg
;
-- add the db-time

merge into bt_mon_ev u
using (
select s.statistic#                 as event_id
     , s.value                      as tim
     , s.value                      as tim_fg
     , s.value      - o.old_tim     as diff
     , s.value      - o.old_tim_fg  as diff_fg
 from v$sysstat   s
    , bt_mon_ev   o
where s.statistic# = o.event_id
) n
on ( u.event_id = n.event_id )
when matched then
  update set
    u.old_tim       = u.new_tim     -- the old is overwritten with previous/new
  , u.old_tim_fg    = u.new_tim_fg
  , u.new_tim       = n.tim         -- the new is filled from the using-clause
  , u.new_tim_fg    = n.tim_fg
  , u.diff          = n.diff        -- the diff was calculated in the using-clause
  , u.diff_fg       = n.diff_fg
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
column wclass   format A8 trunc
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
from gv$instance i
   , gv$session s
where i.inst_id = s.inst_id
group by i.instance_name, i.host_name, i.startup_time, i.status
order by 1, 2, 3 ;

set feedb on
set head on

-- now present the diffs...
select event
     , wait_class as wclass
     , diff
     , diff_fg
from bt_mon_ev e
where wait_class <> 'Idle'
  and (diff + diff_fg ) > 0 
order by e.diff_fg desc;

-- no explicit Exit.

