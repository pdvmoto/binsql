/*

make ash report (html) 
 - start wth two dates, arg1= sec_ago, arg2 = nr_of_sec (or arg1-1), 
 - add sql-id later 
 - wait for other optiohs if needed

make filename contain DB+end-time or DB+SQL_id 

test/find diff between text/html/active-html
 
*/

-- html needs extreme linesize ? 
set linesize 8000 
set trimspool on

-- this determines the type options ... 
define fn_name = 'ash_report_html' ; 
define rpt_options = 1 ; 

define report_name = ash_INSTANCE_s1_s2.html     

-- some values do not need setting:
define  inst_name    = 'Instance';
define  db_name      = 'Database';
define  report_type  = 'html';
define  report_type  = 'text';
define  num_days     = 1;  

-- pick up the snapshots from arguments

define start_dt = &1 ;
define end_dt   = &2 ;

define start_dt = '( sysdate - ( &1 / (24*3600))  )'
define end_dt   = '( sysdate - ( ( &1 - &2 ) / (24*3600))  )'

-- debug...
select 'b/e times : ' || &start_dt || ' ' || &end_dt || ']--'  as debug_info
from dual; 

-- accept check_debug_info

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

spool def_ashrpt.sql

--0....,....1....,....2....,....3....,....4
SELECT 
  ' define    inst_num = ' || s2.instance_number    AS dinst_num
, ' define        dbid = ' || s2.dbid               AS ddbid
, ' define report_name = ash_' || d.NAME || '_' 
  || TO_CHAR ( &start_dt, 'YYYYMMDD_HH24MISS') 
  || '.' || decode ( '&report_type', 'txt', 'text', 'html' )  AS dreport_name
FROM 
dba_hist_snapshot s2, /* sys.wrm$_snapshot s1, */
v$database d
WHERE 1=1 
  and s2.snap_id = ( select max (snap_id ) from dba_hist_snapshot ) ;

spool off

-- get the other defines...
@def_ashrpt.sql

-- -- -- -- now the real work.. -- -- -- 
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
                                                            &start_dt, &end_dt 
                                                , l_sql_id=>'0dxrhyrwprdyq' -- 'bmhj4p4yb22sg'
                                                             ));

spool off
set termout on

prompt "! open &report_name "

host open &report_name 

