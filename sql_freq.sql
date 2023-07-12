
set head on
set pagesize 50 

column time       format A13
column execs      format 999999
column ela        format 999,999
column sec_px     format 9999.99
column get_px     format 9,999,999
column g_pr       format 999
column nr_rows    format 9,999,999
column pln_hv     format A12

set doc off

/*** for awr, uncomment this  ***/

select to_char ( sn.end_interval_time , 'DDMON HH24:MI') /* || to_char ( sn.instance_number, '9') */ as Time
, sq.executions_delta     execs
, sq.buffer_gets_delta    buff_gets
, round ( elapsed_time_delta / ( decode ( executions_delta,     0, 1, executions_delta     ) * 1000000), 2 )   as sec_px -- (1000 * 1000 )
, round ( buffer_gets_delta  / ( decode ( executions_delta,     0, 1, executions_delta     )          ), 2 )   as get_px -- (1000 * 1000 )
, rows_processed_delta nr_rows
, round ( buffer_gets_delta  / ( decode ( rows_processed_delta, 0, 1, rows_processed_delta )          ) , 2)      g_pr -- , elapsed_time_delta ela
, substr ( sq.plan_hash_value, 1, 12 ) || '' as pln_hv
--, substr ( sx.sql_text, 1, 20) sqltxt
--, sq.* 
from dba_hist_sqlstat  sq 
   , dba_hist_snapshot sn
   , dba_hist_sqltext  sx
where sn.snap_id = sq.snap_id
  and sn.dbid = sq.dbid
  and sn.instance_number = sq.instance_number 
  and sq.sql_id = '&1'
  and sq.sql_id = sx.sql_id
  and sq.dbid = sx.dbid
  and sq.executions_delta > 0 
order by sn.snap_id, sn.instance_number ; 

/*** and for PERFSTAT, uncomment below ** * /


With snaps as
( select /* + materialize * /
s2.snap_time
, s1.snap_id s1
, s2.snap_id s2
, s1.dbid
, s1.instance_number
, round ( ( cast ( s2.snap_time as date) - cast (s1.snap_time as date) ) * 3600 * 24 ) as delta_time
--, s1.*, s2.*
from perfstat.stats$snapshot s1
   , perfstat.stats$snapshot s2
  , v$database db    -- ensure it is "this" dbid, add instance if needed.
where 1=1
and s1.snap_id + 1 = s2.snap_id  -- super simple solustion
and s1.dbid = s2.dbid
and s1.instance_number = s2.instance_number
and s1.startup_time = s2.startup_time
--and s1.end_interval_time = s2.begin_interval_time
and s1.dbid = db.dbid
and s2.snap_time > trunc ( sysdate - 10 )  -- only recent
--order by s1.snap_id desc
) 
select to_char ( sn.snap_time, 'YY-MM-DD HH24:MI')  as snap_time
--, ss.snap_id, ss.executions
,              ss.executions   - LAG(ss.executions  , 1) OVER (ORDER BY ss.snap_id)                   as exe
--, ss.elapsed_time/1000000
, round (    ( ss.elapsed_time - LAG(ss.elapsed_time, 1) OVER (ORDER BY ss.snap_id) ) / (1000000), 2) as ela
--, ss.buffer_gets/1000000
, round (      ss.buffer_gets  - LAG(ss.buffer_gets , 1) OVER (ORDER BY ss.snap_id) , 2)              as buff_gets
, round (    ( ss.buffer_gets  - LAG(ss.buffer_gets , 1) OVER (ORDER BY ss.snap_id) ) 
    / decode ( ss.executions   - LAG(ss.executions  , 1) OVER (ORDER BY ss.snap_id)
             , 0, 1
             , ss.executions   - LAG(ss.executions  , 1) OVER (ORDER BY ss.snap_id) ), 2 )            as g_p_ex
, round (  ( ( ss.elapsed_time - LAG(ss.elapsed_time, 1) OVER (ORDER BY ss.snap_id) ) / 1000000)
    / decode ( ss.executions   - LAG(ss.executions  , 1) OVER (ORDER BY ss.snap_id)
             , 0, 1
             , ss.executions   - LAG(ss.executions  , 1) OVER (ORDER BY ss.snap_id) ), 2 )            as sec_p_ex
from snaps sn
     , perfstat.stats$sql_summary ss
where ss.snap_id =  sn.s1
and ss.sql_id = '&1' -- '400r3w6p07q8c' 
order by sn.s1 ; 

/*** uncommewnt for statspack */

