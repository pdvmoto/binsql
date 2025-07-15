column metric format A40 
column value format 9,999,999
column schemaname format A20
column logon_seconds format 9,999,999.99
column avg_active format 9.999999

prompt "mytime.sql: this script adds 2 dbtime, 4 RT, 2 execs and 6 usercalls "

select sn.name as metric, st.value 
from v$mystat st
, v$statname sn
where st.statistic# = sn.statistic# 
and (  sn.name like '%roundtrips%client%'
    or sn.name like '%execute count%'
    or sn.name like 'user calls'
    or sn.name like 'DB time'
    )
order by sn.name
/

/* **** remove stmnt below for better efficiency ***  */

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

