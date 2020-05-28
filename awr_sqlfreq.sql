
set linesize 80 


set linesize 120
set feedb off 
set ver off
set timing off



column username   format A8
column buff_gets  format 99999999
column execs      format 999999
column per_exe    format 9,999,999
column hash_value format 99999999999
column hash_value format A12

column numrows     format 99,999,999
column cpu_sec     format 99,999.99
column ela_sec     format 99,999.99
column every_x_sec format 9999.99

column operation  format A25
column options    format A25
column on_object  format A35
column cost       format 99999999

column acc_pred     format A30 trunc
column fltr_pred    format A30 trunc

column sql_text     format A64

prompt 
prompt 
prompt --------------------------------------------------------------------- 

prompt statement, statistics and explain-plan from sh-pool....

-- some generic numbers, akin to statpack.

select u.username
, a.executions       execs
, a.buffer_gets      buff_gets
, a.buffer_gets/(decode ( executions, 0, 1, executions )) as per_exe
, first_load_time
, rows_processed     numrows
, a.cpu_time/(1000000) as cpu_sec, a.elapsed_time/(1000000) as ela_sec
, sql_id
--, to_char ( ( sysdate - to_date ( a.first_load_time, 'YYYY-MM-DD/HH24:MI:SS' )  ) * 24 * 3600 / a.executions, '99,999.99' ) as every_x_sec
--, a.* 
from v$sql a
, dba_users u
where u.user_id = a.parsing_user_id
--and a.hash_value = '&1'
and a.sql_id = '&1'
/

set head off

-- sqltxt from sh-pool memory 
select  t.sql_text
from v$sqltext t 
where 1=1 -- hash_value = '&1'
and t.sql_id = '&1'
order by piece 
/

set head on

-- explain from shared-pool

select 
   decode ( depth, 0, '', rpad (' ', depth*1, ' ') ) 
|| rtrim  ( operation, 25)  as operation
,  rtrim ( options, 20) as options
,  rtrim( object_owner || '.' || object_name || ' ' || optimizer || ' ' , 30 )  as on_object
, cost
--, v.access_predicates as acc_pred, v.filter_predicates as fltr_pred
--, v.* 
from v$sql_plan v
where 1=1 -- hash_value= '&1' --'18979282' --'15494617' 
and v.sql_id = '&1'
order by child_number, address, hash_value, id
/

prompt history for the last week


column endtime   format A10
column e_snap    format 99999
column txt       format A22
column execs	 format 9,999,999       
column g_p_exe   format A8
column rows_prc  format 9,999,999


-- find frequency of certain sttmtn between snapshots.

SELECT 
  TO_CHAR ( s2.end_interval_time, 'DD HH24:MI' ) AS endtime 
, s2.snap_id AS e_snap
--, (CAST ( s2.end_interval_time AS DATE ) - CAST ( s2.begin_interval_time AS DATE ) ) * 24 * 3600 INTERVAL_sec 
--, sqt.sql_id   sq1
, SUBSTR ( sqt.sql_text, 1, 20 ) AS txt
, st2.executions_delta AS execs 
, TO_CHAR ( st2.buffer_gets_delta / decode ( st2.executions_delta, 0, 1, st2.executions_delta ), '999,999' ) AS g_p_exe  
, st2.rows_processed_delta AS rows_prc
--, (st2.VALUE - st1.VALUE) / ( (CAST ( s2.end_interval_time AS DATE ) - CAST ( s2.begin_interval_time AS DATE ) ) * 24 * 3600 ) AS per_sec
FROM  DBA_HIST_SQLTEXT sqt
   ,  DBA_HIST_SQLSTAT st2
   , DBA_HIST_SNAPSHOT s1    
   , DBA_HIST_SNAPSHOT s2     
WHERE 1=1
   AND sqt.sql_id = '&1' --'ghquhj0t2ga8t'  -- sql_id goes here. 
   AND 1=1  
   AND sqt.dbid  = st2.dbid  -- link sqltext to sqlstat
   AND sqt.sql_id = st2.sql_id       
   AND 1=1
   AND s2.DBID = st2.dbid   -- link sql-stats to the 2nd snapshot (end)
   AND s2.snap_id = st2.snap_id 
   AND s2.instance_number = st2.instance_number
   AND 1=1 
   AND s1.dbid = s2.dbid -- join the snapshots, and only select valid combinations.
   AND s1.instance_number = st2.instance_number
   AND s1.startup_time = s2.startup_time
   AND s1.end_interval_time = s2.begin_interval_time
   and s2.begin_interval_time > (sysdate - 7)
--   AND  s2.begin_interval_time = ( SELECT MAX (begin_interval_time) FROM sys.wrm$_snapshot) -- is s2 the latest ?
ORDER BY s1.snap_id DESC
/
