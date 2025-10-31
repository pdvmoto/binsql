
-- mk_epoch.sql: sql function or macro to get epoch ? 
-- 
-- note: a function would be back-portable.. 
-- note: macro is "atomic" in statemewnt, function is per line, per call..
--

-- this has no decimal-seconds, e.g. precision is 1 sec, no more.
-- and doesnt work anymore
CREATE OR REPLACE FUNCTION f_epoch_old
RETURN NUMBER
IS
begin
  return q'{(CAST(SYSTIMESTAMP AT TIME ZONE ''UTC'' AS DATE) - DATE ''1970-01-01'') * 86400}';
end;
/
show errors

-- Final Function, winner of the tests
CREATE OR REPLACE FUNCTION f_epoch
RETURN NUMBER
IS
  PRAGMA UDF ;
  now_stm  timestamp := systimestamp;
begin
  return (
    ( to_number ( trunc ( now_stm) - TO_date( '1970-01-01', 'YYYY-MM-DD')) * 86400) -- seconds up to sysddate
  + to_number ( to_char ( now_stm, 'SSSSS.FF9' ) )                            -- add today seconds + fraction
  ) ;
end;
/
show errors



CREATE OR REPLACE FUNCTION f_epoch1
RETURN NUMBER
IS
  midnight_sec  number ;
  in_day_sec    number ;
  the_epoch     number ;
begin

  midnight_sec := ( to_number ( trunc ( sysdate) - TO_date( '1970-01-01', 'YYYY-MM-DD')) * 86400) ;
  in_day_sec   := to_number ( to_char ( systimestamp, 'SSSSS.FF9' ) ) ; 

  the_epoch := midnight_sec + in_day_sec ; 

  return the_epoch ;
end;
/
show errors

-- faster function, less code? 
CREATE OR REPLACE FUNCTION f_epoch2
RETURN NUMBER
IS
begin
  return (
    ( to_number ( trunc ( sysdate) - TO_date( '1970-01-01', 'YYYY-MM-DD')) * 86400) -- seconds up to sysddate
  + to_number ( to_char ( systimestamp, 'SSSSS.FF9' ) )                            -- add today seconds + fraction
  ) ;
end;
/
show errors

-- faster function ? this was consistently WORSE.. 
CREATE OR REPLACE FUNCTION f_epoch2a
RETURN NUMBER
IS
begin
  return (
    ( to_number ( trunc ( systimestamp) - TO_date( '1970-01-01', 'YYYY-MM-DD')) * 86400) -- seconds up to sysddate
  + to_number ( to_char ( systimestamp, 'SSSSS.FF9' ) )                            -- add today seconds + fraction
  ) ;
end;
/
show errors

-- faster function ? PRAGMA UDF 
CREATE OR REPLACE FUNCTION f_epoch3
RETURN NUMBER
IS
  PRAGMA UDF ;
begin
  return (
    ( to_number ( trunc ( sysdate) - TO_date( '1970-01-01', 'YYYY-MM-DD')) * 86400) -- seconds up to sysddate
  + to_number ( to_char ( systimestamp, 'SSSSS.FF9' ) )                            -- add today seconds + fraction
  ) ;
end;
/
show errors

-- faster function ? (pragma with 2x tmstmp)
CREATE OR REPLACE FUNCTION f_epoch3a
RETURN NUMBER
IS
  PRAGMA UDF ;
begin
  return (
    ( to_number ( trunc ( systimestamp) - TO_date( '1970-01-01', 'YYYY-MM-DD')) * 86400) -- seconds up to sysddate
  + to_number ( to_char ( systimestamp, 'SSSSS.FF9' ) )                            -- add today seconds + fraction
  ) ;
end;
/
show errors

-- faster function ? (pragma with 1x2 stmp)
CREATE OR REPLACE FUNCTION f_epoch3b
RETURN NUMBER
IS
  PRAGMA UDF ;
  now_stm  timestamp := systimestamp;
begin
  return (
    ( to_number ( trunc ( now_stm) - TO_date( '1970-01-01', 'YYYY-MM-DD')) * 86400) -- seconds up to sysddate
  + to_number ( to_char ( now_stm, 'SSSSS.FF9' ) )                            -- add today seconds + fraction
  ) ;
end;
/
show errors

-- even faster function ? (pragma with dt= + ts=)
CREATE OR REPLACE FUNCTION f_epoch3c
RETURN NUMBER
IS
  PRAGMA UDF ;
  now_stm  timestamp := systimestamp ;
  now_dat  date      := sysdate      ; 
begin
  -- now_stm := systimestamp ; 
  return (
    ( to_number ( trunc ( now_dat) - TO_date( '1970-01-01', 'YYYY-MM-DD')) * 86400) -- seconds up to sysddate
  + to_number ( to_char ( now_stm, 'SSSSS.FF9' ) )                            -- add today seconds + fraction
  ) ;
end;
/
show errors


-- macro..
CREATE or replace FUNCTION m_epoch
RETURN varchar2 
SQL_MACRO(SCALAR) IS
BEGIN
  RETURN ( q'[ 
      ( to_number ( trunc ( sysdate) - TO_date( '1970-01-01', 'YYYY-MM-DD')) * 86400) -- seconds up to sysddate
    +   to_number ( to_char ( systimestamp, 'SSSSS.FF9' ) ) ]' 
  );
END;
/
show errors

column the_epoch format 9999999999.999999999
column the_mepoch format 9999999999.999999999

column f_epoch1 format 9999999999.999999999

select f_epoch the_epoch , 'as nr' from dual ;

select m_epoch the_mepoch , 'as macro' from dual ;

select 'Four diff Functions:', f_epoch2, f_epoch2a, f_epoch3, f_epoch3a from dual ; 

select level, f_epoch the_epoch, m_epoch the_mepoch from dual connect by level < 11 ; 

-- check impact of arraysize..
set arraysize 6

select level
, f_epoch
, f_epoch
, m_epoch
, m_epoch
from dual connect by level < 10 ;

with cnts as ( 
select object_type, count(*) type_cnt  from all_objects group by object_type 
)
select object_type
, type_cnt 
, f_epoch the_epoch
, m_epoch the_mepoch
from cnts 
/


-- testing code here..

column f_epoch1 format 9999999999.999999999

set echo on

select f_epoch1 from dual ;

select f_epoch1, f_epoch1 from dual connect by level < 4 ;

set echo off

