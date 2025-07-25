
column f_epoch   format 9999999999.999999
column f_epoch2  format 9999999999.999999
column f_epoch2a format 9999999999.999999
column f_epoch3  format 9999999999.999999
column f_epoch3a format 9999999999.999999
column f_epoch3b format 9999999999.999999
column f_epoch3c format 9999999999.999999

column with_cte   format 9999999999.999999
column with_mat  format 9999999999.999999
column m_epoch   format 9999999999.999999

set linesize 140
set timing on

prompt .
prompt ' -- -- -- -- Start Check Timing of Epoch Functions and Macro -- -- -- -- --
prompt .

@cdscottf

set arraysize 1005

--@mytime

select /* t0 level */ 
  level 
from dual connect by level < 1001 ;


select /* t1 1st */ 
  f_epoch
, f_epoch 
, f_epoch 
, f_epoch 
, f_epoch 
, f_epoch 
from dual connect by level < 1001 ;


select /* t2 date_time */ 
  f_epoch2
, f_epoch2 
, f_epoch2 
, f_epoch2 
, f_epoch2 
, f_epoch2 
from dual connect by level < 1001 ;

--@mytime

select /* t2a 2x systmst */ 
  f_epoch2a
, f_epoch2a
, f_epoch2a 
, f_epoch2a 
, f_epoch2a 
, f_epoch2a 
from dual connect by level < 1001 ;


select /* t3 pragma dt_tm */ 
  f_epoch3
, f_epoch3 
, f_epoch3 
, f_epoch3 
, f_epoch3 
, f_epoch3 
from dual connect by level < 1001 ;


select /* t3a prgm 2x ts */ 
  f_epoch3a
, f_epoch3a
, f_epoch3a 
, f_epoch3a 
, f_epoch3a 
, f_epoch3a 
from dual connect by level < 1001 ;


select /* t3b prgm ts:=systmst */ 
  f_epoch3b
, f_epoch3b
, f_epoch3b 
, f_epoch3b 
, f_epoch3b 
, f_epoch3b 
from dual connect by level < 1001 ;


select /* t3c prgm dt=, ts= */ 
  f_epoch3c
, f_epoch3c
, f_epoch3c 
, f_epoch3c 
, f_epoch3c 
, f_epoch3c 
from dual connect by level < 1001 ;


with   /* t4 cte */ cte as ( select /* deflt, no mtrlize */  f_epoch3b as with_cte from dual )
select 
  with_cte
, with_cte 
, with_cte 
, with_cte 
, with_cte 
, with_cte 
from cte connect by level < 1001 ;


with   /* t5 mtrlz */ mat as ( select /*+ materialize */ f_epoch as with_mat from dual )
select 
  with_mat
, with_mat 
, with_mat 
, with_mat 
, with_mat 
, with_mat 
from mat connect by level < 1001 ;


select /* t6 macro */ 
  m_epoch
, m_epoch 
, m_epoch 
, m_epoch 
, m_epoch 
, m_epoch 
from dual connect by level < 1001 ;


doc 
-- find exec times..
 select sqa.executions as exes
 , sqa.cpu_time
 , round ( sqa.cpu_time / sqa.executions ) as cpu_px
 , sqa.elapsed_time 
 , round ( sqa.elapsed_time / sqa.executions ) as ela_px 
 , substr ( sqa.sql_text, 1, 40 ) as sql_text
 --  , sqa.* 
 from v$sqlarea sqa 
 where sql_text like '%/* t%' 
 and sql_text not like '%executions%'
 order by sqa.cpu_time ;
 
#
