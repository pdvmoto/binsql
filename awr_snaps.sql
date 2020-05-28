column comnd   format A30
column endtime format A25 

SELECT '@awr_manual_s1_s2 ' || s1.snap_id || ' ' || s2.snap_id  AS comnd
, to_char ( s2.end_interval_time, 'MON DD HH24:MI' )            as endtime
FROM
dba_hist_snapshot s1, /* sys.wrm$_snapshot s1,  */
dba_hist_snapshot s2  /* sys.wrm$_snapshot s2   */
WHERE s1.dbid                 = s2.dbid
  AND s1.instance_number      = s2.instance_number
  AND s1.startup_time         = s2.startup_time
  AND s1.end_interval_time    = s2.begin_interval_time
  AND  s2.begin_interval_time > (sysdate - 20) -- 1 day
ORDER BY s1.snap_id ;
