column metric format A40 
column value format 9.999.999

select sn.name as metric, st.value 
    -- , st.* 
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

