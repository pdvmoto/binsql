
column dend_snap  format A25

With snaps as
( select /* + materialize */ s2.end_interval_time, s1.snap_id s1, s2.snap_id s2, s1.dbid, s1.instance_number
, round ( ( cast ( s2.end_interval_time as date) - cast (s1.end_interval_time as date) ) * 3600 * 24 ) as delta_time
--, s1.*, s2.*
from dba_hist_snapshot s1
  , dba_hist_snapshot s2
  , v$database db    -- ensure it is "this" dbid, add instance if needed.
where 1=1
and s1.snap_id + 1 = s2.snap_id  -- super simple solustion
and s1.dbid = s2.dbid
and s1.instance_number = s2.instance_number
and s1.startup_time = s2.startup_time
and s1.end_interval_time = s2.begin_interval_time
and s1.dbid = db.con_dbid
and s2.begin_interval_time > trunc ( sysdate - 10 )  -- only recent
--order by s1.snap_id desc
)
select /*+ rule */
  '@awr12 '|| s.s1 || ' '|| s.s2 || ' '               as dend_snap
,  to_char ( s.end_interval_time, 'DD MON HH24:MI' ) as date_time
--, s.s1, s.s2, cpu1.value, cpu2.value
, round ( (cpu2.value - cpu1.value)/(1000*1000))       as DB_CPU_SEC
--, round ( (dbt2.value - dbt1.value
--        - (cpu2.value - cpu1.value ) )/(1000*1000))    as DB_non_cpu
--, round ( (dbt2.value - dbt1.value)/(1000*1000))       as DB_TOTTIME
, round ( (dbt2.value - dbt1.value)/(1000*1000*60), 2) as db_min
, ROUND ( ((DBT2.VALUE - DBT1.VALUE)/(1000*1000))  / S.DELTA_TIME, 2 ) AS aas
from snaps s
   , dba_hist_sys_time_model cpu1
   , dba_hist_sys_time_model cpu2
   , dba_hist_sys_time_model dbt1
   , dba_hist_sys_time_model dbt2
--   , dba_hist_system_event e1
where 1=1
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

/
