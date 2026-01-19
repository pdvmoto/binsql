
-- chk_utf8 : a function to check 1,2,3 byte integer is UTF8 char..


/* 

based on:
https://chatgpt.com/share/696b9e82-7cb8-800f-8c43-311ea602cf3d


functions: 
  is_valid_utf8_int ( int ) -> 0/1
  utf8_int_to_codepoint  ( int )  -> int (U-codepoint)
  codepoint_to_utf8_int ( codepoint_int ) -> int

*/ 


spool tst_utf8

-- a table to collect them
-- drop table utf8_chars ; 
create table utf8_chars (
  dec_id     number   -- decimal. hex and bin can be derived, or virtual columns
, ucodepoint number   -- in decimal. the HEX can be a vertual column ? 
, the_char   varchar2(1 char) 
);

alter table utf8_chars add constraint utf8_chars_pk primary key ( dec_id) ;
-- the other two are UK, but not declared yet.. 


CREATE OR REPLACE FUNCTION is_valid_utf8_int (
    p_value IN NUMBER
) RETURN NUMBER
IS
    b0 INTEGER;
    b1 INTEGER;
    b2 INTEGER;
BEGIN
    ------------------------------------------------------------------
    -- 1 BYTE UTF-8
    ------------------------------------------------------------------
    IF p_value BETWEEN 0 AND 127 THEN
        RETURN 1;
    END IF;

    ------------------------------------------------------------------
    -- 2 BYTE UTF-8
    ------------------------------------------------------------------
    IF p_value BETWEEN 0 AND 65535 THEN
        b0 := FLOOR(p_value / 256);
        b1 := MOD(p_value, 256);

        IF b0 BETWEEN 194 AND 223      -- 0xC2–0xDF
           AND b1 BETWEEN 128 AND 191  -- 0x80–0xBF
        THEN
            RETURN 1;
        END IF;
    END IF;

    ------------------------------------------------------------------
    -- 3 BYTE UTF-8
    ------------------------------------------------------------------
    IF p_value BETWEEN 0 AND 16777215 THEN
        b0 := FLOOR(p_value / 65536);
        b1 := FLOOR(MOD(p_value, 65536) / 256);
        b2 := MOD(p_value, 256);

        IF b0 BETWEEN 224 AND 239      -- 0xE0–0xEF
           AND b1 BETWEEN 128 AND 191
           AND b2 BETWEEN 128 AND 191
        THEN
            -- Exclude overlong encodings
            IF b0 = 224 AND b1 < 160 THEN
                RETURN 0;
            END IF;

            -- Exclude UTF-16 surrogate range
            IF b0 = 237 AND b1 > 159 THEN
                RETURN 0;
            END IF;

            RETURN 1;
        END IF;
    END IF;

    ------------------------------------------------------------------
    -- Not valid UTF-8
    ------------------------------------------------------------------
    RETURN 0;
END;
/
list
show errors

CREATE OR REPLACE FUNCTION utf8_int_to_codepoint (
    p_value IN NUMBER
) RETURN NUMBER
IS
    b0 INTEGER;
    b1 INTEGER;
    b2 INTEGER;
    b3 INTEGER;
    cp NUMBER;
BEGIN
    ------------------------------------------------------------------
    -- 1 BYTE UTF-8 : 0xxxxxxx
    ------------------------------------------------------------------
    IF p_value BETWEEN 0 AND 127 THEN
        RETURN p_value;
    END IF;

    ------------------------------------------------------------------
    -- 2 BYTE UTF-8 : 110xxxxx 10xxxxxx
    ------------------------------------------------------------------
    IF p_value BETWEEN 0 AND 65535 THEN
        b0 := FLOOR(p_value / 256);
        b1 := MOD(p_value, 256);

        IF b0 BETWEEN 194 AND 223        -- 0xC2–0xDF
           AND b1 BETWEEN 128 AND 191    -- 0x80–0xBF
        THEN
            cp := (b0 - 192) * 64
                + (b1 - 128);
            RETURN cp;
        END IF;
    END IF;

    ------------------------------------------------------------------
    -- 3 BYTE UTF-8 : 1110xxxx 10xxxxxx 10xxxxxx
    ------------------------------------------------------------------
    IF p_value BETWEEN 0 AND 16777215 THEN
        b0 := FLOOR(p_value / 65536);
        b1 := FLOOR(MOD(p_value, 65536) / 256);
        b2 := MOD(p_value, 256);

        IF b0 BETWEEN 224 AND 239
           AND b1 BETWEEN 128 AND 191
           AND b2 BETWEEN 128 AND 191
        THEN
            -- Overlong encoding check
            IF b0 = 224 AND b1 < 160 THEN
                RETURN NULL;
            END IF;

            -- Surrogate exclusion (U+D800–U+DFFF)
            IF b0 = 237 AND b1 > 159 THEN
                RETURN NULL;
            END IF;

            cp := (b0 - 224) * 4096
                + (b1 - 128) * 64
                + (b2 - 128);
            RETURN cp;
        END IF;
    END IF;

    ------------------------------------------------------------------
    -- 4 BYTE UTF-8 : 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
    ------------------------------------------------------------------
    IF p_value BETWEEN 0 AND 4294967295 THEN
        b0 := FLOOR(p_value / 16777216);
        b1 := FLOOR(MOD(p_value, 16777216) / 65536);
        b2 := FLOOR(MOD(p_value, 65536) / 256);
        b3 := MOD(p_value, 256);

        IF b0 BETWEEN 240 AND 244
           AND b1 BETWEEN 128 AND 191
           AND b2 BETWEEN 128 AND 191
           AND b3 BETWEEN 128 AND 191
        THEN
            -- Overlong encoding check (minimum U+10000)
            IF b0 = 240 AND b1 < 144 THEN
                RETURN NULL;
            END IF;

            -- Maximum Unicode limit U+10FFFF
            IF b0 = 244 AND b1 > 143 THEN
                RETURN NULL;
            END IF;

            cp := (b0 - 240) * 262144
                + (b1 - 128) * 4096
                + (b2 - 128) * 64
                + (b3 - 128);
            RETURN cp;
        END IF;
    END IF;

    ------------------------------------------------------------------
    -- Invalid UTF-8
    ------------------------------------------------------------------
    RETURN NULL;
END;
/
list
show errors

CREATE OR REPLACE FUNCTION codepoint_to_utf8_int (
    p_codepoint IN NUMBER
) RETURN NUMBER
IS
    b0 INTEGER;
    b1 INTEGER;
    b2 INTEGER;
    b3 INTEGER;
BEGIN
    ------------------------------------------------------------------
    -- Invalid Unicode scalar values
    ------------------------------------------------------------------
    IF p_codepoint < 0
       OR p_codepoint > 1114111           -- U+10FFFF
       OR (p_codepoint BETWEEN 55296 AND 57343) -- surrogates
    THEN
        RETURN NULL;
    END IF;

    ------------------------------------------------------------------
    -- 1 BYTE UTF-8
    ------------------------------------------------------------------
    IF p_codepoint <= 127 THEN
        RETURN p_codepoint;
    END IF;

    ------------------------------------------------------------------
    -- 2 BYTE UTF-8
    ------------------------------------------------------------------
    IF p_codepoint <= 2047 THEN
        b0 := 192 + FLOOR(p_codepoint / 64);
        b1 := 128 + MOD(p_codepoint, 64);

        RETURN b0 * 256 + b1;
    END IF;

    ------------------------------------------------------------------
    -- 3 BYTE UTF-8
    ------------------------------------------------------------------
    IF p_codepoint <= 65535 THEN
        b0 := 224 + FLOOR(p_codepoint / 4096);
        b1 := 128 + FLOOR(MOD(p_codepoint, 4096) / 64);
        b2 := 128 + MOD(p_codepoint, 64);

        RETURN b0 * 65536 + b1 * 256 + b2;
    END IF;

    ------------------------------------------------------------------
    -- 4 BYTE UTF-8
    ------------------------------------------------------------------
    b0 := 240 + FLOOR(p_codepoint / 262144);
    b1 := 128 + FLOOR(MOD(p_codepoint, 262144) / 4096);
    b2 := 128 + FLOOR(MOD(p_codepoint, 4096) / 64);
    b3 := 128 + MOD(p_codepoint, 64);

    RETURN b0 * 16777216
         + b1 * 65536
         + b2 * 256
         + b3;
END;
/
list
show errors

CREATE OR REPLACE FUNCTION char_to_utf8_int (
    p_char IN VARCHAR2
) RETURN NUMBER
IS
    cp NUMBER;
BEGIN
    IF p_char IS NULL OR LENGTH(p_char) != 1 THEN
        RETURN NULL;
    END IF;

    -- Get Unicode code point of the character
    cp := UNICODE(p_char);

    -- Encode as UTF-8 integer
    RETURN codepoint_to_utf8_int(cp);
END;
/
list
show errors

CREATE OR REPLACE FUNCTION char_to_utf8_int (
    p_char IN VARCHAR2
) RETURN NUMBER
IS
    cp NUMBER;
    b0 INTEGER;
    b1 INTEGER;
    b2 INTEGER;
    b3 INTEGER;
BEGIN
    IF p_char IS NULL OR LENGTH(p_char) != 1 THEN
        RETURN NULL;
    END IF;

    cp := UNICODE(p_char);

    -- Invalid Unicode scalar
    IF cp < 0 OR cp > 1114111
       OR cp BETWEEN 55296 AND 57343 THEN
        RETURN NULL;
    END IF;

    IF cp <= 127 THEN
        RETURN cp;
    ELSIF cp <= 2047 THEN
        b0 := 192 + FLOOR(cp / 64);
        b1 := 128 + MOD(cp, 64);
        RETURN b0 * 256 + b1;
    ELSIF cp <= 65535 THEN
        b0 := 224 + FLOOR(cp / 4096);
        b1 := 128 + FLOOR(MOD(cp, 4096) / 64);
        b2 := 128 + MOD(cp, 64);
        RETURN b0 * 65536 + b1 * 256 + b2;
    ELSE
        b0 := 240 + FLOOR(cp / 262144);
        b1 := 128 + FLOOR(MOD(cp, 262144) / 4096);
        b2 := 128 + FLOOR(MOD(cp, 4096) / 64);
        b3 := 128 + MOD(cp, 64);
        RETURN b0 * 16777216
             + b1 * 65536
             + b2 * 256
             + b3;
    END IF;
END;
/
list
show errors

CREATE OR REPLACE FUNCTION char_to_utf8_int (
    p_char IN VARCHAR2
) RETURN NUMBER
IS
    r   RAW(4);
    len INTEGER;
    b0  INTEGER;
    b1  INTEGER;
    b2  INTEGER;
    b3  INTEGER;
BEGIN
    IF p_char IS NULL OR LENGTH(p_char) != 1 THEN
        RETURN NULL;
    END IF;

    -- Convert character to UTF-8 bytes
    r   := UTL_RAW.cast_to_raw(p_char);
    len := UTL_RAW.length(r);

    IF len < 1 OR len > 4 THEN
        RETURN NULL;
    END IF;

    -- Extract bytes (RAW is hex, 2 chars per byte)
    b0 := TO_NUMBER(SUBSTR(r,  1, 2), 'XX');

    IF len = 1 THEN
        RETURN b0;
    END IF;

    b1 := TO_NUMBER(SUBSTR(r,  3, 2), 'XX');

    IF len = 2 THEN
        RETURN b0 * 256 + b1;
    END IF;

    b2 := TO_NUMBER(SUBSTR(r,  5, 2), 'XX');

    IF len = 3 THEN
        RETURN b0 * 65536 + b1 * 256 + b2;
    END IF;

    b3 := TO_NUMBER(SUBSTR(r,  7, 2), 'XX');

    RETURN b0 * 16777216
         + b1 * 65536
         + b2 * 256
         + b3;
END;
/
show errors
list

CREATE OR REPLACE FUNCTION codepoint_to_char (
    p_codepoint IN NUMBER
) RETURN VARCHAR2
IS
-- note: TEST! I dont trust chatgpt on this yet..
BEGIN
    -- Validate Unicode scalar value
    IF p_codepoint < 0
       OR p_codepoint > 1114111           -- U+10FFFF
       OR p_codepoint BETWEEN 55296 AND 57343 -- Surrogates
    THEN
        RETURN NULL;
    END IF;

    RETURN CHR(p_codepoint);
END;
/
show errors
list

column lvl      format 999,999,999 
column codep    format 999,999,999 
column is8      format 999
column utf8     format A5
column mFF      format 999
column as_hex   format A8
column cp_hex   format A8
column bin_fmted format A36

column charct         format A6
column back_to_int    forma 999,999

set linesize 128

select level                   as lvl
,  mod ( level, 256)           as mFF
, to_char (level, '0XXXXXX' )   as as_hex
, lpad ( fmt_bin ( dec_to_bin ( level ) ), 32 )    bin_fmted
, is_valid_utf8_int ( level )  as is8 
, '[' || chr ( level ) || ']'  as utf8
from dual connect by level <= 99999  
group by level
having is_valid_utf8_int ( level ) = 1  
order by level
/

prompt .
prompt above is first attempts..
prompt .

with lvl as ( select level as lvl from dual connect by level <= 99999 ) 
select lvl.lvl                as lvl
,  mod ( lvl, 256)            as mFF
, to_char (lvl, '0XXXXXX' )    as as_hex
, lpad ( fmt_bin ( dec_to_bin ( lvl ) ), 32 )    as bin_fmted
, is_valid_utf8_int ( lvl )   as is8 
, '[' || chr ( lvl ) || ']'   as utf8
from lvl 
where is_valid_utf8_int ( lvl ) = 1 ; 
order by lvl.lvl

prompt .
prompt above is 0-99999 (up to 100K)
prompt .

with lvl as ( select level as lvl from dual connect by level < 1000000 )
select lvl 
, to_char (lvl, '0XXXXXX' )       as as_hex
, is_valid_utf8_int ( lvl )       as is8 
, utf8_int_to_codepoint ( lvl )   as codep
, to_char ( utf8_int_to_codepoint ( lvl ), '0XXXXXX' )  as cp_hex
, CASE 
    WHEN is_valid_utf8_int ( lvl ) = 1 THEN chr ( lvl)
    ELSE null
  END CASE as utf8 
, lpad ( fmt_bin ( dec_to_bin ( lvl ) ), 32 )    as bin_fmted
from lvl 
where (   lvl < 130 
       or lvl between 49792 and 57279
      )
order by lvl 
; 

prompt .
prompt above is up to 1M, but printed only to utf8=true, prevent errors
prompt .

-- testin to_utf8
select level                            lvl
, chr ( level)                          utf8
, '[' || chr ( level) || ']'            charct
, char_to_utf8_int ( chr ( level ) )    back_to_int
from dual connect by level < 129
order by level
;

-- ty inserting..
-- probably needs a pl/sql loop later..
insert into utf8_chars ( dec_id, ucodepoint, the_char )
                  select dec_id, ucodepoint, the_char from 
( select level                          as dec_id
                , utf8_int_to_codepoint ( level )   as ucodepoint
                , chr ( level )                     as the_char
              from dual connect by level < 1000000 
)  lvl
where is_valid_utf8_int ( dec_id ) = 1
/

-- next set..
insert into utf8_chars ( dec_id, ucodepoint, the_char )
                  select dec_id, ucodepoint, the_char from 
( select level+14000000                          as dec_id
                , utf8_int_to_codepoint ( level +14000000)   as ucodepoint
                , chr ( level +14000000)                     as the_char
              from dual connect by level < 1000000 
)  lvl
where is_valid_utf8_int ( dec_id ) = 1
/

insert into utf8_chars ( dec_id, ucodepoint, the_char )
                  select dec_id, ucodepoint, the_char from 
( select level+15000000                          as dec_id
                , utf8_int_to_codepoint ( level +15000000)   as ucodepoint
                , chr ( level +15000000)                     as the_char
              from dual connect by level < 1000000
)  lvl
where is_valid_utf8_int ( dec_id ) = 1
/



spool off

