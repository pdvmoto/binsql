
column f_epoch    format 9999999999.999999
column m_epoch2   format 9999999999.999999
column sec_in_day format      A15 

set timing off
set echo on

select  f_epoch
      , f_epoch
      , m_epoch2
      , to_char  ( systimestamp, 'SSSSS.FF6' ) as sec_in_day
from dual connect by level < 4 ;

set echo off


