
column  awrcmd  format A20 
column  endtime format A15 
column  db_min  format 9999.99
column  secs    format 99999 

with snaps as 
( select lag(snap_id) over (order by snap_id) as s1
, s.snap_id                                   as s2
, CAST( s.end_interval_time AS DATE )         as end_dt
, round (  (  CAST( end_interval_time AS DATE ) 
            - CAST( begin_interval_time AS DATE ) ) * 86400 ) as secs
, lag ( startup_time ) over ( order by snap_id )              as prev_startup_time
, s.startup_time
, s.instance_number
, s.dbid
, s.con_id
, s.begin_interval_time, s.end_interval_time
--, s.* 
from dba_hist_snapshot s
where s.con_id = sys_context('USERENV', 'CON_ID')  -- current CON, DBID may have other history. 
)
select 
  '@awr12 ' || s.s1  || ' ' || s.s2                as awrcmd
, to_char ( s.end_interval_time, 'DY DD HH24:MI' ) as endtime
-- , secs                                          as secs 
-- , round ( ss.average, 2 )                                   as nr_conn
, round ( (cpu2.value - cpu1.value) /(1000*1000))               as DB_CPU_SEC
, round ( (dbt2.value - dbt1.value) /(1000*1000*60), 2)         as db_min
, ROUND ( ((DBT2.VALUE - DBT1.VALUE)/(1000*1000))  / S.secs, 2 ) as aas
from 
  snaps s
, dba_hist_sys_time_model cpu1
, dba_hist_sys_time_model cpu2
, dba_hist_sys_time_model dbt1
, dba_hist_sys_time_model dbt2
where 1=1 
  and s.s1 is not null  -- skip first one, there is no prev. 
  and s.prev_startup_time = s.startup_time -- only valid pairs
and s.s1              = cpu1.snap_id
and s.dbid            = cpu1.dbid
and s.instance_number = cpu1.instance_number
and s.s2              = cpu2.snap_id
and s.dbid            = cpu2.dbid
and s.instance_number = cpu2.instance_number
and cpu1.stat_id      = cpu2.stat_id
and cpu1.stat_name    = 'DB CPU' --'DB time'
  and s.s1              = dbt1.snap_id
  and s.dbid            = dbt1.dbid
  and s.instance_number = dbt1.instance_number
  and s.s2              = dbt2.snap_id
  and s.dbid            = dbt2.dbid
  and s.instance_number = dbt2.instance_number
  and dbt1.stat_id      = dbt2.stat_id
  and dbt1.stat_name    = 'DB time'
  order by s.s1 
;

