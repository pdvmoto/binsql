column instance_number format 9999 head inst
column date_time format A15
column cpu_interval format 999999

column dend_snap  format A32

column db_cpu_sec format 999999
column db_non_cpu format 999999
column db_tottime format 999999 
column db_min     format 999.99 
column aas        format  99.99
column date_time  format A15

/* ***/
 select  stm2.snap_id, stm2.dbid, stm2.instance_number 
 , round ( ( stm2.value - stm1.value ) / ( 1000 * 1000) )  cpu_sec 
 from 
   sys.WRH$_sys_TIME_model stm1
,  sys.wrh$_sys_time_model stm2
 , sys.wrh$_stat_name sn
 where sn.stat_id = stm1.stat_id
 and stm1.stat_id         = stm2.stat_id
 and stm1.dbid            = stm2.dbid
 and stm1.instance_number = stm2.instance_number
 and stm1.snap_id         = stm2.snap_id -1    -- two adjacent snaps..
 and stat_name = 'DB CPU'
 and stm1.instance_number = 1 
 order by snap_id , dbid, instance_number ;
 
 select  
   to_char ( s.end_interval_time, 'MON DD HH24:MI' )     date_time
 , stm2.snap_id, stm2.dbid, stm2.instance_number 
 , round ( ( stm2.value - stm1.value ) / ( 1000 * 1000) )  cpu_sec 
 , round (  (CAST( end_interval_time AS DATE ) - CAST( begin_interval_time AS DATE ) ) * 86400 ) as cpu_interval
 from 
   sys.WRH$_sys_TIME_model stm1
,  sys.wrh$_sys_time_model stm2
 , sys.wrh$_stat_name sn
 , sys.wrm$_snapshot s
 where sn.stat_id = stm1.stat_id
 and stm1.stat_id         = stm2.stat_id
 and stm1.dbid            = stm2.dbid
 and stm1.instance_number = stm2.instance_number
 and stm1.snap_id         = stm2.snap_id -1    -- two adjacent snaps..
 and stat_name = 'DB CPU'
 and stm2.instance_number = 1 
 and stm2.snap_id         = s.snap_id
 and stm2.dbid            = s.dbid
 and stm2.instance_number  = s.instance_number
 order by snap_id , dbid, instance_number ;
/*** */

/* *** old version,  **/
 
With snaps as 
( select /*+ materialize * / s2.end_interval_time, s1.snap_id s1, s2.snap_id s2, s1.dbid, s1.instance_number
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
and s1.dbid = db.dbid
and s2.begin_interval_time > trunc ( sysdate - 30 )  -- only recent
--order by s1.snap_id desc 
)
select /*+ rule * /
  to_char ( s.end_interval_time, 'DD MON HH24:MI' ) as date_time 
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
; 
/** old version **/

/***/
With snaps as 
( select /*+ materialize * / 
  s2.end_interval_time
, s1.snap_id s1
, s2.snap_id s2
, s1.dbid, s1.instance_number
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
and s1.dbid = db.dbid
and s2.begin_interval_time > trunc ( sysdate - 30 )  -- only recent
--order by s1.snap_id desc 
)
select /*+ rule * /
  '@awr_manual_s1_s2 ' || s.s1 || ' ' || s.s2  AS dend_snap
, to_char ( s.end_interval_time, 'DY DD HH24:MI' ) 			as date_time 
, round ( (cpu2.value - cpu1.value)/(1000*1000))      			as DB_CPU_SEC
, round ( (dbt2.value - dbt1.value)/(1000*1000*60), 2) 			as db_min
, ROUND ( ((DBT2.VALUE - DBT1.VALUE)/(1000*1000))  / S.DELTA_TIME, 2 ) as aas
--, s.s1, s.s2, cpu1.value, cpu2.value 
--, round ( (dbt2.value - dbt1.value 
--        - (cpu2.value - cpu1.value ) )/(1000*1000))    		as DB_non_cpu
--, round ( (dbt2.value - dbt1.value)/(1000*1000))       		as DB_TOTTIME
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
;
/****/

column nr_conn format 999.99 heading nr_conn

With snaps as
( select /*+ materialize */
  s2.end_interval_time
, s1.snap_id s1
, s2.snap_id s2
, s1.dbid, s1.instance_number
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
and s1.dbid = db.dbid
and s2.begin_interval_time > trunc ( sysdate - 30 )  -- only recent
--order by s1.snap_id desc
)
select /*+ rule */
  '@awr12 ' || s.s1 || ' ' || s.s2  AS dend_snap
, to_char ( s.end_interval_time, 'DY DD HH24:MI' ) 			as date_time
, round ( ss.average, 2 )                                               as nr_conn
, round ( (cpu2.value - cpu1.value)/(1000*1000))      			as DB_CPU_SEC
, round ( (dbt2.value - dbt1.value)/(1000*1000*60), 2) 			as db_min
, ROUND ( ((DBT2.VALUE - DBT1.VALUE)/(1000*1000))  / S.DELTA_TIME, 2 ) as aas
--, s.s1, s.s2, cpu1.value, cpu2.value
--, round ( (dbt2.value - dbt1.value
--        - (cpu2.value - cpu1.value ) )/(1000*1000))    		as DB_non_cpu
--, round ( (dbt2.value - dbt1.value)/(1000*1000))       		as DB_TOTTIME
from snaps s
   , dba_hist_sys_time_model cpu1
   , dba_hist_sys_time_model cpu2
   , dba_hist_sys_time_model dbt1
   , dba_hist_sys_time_model dbt2
--   , dba_hist_system_event e1
   , DBA_HIST_SYSMETRIC_SUMMARY ss
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
and ss.snap_id        = s.s1
and ss.dbid           = s.dbid
and s.instance_number = ss.instance_number
and ss.metric_name    like 'Session Coun%'
order by s.s1
/
 