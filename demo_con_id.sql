
doc
        demo_con_id.sql

        contains the SQL from blogpost
	(and probable some leftover columns and queries)
#


set heading on
set feedback off
set lines 80
set pagesize 30

column  tablespace_name format a30
column  mfree           format 999,999,999
column  mused           format 999,999,999
column  mtotal          format 999,999,999
column  perc_free       format 999.99

column con              format 999
column tsnr             format 999
column fname            format A50
column tsname           format A20 trunc
column pdb_name         format A12
column open_mode        format A12

break on pdb_name on con_id

ech off

prompt .
prompt .

set echo on

select p.con_id con, p.name  as pdb_name
,  round ( sum ( bytes /( 1024 * 1024) ) ) mtotal
--, df.*
from v$datafile df
   , v$pdbs p
where p.con_id = df.con_id
group by p.name, p.con_id
order by p.con_id
/

select 
'Total:' as total,  round ( sum ( bytes /( 1024 * 1024) ) ) mtotal
from v$datafile df;

set echo off

prompt .
prompt .
prompt first an improved version... 
prompt .

set echo on

select df.con_id con, NVL ( p.name, 'CDB_ROOT' )   as pdb_name
,  round ( sum ( bytes /( 1024 * 1024) ) ) mtotal
--, df.*
from       v$datafile df
LEFT JOIN  v$pdbs      p  on p.con_id = df.con_id
group by p.name, df.con_id
order by df.con_id
/

set echo off

prompt .
prompt .
prompt than the better version with containers-view... 
prompt .

set echo on

select df.con_id con, p.name as pdb_name
,  round ( sum ( bytes /( 1024 * 1024) ) ) mtotal
--, df.*
from  v$datafile df
   , v$containers p 
where p.con_id = df.con_id
group by p.name, df.con_id
order by df.con_id ;

select 
'Total:' as total,  round ( sum ( bytes /( 1024 * 1024) ) ) mtotal
from v$datafile df;

set echo off

-- now the demo with session and process..

column usrnm		format  A12 trunc
column osusr		format  A12	trunc
column machine		format  A20	trunc
column program		format  A12	trunc
column process		format  A10
column logon_time 	format A20
column spid		format 99999
column inst             format 999
column serial           format 9999
column sid              format 999
column sidser           format A70
column status           format A15


column con_id    format 9999
column pdb_name  format A10
column total     format A20


prompt .
prompt .
prompt where do connections go, session per instance and per PDB...
prompt .

set echo on

select p.con_id, p.name pdb_name, p.inst_id, count (*) nr_sessions
from gv$session       s
   , gv$containers    p -- using gv$containers, lesson learned...
where p.con_id   = s.con_id
  and p.inst_id  = s.inst_id
group by p.name, p.con_id, p.inst_id
order by p.con_id, p.inst_id ;

select 'Total sessions: ' total, count (*) nr_sessions from gv$session ; 

set echo off

prompt .
prompt .
prompt then the session-count, Fixed with gv$containers and LEFT JOIN

set echo on

select S.con_id
, NVL ( p.name , '-root-' ) pdb_name
, S.inst_id, count (*) nr_sessions
from       gv$session       s
LEFT JOIN  gv$containers    p  ON p.con_id = s.con_id and p.inst_id = s.inst_id
group by p.name, s.con_id, S.inst_id
order by s.con_id, S.inst_id ;

select 'Total sessions: ' total, count (*) nr_sessions from gv$session ; 

set echo off

prompt .
prompt .
prompt Session fixed, total is now Correct.. 
prompt .
prompt Next is a demo with inline-view to unite All Con_Ids
prompt .

set echo on

with all_con_ids as 
  (  select con_id, inst_id, name, open_mode from gv$database 
  union all
     select con_id, inst_id, name, open_mode from gv$containers
  )
select c.con_id, c.inst_id, c.name pdb_name, c.open_mode, count (*) nr_procs
--, s.* 
from gv$process  p
   , all_con_ids c 
where p.con_id = c.con_id 
  and p.inst_id = c.inst_id
group by c.con_id, c.inst_id, c.name, c.open_mode
order by c.con_id ; 

select 'Total processes : ', count (*) nr_processes
from gv$process ;

set echo off

prompt .
prompt End of demo_con_id 
prompt . 

