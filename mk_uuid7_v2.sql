/**** /* 
  mk_uuid7_v2.sql: continuation.. experiments...

original: (run this first..)
  mk_uuid7.sql: Playing with UUID-V7, Tweaks derived from blog by jasmin F.

  first version, fixed for length of last 12.
  2nd version: more compliant?, thx Jasmin !
  3rd version: uuuid7_ts: with option for given timestamp (note the wrong Variat)
  v2: more functions, possibly package: version, to_vc, and uuid_epoch, -ts, -date

functions in this file:
  uuid_get_version
  vc2_to_uuid 
  .. 
  uuid_to_epoch ( ) 
  epoch_to_timestamp ( epoch_incl_decimals for fractional seconds) 


todo:
 - 48-bit timestamp seems to miss the millisec ?? 
 - uuid7 with given date.. for use in partitioning or range-queries
     Use Package and synony to Overload, and stick with 1 single name ? 
     Maybe just rename _ts 
 - uuid7_ts: the Variant-byte is not correctly set. instead we "display the date"
 - if in_ts = null => get ramdom Uuid-v7 based on sysdate, 
     if any given date: use that for uuid-v7
     the null-uuuid has to be done elsewhere, or with separate paremeter.. ? 
 - in fmt_uuid: catch invalid UUIDs - raise error ? 


-- We Really Twist Ourselves here,
-- Someone Please find a more elegant way...
the_timestamp :=  (cast ( (sysdate + ( uuid7_epoch ( id )/ (24*3600)  ) )  
                              as timestamp ) 
                  )                          -- the date-part, as TS
                + to_dsinterval ( '0 00:00:00' || to_char ( mod ( uuid7_epoch ( id ), 1 ), '.999') ) ;  -- add fraciont as interval
                                
adding functions:

Questions..
 - Q1 : how important is the variant-byte ? 
 - Q2 : would "overloaded function" be more elegant -> yes, needs work.
 

examples uuid7:
1...,....1....,....2....,....3..
019A3AD146A8743DB278B7DC46A2B851
12345678000070001234000012345678

formatted, spacing out bits, bytes..
019A3AD2-C960-7F1C-9F2A-ABFE0FD8794D
12345678-0000-7000-1234-1234567890AB
              7000-2025-103116005900
                   YYYY-MMDDHHMISSmm

00000000-0000-0000-0000-000000000000

**************************************** */

CREATE OR REPLACE FUNCTION epoch_to_timestamp ( epoch_sec number )
RETURN timestamp
IS
  dt_start_epoch    DATE        ;
  vc_fract          VARCHAR2(4) ;
  the_timestamp     TIMESTAMP   ;
BEGIN

  IF ( epoch_sec IS NULL ) THEN 

    the_timestamp := NULL ;

  -- Also Catch numbers > 2^31 !

  ELSE

    dt_start_epoch := TO_DATE ( '1979-01-01', 'YYYY-MM-DD' ) ;   
    vc_fract       := TO_CHAR ( mod (  ( epoch_sec ), 1 ), '.999') ; 

    dbms_output.put_line ( 'uuid_to_ts :' || dt_start_epoch || ', vc_fract: ['|| vc_fract || ']' ) ; 

    the_timestamp  :=  dt_start_epoch + ( epoch_sec / (24*3600) )  
                     + to_dsinterval ( '0 00:00:00' || to_char ( mod ( epoch_sec, 1 ), '.999') ) ; 

  END if ;

  RETURN the_timestamp ; 

END;
/
list
show errors


CREATE OR REPLACE FUNCTION uuid_get_version ( in_uuid RAW default null )
RETURN number
-- extract the version number.. simple..
--
-- retval:  
-- NULL -> NULL
-- invalid length: -1
-- invalid content: -2 (what would constitute... ? for exmaple, non-hex values? )
-- min '00000000-0000-0000 ... : -255 (or some low value..., )
-- max:'ffffffff-ffff-ffff...  :  255 (or some high value..)
--
-- Queestions: 
--  - when should we RAISE errors ? 
--  - add check for SYS_GUID ? Others..?
-- 
IS
  n_retval     number ;   -- define as Integer ??
  vc_version   varchar2(1) ; 

BEGIN

  IF in_uuid IS NULL THEN

    n_retval := NULL ;

  ELSIF length ( in_uuid ) != 32 THEN

    n_retval := -1 ;

  ELSIF     in_uuid = HEXTORAW ( REPLACE ( '00000000-0000-0000-0000-000000000000', '-', '') ) THEN

    n_retval := -255 ;
  
  ELSIF  in_uuid = HEXTORAW ( REPLACE ( 'ffffffff-ffff-ffff-ffff-ffffffffffff', '-', '') ) THEN

    n_retval :=  255 ;

  -- NEED MORE CHECKS...
  ELSE

    vc_version := SUBSTR ( in_uuid, 13, 1 ) ; 

    IF REGEXP_LIKE(vc_version, '^[123456780]+$') THEN

      n_retval := vc_version ; 

    ELSE 

      n_retval :=  -2 ; 

    END IF; 

  END IF ; 

  RETURN n_retval ; 

END;  -- uuid_get_version
/ 
list
show errors 


CREATE OR REPLACE FUNCTION vc2_to_uuid ( in_vc Varchar2 default null )
RETURN RAW
-- 
-- Convert the given VC2 into a UUID, if possible.
--
-- retvals:  
-- NULL -> NULL
-- too_short:  raise..error
-- conversion error: raise error
--
-- Queestions: 
--  - should we RAISE errors ?  yes, prevent faulty data.
-- 
IS

  raw_retval     RAW ( 16 ) := NULL ; -- default null
  vc_value       Varchar2(40 ) ;      -- extra space for hyphens, spaces, overhead

BEGIN

  -- dbms_output.put_line ( 'vc2_to_uuid: in = ' || in_vc ) ;

  IF in_vc IS NULL THEN

    -- raw_retval := NULL ; 
    RETURN NULL ;

  ELSIF  length ( in_vc ) < 16 THEN

    -- dbms_output.put_line ( 'vc2_to_uuid: length < 16 ' ) ;

    vc_value := 'too short' ; -- guarantee Error..

  ELSE -- TODO: include more checks on Length, Content..

    vc_value :=  REPLACE ( in_vc, '-', '' )  ; 
    -- dbms_output.put_line ( 'vc2_to_uuid: hyphens replaced, [' || vc_value || ']' ) ;

  END IF ;

  raw_retval := HEXTORAW ( vc_value );

  return raw_retval ; 

END; -- vc2_to_uuid
/

list
show errors 

     
CREATE OR REPLACE FUNCTION uuid_to_vc2 ( the_uuid RAW )
RETURN VARCHAR2
-- for now: wrapper for fmt_uuid (), 
-- see comment there..
IS
BEGIN 
  RETURN fmt_uuid ( the_uuid ) ;
END;
/
list
show errors

CREATE OR REPLACE FUNCTION uuid7_epoch ( the_uuid RAW default null )
RETURN number
-- 
-- extract the epoc from a UUID-V7 (hence the name )
--
-- retval:  
-- NULL -> NULL
-- MIN-uuid, '000....': -> epoch=0, 1970-01-01
-- MAX-uuid, 'fff....': -> Epoch-time, 2038-01-19, 03:14:07, UTC
-- valid uuid-v7: -> return epoch time with 3 decimals, e.g. millisec
-- input invalid, random or conversion error: raise error
--
-- Questions, todo: 
--  - room for improvement
--  - needs more error checking ?
--  - add UUID different versions, consider similar capability for v1 and v6
-- 
IS

  vc_hex_epoch       Varchar2(32 ) ;      -- extra space for  overhead ???

  n_epoch           number ; 
  n_retval_epoch    number ; 

  vc_the_uuid       varchar(40) ; 

BEGIN

  IF the_uuid is NULL THEN

    n_retval_epoch := NULL;

  ELSIF the_uuid = HEXTORAW ( lpad ( '0', 32, '0' ) ) THEN
    n_retval_epoch := 0;
     
  ELSIF the_uuid = HEXTORAW ( lpad ( 'F', 32, 'F' ) ) THEN
    n_retval_epoch := (power ( 2, 31 ) - 1 ) ;  

  ELSIF ( uuid_get_version ( the_uuid ) != 7 ) THEN
     
    vc_the_uuid := uuid_to_vc2 ( the_uuid ) ; 
    RAISE_APPLICATION_ERROR(-20001, 'Error: No valid UUID-V7, ' || vc_the_uuid || '.' );

  ELSE 

    vc_hex_epoch := SUBSTR ( the_uuid, 1, 12 ) ;

    -- dbms_output.put_line ( 'uuid7_to_epoch: uuid: ' || the_uuid || ', vc_hex = [' || vc_hex_epoch || ']' ) ;

    n_retval_epoch := to_number ( vc_hex_epoch, 'XXXXXXXXXXXX' ) / 1000  ;

  END IF ; 

  -- dbms_output.put_line ( 'uuid7_to_epoch: epoch = [' || n_epoch || ']' ) ;

  return n_retval_epoch ;
 
END;
/

list
show errors

set serveroutput on

column id       format A35
column fmt_uuid format A38
column vsiz     format 9999
column ver      format 9999

column the_vc   format A37
column to_raw   format A35
column ep_to_ts format A30

column ts_epoch format 99999999999.999

set linesize 90

with v7 as ( select uuid()       as id          from dual connect by level < 3 )
select id
, fmt_uuid ( id ) fmt_uuid
, vsize ( id )             vsiz 
, uuid_get_version ( id )  ver
from v7 ; 

with v7 as ( select uuid7()      as id          from dual connect by level < 3 )
select id
, fmt_uuid ( id ) fmt_uuid
, vsize ( id )             vsiz 
, uuid_get_version ( id )  ver
from v7 ; 

with v7 as ( select sys_guid()      as id          from dual connect by level < 3 )
select id
, fmt_uuid ( id ) fmt_uuid
, vsize ( id )             vsiz 
, uuid_get_version ( id )  ver
from v7 ; 


delete from t7 ; 

set echo on

insert into t7 ( id )  select id from  (
       select null        as id  from dual
 union select SYS_GUID ()        from dual
 union select UUID()             from dual  -- out comment if versions below v23
 union select UUID7()            from dual  -- out comment if not yet created..
 union select HEXTORAW ( '00' )  from dual
 union select HEXTORAW ( 'FF' )  from dual
 union select HEXTORAW ( REPLACE ( '00000000-0000-0000-0000-000000000000', '-', '' ) ) from dual
 union select HEXTORAW ( REPLACE ( 'ffffffff-ffff-ffff-ffff-ffffffffffff', '-', '' ) ) from dual ) ;

select id
, fmt_uuid ( id ) fmt_uuid
, vsize ( id )             vsiz 
, uuid_get_version ( id )  ver
from t7 ; 

set echo off

with vc_ins as ( 
  select id, fmt_uuid ( id ) as the_vc  
  from t7 
  where (   ( vsize ( id ) = 16 ) -- only the valid ones..
         or id IS NULL )
)
select the_vc, vc2_to_uuid ( the_vc ) as to_raw from vc_ins ; 

-- prevent holding lock
commit ; 

prompt .
prompt Testing uuid7_to_epoch...
prompt .

select uuid7_epoch ( uuid7() ) as ts_epoch, f_epoch as ts_epoch from t7 ; 

set echo on
select id, uuid7_epoch ( uuid7() ) as ts_epoch , f_epoch ()  as ts_epoch from t7 ; 

delete from t7;

insert into t7 ( id )  select id from  (
       select null        as id  from dual
 union select UUID7()            from dual  -- out comment if not yet created..
 union select HEXTORAW ( REPLACE ( '00000000-0000-0000-0000-000000000000', '-', '' ) ) from dual
 union select HEXTORAW ( REPLACE ( 'ffffffff-ffff-ffff-ffff-ffffffffffff', '-', '' ) ) from dual ) ;

insert into t7 ( id )  select min ( id ) from tst_uuid7 ; 
insert into t7 ( id )  select max ( id ) from tst_uuid7 ; 

select  
  fmt_uuid ( id )     as fmt_uuid
, uuid7_epoch ( id )  as ts_epoch 
, epoch_to_timestamp ( uuid7_epoch ( id ) )    as ep_to_ts
from t7 ; 

set echo off
set serveroutput off

