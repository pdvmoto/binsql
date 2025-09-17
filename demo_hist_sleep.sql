set doc off
/*** 

file: demo_hist_sleep.sql : show the anomaly in elapsed-time of sleep-calls

Purpose: 
  run a CPU-using command, timing-on will tell the duration
  run two sleep commands, and the timing-on will show they sleep the desired time
  the query the sql_history, and see how the numbers match...

Preparations: dont forget to set + grant
  alter system set sql_history_enabled=true
  grant execut on dbms_lock    to scott ;
  grant execut on dbms_session to scott ;

Remarks, findings...
  0. ran this against 23.9.0.25.07 (container from gvenzl-free, running on old MBPro i7)
  1. with set-timing-on, both sleep-calls show an Elapsed as expected from the argument.
  2. but in v$sql_history, the elapsed for sleep-calls show only a few millisec.
  3. in v$sql_history shows higher CPU than elapsed: does it consume CPU in background ?


***/

-- we still use EZ connect
connect scott/tiger@192.168.1.7:1521/freepdb1 

-- cleanout if possible
-- alter system flush shared_pool ; 

-- we still use EZ connect
-- connect scott/tiger@192.168.1.7:1521/freepdb1 

spool demo_hist_sleep

set timing on
set echo on

select /* d42: version */ banner_full from v$version ; 

select /* d42: cpu     */ sum (ln(rownum)) from dual connect by level < 1e6;

select /* d42: cnt     */ count (*) from all_source where text like '%x%y%z%'  ;

exec   /* d42: lock    */    dbms_lock.sleep (  9.8 ) ;

exec   /* d42: sess    */ dbms_session.sleep ( 10.2 ) ;

set echo off

-- experiment with sql_history

set linesize 120

column  sql_id format A13

column  buff_g format 999999

column nr_exe  format 99999
column ela_us  format 99,999,999
column cpu_us  format 99,999,999
column sql_txt format A62

column us_p_exe  format 99,999,999

prompt .
prompt "Show session-data from V$SQL_HISTORY, and verify from V$SQLAREA... "
prompt .

set echo on

select h.sql_id 
     , count (*)                                              as nr_exe
     , sum (h.elapsed_time)                                   as ela_us  
     , sum (h.cpu_time)                                       as cpu_us 
     , replace ( substr ( h.sql_text, 1, 60 ), chr(10), ' ' ) as sql_txt
from v$sql_history  h
where h.sid = SYS_CONTEXT ('USERENV', 'SID')     -- only from this SID
group by h.sql_id, h.sql_text
order by 3;

select s.sql_id
, s.executions                            as nr_exe 
, s.elapsed_time                          as ela_us
, s.cpu_time                              as cpu_us
--, s.elapsed_time / s.executions           as us_p_exe
, substr ( s.sql_text, 1, 60 )            as sql_txt 
from v$sqlarea  s
where s.sql_text like '%/* d42:%'               -- only watermarked stmnts
order by s.elapsed_time; 		

set echo off

