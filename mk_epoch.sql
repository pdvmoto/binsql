
-- sql macro to get epoch ? 
-- 
-- note: a function would be back-portable.. 


CREATE OR REPLACE FUNCTION f_epoch_old
RETURN NUMBER
IS
begin
  return q'{(CAST(SYSTIMESTAMP AT TIME ZONE ''UTC'' AS DATE) - DATE ''1970-01-01'') * 86400}';
end;
/
show errors

CREATE OR REPLACE FUNCTION f_epoch
RETURN NUMBER
IS
  the_epoch  number ;
begin
  the_epoch := 
    ( to_number ( trunc ( sysdate) - TO_date( '1970-01-01', 'YYYY-MM-DD')) * 86400) -- seconds up to sysddate
  + to_number ( to_char ( systimestamp, 'SSSSS.FF9' ) ) ;                           -- add today seconds + fraction
  return the_epoch ;
end;
/
show errors

column the_epoch format 9999999999.999999999

select f_epoch from dual ;

with cnts as ( 
select object_type, count(*) type_cnt  from all_objects group by object_type 
)
select object_type
, type_cnt 
, f_epoch the_epoch
from cnts 
/

