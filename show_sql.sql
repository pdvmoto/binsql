set linesize 160
set trimspool on
set feedb off
set ver off
set timing off

column sql_text    format A80

column username    format A10
column buff_gets   format 99999999
column execs       format 999999
column per_exe     format 9999,999
column hash_value  format 99999999999
column sql_id      format A14
column chld        format 9999

column numrows     format 999,999
column cpu_sec     format 9999.99
column ela_sec     format 9999.99
column every_x_sec format 9999.99

column chld               format 99
column datatype           format A15
column bind_variable      format A15
column bind_value         format A20
column bind_vals          format A60 trunc


column operation   format A35
column options     format A15
column on_object   format A35
column cost        format 9999999

column acc_pred     format A30 
column fltr_pred    format A30 


column explout format A60 newline

prompt
prompt
prompt ---------------------------------------------------------------------

-- prompt statement, statistics and explain-plan from sh-pool....

/***
-- some generic numbers, akin to statpack.

select u.username
, a.executions       execs
, a.buffer_gets      buff_gets
, a.buffer_gets/(decode ( executions, 0, 1, executions )) as per_exe , first_load_time
, rows_processed     numrows
, sql_id
, child_number chld
--, a.cpu_time/(1000000) as cpu_sec, a.elapsed_time/(1000000) as ela_sec --, to_char ( ( sysdate - to_date ( a.first_load_time, 'YYYY-MM-DD/HH24:MI:SS' )  ) * 24 * 3600 / a.executions, '99,999.99' ) as every_x_sec --, a.* 
from v$sql a 
, dba_users u 
where u.user_id = a.parsing_user_id 
and a.sql_id = '&1'
order by sql_id, child_number
/

****/


set head off

select 
  'Column          Value'
, '--------------  -----------'                as explout
, 'User          : ' ||  u.username            as explout
, 'sql_id =      : ' || sql_id                 as explout
, 'child_number  : ' || child_number           as explout
, 'plan_hash     : ' || plan_hash_value        as explout
, 'Executions    : ' || a.executions           as explout   
, 'Rows processed: ' || rows_processed         as explout
, 'Buffer_gets   : ' || a.buffer_gets          as explout
, 'disk_reads    : ' || disk_reads             as explout
, 'bufgets/exe   : ' || round ( a.buffer_gets/(decode ( executions    , 0, 1, executions     )), 2)  as explout
, 'bufgets/row   : ' || round ( a.buffer_gets/(decode ( rows_processed, 0, 1, rows_processed )), 2)  as explout
, 'Fist load     : ' || first_load_time        as explout
, 'elapsed (sec) : ' || round ( elapsed_time/1000000                                           , 2) as explout
--, a.cpu_time/(1000000) as cpu_sec, a.elapsed_time/(1000000) as ela_sec --, to_char ( ( sysdate - to_date ( a.first_load_time, 'YYYY-MM-DD/HH24:MI:SS' )  ) * 24 * 3600 / a.executions, '99,999.99' ) as every_x_sec --, a.* 
from v$sql a 
, dba_users u 
where u.user_id = a.parsing_user_id 
and a.sql_id = '&1'
order by sql_id, child_number
/

-- added sql-freq + history from dba_hist_%

column time       format A13
column execs      format 99999
column ela        format 999,999
column sec_px     format 9999
column get_px     format 9,999,999
column g_pr       format 999
column nr_rows    format 9,999,999
column pln_hv     format A10

set pagesize 50
set heading on

select to_char ( sn.end_interval_time , 'DDMON HH24:MI') /* || to_char ( sn.instance_number, '9') */ as Time
, sq.executions_delta     execs
, sq.buffer_gets_delta    buff_gets
, round ( elapsed_time_delta / ( decode ( executions_delta,     0, 1, executions_delta     ) * 1000000), 2 )   as sec_px -- (1000 * 1000 )
, round ( buffer_gets_delta  / ( decode ( executions_delta,     0, 1, executions_delta     )          ), 2 )   as get_px -- (1000 * 1000 )
, rows_processed_delta nr_rows
, round ( buffer_gets_delta  / ( decode ( rows_processed_delta, 0, 1, rows_processed_delta )          ) , 2)      g_pr -- , elapsed_time_delta ela
, to_char ( sq.plan_hash_value )  as pln_hv
--, substr ( sx.sql_text, 1, 20) sqltxt
--, sq.* 
from dba_hist_sqlstat  sq 
   , dba_hist_snapshot sn
   , dba_hist_sqltext  sx
where sn.snap_id = sq.snap_id
  and sn.dbid = sq.dbid
  and sn.instance_number = sq.instance_number 
  and sq.sql_id = '&1'
  and sq.sql_id = sx.sql_id
  and sq.dbid = sx.dbid
    and sq.executions_delta > 0 
order by sn.snap_id, sn.instance_number ; 

-- added sql-freq + history

-- add SQL on perfstat for SE



column time       format A13
column execs      format 999999
column ela        format 999,999
column sec_px     format 9999.99
column get_px     format 9,999,999
column g_pr       format 999
column nr_rows    format 9,999,999
column pln_hv     format A12

set doc off


/* ---- statspack ---  
With snaps as
( select 
s2.snap_time
, s1.snap_id s1
, s2.snap_id s2
, s1.dbid
, s1.instance_number
, round ( ( cast ( s2.snap_time as date) - cast (s1.snap_time as date) ) * 3600 * 24 ) as delta_time
--, s1.*, s2.*
from perfstat.stats$snapshot s1
   , perfstat.stats$snapshot s2
  , v$database db    -- ensure it is "this" dbid, add instance if needed.
where 1=1
and s1.snap_id + 1 = s2.snap_id  -- super simple solustion
and s1.dbid = s2.dbid
and s1.instance_number = s2.instance_number
and s1.startup_time = s2.startup_time
--and s1.end_interval_time = s2.begin_interval_time
and s1.dbid = db.dbid
and s2.snap_time > trunc ( sysdate - 10 )  -- only recent
--order by s1.snap_id desc
) 
select to_char ( sn.snap_time, 'YY-MM-DD HH24:MI')  as snap_time
--, ss.snap_id, ss.executions
,              ss.executions   - LAG(ss.executions  , 1) OVER (ORDER BY ss.snap_id)                   as execs
--, ss.elapsed_time/1000000
, round (    ( ss.elapsed_time - LAG(ss.elapsed_time, 1) OVER (ORDER BY ss.snap_id) ) / (1000000), 2) as ela
--, ss.buffer_gets/1000000
, round (      ss.buffer_gets  - LAG(ss.buffer_gets , 1) OVER (ORDER BY ss.snap_id) , 2)              as buff_gets
, round (    ( ss.buffer_gets  - LAG(ss.buffer_gets , 1) OVER (ORDER BY ss.snap_id) ) 
    / decode ( ss.executions   - LAG(ss.executions  , 1) OVER (ORDER BY ss.snap_id)
             , 0, 1
             , ss.executions   - LAG(ss.executions  , 1) OVER (ORDER BY ss.snap_id) ), 2 )            as get_px
, round (  ( ( ss.elapsed_time - LAG(ss.elapsed_time, 1) OVER (ORDER BY ss.snap_id) ) / 1000000)
    / decode ( ss.executions   - LAG(ss.executions  , 1) OVER (ORDER BY ss.snap_id)
             , 0, 1
             , ss.executions   - LAG(ss.executions  , 1) OVER (ORDER BY ss.snap_id) ), 2 )            as sec_px
from snaps sn
     , perfstat.stats$sql_summary ss
where ss.snap_id =  sn.s1
and ss.sql_id = '&1' -- '400r3w6p07q8c' 
order by sn.s1 ; 


* --- end statspack --- */



/**** 
-- one-off for pcs only: fetch old data from sqh-tables..
select to_char ( sn.end_interval_time , 'DDMON HH24:MI') 
-- || to_char ( sn.instance_number, '9')  
  as Time
, sq.executions_delta     execs
, sq.buffer_gets_delta    buff_gets
, round ( elapsed_time_delta / ( decode ( executions_delta,     0, 1, executions_delta     ) * 1000000), 2 )   as sec_px -- (1000 * 1000 )
, round ( buffer_gets_delta  / ( decode ( executions_delta,     0, 1, executions_delta     )          ), 2 )   as get_px -- (1000 * 1000 )
, rows_processed_delta nr_rows
, round ( buffer_gets_delta  / ( decode ( rows_processed_delta, 0, 1, rows_processed_delta )          ) , 2)      g_pr -- , elapsed_time_delta ela
, substr ( sq.plan_hash_value, 1, 6 ) || '..' as pln_hv
--, substr ( sx.sql_text, 1, 20) sqltxt
--, sq.* 
from sqh_sqlstat  sq 
   , sqh_snapshot sn
   , sqh_sqltext  sx
where sn.snap_id = sq.snap_id
  and sn.dbid = sq.dbid
  and sn.instance_number = sq.instance_number 
  and sq.sql_id = '&1'
  and sq.sql_id = sx.sql_id
  and sq.dbid = sx.dbid
  --and sq.executions_delta > 0 
order by sn.snap_id, sn.instance_number ; 

*****/

set head off

-- sqltxt from sh-pool memory

prompt .
prompt The SQL_TEXT from Sh-Pool...
prompt .

select  t.sql_text
from v$sqltext t
where sql_id = '&1'
order by piece
/

set head on

/* 
-- try picking bind-vars from memory, only cursors 0+1

select  --bvc.sql_id
  bvc.child_number     chld
--, bvc.name             bind_variable
--, bvc.datatype_string  datatype
--, bvc.value_string     bind_value
--bvc.*
--ANYDATA.AccessTimestamp(bvc.value_anydata)
-- ANYDATA.Accessdate(bvc.value_anydata)
, ' ' ||  lpad( replace ( bvc.name, ':', ':b' ), 5) ||  ' := '
  || decode ( substr ( bvc.datatype_string, 1, 3)
            ,  'NUM' , nvl ( bvc.value_string, '''''' )
            ,  'VAR' , '''' || bvc.value_string || ''''
            ,  'DAT' , '      to_date ( ' || '''' || ANYDATA.Accessdate(bvc.value_anydata) || ''', ''YYYY-MM-DD HH24:MI:SS'' ) '
            ,  'TIM' , ' to_timestamp ( ' || '''' || ANYDATA.AccessTimestamp(bvc.value_anydata) || ''', ''YYYY-MM-DD HH24:MI:SS'' ) '
            ,  bvc.value_string
            ) || '  ;'   as bind_vals
from v$sql_bind_capture bvc
where 1=1
and child_number < 2
and sql_id = '&1'
order by child_number, name ;

*/

/****** old stuff ****

select -- bvc.sql_id,
  bvc.child_number     chld
, bvc.name             bind_variable
, bvc.datatype_string  datatype
, bvc.value_string     bind_value
--, bvc.*
from v$sql_bind_capture bvc
where 1=1
and sql_id = '&1'
order by child_number, name;

**** */

-- explain from shared-pool

set linesize 190
set trimspool on

/** skip this if  dbms_xplan is more readable ***/

select
  cost
, decode ( depth, 0, '', rpad (' ', depth*1, ' ') )
|| rtrim  ( operation, 30)  as operation
,  rtrim ( options, 15) as options
,  rtrim( object_owner || '.' || object_name || ' ' || optimizer || '
' , 30 )  as on_object
, v.access_predicates as acc_pred, v.filter_predicates as fltr_pred 
--, v.* 
from v$sql_plan v where sql_id = '&1' --'18979282' --'15494617'
order by hash_value, child_number, address, id 
/

/**** skipped now ****/

prompt '--------- plans from memory -- '

-- explain from memory if available

SELECT plan_table_output FROM table(DBMS_XPLAN.DISPLAY_CURSOR('&1'));

-- explained from AWR, whatever is available

prompt '--------- plans from awr -- '

select plan_table_output from table (dbms_xplan.display_awr('&1'));

prompt . 
prompt . output in :
prompt ed sql_&1..lst
prompt .
spool off



