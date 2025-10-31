/* 
  mk_uuid7.sql: from blog  by jasmin F.

  first version, fixed for length of last 12.
  2nd version: more compliant?
  3rd version: with in_ts: option for given timestamp

todo:
 - uuid7 with given date.. for use in partitioning or range-queries
 - if in_ts = null => get ramdom Uuid-v7 based on sysdate, 
     if any given date: use that for uuid-v7
     the null-uuuid has to be done elsewhere, or with separate paremeter.. ? 

example uuid7:
1...,....1....,....2....,....3..
019A3AD146A8743DB278B7DC46A2B851
12345678000070001234000012345678

formatted
019A3AD2-C960-7F1C-9F2A-ABFE0FD8794D
12345678-0000-7000-1234-1234567890AB
              7000-2025-103116005900
                   YYYY-MMDDHHMISSmm

vc_ts: 2025103115445700000000
       1...,....1

*/

-- just in case, debug..
set serveroutput on

CREATE OR REPLACE FUNCTION uuid7_ts ( in_ts TIMESTAMP default NULL )
RETURN RAW
--
-- use the given TS to construct a UUID-V7, 
-- bonus: report timestamp in last bits (but not conform-Standard...)
--
-- on NULL, return uuid-v7 using current SYSTIMESTAMP
-- 
-- question: should the NULL contain a V7 indicator 
--    answer: no, but that is strictly no UUID-V7 anymore.
--
-- question: should we fill with random bytes or just 00s
--    answer: 00s at this point, it makes the value "Fixed" ???
--
-- Credits: Build on an example from Jasmin Fluri, Oct 2025.
--
IS
  vc_ts      VARCHAR2(32)   := to_char ( in_ts, 'YYYYMMDDHH24MISSFF' ) ;

  -- chop out the comopnents..
  vc_yr      VARCHAR2(4)    := substr ( vc_ts,   1, 4 ) ;
  vc_mmdd    VARCHAR2(4)    := substr ( vc_ts,   5, 4 ) ;
  vc_tim_ms  VARCHAR2(9)    := substr ( vc_ts, -15, 8 ) ;

  ts_ms      NUMBER ;
  ts_high    RAW(4) ;
  ts_low     RAW(2) ;

  rw_retval  RAW(16)        ;
BEGIN

  -- dbms_output.put_line ( 'uuid7: in_ts :' || to_char ( in_ts ) || ', vc_ts :[' || vc_ts || ']' ) ;

  IF in_ts IS NULL THEN                 -- NULL given, return proper uuid-v7
  BEGIN
                              -- Considered: If Explicit NULL given, return 00s
                              -- dbms_output.put_line ( 'uuid7: set to 00s ' ) ;
                              -- rw_retval := HEXTORAW ( LPAD ( '0', 32, '0' ) ) ;

    rw_retval := uuid7 () ;  -- just call existing function
  END ;
  ELSE                                  -- use the in_ts to construct UUID-V7
  --BEGIN

    -- dbms_output.put_line ( 'uuid7: using given ts ' ) ;
    -- construct...

    -- dbms_output.put_line ( 'uuid7: vc_items : [' || vc_yr || '-'|| vc_mmdd || '.' || vc_tim_ms || ']' ) ;

    ts_ms    := (CAST(in_ts AS DATE) - DATE '1970-01-01') * 86400000;

    ts_high := HEXTORAW(LPAD(TO_CHAR(TRUNC(ts_ms / 65536), 'FM0XXXXXXX'), 8, '0'));
    ts_low  := HEXTORAW(LPAD(TO_CHAR(MOD(TRUNC(ts_ms), 65536), 'FM0XXX'), 4, '0'));

    rw_retval := UTL_RAW.CONCAT(ts_high, ts_low     -- 8 + 4 = 12
                  , hextoraw ( '700' )
                  , hextoraw ( vc_yr )
                  , hextoraw ( vc_mmdd )
                  , hextoraw ( vc_tim_ms ) ) ;
                  -- , hextoraw ( '000000000000' ) );

  --END;
  END IF ; -- null given , null returned

  -- dbms_output.put_line ( 'uuid7: retval : ['|| rw_retval || ']' ) ;

  return rw_retval ; 

END;
/
show errors 

-- just in case, debug..
set serveroutput on

-- v2: generate_uuid_v7_rfc9562
CREATE OR REPLACE FUNCTION uuid7
RETURN RAW
  -- Build on Initial from Jasmin Fluri, Oct 2025
  -- v2: generate_uuid_v7_rfc9562
IS
    -- 1. Timestamp in ms seit Unix Epoch (48 Bit)
    ts_ms NUMBER := (CAST(SYSTIMESTAMP AT TIME ZONE 'UTC' AS DATE) - DATE '1970-01-01') * 86400000;

    -- 2. Random für rand_a (12 Bit), rand_b (62 Bit)
    rand_a NUMBER := TRUNC(DBMS_RANDOM.VALUE(0, 4096)); -- 12 Bit
    rand_b1 NUMBER := TRUNC(DBMS_RANDOM.VALUE(0, POWER(2,16))); -- für 16+16+16+14 Bit (62 Bit rand_b werden auf 16+16+16+14 verteilt)
    rand_b2 NUMBER := TRUNC(DBMS_RANDOM.VALUE(0, POWER(2,16)));
    rand_b3 NUMBER := TRUNC(DBMS_RANDOM.VALUE(0, POWER(2,16)));
    rand_b4 NUMBER := TRUNC(DBMS_RANDOM.VALUE(0, POWER(2,14)));

    uuid RAW(16);
BEGIN
    -- 48 Bit Zeitstempel: High 32 Bit, Low 16 Bit
    -- Zeitstempel als 12 hex-stellige Zahl (6 Bytes)
    -- ts_high: erste 4 Bytes
    -- ts_low: letzte 2 Bytes
    DECLARE
        ts_high RAW(4) := HEXTORAW(LPAD(TO_CHAR(TRUNC(ts_ms / 65536), 'FM0XXXXXXX'), 8, '0'));
        ts_low  RAW(2) := HEXTORAW(LPAD(TO_CHAR(MOD(TRUNC(ts_ms), 65536), 'FM0XXX'), 4, '0'));

        -- Version 7 ins erste Nibble von rand_a (0x7<<12) | (rand_a amp 0xFFF)
        ver_rand_a RAW(2) := HEXTORAW(LPAD(TO_CHAR(BITAND(rand_a, 4095) + 28672, 'FM0XXX'), 4, '0'));

        -- Variant 0b10xxxxxx...  (RFC Variant: 2 High Bits = 10)
        -- Wir nehmen 2 variant bits (0x8000) plus 14 random bits
        var_rand_b1 RAW(2) := HEXTORAW(LPAD(TO_CHAR(BITAND(rand_b4, 16383) + 32768, 'FM0XXX'), 4, '0'));

        -- 4 * 2 Byte random:
        r_b1 RAW(2) := HEXTORAW(LPAD(TO_CHAR(rand_b1, 'FM0XXX'), 4, '0'));
        r_b2 RAW(2) := HEXTORAW(LPAD(TO_CHAR(rand_b2, 'FM0XXX'), 4, '0'));
        r_b3 RAW(2) := HEXTORAW(LPAD(TO_CHAR(rand_b3, 'FM0XXX'), 4, '0'));

        -- Zusammenbauen: 6-2-2-2-2-2 = 16 bytes
    BEGIN
        uuid := UTL_RAW.CONCAT(ts_high, ts_low, ver_rand_a, var_rand_b1, r_b1, r_b2, r_b3);
        RETURN uuid;
    END;
END;
/

show errors


-- the first version.., fixed for  length of r3, r4
CREATE OR REPLACE FUNCTION uuid7_v1
RETURN RAW
IS
    -- Get current timestamp in milliseconds since Unix epoch
    ts NUMBER := (CAST(SYSTIMESTAMP AT TIME ZONE 'UTC' AS DATE) - DATE '1970-01-01') * 86400000;

    -- Variables for building the UUID
    ts_high RAW(4);      -- First 4 bytes of timestamp
    ts_low RAW(2);       -- Last 2 bytes of timestamp
    ver_rand RAW(2);     -- Version (4 bits) + random (12 bits)
    var_rand RAW(2);     -- Variant (2 bits) + random (14 bits)
    rand_bytes RAW(6);   -- Last 6 random bytes

    -- Random numbers for the UUID
    r1 NUMBER;
    r2 NUMBER;
    r3 NUMBER;
    r4 NUMBER;

    uuid RAW(16);
BEGIN
    -- Extract timestamp bytes (48 bits total)
    -- Split 48-bit timestamp into 6 bytes
    ts_high := HEXTORAW(LPAD(TO_CHAR(TRUNC(ts / 65536), 'FM0XXXXXXX'), 8, '0'));
    ts_low := HEXTORAW(LPAD(TO_CHAR(MOD(TRUNC(ts), 65536), 'FM0XXX'), 4, '0'));

    -- Generate random values consider 16777215 for 0xFFFFFF (6 Fs)
    r1 := TRUNC(DBMS_RANDOM.VALUE(0, 65536)); -- 16 bits
    r2 := TRUNC(DBMS_RANDOM.VALUE(0, 65536)); -- 16 bits
    r3 := TRUNC(DBMS_RANDOM.VALUE(0, 16777216)); -- 24 bits
    r4 := TRUNC(DBMS_RANDOM.VALUE(0, 16777216)); -- 24 bits

    -- Version byte: Set version 7 (0111) in high nibble, keep 12 random bits
    -- Version = 0x7X where X is random
    ver_rand := HEXTORAW(LPAD(TO_CHAR(BITAND(r1, 4095) + 28672, 'FM0XXX'), 4, '0')); -- 0x7000 | (r1 amp 0x0FFF)

    -- Variant byte: Set variant bits to 10xx (RFC 4122), keep 14 random bits
    -- Variant = 0x8X or 0x9X or 0xAX or 0xBX
    var_rand := HEXTORAW(LPAD(TO_CHAR(BITAND(r2, 16383) + 32768, 'FM0XXX'), 4, '0')); -- 0x8000 | (r2 amp 0x3FFF)

    -- Last 6 bytes are fully random
    rand_bytes := UTL_RAW.CONCAT(
        HEXTORAW(LPAD(TO_CHAR(r3, 'FM0XXXXX'), 6, '0')),
        HEXTORAW(LPAD(TO_CHAR(r4, 'FM0XXXXX'), 6, '0'))
    );

    -- dbms_output.put_line ( 'uuid7: [' || ts_high || '-' || ts_low || '-' || ver_rand || '-' || rand_bytes || ']' ) ;

    -- Concatenate all parts to form 16-byte UUIDv7
    uuid := UTL_RAW.CONCAT(ts_high, ts_low, ver_rand, var_rand, rand_bytes);

    RETURN uuid;
END;
/

show errors


-- now for some formatting... 8-4-4-4-12

CREATE OR REPLACE FUNCTION fmt_uuid ( the_uuid RAW )
RETURN VARCHAR2
-- format UUID into the most common format, lowercase.
-- future versions: choose lower/upper, maybe more..
-- future versions: allow input of 32-length varchar ? 
IS
  vc_retval varchar2(40) := '';
begin

  IF the_uuid IS NULL THEN
    vc_retval := '00000000-0000-0000-0000-000000000000';

  ELSE  

    vc_retval :=  substr ( the_uuid,  1, 8 ) 
        || '-' || substr ( the_uuid,  9, 4 )
        || '-' || substr ( the_uuid, 13, 4 )
        || '-' || substr ( the_uuid, 17, 4 )
        || '-' || substr ( the_uuid, 21 )  ;
      
  End if;
  
  vc_retval := lower ( vc_retval ) ;

  return vc_retval ;
  
END; -- fmt_uuid (raw)
/

show errors

-- demo the function..
select uuid7 from dual connect by level < 6;
select raw_to_uuid ( uuid7 ) as with_hyphens from dual connect by level < 6;

set echo off
prompt . 
prompt .........  demo the format ......... 
prompt .

set echo on

select  fmt_uuid ( null        )  as fmt_null     from dual   ;
select  fmt_uuid ( sys_guid()  )  as fmt_sys_guid from dual ;
select  fmt_uuid ( uuid()      )  as fmt_uuid4    from dual ;

with max_uuid as ( select hextoraw ( lpad ( 'F', 32, 'F' ) )  as max_id from dual )  
select  fmt_uuid ( max_id      )  as max_uuid     from max_uuid ;

set echo off

column id        format A32
column fmt_uuid  format A37
column vsiz      format 9999 

set echo on

-- check the format and size for v7 ???
with v7 as ( select uuid7() as id from dual )
select id, fmt_uuid ( id ) fmt_uuid, vsize ( id )  vsiz from v7 ;

with v4 as ( select uuid() as id from dual )
select id, fmt_uuid ( id ) fmt_uuid, vsize ( id )  vsiz from v4 ;


-- now testing V7 with given Timestamp
select uuid7_ts ( )              as no_param    from dual connect by level < 2; 
select uuid7_ts ( NULL )         as with_null   from dual connect by level < 2; 
select uuid7_ts ( systimestamp ) as in_timestmp from dual connect by level < 2; 
select uuid7_ts ( sysdate )      as in_sysdate  from dual connect by level < 2; 

-- more tests..
with v7 as ( 
select uuid7_ts ( )              as id          from dual connect by level < 3)
select id, fmt_uuid ( id ) fmt_uuid, vsize ( id )  vsiz from v7 ; 

with v7 as ( 
select uuid7_ts ( NULL )         as id          from dual connect by level < 3)
select id, fmt_uuid ( id ) fmt_uuid, vsize ( id )  vsiz from v7 ; 

with v7 as ( 
select uuid7_ts ( systimestamp)  as id          from dual connect by level < 9)
select id, fmt_uuid ( id ) fmt_uuid, vsize ( id )  vsiz from v7 ; 

with v7 as ( 
select uuid7_ts ( sysdate-level) as id          from dual connect by level < 9)
select id, fmt_uuid ( id ) fmt_uuid, vsize ( id )  vsiz from v7 ; 

