
-- prompt "mysqlshist.sql: try to list the heavy SQLs form this session "

-- experiment with sql_history

set linesize 120
column  key format 99999999999
column  start_tm format A10
column  sql_id   format A13
column  sql_txt  format A100
column  ela_us format 99999999
column  cpu_us format 99999999
column  buff_g format 999999

/*** 
select 
  h.key
, to_char ( h.sql_exec_start, 'HH24:MI:SS' ) as start_tm
, sql_id
, h.elapsed_time ela_us, h.cpu_time cpu_us, h.buffer_gets buff_g
, sql_id
, replace ( substr ( h.sql_text, 1, 98 ), chr(10), '' ) sql_txt
--, h.con_id
--, h.* 
from v$sql_history h 
where 1=0
and h.sql_id not in ( '38d0yqrm0yb2z' ) 
order by h.sql_exec_start nulls first, h.key ;

****/

-- sql grouped and ordered per elapsed time..

column nr_exe format 99999
column ela_us  format 99,999,999
column cpu_us  format 99,999,999
column sql_txt format A52

column sid format 99999
column module format A30
column nr_hist  format 999999 

set echo on

select count (*) nr_exe
     , sum (h.elapsed_time) ela_us 
     , sum (h.cpu_time) cpu_us 
     , h.sql_id
     , replace ( substr ( h.sql_text, 1, 50 ), chr(10), '|' ) sql_txt
from v$sql_history  h
where h.sid = SYS_CONTEXT ('USERENV', 'SID')
group by h.sql_id, h.sql_text
order by 3;

set echo off

column  sid format 9999 

select s.sid, s.module module, count (*) nr_hist
-- , h.* 
from v$sql_history  h
, v$session s 
where s.sid = h.sid 
group by s.sid, s.module 
order by s.sid;


select 'total_hist' as sql_id, count (*) nr_exe
from v$sql_history h
group by 'total_hist'; 

