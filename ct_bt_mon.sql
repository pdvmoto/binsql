
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
    do_st_mon.sh + do_st_mon.sql + .._go.sql : monitor system-stats
    do_ev_mon.sh + do_ev_mon.sql + .._go.sql : monitor event, syste-wide
    do_se_mon.sh + do_se_mon.sql + .._go.sql : monitor session-system

limitations:
 - only 1 user can run the watcher-screen
 - locking!!
 - when running from sh: beware of extra logons.

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

-- call the sql to do monitoring, implicit test
@@do_st_mon

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


-- now call the do_ev_mon to show it works (and have code in 1 place).

host sleep 2

@@do_ev_mon

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


-- add the wall-clock-time-seconds, to include it in later comparisons
-- consider adding other time-stats ?

insert into bt_mon_se
select 
  'Wall Clock time'  as event 
, -1 as event_id 
, 'Other' as wait_class
, ( sysdate - trunc (sysdate)) * 24 * 3600 as old_tim
, ( sysdate - trunc (sysdate)) * 24 * 3600 as new_tim
, 0  as diff
, sysdate
from v$sysstat
where name like 'DB time'
order by name ; 


-- merge events to demo after create-table

host sleep 2

@@do_se_mon

prompt pause to verify system-events on display
accept &accept_some


set doc off

-- -- -- -- -- add some refernce-doc -- -- -- 
doc

idle events, check v$syste_wait_class or web:
https://docs.oracle.com/cd/B16240_01/doc/doc.102/e16282/oracle_database_help/oracle_database_idle_events.html

#

