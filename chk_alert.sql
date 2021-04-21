/*** 
select * from alertlog
where originating_timestamp > (sysdate - 10)
and message_text like '%00700%';

select * from sys.V_$DIAG_ALERT_EXT;


***/

set linesize 120 
column tstamp format A25 trunc
column message_text format A80  

select rtrim ( to_char ( a.originating_timestamp , 'YYYY-DD-MM HH24:MI:SS.FF'), 24) tstamp
, a.message_text
--, a.*
from sys.V_$DIAG_ALERT_EXT a
where a.originating_timestamp > ( sysdate - 1 ) 
order by a.originating_timestamp;

select rtrim ( to_char ( a.originating_timestamp , 'YYYY-DD-MM HH24:MI:SS.FF'), 24) tstamp
, a.message_text
--, a.*
from sys.V_$DIAG_ALERT_EXT a
where a.originating_timestamp > ( sysdate - 1 ) 
and a.message_text like '0060'
order by a.originating_timestamp;



