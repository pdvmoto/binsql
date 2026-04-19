
/*
file : demo_iot

Essence of an IOT:
 - grouped records, all children in 1 block: parent-child cases.
 - secondary key larger but more efficient when looking for PK-values.
	=> usefull when joining over a relation-table.

*/


alter session set optimizer_mode = first_rows;

set autotrace off
set echo on
set pagesize 100
set linesize 100

column owner       format A15
column table_name  format A30 
column iot_type    format A15
column iot_name    format A30


spool iot_demo

-- drop and recreate the table with a 2-field PK, typical parent-child.

drop   table ovl;
create table ovl as 
select OWNER, TABLE_NAME, TABLESPACE_NAME, IOT_TYPE, IOT_NAME, NUM_ROWS, AVG_ROW_LEN, LAST_ANALYZED, STATUS
from all_tables order by dbms_random.value ;
create unique index ovl_pk on ovl ( owner, table_name );
alter table ovl add constraint ovl_pk primary key ( owner, table_name ) using index ovl_pk ;

select count (*) from ovl;

--
-- Notice: 
-- Just a table. 
-- Imagine a normal Parent-Child set of data.
--

accept press_enter prompt "press enter to continue..."


select owner, count (*) from ovl group by owner ;

--
-- Notice: 
-- Generally DBSMNP has 20-something tables... 
-- A small subset of the total. 
--
-- But when accessed by parent-key,
-- in the worst case we have 20-some times 
-- an index-by-rowid into the table...
-- 

accept press_enter prompt "press enter to continue..."


select 
		owner, tablespace_name, table_name  
	from	
		ovl
	where 	owner = 'DBSNMP'
	order   by 
		owner, table_name
/
select * from table(dbms_xplan.display_cursor(null,null,'BASIC LAST'));

--
-- Notice: 
-- Access seems efficient enough: index-scan, 
-- with expected low-percentage of table to be visited.
-- 

accept press_enter prompt "press enter to continue..."



set autotrace on stat
select 
		owner, tablespace_name, table_name  
	from	
		ovl
	where 	owner = 'DBSNMP'
	order   by 
		owner, table_name
/
set autotrace off

--
-- notice: 
-- the number of consistent gets...
-- for every entry in the index, we visit the table...
-- (Ora-jargon: this index has a bad clustering factor)
-- 

accept press_enter prompt "press enter to continue..."

--
-- now for something completely different: the IOT 
--

accept press_enter prompt "press enter to continue..."

drop table iot ;

CREATE TABLE IOT
(
  OWNER            VARCHAR2(30 BYTE)            NOT NULL,
  TABLE_NAME       VARCHAR2(30 BYTE)            NOT NULL,
  TABLESPACE_NAME  VARCHAR2(30 BYTE),
  IOT_TYPE         VARCHAR2(12 BYTE),
  IOT_NAME         VARCHAR2(30 BYTE),
  NUM_ROWS         NUMBER,
  AVG_ROW_LEN      NUMBER,
  LAST_ANALYZED    DATE,
  STATUS           VARCHAR2(8 BYTE),
constraint iot_pk primary key ( OWNER, TABLE_NAME )
)
organization index ;

insert into iot select * from ovl ;
commit ;

--
-- An IOT now contains the same data.
--
-- but the data is ORDERED by PK: OWNER and TABLE_NAME
--
-- that is notably handy if we are interested in 
-- Children of just one or just a few parents...
-- 

accept press_enter prompt "press enter to continue..."

select 
		owner, tablespace_name, table_name  
	from	
		iot
	where 	owner = 'DBSNMP'
	order   by 
		owner, table_name
/
select * from table(dbms_xplan.display_cursor(null,null,'BASIC LAST'));

--
-- notice: 
-- access is now via index scan PK, 
-- and via PK index ONLY  
-- although at least one column is not part of the PK.
-- But: ALL the data is stored in the PK!
-- 

accept press_enter prompt "press enter to continue..."


set autotrace on stat
select 
		owner, tablespace_name, table_name  
	from	
		iot
	where 	owner = 'DBSNMP'
	order   by 
		owner, table_name
/
set autotrace off

--
-- notice: 
-- the number of consistent gets...
-- it is even lower..
-- (this PK now has a GOOD clustering factor)
-- 

accept press_enter prompt "press enter to continue..."

-- 
-- Recap:
--  . IOTs more efficient then (overloaded PK) indexes.
--  . notably in parent-child table
--  . notably when required data is "grouped" by parent.
--
--

accept press_enter prompt "press enter to continue..."

-- ----------------- BONUS -----------------------
-- 
-- now for the BONUS feature:
-- IOT have other, secondary indexes, 
-- and those contain the PK!
--
-- note: compare normal OVL table to same qry on IOT.
--

accept press_enter prompt "press enter to continue..."


select iot_type, count (*) from ovl 
group by iot_type 
order by iot_type ;

--
-- notice:
-- relatively few IOTs and even less Overflow-segments.
-- 
-- suppose we investigate the overflow segments...
--

accept press_enter prompt "press enter to continue..."


select owner, table_name, iot_type, iot_name from ovl 
where iot_type = 'IOT_OVERFLOW'
/
select * from table(dbms_xplan.display_cursor(null,null,'BASIC LAST'));

-- 
-- That was a full-scan: no index on this property...
-- 

accept press_enter prompt "press enter to continue..."

set autotrace on stat
select owner, table_name, iot_type, iot_name from ovl 
where iot_type = 'IOT_OVERFLOW'
/
set autotrace off

--
-- notice: 
-- this qry scanned all buffers from the table.
-- but ... on large tables, 
-- a full scan is (almost) never a good idea. 
-- we may have to index some fields...
-- 

accept press_enter prompt "press enter to continue..."

create index ovl_ix1 on ovl ( iot_type, iot_name ) compute statistics ;

--
-- notice: 
-- an index on just two fields.
-- (from overload-demo: need 4 fields/index ?)
--

accept press_enter prompt "press enter to continue..."

select owner, table_name, iot_type, iot_name from ovl 
where iot_type = 'IOT_OVERFLOW'
/
select * from table(dbms_xplan.display_cursor(null,null,'BASIC LAST'));

-- 
-- now we seem to use an index on a normal table, 
-- but we still have to access both index and Table. 
-- 

accept press_enter prompt "press enter to continue..."

set autotrace on stat
select owner, table_name, iot_type, iot_name from ovl 
where iot_type = 'IOT_OVERFLOW'
/
set autotrace off

--
-- Notice: 
-- ... and how much blocks do we get?
-- We still go from-index-to-table for every row.
-- 
-- what if we did the same qry against the IOT...
--
--

accept press_enter prompt "press enter to continue..."


create index iot_ix1 on iot ( iot_type, iot_name ) compute statistics ;

--
-- same index on the two fields we are interested in.
--

accept press_enter prompt "press enter to continue..."


select owner, table_name, iot_type, iot_name from iot
where iot_type = 'IOT_OVERFLOW'
/
select * from table(dbms_xplan.display_cursor(null,null,'BASIC LAST'));

-- 
-- again we seem to use the index
-- but ... no table access ??
-- 

accept press_enter prompt "press enter to continue..."

set autotrace on stat
select owner, table_name, iot_type, iot_name from iot
where iot_type = 'IOT_OVERFLOW'
/
set autotrace off

--
-- notice: 
-- ... and we scanned even less blocks
-- 
--

accept press_enter prompt "press enter to continue..."

--
-- Recap of Bonus:
--  . 2ndary indexes on IOT can be even more efficient; 
--    they are overloaded with the PK values.
--
--  . A 2ndary index on IOT does not use ROWIDS,
--    instead, it contains PK values of target-record.
--    (and a row-guess, but that is an RTFM item...)
--


spool off
