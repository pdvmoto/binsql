column awrcmd format A20
column endtime format A20
column rd_mb   format 999.99
column wr_mb   format 999.99
column lg_mb   format 999.99


select '@awr12 ' || ( sr.snap_id -1 )  || ' ' ||  sr.snap_id as awrcmd
,  to_char ( sr.end_time, 'DY DD HH24:MI' ) as endtime 
, round ( sr.average /(1024*1024), 2) rd_mb 
, round ( sw.average /(1024*1024), 2) wr_mb 
, round ( sl.average /(1024*1024), 2) lg_mb 
--, sr.metric_name, sr.* 
from dba_hist_sysmetric_summary sr
   , dba_hist_sysmetric_summary sw
   , dba_hist_sysmetric_summary sl
where 1=1
  and sr.snap_id = sw.snap_id
  and sr.snap_id = sl.snap_id
  and 1=1  -- more joins would be correct...
  and sr.metric_name like '%Read Bytes%'
  and sw.metric_name like '%Write Bytes%' 
  and sl.metric_name like '%Redo Generated Per Sec%'
order by sr.snap_id;

prompt . 
Prompt data form event_summary, small diff with awrrpt load profile.
prompt . 
