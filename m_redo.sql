column awrcmd format A20
column endtime format A15
column redo_m_psec format  9,999.999
column phrd_m_psec format  9,999.999

select 
  '@awr12 ' || ( s.snap_id -1 )  || ' ' ||  s.snap_id as awrcmd
,  to_char ( s.end_time, 'DY DD HH24:MI' ) as endtime
--, s.metric_name
,     s.average /(1024*1024) as redo_m_psec
,  prds.average /(1024*1024) as phrd_m_psec
--, s.* 
from DBA_HIST_SYSMETRIC_SUMMARY s
   , dba_hist_sysmetric_summary prds
where 1=1
  and s.metric_name like '%Redo Generated Per Sec%'
  and prds.metric_name like 'Physical Read Bytes Per Sec%'
  and s.snap_id = prds.snap_id
  and s.dbid    = prds.dbid
  and s.instance_number = prds.instance_number
order by s.snap_id, s.metric_name 
/

