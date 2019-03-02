
-- redo per SEC and per TX, notably before/after index-creation
-- tx/sec is derived, becaseu not summary available.

column awr_cmd format A18
column end_time format A18
column rdo_p_sec format 999,999,999 
column rdo_per_tx  format 999,999,999 
column tx_p_sec  format 9,999.99

select 'awr12 ' || psc.snap_id || ' ' || ( psc.snap_id -1) awr_cmd
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

