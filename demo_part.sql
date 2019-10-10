
/* 
 demo_part.sql: demonstrate use of partitions.

notably
 - table with pk and payload, (local) index on payload
 - generate  records.
 - demo delete from large table  (time + redo)
 - demo drop partition, see how fast?

create sequence pt_seq start with 1 maxvalue 99999 cycle;

with series as (
select rownum num 
,  to_char (to_date ( rownum, 'J'), 'JSP' ) 
from dual 
connect by rownum < 10 )
select * from series ; 

*/


-- table with integer-key, add 500K values, 
-- will create 5 partitions, 2 named and 2 sys-named partitions
-- 

drop table pt ; 

purge recyclebin ; 

create table pt 
( id number ( 9,0)   
, payload varchar2( 200) 
)
partition by range ( id )  interval ( 100000 ) 
(   partition pt_1 values less than ( 100000 )  
  , partition pt_2 values less than ( 200000 ) ) ;

-- beware, constraint in table-def generates global index
create unique index pt_pk on  pt ( id ) local ; 

alter table pt add constraint pt_pk primary key ( id ) ;

-- 400K records
set timing on

set echo on
set feedback on
set timing on

insert into pt
select rownum num
,  to_char (to_date ( rownum, 'J'), 'JSP' )
from dual
connect by rownum < 500000 ;

set echo off

commit ;

EXEC DBMS_STATS.gather_table_stats('SCOTT', 'PT');


set autotrace on stat 
set timing on

-- how long to delete...
delete from pt where id < 10001 ;

-- so easy to remove a parittion, any partition:
set echo on

alter table pt drop partition pt_1 ; 
alter table pt drop partition pt_2 ; 

set echo off
set autotrace off

column table_name format A20  
column part_name  format A20 
column hv format 999999 head High_val


select table_name, partition_name part_name, num_rows 
from user_tab_partitions
where table_name like 'PT%'
order by table_name, partition_name ; 

/*
-- find  out which partition contains the values below 2000
select table_name, partition_name part_name, high_value hv
from user_tab_partitions 
where table_name = 'PT'
and 1=1
/

*/




