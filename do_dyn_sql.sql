
set feedb off

'SPOOL'||TO_CHAR(SYSDATE,'MON_DD_YYYY_HH24MISS')||'_DYN_SQL_FOR_'||DB.NAME||'_'-
--------------------------------------------------------------------------------
spool AUG_08_2018_171536_Dyn_SQL_for_TEMP_                                      

@date

prompt
prompt

@where


select username, count (*)  dyn_stmnts from v$sql s , dba_users u
where u.user_id = s.parsing_user_id
and u.username not in ('SYS', 'SYSTEM' )
and executions in (1, 2, 3, 4)
and s.executions > 0
group by username
/

set feedb on
