/*

file : demo_index

Demonstrate : 
 - explain-plan and autotrace.
 - run stmnt twice to avoid effect of parseing.
 - demo effect of index-range-scan
 - demo effect of unique-scan? 
 - demo effect of index-only.


 - Extra field in index.
 - how PK or unique constraint can be enforced with non-unique index.
 - how to save on index-to-table access to reduce logical IO.
 
When to use this trick:
 - if table-access is on PK or other index, but _always_ requires extra field.
   example: parent-child records where a "status" or "date" is used to include/exclude records

actions in the script:
 - create table based on dba_tables user=parent, table_name=child, pk is 2 fields
 - demonstrate that a qry by index does a lot of gets to fetch individual rows.
 - overload the index, show it can still enforce PK
 - Demonstrate that an overloaded index results in index-only access.
 - then demonstrate the additional selectivity, even when table-access is still needed.

Moral:
 - you can add to PK indexes, for example a "status" field.

todo:
 - consider a nicer, shorter xplan plan output.
 - make sure all xplan calls are the same.
 - consider using just autotrace (too much extra output)
 - beware of CPU-costing warning

other notes:
 - in case of doubt: alter session set optimizer_mode = first_rows;
 - order-by-random to un-cluster data per parent, maximize gets on 1st qry.
 - Richard Foote has shown that unique indexes are generally better... (re-visit blog)

Finally:
 - by presenting this as demo, I make all the mistakes... 
 - confusing screen-jumps
 - reading text litteraly from screen.
 - give 2 or 3 messages at once (inflated index, enforce-constraint etc..)
 - was this detailed item worth all the hard work ?

Ideas:
 - demonstrate IOT by selecting owner dbsnmp : 20 rows, 20 blocks ?
 - demonstrate 2ndary index on IOT by selecting all tables with certain property...
 - clusters ?
 - compressed indexes ?

*/

alter session set optimizer_mode = first_rows;

set echo on
set pagesize 100
set linesize 100
column owner format A20
column table_name format A30


spool demo_index

clear screen

-- drop and recreate the table with a 2-field PK, typical parent-child.

drop   table OVL;
create table OVL as 
select OWNER, TABLE_NAME, TABLESPACE_NAME
     , IOT_TYPE, IOT_NAME, NUM_ROWS, AVG_ROW_LEN
     , LAST_ANALYZED, STATUS
from all_tables order by dbms_random.value ;


-- 
-- table with some fields..
-- now some SQL on that table to demonstrate how to explain and trace...
-- 

accept press_enter prompt "press enter to continue..."

select 
	owner, table_name, num_rows
from 	ovl
where   owner = 'DBSNMP'
/
select * from table(dbms_xplan.display_cursor('',null,'BASIC'));        

--
-- notice the full table access, why no indexes ?
--
accept press_enter prompt "press enter to continue..."


set autotrace on stat 
select 
	owner, table_name, num_rows
from 	ovl
where   owner = 'DBSNMP'
/
set autotrace off

-- 
-- Notice the autotrace information: consistent-gets.
-- 

accept press_enter prompt "Add index and constraint. enter to continue..."


create unique index OVL_PK on OVL ( OWNER, TABLE_NAME );
alter table OVL add constraint OVL_PK primary key ( OWNER, TABLE_NAME ) using index ovl_pk ;

-- Index and constraint added.
-- first pass of the qry is a good moment to use display_cursor.
-- second pass of the qry we will use autotrace-stats to see IO.
accept press_enter prompt "press enter to continue..."

select 
	owner, table_name, num_rows
from 	ovl
where   owner = 'DBSNMP'
/
select * from table(dbms_xplan.display_cursor('',null,'BASIC'));        

--
-- notice the access via PK-range, followed by access-by-idx-rowid
--
accept press_enter prompt "press enter to continue..."

set autotrace on stat 
select 
	owner, table_name, num_rows
from 	ovl
where   owner = 'DBSNMP'
/
set autotrace off

--
-- notice the nr of consistent-gets:
-- the query is now able to filter its set based on the index 
-- but then has to visit the table to pickup the num_rows...
--
accept press_enter prompt "press enter to continue..."

--
-- what if we dont need the field NUM_ROWS ... ?? 
--
accept press_enter prompt "press enter to continue..."


select 
	owner, table_name
from 	ovl
where   owner = 'DBSNMP'
/
select * from table(dbms_xplan.display_cursor('',null,'BASIC'));        

--
-- notice the access via index range scan on PK, 
-- but no table-access..
--
accept press_enter prompt "press enter to continue..."

set autotrace on stat 
select 
	owner, table_name
from 	ovl
where   owner = 'DBSNMP'
/
set autotrace off

--
-- notice the nr of consistent-gets:
-- now even lower: we didnt visit the table.
--
accept press_enter prompt "press enter to continue..."

--
-- now for a demo on how index-access can be IN-efficient
--
--
accept press_enter prompt "press enter to continue..."

select 
	owner, table_name, num_rows
from 	ovl
where   owner like 'SYS%'
and     num_rows > 100000
/
select * from table(dbms_xplan.display_cursor('',null,'BASIC'));        

--
-- notice: on first sight we have an efficient SQL,
-- index range scan and table-by-rowid.
-- but how much effort did the qry do?
--

accept press_enter prompt "press enter to continue..."

set autotrace on stat
select 
	owner, table_name, num_rows
from 	ovl
where   owner like 'SYS%'
and     num_rows > 100000
/
set autotrace off


--
-- notice: 
-- qry did many block-access to return only few rows.
-- (a full table scan might have been more efficient...)
--

accept press_enter prompt "press enter to continue..."



--
-- now we will recreate an inflated PK_index, but keep the same PK
--

alter table ovl drop constraint ovl_pk ;
drop index ovl_pk ;
create index OVL_PK on ovl ( OWNER, TABLE_NAME, NUM_ROWS );
alter table OVL add constraint OVL_PK PRIMARY KEY ( OWNER, TABLE_NAME ) using index ovl_pk ;

insert into ovl ( owner, table_name ) values ('SYS', 'DUAL' );

--
-- notice: 
-- The PK is still the same two fields,
-- and the constraint is in effect (ORA-00001). 
-- But the index contains 3 (three) fields, 
-- and the Index is non-unique.
--

accept press_enter prompt "press enter to continue..."

--
-- again, do qry twice to reduce effect of recursive sql at parse.
--

select 
        owner, table_name 
from 
        ovl 
where 
       owner like 'SY%' and
       num_rows > 100000
/
select * from table(dbms_xplan.display_cursor('',null,'BASIC'));        

--
-- notice: 
-- only PK-range-scan, only need to read the index
--

accept press_enter prompt "press enter to continue..."

set autotrace on stat
select 
        owner, table_name 
from 
        ovl 
where 
       owner like 'SY%' and
       num_rows > 100000
/
set autotrace off

--
-- notice: Reduced nr of consitent-gets, no more table-access. 
-- we scanned a lot less blocks by just using the index.
-- this shows how index-only access is a beneficial.
--

accept press_enter prompt "press enter to continue..."

--
-- note: 
-- If we have to retrieve More columns, 
-- we will have to access the table.
-- 
-- But the index (with additional field) is still beneficial.
-- better filtering means less table-access....
--

accept press_enter prompt "press enter to continue..."

select 
    owner, table_name, num_rows, status
from 
    ovl 
where 
        owner like 'SY%' and
        num_rows > 100000
/
select * from table(dbms_xplan.display_cursor('',null,'BASIC'));        

--
-- notice:
-- the access is now PK + acces-by-rowid again 
--
accept press_enter prompt "press enter to continue..."

set autotrace on stat
select 
    owner, table_name, num_rows, status
from 
    ovl 
where 
        owner like 'SY%' and
        num_rows > 100000
/
set autotrace off

--
-- but notice:
-- despite the additional acces-by-rowid, 
-- we accessed less rows then in the original qry: Filtering!
-- 

accept press_enter prompt "press enter to continue..."

-- 
-- and now select less rows in the result set
-- and we see the consistent gets go down..
-- 
select 
    owner, table_name, num_rows, status
from 
    ovl 
where 
        owner like 'SY%' and
        num_rows > 1000000
/
select * from table(dbms_xplan.display_cursor('',null,'BASIC'));        

--
-- we selected less rows...
--
--
accept press_enter prompt "press enter to continue..."

set autotrace on stat
select 
    owner, table_name, num_rows, status
from 
    ovl 
where 
        owner like 'SY%' and
        num_rows > 1000000


/
set autotrace off

-- 
-- Notice: 
-- We selected less rows,
-- the rows were filtered out by the index, 
-- all where-fields were in the index,
-- and the query doesnt visit the row-blocks 
-- if it doesnt "need" the column-values.
-- Thus we have even less gets..
--
-- 

accept press_enter prompt "press enter to continue..."

--
-- Recap: 
-- 1. we showed how an overloaded index can help qry-efficiency
-- 2. we showed how even a PK-index can be overloaded and still be a PK
--
-- Of course, I will _not_ show you:
-- a. the downsides of overloaded indexes (slow DML, extra redo) 
-- b. PK-index is now non-unique. The defined Constraint enforces it. 
-- c. Trickery to force demo to work with the too-clever CBO. 
--    (old fashioned first_rows, PLEASE DONT USE, or: get rid of quickly!).
--

spool off
