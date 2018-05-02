rem
rem Script: chk_sql.sql
rem
rem Usage : This script displays the current sqltext off non system users in
rem         the database with there oracle process id and unix process id.
rem

set pagesize 2000
set linesize 100
set feedback off
break on ora_id on unix_id on username on command on status
column ora_id   format 999999
column unix_id  format a7
column username format a8
set recsep off
column sql_text format a46 word_wrapped
column status   format a8
column command  format 99
select pid ora_id
,      spid unix_id
,      rtrim(v$process.username) username
--,      command
,      status
,      sql_text 
from v$sqltext
,    v$session
,    v$process
where v$session.paddr = v$process.addr
and v$session.sql_address = v$sqltext.address
and v$session.sql_hash_value = v$sqltext.hash_value
and v$session.sid > 6
and v$session.username <> 'SYSTEM'
--and v$sqltext.piece < 5
order by spid, piece
/

