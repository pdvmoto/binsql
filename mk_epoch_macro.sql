
-- mk_epoch_macro.sql: turn sql function into macro, including errors
-- 
-- note: a function is back-portable..  macros are 21c and higher
--


-- macro..
CREATE or replace FUNCTION m_epoch1
RETURN varchar2 
SQL_MACRO(SCALAR) IS
  now_stm timestamp := systimestamp ;
BEGIN
  RETURN ( 
      ( to_number ( trunc   ( now_stm) - TO_date( '1970-01-01', 'YYYY-MM-DD')) * 86400) -- seconds up to sysddate
    +   to_number ( to_char ( now_stm, 'SSSSS.FF9' ) ) 
  );
END;
/
show errors


-- macro..
CREATE or replace FUNCTION m_epoch2
RETURN varchar2 
SQL_MACRO(SCALAR) IS
BEGIN
  RETURN ( q'[ 
      ( to_number ( trunc ( sysdate) - TO_date( '1970-01-01', 'YYYY-MM-DD')) * 86400) 
    +   to_number ( to_char ( systimestamp, 'SSSSS.FF9' ) ) 
             ]' 
  );
END;
/
show errors

-- macro.., definite version, no suffix
CREATE or replace FUNCTION m_epoch
RETURN varchar2 
SQL_MACRO(SCALAR) IS
BEGIN
  RETURN ( q'[ 
      ( to_number ( trunc ( sysdate) - TO_date( '1970-01-01', 'YYYY-MM-DD')) * 86400) 
    +   to_number ( to_char ( systimestamp, 'SSSSS.FF9' ) ) 
             ]' 
  );
END;
/
show errors

column f_epoch    format 9999999999.999999
column m_epoch1   format 9999999999.999999
column m_epoch2   format 9999999999.999999
column sec_in_day format A15

-- testing code here..

set timing off
set echo on

select f_epoch , 'as func'  func  from dual ;
select m_epoch2, 'as macro' macro from dual ;

-- repeated queries, tests...

set echo on

select m_epoch2 from dual ;

! sleep 1
! date +%s

select m_epoch2 from dual ;

set echo off

prompt .
prompt Repeated identical queries now give increasing epoch values.
prompt .

set echo on

-- two columns and systimestamp... 

select  m_epoch2
      , m_epoch2 
      , to_char ( SYSTIMESTAMP, 'SSSSS.FF6' ) as sec_in_day
from dual connect by level < 4 ;

! date +%s

set echo off

prompt .
prompt Atomic: Repeated colums calling epoch, yield identical values.
prompt And the fractional-seconds show : epoch = systimestamp 
prompt .


set echo off

prompt .
prompt All Rows and Cols of an SQL refer to same Epoch + Systimestamp
prompt .


-- now compare to function and timestamp:
-- tot hier. func, macro, sysdate, systimestamp. all compareable.. 
-- Atomic.. 

select 
  f_epoch, f_epoch
, m_epoch, m_epoch 
, to_char ( systimestamp, 'SSSSS.FF6' ) as sec_in_day
from dual ;

! date +%s

! sleep 1 

/

select 
  f_epoch, f_epoch
, m_epoch, m_epoch 
, to_char ( systimestamp, 'SSSSS.FF6' ) as sec_in_day
from dual connect by level < 3 ;


prompt End of script 
