/*

file: demo_di ; drop + recreate constraint, drop index later.

How: create a table with PK, then add field to the PK,

Demonstrate : 
 - replae PK index with "fatter" index.
 - Actal constraint is never "removed" 

Moral:
 - you can add to PK indexes, for example a "status" field.

other notes on doing index_demos:
 - in case of doubt: alter session set optimizer_mode = first_rows;
 - order-by-random to un-cluster data per parent, maximize gets on 1st qry.
 - Richard Foote has shown that unique indexes are generally better... (re-visit blog)


-- ruler
prompt ....,....1....,....2....,....3....,....4....,....5....,....6....,....7....,....8

*/

-- for index-demos, avoid FTS on small tbls...
alter session set optimizer_mode = first_rows;

set echo off
set pagesize 100
set linesize 100
column owner format A20
column table_name format A30

set sqlprompt "SQL > " 

spool demo_di

clear screen

prompt table with constraint + implict index

set echo on

drop   table tab_with_con;
create table tab_with_con as
select OWNER, TABLE_NAME, TABLESPACE_NAME
     , IOT_TYPE, IOT_NAME, NUM_ROWS, AVG_ROW_LEN
     , LAST_ANALYZED, STATUS
from all_tables ;

alter table tab_with_con add constraint tab_with_con_PK primary key ( OWNER, TABLE_NAME ) ;

set echo off

prompt .
prompt We have a table with PK, 
prompt and inserting double will generate an error...
prompt . 
accept press_enter prompt "press enter to continue..."

set echo on

insert into tab_with_con 
select OWNER, TABLE_NAME, TABLESPACE_NAME
     , IOT_TYPE, IOT_NAME, NUM_ROWS, AVG_ROW_LEN
     , LAST_ANALYZED, STATUS
from all_tables ;

set echo off

prompt .
prompt Checked: Constraint is Enforced.
prompt Now let's drop the constraint, but we keep the index...
prompt . 
accept press_enter prompt "press enter to continue..."

set echo on

alter table tab_with_con drop constraint tab_with_con_pk KEEP INDEX ; 

set echo off

prompt .
prompt Constraint is Dropped, Check: is PK still working ... ?
prompt . 
accept press_enter prompt "press enter to continue..."

set echo on

insert into tab_with_con 
select OWNER, TABLE_NAME, TABLESPACE_NAME
     , IOT_TYPE, IOT_NAME, NUM_ROWS, AVG_ROW_LEN
     , LAST_ANALYZED, STATUS
from all_tables ;

set echo off

prompt .
prompt Check! 
prompt Now, create a "fat index" , and use it to re-create Constraint.
prompt . 
accept press_enter prompt "press enter to continue..."

set echo on

create index tab_with_con_pk_fat on tab_with_con ( OWNER, TABLE_NAME, STATUS );

alter  table tab_with_con add constraint tab_with_con_pk primary key ( OWNER, TABLE_NAME ) using index tab_with_con_pk_fat ; 
 
set echo off

prompt .
prompt Fat index created, constraint added, PK always enforced.
prompt Let's drop the original index, and check PK still works?
prompt . 
accept press_enter prompt "press enter to continue..."

set echo on

drop index tab_with_con_pk ; 

insert into tab_with_con 
select OWNER, TABLE_NAME, TABLESPACE_NAME
     , IOT_TYPE, IOT_NAME, NUM_ROWS, AVG_ROW_LEN
     , LAST_ANALYZED, STATUS
from all_tables ;

set echo off

prompt .
prompt QED: Constraint is Enforced. 
prompt . 
prompt End of demo.
prompt . 
accept press_enter prompt "press enter to continue..."


/***** notes:

- in earlier versions, the fat index could not be unique,
- Richard Foote explaind it once.. 

- beware: table will be locked for initializing the PK...  

- recently had some ora-54: resource-busy-nowait, 
  added ONLINE keyword to create index, then testers using XE got error.. 

*****/

spool off

-- I want my prompt back!!
@pr5 
