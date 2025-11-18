
-- tst_uuid.sql: compare uuid v4 and v7.

-- a few test_cases..
/*
drop table ts;
drop table t4;
drop table t7;
*/

create table ts as select sys_guid() as id from dual ; 
create table t4 as select uuid()     as id from dual ; 
create table t7 as select uuid7()    as id from dual ; 

-- correct the size
alter table t7 modify id RAW(16) ; 

select id from ts
select id from t4
select id from t7


select rawtohex  ( id ) from ts ; 
select raw_to_uuid ( id ) from ts ; 

select rawtohex  ( id ) from t4 ; 
select raw_to_uuid ( id ) from t4 ; 

select rawtohex  ( id ) from t7 ; 
select raw_to_uuid ( id ) from t7 ; 


-- first the uuid v4, then v7, and also sys_guid

-- drop   table tst_uuids ; 

create table tst_uuids ( 
  id            raw (16)
, created_dt    timestamp 
, ts_epoch      number
, id_vc         varchar2(40)  -- id with hyphens
, payload       varchar2(128 ) -- notes, etc.. 
) ;

alter table tst_uuids add constraint tst_uuids_pk primary key ( id ) ;

-- drop   table tst_uuid4 ; 

create table tst_uuid4 ( 
  id            raw (16)
, created_dt    timestamp 
, ts_epoch      number
, id_vc         varchar2(40)  -- id with hyphens
, payload       varchar2(128 ) -- notes, etc.. 
) ;

alter table tst_uuid4 add constraint tst_uuid4_pk primary key ( id ) ;


--drop table tst_uuid7 ;

create table tst_uuid7 ( 
  id            raw (16)
, created_dt    timestamp 
, ts_epoch      number
, id_vc         varchar2(40)  -- id with hyphens
, payload       varchar2(128 ) -- notes, etc.. 
) ;

alter table tst_uuid7 add constraint tst_uuid7_pk primary key ( id ) ;


-- insert some data.

insert into tst_uuids ( id, created_dt, ts_epoch, id_vc, payload )
with uuid_data as ( 
  select sys_guid()       as id
     , systimestamp       as created_dt
     , f_epoch            as ts_epoch
     , ' '                as id_vc
     , 'payld'            as payload
  from dual connect by level < 10 )
select id, created_dt, ts_epoch, id_vc, payload from uuid_data;

commit ; 

insert into tst_uuid4 ( id, created_dt, ts_epoch, id_vc, payload )
with uuid_data as ( 
  select uuid()           as id
     , systimestamp       as created_dt
     , f_epoch            as ts_epoch
     , ' '                as id_vc
     , 'payld'            as payload
  from dual connect by level < 10 )
select id, created_dt, ts_epoch, id_vc, payload from uuid_data;

commit ; 

insert into tst_uuid7 ( id, created_dt, ts_epoch, id_vc, payload )
with uuid_data as ( 
  select uuid7()       as id
     , systimestamp       as created_dt
     , f_epoch            as ts_epoch
     , ' '                as id_vc
     , 'payld'            as payload
  from dual connect by level < 10 )
select id, created_dt, ts_epoch, id_vc, payload from uuid_data;

commit ; 

