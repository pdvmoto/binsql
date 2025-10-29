
/*

Minor thing, but let me point out...
The message for ORA-62432 seems not quite implemented in 23.26.

The new UUID (V4) can be displayed in hyphened format using RAW_TO_UUID.
And an old SYS_GUID, or a UUID-V7, should(?) results in an error message.
That message does comes out garbled on the latest container.

And allow me to make the two points 
point 1: a UUID-V7 would be nice to have, I expect that soon-ish.
point 2: a data-type UUID would also be nice to have..

*/

column banner_full format A50 wrap

drop table ts ;
drop table t4 ;

-- two tables, two versions of the uuid
create table t4 as select UUID ()     as id from dual ;
create table ts as select SYS_GUID () as id from dual ;

-- inspect the data...
set echo on

select id as uuid_v4 from t4 ;
select id as sysguid from ts ;

select rawtohex    ( id ) raw_uuid_to_hex  from t4 ;
select raw_to_uuid ( id ) raw_uuid_to_uuid from t4 ;

select rawtohex    ( id ) sysguid_to_hex  from ts ;
select raw_to_uuid ( id ) sysguid_to_uuid from ts ;

select banner_full from v$version ; 

set echo off

accept hitenter prompt "The Error message for ORA-62432 is not yet implemented ?"

