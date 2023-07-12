
-- test DV view for json duality with p + c 
-- notably test : 
-- 1) lots of select.. and 
-- 2) upserts many tables.
-- 

column p_data format A18
column c_data format A18

drop table c ;
drop table p ; 

create table p ( 
  p_id number ( 9,0 ) 
, p_data varchar2 ( 16 ) 
, constraint p_pk primary key ( p_id ) 
) ; 

create table c (
  c_id number ( 9,0 ) 
, p_id number ( 9,0 ) 
, c_data varchar ( 16 ) 
, constraint c_pk primary key ( c_id ) 
, constraint c_p_fk foreign key ( p_id ) references p ( p_id ) 
);

-- index on fk, good practice just in case.. 
-- (would be good test to leave out...)
create index c_p_fk on c ( p_id ) ; 

insert into p ( p_id, p_data ) 
select rownum as p_id
, 'parent_' || trim ( to_char ( rownum ) ) as p_data
from all_source 
where rownum < 101;

select * from p ;

host read -p 'check p, hit enter...' abc

insert into c ( c_id, p_id, c_data )
select rownum as c_id
,                          1 + trunc ( rownum / 10 )      as p_id
, 'p_' || trim ( to_char ( 1 + trunc ( rownum / 10 ) ) ) 
||'c_' || trim ( to_char ( rownum ) )                     as c_data
from all_source 
where rownum < 1000;

select * from c ;

host read -p 'check c, hit enter...' abc

-- now create the duality views

create or replace json relational duality view p_dv as
p @insert @update @delete
{
  parent_id : p_id
  parent_data : p_data
  child : c @insert @update @delete
  {
    child_id : c_id
    child_data : c_data
  }
};

desc p_dv

select json_serialize(p.data pretty) from p_dv p 
where rownum < 5;

select json_serialize(p.data pretty) from p_dv p 
where p.data.c_id=13


