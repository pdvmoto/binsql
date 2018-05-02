

column endtime    format A15 
column event_name format A25 

column nr_sequrds     format 999999999

column sequrd_tot     format 999999.99
column sequrd_avg     format   9999.9

column scatrd_tot    format 999999.99
column scatrd_avg    format   9999.9

/*
 a version based directly on the wrm/wrh tables is much more efficient:

kandidate metric:
 - read by other session
 - direct path read (sorts?)
 - db file parallel read
 - controlfile seq read

note: a shortcut SQL would be:
select e.snap_id, e.event_name  
,   nvl(time_waited_micro-lag(time_waited_micro) over (order by e.instance_number,e.snap_id),0) / (1000000) db_time_seconds
from dba_hist_system_event  e
where e.event_name = 'log file sequential read' --'control file sequential read' --'cell single block physical read'
and e.instance_number = 1 
order by  e.snap_id desc ; 


*/

/* 
SELECT 
  TO_CHAR ( s2.end_interval_time, 'MON DD HH24:MI' )                                                     AS endtime 
, e2a.total_waits - e1a.total_waits                                                                      as nr_sequrds
, ( e2a.time_waited_micro - e1a.time_waited_micro )/ (1000000 )                                          AS sequrd_tot
, ( e2a.time_waited_micro - e1a.time_waited_micro )/ ( (e2a.total_waits - e1a.total_waits +1 ) * 1000 )  AS sequrd_avg
, ( e2b.time_waited_micro - e1b.time_waited_micro )/ (1000000 )                                          AS scatrd_tot
, ( e2b.time_waited_micro - e1b.time_waited_micro )/ ( (e2b.total_waits - e1b.total_waits +1 ) * 1000 )  AS scatrd_avg
-- , s1.* 
FROM 
  sys.wrh$_system_event e1a
, sys.wrh$_system_event e2a 
, sys.wrh$_system_event e1b
, sys.wrh$_system_event e2b 
, sys.wrm$_snapshot  s1      
, sys.wrm$_snapshot  s2      
, sys.wrh$_event_name na
, sys.wrh$_event_name nb
--, v$database d
WHERE s1.dbid              = s2.dbid
  AND s1.instance_number   = s2.instance_number 
  AND s1.startup_time      = s2.startup_time
  AND s1.end_interval_time = s2.begin_interval_time
  AND s1.snap_id + 1       = s2.snap_id
  AND s2.begin_interval_time > TRUNC ( SYSDATE - 14 ) -- over the last 7 days 
--   AND  s2.begin_interval_time = ( SELECT MAX (begin_interval_time) FROM sys.wrm$_snapshot) -- is s2 the latest ?
  AND e1a.snap_id         = s1.snap_id
  AND e1a.dbid            = s1.dbid 
  AND e1a.instance_number = s1.instance_number 
  AND e2a.snap_id         = s2.snap_id   
  AND e2a.dbid            = s2.dbid 
  AND e2a.instance_number = s2.instance_number 
  AND e2a.event_id        = e1a.event_id  
  AND e1a.event_id        =  na.event_id
                                 AND na.event_name LIKE 'db file sequential r%'
  AND e1b.snap_id         = s1.snap_id
  AND e1b.dbid            = s1.dbid 
  AND e1b.instance_number = s1.instance_number 
  AND e2b.snap_id         = s2.snap_id   
  AND e2b.dbid            = s2.dbid 
  AND e2b.instance_number = s2.instance_number 
  AND e2b.event_id        = e1b.event_id  
  AND e2b.event_id        =  nb.event_id
                                 AND nb.event_name LIKE 'db file sc%'
ORDER BY s1.snap_id ;

*/

/* and a version for when Sys.wr$ tables not readable */


SELECT 
  TO_CHAR ( s2.end_interval_time, 'MON DD HH24:MI' )                                                     AS endtime 
, e2a.total_waits - e1a.total_waits                                                                      as nr_sequrds
, ( e2a.time_waited_micro - e1a.time_waited_micro )/ (1000000 )                                          AS sequrd_tot
, ( e2a.time_waited_micro - e1a.time_waited_micro )/ ( (e2a.total_waits - e1a.total_waits +1 ) * 1000 )  AS sequrd_avg
, ( e2b.time_waited_micro - e1b.time_waited_micro )/ (1000000 )                                          AS scatrd_tot
, ( e2b.time_waited_micro - e1b.time_waited_micro )/ ( (e2b.total_waits - e1b.total_waits +1 ) * 1000 )  AS scatrd_avg
-- , s1.* 
FROM 
  dba_hist_system_event e1a
, dba_hist_system_event e2a 
, dba_hist_system_event e1b
, dba_hist_system_event e2b 
, dba_hist_snapshot  s1      
, dba_hist_snapshot  s2      
, dba_hist_event_name na
, dba_hist_event_name nb
--, v$database d
WHERE s1.dbid              = s2.dbid
  AND s1.instance_number   = s2.instance_number 
  AND s1.startup_time      = s2.startup_time
  AND s1.end_interval_time = s2.begin_interval_time
  AND s1.snap_id + 1       = s2.snap_id
  AND s2.begin_interval_time > TRUNC ( SYSDATE - 32 ) -- over the last 7 days 
--   AND  s2.begin_interval_time = ( SELECT MAX (begin_interval_time) FROM sys.wrm$_snapshot) -- is s2 the latest ?
  AND e1a.snap_id         = s1.snap_id
  AND e1a.dbid            = s1.dbid 
  AND e1a.instance_number = s1.instance_number 
  AND e2a.snap_id         = s2.snap_id   
  AND e2a.dbid            = s2.dbid 
  AND e2a.instance_number = s2.instance_number 
  AND e2a.event_id        = e1a.event_id  
  AND e1a.event_id        =  na.event_id
  and e1a.dbid            =  na.dbid
                                 AND na.event_name LIKE 'db file sequential r%'
  AND e1b.snap_id         = s1.snap_id
  AND e1b.dbid            = s1.dbid 
  AND e1b.instance_number = s1.instance_number 
  AND e2b.snap_id         = s2.snap_id   
  AND e2b.dbid            = s2.dbid 
  AND e2b.instance_number = s2.instance_number 
  AND e2b.event_id        = e1b.event_id  
  AND e2b.event_id        =  nb.event_id
  and e1b.dbid            =  nb.dbid
                               AND nb.event_name LIKE 'db file sc%'
--  and s1.dbid = d.dbid
ORDER BY s1.end_interval_time , s1.snap_id ;

/**/

