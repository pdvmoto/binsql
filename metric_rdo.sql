
-- redo per SEC and per TX, notably before/after index-creation
-- tx/sec is derived, becaseu not summary available.

column awr_cmd format A18
column end_time format A18
column rdo_p_sec format 999,999,999 
column rdo_per_tx  format 999,999,999 
column tx_p_sec  format 9,999.99

select '@awr12 ' || ( psc.snap_id -1 ) || ' ' ||  psc.snap_id awr_cmd
, to_char ( psc.end_time , 'DY DDMON HH24:MI') end_time
, round ( psc.average ) as Rdo_p_sec
, round ( ptx.average ) as Rdo_p_tx
, round ( (psc.average / ptx.average ), 3 ) tx_p_sec
-- , ss.* 
from dba_hist_sysmetric_summary psc
   , dba_hist_sysmetric_summary ptx
where 1=1
  and psc.snap_id = ptx.snap_id
  and psc.dbid    = ptx.dbid
  and psc.instance_number = ptx.instance_number
  and psc.metric_name like 'Redo Generated Per Sec%'
  and ptx.metric_name like 'Redo Generated Per Txn%'
  and psc.end_time > (sysdate - 30)
order by psc.snap_id , psc.metric_name  ; 

prompt '....,...0 ....,...0 ....,...0 ....,...4 ....,...0 ....,...0 ....,...0 ....,...8'

/****
prompt hit enter to continue...
accept hit_enter

column bargraph_pct format A25 trunc
column val format 99999999 head rdo_p_sec

set headin off

spool rdo.csv

prompt DateTime  Redo_p_sec
with metrics as (  
  -- keep the metric simple: snap, time, value
  -- do the processing +formatting below
select 
  --'@awr12 ' || ( psc.snap_id -1 ) || ' ' ||  psc.snap_id awr_cmd
  psc.snap_id
, psc.end_time
, psc.average  as val
  --, round (max(psc.average) over () ) maxval
  --, rpad ( ' ', 100 * psc.average / (max(psc.average) over () ), '*'  )as bargraph_pct
from dba_hist_sysmetric_summary psc
where 1=1
  and psc.metric_name like 'Redo Generated Per Sec%'
  and psc.end_time > (sysdate - 100 )
  )
select 
  to_char ( metrics.end_time , 'DY DDMON HH24:MI') end_time
, round ( metrics.val ) as val
-- , (max(val) over () )  as max
-- , round  ( 100 * val / (max(val) over () ) ) as pct
, rpad ( '_', 100 * val / (max(val) over () ), '*'  ) as bargraph_pct
from metrics 
order by metrics.end_time 
;
  
spool off

***/
