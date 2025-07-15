column metric format A40
column value format 99,999,999
column uptime_sec   99,999,999.99

select sn.name as metric, st.value
    -- , st.*
    from v$sysstat st
    , v$statname sn
    where st.statistic# = sn.statistic#
    and (  sn.name like '%roundtrips%client%'
        or sn.name like '%execute count%'
        or sn.name like 'user calls'
        or sn.name like 'DB time'
        )
      order by sn.name
/

/* 
select i.instance_name                                 as instance
, i.host_name           as hostname
, to_char ( i.startup_time, 'YYYY-MON-DD HH24:MI:SS' ) as started
, to_number  ( sysdate - i.startup_time ) * 86400 
  +  to_number ( to_char ( systimestamp, '.FF9' ) )   as sec_up
from v$instance i
order by 1, 2, 3 ;
*/ 

with 
instance_up as (
  select i.instance_name                                 as instance
  , i.host_name                                          as hostname
  , to_char ( i.startup_time, 'YYYY-MON-DD HH24:MI:SS' ) as started
  , to_number  ( sysdate - i.startup_time ) * 86400
    +  to_number ( to_char ( systimestamp, '.FF9' ) )    as uptime_sec
  from v$instance i
) ,
dbtime as (
  select sn.name                                         as metric
   , st.value                                            as dbtime
      -- , st.*
  from v$sysstat st
  , v$statname sn
  where st.statistic# = sn.statistic#
  and sn.name like 'DB time'
)
select i.started
, i.uptime_sec   
, t.dbtime                        as dbtime_centisec
, 0.01 * t.dbtime / i.uptime_sec  as AAS_average
from instance_up i
   , dbtime t
;

