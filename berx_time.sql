

column db_time_stat_before       new_value _db_time_stat_before
column db_time_stat_after        new_value _db_time_stat_after 
column db_time_time_model_before new_value _db_time_time_model_before
column db_time_time_model_after  new_value _db_time_time_model_after

select sn.name   as metric
     , st.value  as db_time_stat_before 
     , stm.value as db_time_time_model_before 
from v$mystat          st
   , v$statname        sn
   , v$sess_time_model stm
where st.statistic# = sn.statistic# 
  and sn.name       = stm.STAT_NAME
  and stm.sid       = sys_context('userenv', 'sid')
  and sn.name       = 'DB time'
;
prompt db_time_stat_before       : &_db_time_stat_before;
prompt db_time_time_model_before : &_db_time_time_model_before;

exec dbms_session.sleep ( 10 ) ; 
--select sum (ln(rownum)) from dual connect by level < 1e6;

select sn.name   as metric
     , st.value  as db_time_stat_after 
     , stm.value as db_time_time_model_after 
from v$mystat          st
   , v$statname        sn
   , v$sess_time_model stm
where st.statistic# = sn.statistic# 
  and sn.name       = stm.STAT_NAME
  and stm.sid       = sys_context('userenv', 'sid')
  and sn.name       = 'DB time'
;  
prompt db_time_stat_after       : &_db_time_stat_after;
prompt db_time_time_model_after : &_db_time_time_model_after;


select ( '&_db_time_stat_after' - '&_db_time_stat_before' ) / 100 as db_time_delta_stat_sec  -- DB time is in centiseconds, not microseconds 
     , ( '&_db_time_time_model_after' - '&_db_time_time_model_before' ) / 1000000 as db_time_delta_time_model_sec
from dual; 

