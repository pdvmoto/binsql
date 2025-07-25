
column f_epoch   format 9999999999.999999
column f_epoch1  format 9999999999.999999
column f_epoch2  format 9999999999.999999
column f_epoch2a format 9999999999.999999
column f_epoch3  format 9999999999.999999
column f_epoch3a format 9999999999.999999
column f_epoch3b format 9999999999.999999
column f_epoch3c format 9999999999.999999

column with_cte   format 9999999999.999999
column with_mat  format 9999999999.999999
column m_epoch   format 9999999999.999999

column execs    format 99999
column sql_text format A55

set linesize 140
set timing on

prompt .
prompt ' -- -- -- -- Check Timing of Epoch Function -- -- -- -- --
prompt .

-- alter system flush shared_pool ;

set arraysize 1005
set termout off

select /* t0 nrs-only    */ 
  1700000000.000001 
from dual connect by level < 1001 ;
/
/

select /* t1 test 1col   */ 
  f_epoch1 
from dual connect by level < 1001 ;
/
/

select /* t1.2 test 2col */
  f_epoch1
, f_epoch1
from dual connect by level < 1001 ;
/
/

select /* t1.3 test 3col */
  f_epoch1
, f_epoch1
, f_epoch1
from dual connect by level < 1001 ;
/
/

select /* t1.4 test 4col */
  f_epoch1 , f_epoch1
, f_epoch1 , f_epoch1
from dual connect by level < 1001 ;
/
/

select /* t1.6 test 6col */
  f_epoch1, f_epoch1
, f_epoch1, f_epoch1
, f_epoch1, f_epoch1
from dual connect by level < 1001 ;
/
/

select /* t1.8 test 8col */ 
  f_epoch1, f_epoch1
, f_epoch1, f_epoch1
, f_epoch1, f_epoch1
, f_epoch1, f_epoch1
from dual connect by level < 1001 ;
/
/

set termout on
set echo on

-- find exec times..
 select sqa.executions as execs
  , round ( sqa.cpu_time / sqa.executions ) as cpu_px
 , round ( sqa.elapsed_time / sqa.executions ) as ela_px
 , substr ( sqa.sql_text, 1, 50 )|| '...' as sql_text
 from v$sqlarea sqa  
 where sql_text like '%/* t%'      
 and sql_text not like '%executions%'
 order by 2 ;

set echo off

