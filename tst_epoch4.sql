
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
set pagesize 20
set timing   on

prompt .
prompt ' -- -- -- -- Check outcomes and Timing of Epoch function, macro -- -- -- -- --
prompt .

-- alter system flush shared_pool ;

set arraysize 1005
set termout off

DOC
-- Skip this, but use it manually to show first-pase effect
-- prime the macro, do a call that isnt part of the measurements
select /* tm0 prime of macro */
  m_epoch2
from dual ;

#

select /* tm1.1.1 1col x 1k  */
  m_epoch2
from dual connect by level < 1001 ;
/
/

select /* tm1.1.2 1col x 2k  */
  m_epoch2
from dual connect by level < 2001 ;
/
/


select /* tm1.1.4 1col x 4k  */
  m_epoch2
from dual connect by level < 4001 ;
/
/

select /* tm1.1.8 1col x 8k  */
  m_epoch2
from dual connect by level < 8001 ;
/
/


select /* tm1.2.1 2col x 1k  */
  m_epoch2 , m_epoch2
from dual connect by level < 1001 ;
/
/


select /* tm1.2.2 2col x 2k  */
  m_epoch2 , m_epoch2
from dual connect by level < 2001 ;
/
/


select /* tm1.2.4 2col x 4k  */
  m_epoch2 , m_epoch2
from dual connect by level < 4001 ;
/
/

select /* tm1.2.8 2col x 8k  */
  m_epoch2 , m_epoch2
from dual connect by level < 8001 ;
/
/


select /* tm1.4.1 4col x 1k  */
  m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
from dual connect by level < 1001 ;
/
/

select /* tm1.8.1 8col x 1k  */
  m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
from dual connect by level < 1001 ;
/
/

select /* tm1.8.2 8col x 2k  */
  m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
from dual connect by level < 2001 ;
/
/

select /* tm1.8.8 8col x 4k  */
  m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
from dual connect by level < 4001 ;
/
/

select /* tm1.8.8 8col x 8k  */
  m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
, m_epoch2 , m_epoch2
from dual connect by level < 8001 ;
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

