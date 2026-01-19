/* 
  mk_2bin.sql: convert integer to binary varchar..
  later: 2-compliment

 1. output binary varchar as 101 (5) or 100000 (16)
  =>  dec_2_bin covers this for the moment: test it foor extremes.., up to .. how high ?

 2. split a binary varchar into  Bytes : 11111111.11111111 (FF) and return with dots in between

 3. convet bin to Dec : varchar2 in, number out.

 4. and bin to Hex : varchar2 in , and varchar2-hex out. (or.. raw-hex out?)

 5. try using the format 'F9999B' in oracle 21 ? 

 6. create table with all UTF8 chars.. for later use:  Decimal_id, CHAR, [char], hex-rep, bin-represent .., example..
  Valid ranges in decimal/integers, :  0-127
    1 byte, 0xxxxxx : 0-127
    2 bytes, 110xxxxx 10xxxxxx: 49,792 – 57,279
    3 bytes, 1110xxxx 10xxxxxx 10xxxxxx:14,704,640 – 15,728,575


 7. Get Freq-distro of the charcs in a column: count ASCII values.. (and detect strange chars)

*/

set linesize 128 

column bin        format A33
column bin_fmted  format A33 justify left 
column dec        format 9,999,999,999

-- recursive example
WITH r (n, bin) AS (
  SELECT 15, '' FROM dual
  UNION ALL
  SELECT floor(n / 2),
         mod(n, 2) || bin
  FROM r
  WHERE n > 0
)
SELECT bin
FROM r
WHERE n = 0
/


CREATE OR REPLACE FUNCTION mk_2bin ( in_int number default NULL )
RETURN varchar2
-- 
--
-- on NULL, return null
-- 
-- 
--
IS

  vc_retval  varchar2(33); 

BEGIN

  -- dbms_output.put_line ( 'uuid7: in_int :' || to_char ( in_ts ) || ', vc_ts :[' || vc_ts || ']' ) ;

  select reverse(max(replace(sys_connect_by_path(mod(trunc(in_int/power(2,level-1)),2),' '),' ',''))) 
  into vc_retval 
  from dual connect by level <= 32 ;

  dbms_output.put_line ( 'in: : ' || in_int || ' - '|| vc_retval || '.' ) ;

  return vc_retval ; 

END;
/
show errors 

-- just in case, debug..
set serveroutput on

select  mk_2bin ( 1 ) from dual; 
select  mk_2bin ( 9 ) from dual; 



CREATE OR REPLACE FUNCTION f_to_bin ( in_num IN NUMBER )
RETURN NUMBER
IS
ln_max NUMBER := FLOOR ( LN ( ABS ( in_num ) ) / LN(2) );
ln_num NUMBER := ABS ( in_num );
lv_bin VARCHAR2(4000) := '0';
ln_Sign NUMBER;
BEGIN
IF in_num >= 0 THEN
ln_Sign := 1;
ELSE
ln_Sign := -1;
END IF;

FOR i IN REVERSE 0..ln_max
LOOP
IF ln_num >= POWER ( 2, i ) THEN
lv_bin := lv_bin || '1';
ln_num := ln_num - POWER ( 2, i );
ELSE
lv_bin := lv_bin || '0';
END IF;
!! Contains Error!
END LOOP;

RETURN TO_NUMBER ( lv_bin ) * ln_Sign;
END f_to_bin;
/

show errors 

-- test it..
select level, f_to_bin ( level ) from dual connect by level < 17;


-- from chatgpt: 
CREATE OR REPLACE FUNCTION dec_to_bin (
  p_number IN NUMBER
) RETURN VARCHAR2
IS
  v_num    NUMBER := TRUNC(p_number);
  v_bin    VARCHAR2(32767) := '';
  v_rem    NUMBER;
BEGIN
  -- Handle zero explicitly
  IF v_num = 0 THEN
    RETURN '0';
  END IF;

  -- Only non-negative integers supported
  IF v_num < 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Negative numbers not supported');
  END IF;

  -- Repeated division by 2
  WHILE v_num > 0 LOOP
    v_rem := MOD(v_num, 2);           -- remainder (0 or 1)
    v_bin := v_rem || v_bin;          -- prepend remainder
    v_num := FLOOR(v_num / 2);        -- quotient for next step
  END LOOP;

  RETURN v_bin;
END dec_to_bin;
/

show errors

select level dec
, lpad ( dec_to_bin ( level ), 32) bin 
from dual connect by level < 66 ;


-- from chatgpt: 
CREATE OR REPLACE FUNCTION fmt_bin ( vc_the_bin IN varchar2) RETURN VARCHAR2
IS
  -- if input is <8 char: 
  --   just return.
  -- else 
  --   take last 8 char, add a . in front , call it vc_back
  --   call same function with remaining front-length.., and call it vc_front
  --   return  vc_front || vc_back
  -- endif

  n_len       number ;
  vc_retval   varchar2(100) ; 
  vc_front    varchar2(128) ;
  vc_back     varchar2(9) ;

BEGIN
   
  n_len := length ( ' ' || vc_the_bin ) -1 ;
  -- dbms_output.put_line ( 'fmt_bin: [' || vc_the_bin || '], len=' || n_len || '.' );

  IF  n_len < 9 THEN

    --dbms_output.put_line ( 'fmt_bin: [' || vc_the_bin || '], last one.' );

    vc_retval := vc_the_bin ; 

  ELSE
    vc_back  := substr ( vc_the_bin, -8 ) ;
    vc_front := substr ( vc_the_bin,  0, length( vc_the_bin ) - 8 ) ;

    --dbms_output.put_line ( 'fmt_bin: [' || vc_front || '.' || vc_back || '], ... need next call.' );

    vc_front := fmt_bin ( vc_front ) ; 

    vc_retval := vc_front || '.' || vc_back ; 

    -- dbms_output.put_line ( 'fmt_bin: [' || vc_retval || '], ... returning.' );
    
  END IF;
   
  RETURN vc_retval ; 

END ;
/
show errors

set serveroutput on

select fmt_bin ( '1010101010101010101010101010' ) from dual ; 

select dec_to_bin ( 65355 + level ) 
from dual connect by level < 30 ;

 
with nrs as ( select level lvl, power ( level, 5 ) as nr from dual connect by level < 40 )
select                             lvl       
,                                  nr              dec
,    lpad (           dec_to_bin ( nr )  , 32)     bin
,    lpad ( fmt_bin ( dec_to_bin ( nr ) ), 32 )    bin_fmted
from nrs ;
 

drop table tst_utf8 ; 
create table tst_utf8 ( 
  dec_id    number
, vc_hex    varchar2(10)     -- the hex, for exapmle: Captal B is nr 0x42, lowercase 0 is 0x6F
, rawhex    raw ( 8 )       -- the raw representqtion, why... ? 
, vc_bin    varchar2(128)   -- bin representation, prefereably with dots: 11111111.00000000.1111111.00000000
, the_char  varchar2(4)    -- the actual char
, brackets  varchar2(7)     -- the char in between [x]
, example   varchar2(64)    -- some example word, if we have one
); 

alter table tst_utf8 add constraint tst_utf8_pk primary key ( dec_id ) ;


-- the 1-byte set, from 0x00 to 0x7F: 0 to 127
insert into tst_utf8 ( 
  dec_id
, vc_hex
, the_char
, brackets 
, vc_bin )
select 
  level
, to_char ( level, 'XXXXX' )
,        chr( level) 
, '[' || chr ( level ) || ']'
, dec_to_bin ( level ) 
from dual 
connect by level < 128 ; 

commit ; 



-- a query from chat..?
SELECT codepoint,
       UNISTR('\{' || TO_CHAR(codepoint, 'FMXXXXXX') || '}') AS utf8_char
FROM (
  CONNECT BY LEVEL <= 1114112
)
WHERE codepoint NOT BETWEEN 55296 AND 57343;


-- re attemapt
CREATE TABLE utf8_chars (
  codepoint NUMBER,
  utf8_char NVARCHAR2(1)
);

BEGIN
  FOR cp IN 0 .. 1114111 LOOP
    IF cp NOT BETWEEN 55296 AND 57343 THEN
      BEGIN
        INSERT INTO utf8_chars
        VALUES (
          cp,
          UNISTR('\{' || TO_CHAR(cp, 'FMXXXXXX') || '}')
        );
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;
    END IF;
  END LOOP;

  COMMIT;
END;
/



-- and a loop
SET SERVEROUTPUT ON SIZE UNLIMITED

DECLARE
  l_char  NVARCHAR2(1);
BEGIN
  FOR codepoint IN 0 .. 1114111 LOOP  -- 0x10FFFF

    -- Skip surrogate range
    IF codepoint BETWEEN 55296 AND 57343 THEN
      CONTINUE;
    END IF;

    BEGIN
      l_char := UNISTR('\{' || TO_CHAR(codepoint, 'FMXXXXXX') || '}');
      DBMS_OUTPUT.PUT_LINE(codepoint || ' = ' || l_char);
    EXCEPTION
      WHEN OTHERS THEN
        NULL; -- ignore invalid/unrenderable characters
    END;
  END LOOP;
END;
/

--notes saved,
prompt And how does this come out in sqlplus ..
select ascii ( 'Ħ' ), char_to_utf8_int ('Ħ'), chr ( 50342)  from dual ; 


select level
, to_char ( level, 'XXXXXXX') lvel_hex 
, CODEPOINT_TO_UTF8_INT (level ) dec_id
, chr (CODEPOINT_TO_UTF8_INT (level )) the_char
, 2097152 as maxcodedpoint2_20th
from dual 
where chr (CODEPOINT_TO_UTF8_INT (level )) is not null
connect by level <= power ( 2, 20 ) --(127866 + 10)
order by level  desc ;


