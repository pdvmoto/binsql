
--SELECT plan_table_output FROM table(DBMS_XPLAN.DISPLAY_CURSOR (''))

--select * from table(dbms_xplan.display_cursor('',null,'BASIC'))
select * from table(dbms_xplan.display_cursor(null, null, 'BASIC'))
/
