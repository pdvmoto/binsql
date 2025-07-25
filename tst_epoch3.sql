
-- tst_epoch3.sql: testing the macro version..

column f_epoch   format 9999999999.999999
column f_epoch1  format 9999999999.999999
column f_epoch2  format 9999999999.999999
column f_epoch2a format 9999999999.999999
column f_epoch3  format 9999999999.999999
column f_epoch3a format 9999999999.999999
column f_epoch3b format 9999999999.999999
column f_epoch3c format 9999999999.999999

column m_epoch   format 9999999999.999999
column m_epoch1  format 9999999999.999999
column m_epoch2  format 9999999999.999999

column with_cte   format 9999999999.999999
column with_mat  format 9999999999.999999

column execs    format 99999
column sql_text format A55

set linesize 128
set timing   on

prompt .
prompt ' -- -- -- -- Check outcomes and Timing of Epoch function, macro -- -- -- -- --
prompt .

-- alter system flush shared_pool ;

set arraysize 1005
set termout off

-- compare to original function

select /* tf1.1 test 1col */ 
  m_epoch 
from dual connect by level < 1001 ;
/
/

select /* tf1.4 test 4col */
  f_epoch , f_epoch
, f_epoch , f_epoch
from dual connect by level < 1001 ;
/
/


select /* tm1.1 mcr 1col  */
  m_epoch2
from dual connect by level < 1001 ;
/
/

DOC 

out comment these for the moment

select /* tm1.1.2 mcr 1col  */
  m_epoch2
from dual connect by level < 2001 ;
/
/

select /* tm1.1.3 mcr 1col  */
  m_epoch2
from dual connect by level < 3001 ;
/
/

#

select /* tm1.2 mcr 2col  */
  m_epoch2 , m_epoch2
from dual connect by level < 1001 ;
/
/

select /* tm1.3 mcr 3col  */
  m_epoch2 , m_epoch2
, m_epoch2 
from dual connect by level < 1001 ;
/
/

select /* tm1.4 mcr 4col  */
  m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
from dual connect by level < 1001 ;
/
/

select /* tm1.8 mcr 8col  */
  m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
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

