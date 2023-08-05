/*

awr_list: show list of available snapshots, possibly prepare manual-runs

	
*/

-- some values do not need setting:
      define  inst_name    = 'Instance';
      define  db_name      = 'Database';
      define  report_type  = 'html';
      define  num_days     = 1;

-- some values need setting, as they can differ from one run to aother,
-- we will assume we need a txt report over the last valid interval,
-- hence we look for the last two snaps, the inst_id, the dbid.#
-- the report name will be constructed separately, from time-

column dinst_num    format A55
column ddbid        format A55
column dbegin_snap  format A55
column dreport_name format A55

column dend_snap    format A45
column endtime      format A30

set linesize 80
set heading on
set feedb off
set verify off

--spool last_awrrpt.lst

--0....,....1....,....2....,....3....,....4
SELECT '@awr12 ' || s1.snap_id || ' ' || s2.snap_id  AS dend_snap
, '-- ' || to_char ( s2.end_interval_time, 'DY DD HH24:MI:SS' ) as endtime 
FROM 
dba_hist_snapshot s1, /* sys.wrm$_snapshot s1,  */
dba_hist_snapshot s2  /* sys.wrm$_snapshot s2   */
WHERE s1.dbid                 = s2.dbid
  AND s1.instance_number      = s2.instance_number
  AND s1.startup_time         = s2.startup_time
  AND s1.end_interval_time    = s2.begin_interval_time
  AND  s2.begin_interval_time > trunc ( sysdate - 10 )
--          ( SELECT MAX (begin_interval_time) FROM /* sys.wrm$_snapshot*/ dba_hist_snapshot) -- is s2 the latest ?  
ORDER BY s1.end_interval_time
-- s1.snap_id 
;

spool off

-- now call the script to add the other definitions, 
-- this will then use awr_manual_s1_s2.sql to run the actual report.

-- @last_awrrpt.lst
