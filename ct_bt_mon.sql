
rem ct_bt_mon: create the table for bt_monitoring, events and statistics

/*  
concept is simple (and primitive)
 - table(s) to store "snapshot of statitics and event
 - merge after x seconds
 - show difference
 - use watch -n<sec> to repeat
 - in sh-scripts: call an sql-file with @, prevent use of \$ to escape-dollar.

tables (at the moment, 07Aug2018)
 - bt_mon_st : stats  (incl db-time.. which might be added to events..)
 - bt_mon_ev : events (incl timing)
 - bt_mon_se : sessions_events (incl timing)

 - scripts: 
    do_st_mon.sh + do_st_mon.sql : monitor system-stats
    do_ev_mon.sh + do_ev_mon.sql : monitor event, syste-wide
    do_se_mon.sh + do_se_mon.sql : monitor session-system

limitations:
 - only 1 user can run the watcher-screen
 - locking!!

improvements: 
 - use session-id to isolate multiple watchers.
 - dont use GV, avoid PX-exec.
 - add time (per record) to get per-sec values
 - separate : stats-time/sec, and stats-counters.
 - separate : session-events.. 

long-term:
 - devise way to run wihtout table, e.g. cast varray to table ? 
 - show (IN)Active Sessions and DB-time
 - show PX activity.

*/ 

-- at create-time, we determine which Stat go in...

drop table bt_mon_stats ;

create table bt_mon_stats as (
select s.statistic#, name
, value as old_val , value new_val
, (value-value) as diff
, (value-value) as per_sec
, sysdate       as dt_recorded
from v$sysstat  s
where 1=1
and name in ( 'DB time'
, 'logons current'      , 'logons cumulative'
, 'OS System time used' , 'OS User time used'
, 'consistent gets'     , 'db block gets'
, 'physical reads'
, 'parse time cpu'      , 'parse time elapsed'
, 'redo blocks written' , 'redo write time'
, 'user commits'        , 'user rollbacks'
, 'user calls'          , 'execute count'
, 'user logons cumulative'
, 'user I/O wait time'
, 'CPU used by this session', 'DB time')
);

create unique index bt_mon_stats_pk on bt_mon_stats ( statistic# ) ;
create unique index bt_mon_stats_uk on bt_mon_stats ( name ) ;

-- this stmnt to merge next set of diff-stats
-- better test: call the do_st_mon.sql script to test first right away

host sleep 2 

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
           , u.diff    = n.diff
           , u.per_sec = n.diff * 24 * 3600 / (sysdate - u.dt_recorded)
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
column per_sec          format     999,999.00

rem clear screen

-- now display: instance, sesion, and stats

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

-- differences f
select name, diff, per_sec
from bt_mon_stats
order by name ;

prompt pause to verify system-statistics on display
accept &accept_some


-- -- -- System Events -- -- - -

-- at create time, we take "all" events, will be .. +/- 100 

drop table bt_mon_ev;

create table bt_mon_ev as
select e.event
, e.event_id
, e.wait_class
, e.time_waited_micro       old_tim
, e.time_waited_micro_fg    old_tim_fg
, e.time_waited_micro       new_tim
, e.time_waited_micro_fg    new_tim_fg
, e.time_waited_micro       - e.time_waited_micro      diff
, e.time_waited_micro_fg    - e.time_waited_micro_fg   diff_fg
from v$system_event e
   , v$system_wait_class c
where 1=1
and e.wait_class_id = c.wait_class_id
order by e.event ;

create unique index bt_mon_ev_pk on bt_mon_ev ( event_id ) ;
create unique index bt_mon_ev_uk on bt_mon_ev ( event ) ;


-- add the db-time, to include it in later comparisons

insert into bt_mon_ev
select 
  name as event 
, statistic# as event_id 
, 'Other' as wait_class
, value as old_tim
, value as old_tim_fg 
, value as new_tim
, value as new_tim_fg
, value - value as diff
, value - value as diff_fg
from v$sysstat
where name like 'DB time'
order by name ; 


-- merge events to demo

host sleep 2

set timing on

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


-- add the db-time, using the fact that stat# is stored in event_id

merge into bt_mon_ev u
using (
select s.statistic# 		    as event_id
     , s.value                      as tim
     , s.value    	            as tim_fg
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
set feedb on
set pagesize 50


column event    format A30 trunc
column wclass   format A8 trunc
column diff     format 999,999,999,999
column diff_fg  format 999,999,999,999

-- now present the diffs...
select event
     , wait_class as wclass
     , diff
     , diff_fg
from bt_mon_ev e
order by e.diff_fg desc;

-- commit, in case someone is watch-ing the data
commit;

prompt pause to verify system-events on display
accept &accept_some


-- -- -- -- now add sum-session-events.. These are the actual events in Top-N AWR -- -- -- 

drop table bt_mon_se;

create table bt_mon_se as
select event
     , event_id
     , wait_class
     , sum ( time_waited_micro ) as old_tim 
     , sum ( time_waited_micro ) as new_tim 
     , sum ( time_waited_micro-1 ) as diff 
     , sysdate                      as dt_recorded
from v$session_event
where wait_class <> 'Idle'
group by event_id, event, wait_class
; 

create unique index bt_mon_se_pk on bt_mon_se ( event_id ) ;
create unique index bt_mon_se_uk on bt_mon_se ( event ) ;

-- add the db-time, to include it in later comparisons
-- consider adding other time-stats ?

insert into bt_mon_se
select 
  name as event 
, statistic# as event_id 
, 'Other' as wait_class
, value as old_tim
, value as new_tim
, value - value as diff
, sysdate
from v$sysstat
where name like 'DB time'
order by name ; 


-- merge events to demo after create-table

host sleep 2

set timing on

merge into bt_mon_se u
using (
select e.event_id as event_id
     , sum ( e.time_waited_micro )                  as tim
     , sum ( e.time_waited_micro )  - o.old_tim     as diff
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

-- add the db-time (lter) and elapsed

merge into bt_mon_se u
using (
select s.statistic# 		    as event_id
     , s.value                  as tim
     , s.value      - o.old_tim     as diff
 from v$sysstat   s
    , bt_mon_se   o
where s.statistic# = o.event_id
) n
on ( u.event_id = n.event_id )
when matched then
  update set
    u.old_tim       = u.new_tim     -- the old is overwritten with previous/new
  , u.new_tim       = n.tim         -- the new is filled from the using-clause
  , u.diff          = n.diff        -- the diff was calculated in the using-clause
  , u.dt_recorded   = sysdate 
;

set timing off

-- now show..

set verify off
set feedb on
set pagesize 50

column event    format A30 trunc
column wclass   format A8 trunc
column diff     format 999,999,999,999
column diff_fg  format 999,999,999,999

-- now present the diffs...
select event
     , wait_class as wclass
     , diff
from bt_mon_se e
order by e.diff desc;

-- commit, in case someone is watch-ing the data
commit;

prompt pause to verify system-events on display
accept &accept_some


set doc off

-- -- -- -- -- add some refernce-doc -- -- -- 
doc

idle events, check v$syste_wait_class or web:
https://docs.oracle.com/cd/B16240_01/doc/doc.102/e16282/oracle_database_help/oracle_database_idle_events.html

#

