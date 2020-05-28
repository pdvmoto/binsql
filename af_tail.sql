
set linesize 140
set pagesize 200

column dt format A20
column message_text format A115 wrap
set trimspool on

spool af_tail

prompt ------- Alert info from last 3 hrs. ------- 

set echo on

select to_char ( a.originating_timestamp, 'YYYY-MON-DD HH24:MI:SS') dt
, -- '['||
message_text  message_text
from alertlog a
where 1=1-- message_text like '%ALTER%'
and a.originating_timestamp  >   (sysdate - 1)
order by a.indx  
/


spool off

set echo off

