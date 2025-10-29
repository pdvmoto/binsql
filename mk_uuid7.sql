-- mk_uuid7.sql: from blog  by jasmin F.

CREATE OR REPLACE FUNCTION uuid7
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

    -- Generate random values
    r1 := TRUNC(DBMS_RANDOM.VALUE(0, 65536)); -- 16 bits
    r2 := TRUNC(DBMS_RANDOM.VALUE(0, 65536)); -- 16 bits
    r3 := TRUNC(DBMS_RANDOM.VALUE(0, 65536)); -- 16 bits
    r4 := TRUNC(DBMS_RANDOM.VALUE(0, 65536)); -- 16 bits

    -- Version byte: Set version 7 (0111) in high nibble, keep 12 random bits
    -- Version = 0x7X where X is random
    ver_rand := HEXTORAW(LPAD(TO_CHAR(BITAND(r1, 4095) + 28672, 'FM0XXX'), 4, '0')); -- 0x7000 | (r1 amp 0x0FFF)

    -- Variant byte: Set variant bits to 10xx (RFC 4122), keep 14 random bits
    -- Variant = 0x8X or 0x9X or 0xAX or 0xBX
    var_rand := HEXTORAW(LPAD(TO_CHAR(BITAND(r2, 16383) + 32768, 'FM0XXX'), 4, '0')); -- 0x8000 | (r2 amp 0x3FFF)

    -- Last 6 bytes are fully random
    rand_bytes := UTL_RAW.CONCAT(
        HEXTORAW(LPAD(TO_CHAR(r3, 'FM0XXX'), 4, '0')),
        HEXTORAW(LPAD(TO_CHAR(r4, 'FM0XXX'), 4, '0'))
    );

    -- Concatenate all parts to form 16-byte UUIDv7
    uuid := UTL_RAW.CONCAT(ts_high, ts_low, ver_rand, var_rand, rand_bytes);

    RETURN uuid;
END;
/

show errors


-- now for some formatting... 8-4-4-4-12

CREATE OR REPLACE FUNCTION fmt_uuid ( the_uuid RAW )
RETURN VARCHAR2
IS
  vc_retval varchar2(64) := '';
begin

  IF the_uuid IS NULL THEN
    vc_retval := '00000000-000-0000-0000-000000000000';

  ELSE  

    vc_retval :=  substr ( the_uuid,  1, 8 ) 
        || '-' || substr ( the_uuid,  9, 4 )
        || '-' || substr ( the_uuid, 13, 4 )
        || '-' || substr ( the_uuid, 17, 4 )
        || '-' || substr ( the_uuid, 20 )  ;
      
  End if;
  
  return vc_retval ;
  
END; -- fmt_uuid (raw)
/

show errors

-- demo the function..
select uuid7 from dual connect by level < 6;
select raw_to_uuid ( uuid7 ) as with_hyphens from dual connect by level < 6;

-- demo the format..
select  fmt_uuid ( null )         as fmt_null from dual ;
select  fmt_uuid ( sys_guid()  )  as fmt_sys_guid from dual ;
select  fmt_uuid ( uuid()  )      as fmt_uuid4  from dual ;
select  fmt_uuid ( uuid7()  )     as fmt_uuid7  from dual ;


set linesize 80
column id        format A32
column fmt_uuid  format A37
column vsiz      format 9999 

-- check the format for v7 ???
with v7 as ( select uuid7() as id from dual )
select id, fmt_uuid ( id ) fmt_uuid, vsize ( id )  vsiz from v7 ;

with v4 as ( select uuid() as id from dual )
select id, fmt_uuid ( id ) fmt_uuid, vsize ( id )  vsiz from v4 ;

