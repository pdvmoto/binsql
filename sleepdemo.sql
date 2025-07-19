
column metric format A40 
column value format 9,999,999
column schemaname format A10
column logon_seconds format 9,999,999.99
column avg_active format 9.999999

prompt .
prompt "mytime.sql: this sql adds some to dbtime, RT, execs and usercalls "
prompt .

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

set echo on
exec dbms_session.sleep ( 10 ) ;
set echo off

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

prompt .
prompt "Compare the db-time (centisec), the 10sec sleep seems added to DBtime ?"
prompt .


prompt " which version are we on ..." 

select * from v$version ; 


