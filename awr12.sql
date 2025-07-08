/*

make report runnable : awr_manual_s1_s2... (on v11.2 and v12.1)
... if &1 is empty: assume last snapshots
... if &1 is -1: assume last-but-one etc..

make filename contain DB+snaptimes 

test/find diff between text/html/active-html
 
*/

-- html needs extreme linesize ? 
set linesize 8000 
set trimspool on

-- this determines the type options ... 
define fn_name = 'awr_report_html' ; 
define rpt_options = 1 ; 

define report_name = awr_INSTANCE_s1_s2.html     

-- some values do not need setting:
define  inst_name    = 'Instance';
define  db_name      = 'Database';
define  report_type  = 'html';
define  report_type  = 'text';
define  num_days     = 1;  

-- pick up the snapshots from arguments

define bid = &1 ;
define eid = &2 ;

-- to pick up dbid and inst_num and report-name, we use spooled-define-stmnts

/***

***/

-- use code from previous files s1/s2

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
, ' define report_name = awr_' || d.global_name || '_' 
  || TO_CHAR (s2.end_interval_time, 'YYYYMMDD_HH24MISS') 
  || '.' || decode ( '&report_type', 'txt', 'text', 'html' )  AS dreport_name
FROM 
dba_hist_snapshot s2, /* sys.wrm$_snapshot s1, */
global_name d
WHERE 1=1 
  and s2.snap_id = &2 ;

spool off

-- get the other defines...
@def_awrrpt.sql

-- now the real work..
set echo off
set pagesize 0
set heading off

-- html needs extreme linesize ? 
set linesize 8000 
set trimspool on

set termout off

-- set spoolfile..
spool &report_name

-- this then seems to work
select output from table(dbms_workload_repository.&fn_name( &dbid,
                                                            &inst_num,
                                                            &bid, &eid,
                                                            &rpt_options ));

spool off

set termout on

prompt file spooled and  opening automatically

! open &report_name

