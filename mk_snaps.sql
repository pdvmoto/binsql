
-- mk_snaps.sql: view to generate valid snapshot-combinations
-- BEWARE: only if direct grants, so not often usable.
-- use as template if needed

create or replace view snaps as 
select s1.snap_id as snap1
, s2.snap_id as snap2
--,  ( s1.end_interval_time -   s1.begin_interval_time) * (24*3600)  as secs
,  ( cast ( s1.end_interval_time as date)  -   cast ( s1.begin_interval_time as date )) * (24*3600)  as secs
--, extract ( day from ( (s1.end_interval_time -  s1.begin_interval_time) * 24*3600 ))
, s2.instance_number, s2.dbid
, s2.startup_time
, s1.begin_interval_time, s1.end_interval_time 
--, s2.* 
from sys.wrm$_snapshot s1
   , sys.wrm$_snapshot s2
where 1=1 
and s1.dbid = s2.dbid
and s1.startup_time = s2.startup_time
and s1.instance_number = s2.instance_number
and s2.begin_interval_time = s1.end_interval_time  /* only adjacent */
;



