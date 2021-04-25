

-- nr of connections from tnslsnr.

column minute format a20
column conn_attempts format 9,999

select to_char (originating_timestamp, 'DD DAY HH24:MI') as minute
, count (*) conn_attempts
from v$diag_alert_ext
where component_id ='tnslsnr'
and originating_timestamp > (sysdate -1)
group by to_char (originating_timestamp, 'DD DAY HH24:MI')
order by 1;
