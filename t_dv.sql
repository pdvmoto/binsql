
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
where rownum < 4;

select * from p ;

host read -p 'check p, hit enter...' abc

insert into c ( c_id, p_id, c_data )
select rownum as c_id
,                          1 + trunc ( rownum / 10 )      as p_id
, 'p_' || trim ( to_char ( 1 + trunc ( rownum / 10 ) ) ) 
||'c_' || trim ( to_char ( rownum ) )                     as c_data
from all_source 
where rownum < 30;

select * from c ;

host read -p 'check c, hit enter...' abc

-- now create the duality views

-- the parent view, to include children with the parent
-- note: no commas
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

select /* wm1 */ json_serialize(p.data pretty) from p_dv p 
where rownum < 5;

select /* wm2 */ json_serialize(p.data pretty) from p_dv p 
where p.data.c_id=13

-- the child-view: join the parent-data to the children
-- note: no commas
create or replace json relational duality view c_dv as
c @insert @update @delete
{
  child_id: c_id
  child_data: c_data
  p @unnest @update
  {
    parent_id: p_id
    parent_data: p_data
  }
};

select json_serialize(c.data pretty) from c_dv c;


-- now try inserting parent and child: p+c
-- note: using commas..
-- note: the c doesn not specify a p_id.. 
-- note: the fields must be named as in the DV, not as in the table-columns
-- note: we can add children via the array
insert into p_dv p ( data ) 
values ('
{
  parent_id: 4 , 
  parent_data: "parent_4_ins", 
  child : [
        { child_id : 40, 
          child_data : "c_40_ins"
        },
        { child_id : 41, 
          child_data : "c_41_ins"
        }
      ]
}') ;

-- verify this from sql:
select * from p where p_id = 4;
select * from c where p_id = 4;

-- now try updating, p=4..

-- note: the parent_id has to be specified in the SET, or it will null
-- note: commas
update p_dv p
set p.data = ('
{
  parent_id : 4, 
  parent_data : "new_data_p4", 
  child : [
    {
      child_id : 43, 
      child_data : "child_43_upd"
    }
  ]
}')
where p.data.parent_id = 4;

-- verify this from sql:
select * from p where p_id = 4;
select * from c where p_id = 4;

