column metric format A50 
column value format 9,999,999,999.0
column schemaname format A10
column logon_seconds format 9,999,999.99
column avg_active format 9.999999

-- prompt "mytime.sql: this script adds 2 dbtime, 4 RT, 2 execs and 6 usercalls "

select sn.name   as metric
     , st.value  as value
from v$mystat   st
   , v$statname sn
where st.statistic# = sn.statistic# 
and (  sn.name like '%roundtrips%client%'
    or sn.name like '%execute count%'
    --or sn.name like '%arse count (hard%'
    --or sn.name like 'user calls'
    or sn.name like 'redo size'
    or sn.name like 'DB time'
    )
union all 
select ' ~ ', null from dual
union all 
select ' ' || stm.stat_name || ' (micro-sec)' 
     , stm.value
from v$sess_time_model  stm
where stm.sid =  sys_context('userenv', 'sid')
  and (  stm.stat_name like 'DB time'
      --or stm.stat_name like 'DB CPU'
      --or stm.stat_name like 'sql execu%'
      --or stm.stat_name like 'PL/SQL execu%'
      )
--order by 1
/

/* **** remove stmnt below for better efficiency ***  

with 
mysid as ( 
  select max ( sid ) as sid from v$mystat
),
mydbtime as (
  select value / 100 as consumed_secs
  from v$mystat st
  , v$statname sn
  where st.statistic# = sn.statistic#
    and sn.name like 'DB time'
)
select s.schemaname
, to_char ( logon_time, 'YYYY-MM-DD HH24:MI:SS' )       as logon_since
, (sysdate - logon_time ) * 86400                       as logon_seconds
, consumed_secs / ( (sysdate - logon_time ) * 86400 )   as avg_active
from v$session s, mysid, mydbtime 
where s.sid = mysid.sid
/

***/


-- experiment with sql_history

set linesize 120
column  key format 99999999999
column  start_tm format A10
column  sql_id   format A13
column  sql_txt  format A100
column  ela_us format 99999999
column  cpu_us format 99999999
column  buff_g format 999999

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

--drop table xx_sql_hist ;
create table xx_sql_hist as 
select h.key, h.sql_id, h.sql_text
, h.elapsed_time, h.cpu_time, h.buffer_gets
, h.plan_hash_value
, h.sql_exec_start, h.last_active_time
, h.session_user#, h.current_user#
, h.statement_type
, h.sid, h.session_serial#
, h.con_id
from v$sql_history h 
where 1=0 ;

set feedb on
set echo on
insert into xx_sql_hist 
select h.key, h.sql_id, h.sql_text
, h.elapsed_time, h.cpu_time, h.buffer_gets
, h.plan_hash_value
, h.sql_exec_start, h.last_active_time
, h.session_user#, h.current_user#
, h.statement_type
, h.sid, h.session_serial#
, h.con_id
from v$sql_history h 
where 1=1
-- prevent doubles, in case stmnt is run multiple times..
and h.key not in (select distinct key from xx_sql_hist )
;

commit ; 

set echo off

