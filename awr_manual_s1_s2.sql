/*

The spooling of txt-report from AWR

There are two related files
1. awr_last.sql: spool a text report of the last valid interval.
2. awr_manual_s1_s2 : spool report with &1 and &2 as begin/end snapshots.
	
Updates:
 - use s1 for qry to get correct report-name with END time.	
	
*/

-- some values do not need setting:
      define  inst_name    = 'Instance';
      define  db_name      = 'Database';
      define  report_type  = 'html';
--      define  report_type  = 'text';
      define  num_days     = 1;

-- some values need setting, as they can differ from one run to aother,
-- we will assume we need a txt report over the last valid interval,
-- hence we look for the last two snaps, the inst_id, the dbid.#
-- the report name will be constructed separately, from time-


column dinst_num    format A55
column ddbid        format A55
column dbegin_snap  format A55
column dend_snap    format A55
column dreport_name format A55

set linesize 60
set heading off
set feedb off
set verify off

spool def_awrrpt.sql

--0....,....1....,....2....,....3....,....4
SELECT 
  ' define    inst_num = ' || s2.instance_number    AS dinst_num
, ' define        dbid = ' || s2.dbid               AS ddbid
, ' define report_name = awr_' || d.NAME || '_' 
  || TO_CHAR (s2.end_interval_time, 'YYYYMMDD_HH24MISS') 
  || '.' || decode ( '&report_type', 'txt', 'text', 'html' )  AS dreport_name
FROM 
dba_hist_snapshot s2, /* sys.wrm$_snapshot s1, */
v$database d
WHERE 1=1 
  and s2.snap_id = &2 ;

spool off

-- define the snapshots
define begin_snap = &1
define end_snap   = &2

-- get the other defines...
@def_awrrpt.sql

-- here we call the rdbms-admin provided file, with NO MODIFICATIONS in the file,
-- there may be a little more output to stdout, but by tolerating that,
-- we re-use an exising, oracle-provided file with no modifications - no maintnance.

@?/rdbms/admin/awrrpti