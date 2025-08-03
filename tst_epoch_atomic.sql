
column f_epoch    format 9999999999.999999
column m_epoch2   format 9999999999.999999
column fractsec format      A10 

set timing off
set echo on

select  f_epoch
      , f_epoch
      , m_epoch2
      , to_char  ( systimestamp, '.FF6' ) as fractsec
from dual connect by level < 4 ;

set echo off


