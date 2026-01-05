
-- check create-times of db and objects

column name format A33 
column dbid format 9999999999 

column earlies  format A20
column latest  format A20
column db_created  format A20

alter session set NLS_DATE_FORMAT = 'yyyy-MM-dd HH24:MI:SS' ;

-- earliest and latest..
select min ( ctime) earliest, max(ctime) latest
, min ( mtime) earliest, max(mtime) latest
from sys.obj$;

select to_char ( d.created, 'YYYY-MON-DD HH24:MI:SS' ) db_created 
, d.name 
, d.dbid
--, d.*
from v$database d ;

-- early objects
select o.ctime earliest, o.name 
--, o.*
from sys.obj$ o
where o.ctime = ( select min ( m.ctime ) from sys.obj$ m );

-- early objects
select o.ctime latest, o.name 
--, o.*
from sys.obj$ o
where o.ctime = ( select max ( m.ctime ) from sys.obj$ m );


