
-- size of tablespace from dba_hist

select ts.tsname, round (tsu.tablespace_size * 8192 / (1024*1024*1024)) gb 
, tsu.rtime
--, tsu.* 
from dba_hist_tbspc_space_usage tsu
, dba_hist_tablespace ts
where ts.dbid = tsu.dbid
  --and ts.snap_id = tsu.snap_id
  and ts.ts# = tsu.tablespace_id
  and ts# in ( 09, 10, 11 )
  and mod (snap_id , 96) = 0 
order by tsu.snap_id, tablespace_id;

