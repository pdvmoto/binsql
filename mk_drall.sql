
set pagesize 250
set linesize 200
set feedback off
set heading off
set echo off

spool drall.lst

-- first disable constraints
select ' alter table ' || table_name 
|| ' drop constraint ' || constraint_name || ';'
from user_constraints
where constraint_type = 'R'
/

-- first drop pass: plsql code
select 'drop ' ||  object_type  
|| ' ' || object_name || ';' 
from user_objects 
where object_type in (  /*'TRIGGER', */ 
  'PROCEDURE', 'PACKAGE', 'PACKAGE BODY', 'FUNCTION'
, 'SEQUENCE'
)
order by object_type
/

-- second drop pass: types
select 'drop ' ||  object_type  
|| ' ' || object_name || ';' 
from user_objects 
where object_type in ( 'TYPE' )
order by object_type
/

-- final drop phase: tables, indexes.
select 'drop ' ||  object_type  
|| ' ' || object_name || ';' 
from user_objects 
where object_type in ( 'TABLE' )
order by object_type
/

spool off

-- show what goes on...
set echo on
set feedb on

-- now call the generated sript
-- @drall.lst

