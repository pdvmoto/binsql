
/* 
  file.sql: -- test some where clauses on enums

  requirements: demo_enum.sql and demo_enum_4select.sql to prepare objects.

  todo:
    - make the Case visable ! need autotrace on explain instead of display
    - check between versions 23.5 and 23.6
    - check notably the describe and the info-results: does it show number?
    - add difference in desc from sqlplus ? 
    - recommend SQLcl...
    - 

  docu on domain_display: 
https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/domain_display.html


*/


column id         format 999999
column color_disp format A20
column roman_disp format A20

set sqlformat default
set linesize 120
set autotrace  off
set timing off

drop table if exists tcolors ; 
drop index if exists data_enum_fbi_roman ; 

set echo on

-------- start here.  -------- 

create table tcolors (
  id      number  not null primary key
, color   color_enum
);

create index tcolors_idx_col on tcolors ( color ) ;

--
-- Created the table that uses the color-DOMAIN for LoV and Check-constraint.
-- Out of habit, created on index on the color-column already
-- It is kind of an FK, after all. Someone may want to search on it.
-- 
set echo off
pause hit_enter_to_continue

set echo on

info tcolors 

-- The INFO-command shows the table-definition, 
-- the column COLOR has both Number and domain.
-- 
set echo off
pause hit_enter_to_continue
set echo on

-- Let's try some inserts. 
-- We can use the enum-definitions (as constants)
-- or just insert numbers.

insert into tcolors values 
  ( 1, color_enum.red ) 
, ( 2, color_enum.orange ) 
, ( 3, color_enum.yellow ) 
, ( 4, color_enum.GREEN ) 
, ( 5, color_enum.Blue ) 
, ( 6, color_enum.indigo ) ;

insert into tcolors values 
  ( 7, 7 ) /* I happen to know: 7=Violet */  ; 

commit ; 

--
-- that went well. We can insert constants or numbers
--
set echo off
pause hit_enter_to_continue
set echo on
 
--
-- this wont work, the enum does not have a value "purple"
--

insert into tcolors values ( 16, color_enum.purple ) ;

--
-- A non-existant value for the enum: error msg is a bit weird...? 
--
set echo off
pause hit_enter_to_continue
set echo on

--
-- try a numeric value which is out of range..
--
insert into tcolors values ( 18, 8 ) ;

--
-- An invalid (numeric) value for the color: 
-- More Infomative Error refers to "check constraint".
-- 
-- Notice the ENUM acts both as a LoV "check" constraint 
-- and as a set of constants we can use in code.
--

set echo off
pause hit_enter_to_continue
set echo on

-- just a quick select to verify what went into the table...

select c.*, domain_display ( c.color ) from tcolors c order by c.color;

-- Notice: 
-- 1. The two actual colums of the table come out as numbers.
-- 2. We need the domain-display to see the "meaning" of the color-nrs.
-- 
set echo off
pause hit_enter_to_continue
set autotrace on explain
set echo on

--
-- Numer-type columns and domain_display have consequences. 
-- If we want to select on the color using the "name"... 
--

select t.*, domain_display ( t.color )
  from tcolors t 
where domain_display ( t.color ) Like 'RED%' ;

set echo off
set autotrace off
-- set feedback off
-- select * from table(dbms_xplan.display_cursor(null, null, 'BASIC')) ;
-- set feedback on
set echo on

--
-- Searching for the string-value 'RED' we can not use the (numeric) index.
-- And we also get a peek inside the domain: it uses CASE-stmnt internally.
--
set echo off
pause hit_enter_to_continue
set echo on

select t.*, domain_display ( t.color )  
  from tcolors t 
where t.color in ( color_enum.Red, 7 ) ; 

set echo off
set feedback off
select * from table(dbms_xplan.display_cursor(null, null, 'BASIC')) ;
set feedback on
set echo on

-- 
-- We can either use a constant from the domain, or an actual Number,
-- both will result in use of the (numeric) index on the column.
--

set echo off
pause hit_enter_to_continue
set echo on

--
-- As with most functions, you can consider a Function-Based-Index.
-- And that works fine:
--

create index tcolors_col_fbi on tcolors ( domain_display ( color ) ) ; 

select t.*, domain_display ( t.color )
  from tcolors t 
where domain_display ( t.color ) Like 'RED%' ;

set echo off
set feedback off
select * from table(dbms_xplan.display_cursor(null, null, 'BASIC')) ;
set feedback on
set echo on

--
-- With an FBI, search for the string-value 'RED' can use an Index. 
-- But you have to decide for yourself if you want or need the extra Index.
--
set echo off
pause hit_enter_to_continue
set echo on

--
-- now for one more Excotic query, just bcse we can..
-- as with a traditional LoV table, you can join the DOMAIN 
-- and use the domain to translate RED into the nr 1...
--

set echo on

select t.*, domain_display ( t.color )
  from tcolors t 
     , color_enum c
where c.enum_value =   t.color
  and c.enum_name  like 'RED%' ;

set echo off
set feedback off
select * from table(dbms_xplan.display_cursor(null, null, 'BASIC')) ;
set feedback on
set echo on

--
-- With a join to (the view of) the domain, you can make it as as LoV 
-- if you like excotic, or "Classic"  constructs, be my guest...
--
pause hit_enter_to_continue

-------------------------------------------------------
prompt "--------- below is old ----- "
pause abc

quit 


desc data_enum

--
-- desc show columns, but in old sqlplus: no domain.
--

info data_enum 

--
-- sqlcl-info: show more complete info.
-- notice indexes on both enum columns: roman and color, 
-- as they are similar to FK, I consider it good practice to index them.
set echo off
prompt 
accept hit_enter prompt "-- Check the definitions..."

alter system flush shared_pool ;

set autotrace on explain
set echo on

-- first execute, ignore parse, just show plan

select d.* 
  from data_enum d
 where d.color_id = 7 
   and rownum < 4;

set echo off
prompt 
accept hitenter prompt "Just some rows. Check Basic plan,..."
set autotrace on stat
set echo on

l
/

set echo off
set autotrace off

--
-- look Fine: using index? reasonable stats ?
-- 
-- next try with color_enum.yellow
-- mixing capitals for good measure
--
accept hit_enter prompt "next is using constants ... "

set autotrace on explain
set echo on

select * from data_enum d
where d.color_id = color_enum.Yellow 
  and rownum < 4
;

set echo off
set autotrace off
prompt 
prompt "Using domain-values as constants, basic plan."
prompt "Note that the system knows for Yellow => ID=3"
prompt
prompt "And then it also filters the limits 1 and 7, "
prompt "Is that bcse the color_id must fall inside the valid range ? "
prompt 
accept hitenter prompt "Next, Also check the stats ..."

set autotrace on stat
set echo on

l
/

set echo off
set autotrace off

--
-- using the enum as a constant seems to work, and using the index
-- but in the result-set, we do not see the domain-description yet.
--
-- showing the description requires the domain_display ()
--
accept hit_enter prompt "Next is display of domain values, ..."

set autotrace on explain
set echo on

select d.id, d.color_id, d.roman_id
, domain_display ( d.color_id ) as color_disp 
, domain_display ( d.roman_id ) as roman_disp 
from data_enum d
where d.color_id = color_enum.yeLLow
  and rownum < 4
-- order by d.id -- use order-by to get some diversity
;

set echo off
set autotrace off
prompt 
accept hit_enter prompt "Now showing the display values, still using index?..."

set autotrace on stat
set echo on

l
/

set echo off
set autotrace off
prompt 
prompt 
accept hit_enter prompt "Display Domain values, Stats should still be same.."
set autotrace off
 
-- 
-- so far all is good. we can use the enums as "constants"
--
-- now some things to avoid.
-- 
-- we know the color_id = 3 represents Yellow, 
-- and displays as YELLOW (capitals).
-- 
-- 

-- Would this work :
-- 
set echo on

select domain_display ( 3 ) as "yellow?" from dual ; 

set echo off

-- evidently Not. But also: No Error...
--
-- because the domain_display function has no clue which domain to use.
-- That function only works on a column or expression 
-- which is associated with the domain. Then it know Where to Look.
--

-- now some where-clause

set autotrace on explain
set echo on

select d.*, domain_display ( d.roman_id ) 
from data_enum d
where domain_display ( d.roman_id ) = 'XLII'
;

set echo off
prompt 
prompt "This was more or less predictable, it is a Function."
prompt "But also note how the domain-display works. CASE-stmnt"
prompt
accept hit_enter prompt "..."
set autotrace on stat

l
/

set echo off
set autotrace off
prompt
prompt "Check the statistics, clearly no index used."
prompt 
accept hit_enter prompt "Would and F B I  help ? ..."
set echo on

create index data_enum_fbi_roman on data_enum ( domain_display ( roman_id ) ) ;

set echo off
set autotrace off
prompt
prompt "Created Function Based Index (FBI)."
prompt 
accept hit_enter propmpt "Re-try the Query..."
set autotrace on explain

set echo on

select d.*, domain_display ( d.roman_id ) 
from data_enum d
where domain_display ( d.roman_id ) = 'XLII'
and rownum < 4
;

set echo off
prompt 
prompt "Yep, a function, and can be indexed."
accept hit_enter prompt "..."

set autotrace on stat
set echo on

l
/

set echo off
set autotrace off
prompt 
prompt "and with the FBI, the plan is Efficient again."
prompt 
pause "That concludes the where-clause demo for the moment..."

set doc on

prompt 
prompt "I'd like to point out several things: "
prompt 
prompt "- The values in the domain-column are numeric, in this (default-)case!"
prompt "- The enum_value can be used as a Constant in your code."
prompt "- Display of the descriptive values needs call to domain_display ()."
prompt "- Domain_display () behaves like any other funcitons in where-clauses."
prompt "- The display-function seems to use a CASE-stmnt."
prompt 
prompt "Also note: I do not categorically advise to use an FBI on enum-columns."
prompt 

#

set doc off


-- 
-- 
set echo off

accept hit_enter prompt "-- -- -- -- -- end of script ..."

