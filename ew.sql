
/* 
  file.sql: -- test some where clauses on enums

  requirements: demo_enum_4select.sql to prepare table.

  todo:
    - check between versions 23.5 and 23.6
    - check notably the describe and the info-results: does it show number?
    - add difference in desc from sqlplus ? 
    - recommend SQLcl...
    - 

  docu on domain_display: 
https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/domain_display.html


*/


--alias showplan=select * from table(dbms_xplan.display_cursor());
  alias showplan=select * from table(dbms_xplan.display_cursor('',null,'BASIC'));

column id         format 999999
column color_disp format A20
column roman_disp format A20

set doc on
set linesize 120
set timing off
set doc on

drop index if exists data_enum_fbi_roman ; 

set echo on

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

