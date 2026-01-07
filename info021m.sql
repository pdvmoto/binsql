doc
        info021m.sql

        Sizing info: CDB + PDBS - needs work..
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

break on con_id
break on pdb_name on con_id



select con_id, ts# tsnr, '..'||substr ( name, 50) as fname
,  round ( bytes /( 1024 * 1024)) mtotal
--, df.*
from v$datafile df
order by df.con_id, df.ts#
/

prompt .
prompt .

select p.con_id con_id
, p.name     as pdb_name
, ts.ts#     as tsnr
, ts.name    as tsname
,  round ( sum ( bytes /( 1024 * 1024) ) ) mtotal
--, df.*
from v$datafile df
   , v$tablespace ts
   , v$pdbs p
where p.con_id = df.con_id
  and p.con_id = ts.con_id
  and ts.ts# = df.ts#
group by p.con_id, p.name, ts.ts#, ts.name, p.con_id
order by p.con_id, ts.ts#
/

prompt .
prompt .


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
