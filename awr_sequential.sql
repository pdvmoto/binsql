spool awr-sequential-reads.lst
set pages 2000
set lines 160
col snapshots format a14
col delta format 999999999999
col delta_nr_waits format 9999999999999
col diff format a26 head "Delta in time_waited_micro"
col lios_per_sec format 99999999999999
col BEGIN_INTERVAL_TIME format a26
col END_INTERVAl_TIME format a26
col avg_wait_seq format 999.999 head "Average Wait (ms)|db file sequential read"
select s.begin_interval_time, s.end_interval_time, s.end_interval_time - s.begin_interval_time diff ,b.snap_id||','||e.snap_id snapshots,
              e.TIME_WAITED_MICRO - b.TIME_WAITED_MICRO delta , e.TOTAL_WAITS - b.TOTAL_WAITS delta_nr_waits ,
              round ( (e.TIME_WAITED_MICRO - b.TIME_WAITED_MICRO) / (e.TOTAL_WAITS - b.TOTAL_WAITS),4) / 1000 avg_wait_seq
from  dba_hist_system_event b,
       dba_hist_system_event e,
       dba_hist_snapshot s,
       v$database v
where b.snap_id         = e.snap_id -1
          and e.snap_id         > b.snap_id
          and b.dbid            = v.dbid
          and e.dbid            = v.dbid
          and b.instance_number = 1
          and e.instance_number = 1
          and b.event_id         = e.event_id
          and e.event_name in ('db file sequential read')
          and s.snap_id = e.snap_id
order by 1;

spool off
