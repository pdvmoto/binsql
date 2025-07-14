select s.begin_interval_time, s.end_interval_time, s.end_interval_time - s.begin_interval_time diff ,b.snap_id||','||e.snap_id snapshots,
                e.value - b.value delta ,
               round((e.value - b.value)/3600,2) lios_per_sec
from  dba_hist_sysstat b,
        dba_hist_sysstat e,
        dba_hist_snapshot s,
        v$database v
where b.snap_id         = e.snap_id -1
           and e.snap_id         > b.snap_id
           and b.dbid            = v.dbid
           and e.dbid            = v.dbid
           and b.instance_number = 1
           and e.instance_number = 1
           and b.stat_id         = e.stat_id
           and e.stat_name in ('session logical reads')
           and s.snap_id = e.snap_id
order by 1
/


select systimestamp systimest from dual ; 

SELECT TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF6')  
    AS current_timestamp_microsecond
FROM dual;

set linesize 120 

column epoch_nano format 9999999999.999999999 

SELECT 
  TO_CHAR(
    (sysdate - TO_date('1970-01-01', 'YYYY-MM-DD')) * 86400 
  )                                       as epoch_sec
,   to_number ( 
      TO_CHAR (
        (trunc ( sysdate ) - TO_date('1970-01-01', 'YYYY-MM-DD')) * 86400
    )  )                                                as secs_today
, to_number ( to_char ( systimestamp, 'SSSSS.FF9' ) )   as secs_in_day
,   to_number ( 
      TO_CHAR (
        (trunc ( sysdate ) - TO_date('1970-01-01', 'YYYY-MM-DD')) * 86400
    )  ) 
  + to_number ( to_char ( systimestamp, 'SSSSS.FF9' ) ) as epoch_nano
FROM dual;

prompt ' '
prompt ' '

set echo on

prompt set format to 10 plus 9 digits 

column epoch_nano format 9999999999.999999999 

select 
  ( to_number ( trunc ( sysdate) - TO_date( '1970-01-01', 'YYYY-MM-DD')) * 86400) -- seconds up to sysddate
+   to_number ( to_char ( systimestamp, 'SSSSS.FF9' ) )                           -- add today seconds + fraction
as epoch_nano 
from dual;

prompt ' ' 
prompt ' ' 

