spool awr-lios.lst
set pages 2000
set lines 160
col snapshots format a14
col delta format 999999999999
col delta_nr_waits format 9999999999999
col diff format a26 head "Delta in time_waited_micro"
col lios_per_sec format 99999999999999
col BEGIN_INTERVAL_TIME format a26
col END_INTERVAl_TIME format a26
col avg_wait_scat format 999.999 head "Average Wait (ms)|session logical reads"
select s.begin_interval_time, s.end_interval_time, s.end_interval_time - s.begin_interval_time diff ,b.snap_id||','||e.snap_id snapshots,
                e.value - b.value delta ,
               round((e.value - b.value)/3600,2) lios_per_sec
from  dba_hist_sysstat b,
        dba_hist_sysstat e,
        dba_hist_snapshot s,
        v$database v
where b.snap_id         = e.snap_id -1
           and e.snap_id         > b.snap_id
           and b.dbid            = v.dbid
           and e.dbid            = v.dbid
           and b.instance_number = 1
           and e.instance_number = 1
           and b.stat_id         = e.stat_id
           and e.stat_name in ('session logical reads')
           and s.snap_id = e.snap_id
order by 1
/


spool off
