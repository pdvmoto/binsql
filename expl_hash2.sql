
set linesize 120
set feedb off 
set ver off
set timing off

column sql_text   format A80

column username   format A10
column buff_gets  format 99999999
column execs      format 999999
column per_exe    format 99999.99
column hash_value format 99999999999

column numrows    format 999,999
column cpu_sec    format 9999.99
column ela_sec    format 9999.99
column every_x_sec format 9999.99

column id         format 999 header id

column operation  format A35
column options    format A20
column on_object  format A35
column cost       format 99999999

column acc_pred     format A50 
column fltr_pred    format A50 

prompt 
prompt 
prompt --------------------------------------------------------------------- 

-- prompt statement, statistics and explain-plan from sh-pool....

-- some generic numbers, akin to statpack.

select u.username
, a.executions       execs
, a.buffer_gets      buff_gets
, a.buffer_gets/(decode ( executions, 0, 1, executions )) as per_exe
, first_load_time
, rows_processed     numrows
, hash_value
--, a.cpu_time/(1000000) as cpu_sec, a.elapsed_time/(1000000) as ela_sec
--, to_char ( ( sysdate - to_date ( a.first_load_time, 'YYYY-MM-DD/HH24:MI:SS' )  ) * 24 * 3600 / a.executions, '99,999.99' ) as every_x_sec
--, a.* 
from v$sql a
, dba_users u
where u.user_id = a.parsing_user_id
and a.hash_value = '&1'
/

set head off

-- sqltxt from sh-pool memory 
select  t.sql_text
from v$sqltext t 
where hash_value = '&1'
order by piece 
/

set head on

-- explain from shared-pool

column id         format 999 header id

select id, 
   decode ( depth, 0, '', rpad (' ', depth*1, ' ') ) 
|| rtrim  ( operation, 35)  as operation
,  rtrim ( options, 20) as options
,  rtrim( object_owner || '.' || object_name || ' ' || optimizer || ' ' , 30 )  as on_object
, cost
--, v.access_predicates as acc_pred, v.filter_predicates as fltr_pred
--, v.* 
from v$sql_plan v
where hash_value= '&1' --'18979282' --'15494617' 
order by child_number, address, hash_value, id
/
 
select id as id
--   decode ( depth, 0, '', rpad (' ', depth*1, ' ') ) 
--|| rtrim  ( operation, 35)  as operation
--,  rtrim ( options, 20) as options
--,  rtrim( object_owner || '.' || object_name || ' ' || optimizer || ' ' , 30 )  as on_object
--, cost
, v.access_predicates as acc_pred, v.filter_predicates as fltr_pred
--, v.* 
from v$sql_plan v
where hash_value= '&1' --'18979282' --'15494617' 
and ( v.access_predicates || v.filter_predicates is not null )
order by child_number, address, hash_value, id
/


