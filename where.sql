
column database    format A10
column instance    format A8   head curr_inst
column created     format a21
column arch        format a6
column role        format a8
column prot_mode   format A8
column prot_level  format a8  wrap  
column hostname    format a10
column started     format a21

set feedb off

select d.name       				  as database
, i.instance_name 				  as instance
, to_char ( d.created, 'YYYY-MON-DD HH24:MI:SS' ) as created
, substr ( d.log_mode, 1, 5)                      as arch
, substr ( d.database_role, 1, 7 )                as role
,           substr ( d.protection_mode, 1, 3) 
  || ' ' || substr ( d.protection_mode, 9, 4)     as prot_mode
, substr ( d.protection_level, 1, 6 )             as prot_level
from gv$database  d
   , gv$instance  i ;



column instance    format a8 head instance

select i.instance_name                                 as instance
, i.host_name						as hostname
, to_char ( i.startup_time, 'YYYY-MON-DD HH24:MI:SS' ) as started
, i.status
, count (*) as sessions
from gv$instance i
   , gv$session s
where i.inst_id = s.inst_id
group by i.instance_name, i.host_name, i.startup_time, i.status
order by 1, 2, 3 ;

rem CDB/PDB
column con_id format A10
column con_name format A20

select 
  sys_context('USERENV', 'CON_ID') as con_id, 
  sys_context('USERENV', 'CON_NAME') as con_name 
from dual ; 

-- need a blank line...
prompt
-- select '' from dual;

set feedb on
