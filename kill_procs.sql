
-- find deatils on sid 


column username format A10
column program  format A25 
column terminal format a10
column osuser   format a10
column logontim format a15
column uxpid    format 99999 head uxpid
column machine  format A20

column whoisout format A75 newline

column waitsid                       format 9999999
column usr_osusr_mchn_term_prgr_evnt format A70

col event for a35
set pages 60

select s.sid
, s.username
, p.program
, p.terminal
, s.osuser
, p.spid  as uxpid
, to_char ( s.logon_time, 'MON-DD HH24:MI:SS' ) as logontim
, s.machine
from v$session s
   , v$process p 
where s.paddr = p.addr(+)
  and s.sid = &1
  --and s.sql_id in ( 'g59s8dj44w454' )
/

set head off

select 
  'Column          Value'
, '--------------  -----------'  as whoisout
, 's.SID, s.Sess : ' || s.sid || ',' || s.serial#   as whoisout
, 's.Username    : ' || s.username                  as whoisout
, 's.osuser      : ' || s.osuser                    as whoisout
, 'p.Program     : ' || p.program                   as whoisout
, 'p.Terminal    : ' || p.terminal                  as whoisout
, 'p.pid, p.spid : ' || p.pid || ',' ||  p.spid     as whoisout
-- , 'p.spid        : ' || p.spid                   as whoisout
, 's.logontime   : ' || to_char ( s.logon_time, 'MON-DD HH24:MI:SS' ) as whoisout
, 's.machine     : ' || s.machine                   as whoisout
, 's.type        : ' || s.type                      as whoisout
, 's.module      : ' || s.module                    as whoisout
, 's.client_info : ' || s.client_info               as whoisout
, 's.sqladdr+hsh : ' || s.sql_address || ',' || s.sql_hash_value       as whoisout 
--, 's.event       : ' || s.event || ' ('|| s.wait_class || ')'        as whoisout
--, 's.blckng_ses  : ' || s.blocking_session          as whoisout
from v$session s
   , v$process p 
where s.paddr = p.addr(+)
  and s.sid = &1
/



select 
  'Column          Value'
, '--------------  -----------'  as whoisout
, 's.event       : ' || s.event || ' ('|| s.wait_class || ')'                           as whoisout
--, 's.blckng_ses  : ' || nvl ( to_char ( s.blocking_session), 'none' )                   as whoisout
--, ' '     as whoisout
--, 'alter system kill session ''' || s.sid ||         ',' || s.serial#        || ''';'   as whoisout
, 'exec rdsadmin.rdsadmin_util.kill( sid =>' || s.sid || ', serial =>'|| s.serial# ||' );' as whoisout
--, 'exec DBMS_MONITOR.SESSION_TRACE_ENABLE( session_id =>' || s.sid || ', serial_num =>'|| s.serial# ||',waits=>true,binds=>false);' as whoisout
--, 'exec dbms_shared_pool.purge  ( ''' || s.sql_address || ',' || s.sql_hash_value || ''', ''C'');'   as whoisout 
from v$session s
   , v$process p 
where s.paddr = p.addr(+)
  and s.sql_id in ( 'g59s8dj44w454' )
  and s.sid = &1
/
set head on


select waiting_session waitsid
--, holding_session 
, s.schemaname || '|' || s.osuser || ' @ ' || s.machine|| '|' || s.terminal|| '|' ||s.program 
/* || '|'||  s.event */ AS usr_osusr_mchn_term_prgr_evnt
--, s.*
from dba_waiters  w
, v$session s
where w.waiting_session = s.sid
and w.holding_session = &1
order by holding_session, waiting_session ; 
