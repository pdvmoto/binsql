
/*
find dynamic sql.

Concept:
If 
  many queries have the same plan_hash_value (e.g. same execution plan), 
  but they have different hash-values (e.g. different text), 
then 
  they are likely to be dynamically generated.

Caveat: always manually verify!

*/

-- plan_hash seems to have up to 12 digits, so give it format of 13
--     ....,....1....,         ....,....1...., 
column plan_hash_value  format 999999999999999 
column nr_occ           format 999999
column sql_text         format A53 wrap
column nr_exec          format 999999 head execs
 
set feedb off
set pagesize 200

spool do_dyn_sql.sql

prompt
prompt set feedb off

-- make sure spoolfile is unique and contains database and server.
SELECT  'spool '
 || to_char ( sysdate, 'MON_dd_YYYY_HH24MISS' )
 || '_Dyn_SQL_for_' ||db.name|| '_'
-- || RTRIM(SUBSTR ( p.program, INSTR ( p.program, '@' ) + 1
--                        ,   INSTR ( p.program, ' ' )
--                            -  INSTR ( p.program, '@' )  ) )
FROM    v$database      db
,       global_name     gn
,       v$process       p
where p.program LIKE '%(PMON)%' ;


prompt
prompt @date
prompt 

prompt prompt
prompt prompt

prompt
prompt @where
prompt

prompt
prompt select username, count (*)  dyn_stmnts from v$sql s , dba_users u
prompt where u.user_id = s.parsing_user_id
prompt and u.username not in ('SYS', 'SYSTEM' )
prompt and executions in (1, 2, 3, 4)
prompt and s.executions > 0
prompt group by username 
prompt /
prompt 

prompt set feedb on

spool off

-- now generate the spoolfile with first lines...

set feedb om

@do_dyn_sql

SELECT plan_hash_value  as plan_hash
, COUNT(*)              as nr_occ
, sum ( executions )   as nr_exec
, min ( sql_text )     as sql_text
--, MIN ( SUBSTR (sql_text, 1, 52 ) ) as sql_text
FROM v$sql s
GROUP BY plan_hash_value
HAVING COUNT (*) > 5
ORDER BY 2 DESC
/

spool off
