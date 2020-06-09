

-- checks.sql: various numbers and checks on a database


-- report which datbase

-- part-1 : users
-- list users, locked/expired
-- nr of objects per user
-- top-10 users with most tables
-- top-10 users with most pl/sql (p/f/pkg)


-- part-2 : size, GB
-- size: tablespaces (old info02)
-- size: gb per user.
-- top-5 GB users
-- top-10 large objects
-- top-10 large tables (excluding lobs)
  
-- part-3 : qa datamodel
-- qa: see script chk_data_mature.sql (works on 5 defined schemas)
-- qa: tables without PK/UK
-- qa: tables without index at all.
-- qa: tables without relations
-- qa: tables without dependencies (e.g. no views, no plsql)
-- qa: check col-names versus data-types (dates/nrs in varchars)

-- part-4 : counts
-- qa: add script to store all table-counts (do_count_tabs.sql)
-- placeholder: mk_count (the early primitive version)

-- part-5 : empties
-- qa: see script find_empties.sql, list empty tables, determine usage.


-- todo list:..
-- count-script (the mk_count and do_count are too primitive)
-- formatting
-- exclude system-users on many SQL
--

#


column database    format A10
column instance    format A8   head curr_inst
column created     format a21
column arch        format a6
column role        format a8
column prot_mode   format A8
column prot_level  format a8  wrap  
column hostname    format a20
column started     format a21
column instance    format a8 head instance

set feedb off

select d.name       				  as database
, i.instance_name 				  as instance
, to_char ( d.created, 'YYYY-MON-DD HH24:MI:SS' ) as created
, substr ( d.log_mode, 1, 5)                      as arch
, substr ( d.database_role, 1, 7 )                as role
,           substr ( d.protection_mode, 1, 3) 
  || ' ' || substr ( d.protection_mode, 9, 4)     as prot_mode
, substr ( d.protection_level, 1, 6 )             as prot_level
from gv$database  d
   , gv$instance  i ;



select i.instance_name                                 as instance
, i.host_name						as hostname
, to_char ( i.startup_time, 'YYYY-MON-DD HH24:MI:SS' ) as started
, i.status
, count (*) as sessions
from gv$instance i
   , gv$session s
where i.inst_id = s.inst_id
group by i.instance_name, i.host_name, i.startup_time, i.status
order by 1, 2, 3 ;

rem CDB/PDB
column con_id format A10
column con_name format A20

select 
  sys_context('USERENV', 'CON_ID') as con_id, 
  sys_context('USERENV', 'CON_NAME') as con_name 
from dual ; 

-- need a blank line...
prompt
-- select '' from dual;

set feedb on

set pagesize 50
set linesize 80

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- part-1 : users
-- list users, locked/expired
-- nr of objects per user
-- top-10 users with most tables
-- top-10 users with most pl/sql (p/f/pkg)


column user_id format 99,999,999,999
column username format A15 
column default_tablespace format A10
column temporary_tablespace format A10
column local_temp_tablespace format A10
column account_status format A17


prompt 'Total users in this DB.'
prompt '(note Oracle will have about 35 dflt users already)


select count (*) 	|| ' users defined in the database.' as Total_users
from  sys.dba_users
/


select username, user_id
, default_tablespace 
, temporary_tablespace
-- , local_temp_tablespace
, account_status
from dba_users 
order by username 
/

column expires format A20

prompt List of users about to expire

-- list of users about to expire or grace
select username
-- , local_temp_tablespace
, account_status
, to_char ( expiry_date, 'YYYY-MON-DD' ) expires
from dba_users
where expiry_date < (sysdate + 64 ) 
--and   expiry_date > sysdate 
order by username
/

-- list of users locked or expired
select username
, account_status
, to_char ( expiry_date, 'YYYY-MON-DD' ) expires
from dba_users
where account_status != 'OPEN'
order by username
/


column owner       format A15
column nr_objects  format 99999
column object_type format A15

set heading on

-- total objects per owne..
select owner, count (*)    nr_objects
from  sys.dba_objects
group by owner
order by owner
/


break on owner
 
select owner, object_type, count (*)    nr_objects
from  sys.dba_objects
group by owner, object_type
order by owner, object_type
/

clear breaks


-- top-10s.. most tables,most plsql

column nr_tables format 99999 

prompt Top-10 users with many tables

select owner, count (*) nr_tables
from dba_tables
group by owner
order by 2 desc
fetch first 10 rows only
;

column nr_plsql_objects format 999999

prompt Top-10 users with many tables

select owner, count (*) nr_plsql_objects
from dba_objects
where object_type in ('PACKAGE', 'PROCEDURE', 'FUNCTION' )
group by owner
order by 2 desc
fetch first 10 rows only
;


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- next is size, part-2


doc
	Sizing info: Sizes and Gb usage of tablespaces
#

set heading on
set feedback off
set lines 80

column	tablespace_name format a30
column	gbfree		format 99999999999
column	gbused		format 99999999999
column	gbktotal	format 99999999999
column	perc_free	format 999.99

select  ts.tablespace_name 
     , df.free gbFree 
     , ts.total - df.free as gbused
     , ts.total gbtotal
     , 100 * (df.free) / ts.total perc_free
from ( select sum ( t.bytes /( 1024*1024*1024 )) total, t.tablespace_name tablespace_name  
       from dba_data_files t
       group by t.tablespace_name ) ts
   , ( select sum ( f.bytes / ( 1024*1024*1024)) free, f.tablespace_name
       from dba_free_space f
       group by f.tablespace_name ) df
where df.tablespace_name = ts.tablespace_name       
order by 1 ;

set head off

column	sgbfree		format 99999999999
column	sgbused		format 99999999999
column	sgbtotal	format 99999999999
column	sperc_free	format 99.99 head perc_free

select '                               '||'------------'||' '||'------------'||' '||'------------'||' '||'---------' from dual;
select '                        Total:', sum ( gbfree) sgbfree
,sum(gbused) skfree, sum(gbTotal) skused, 100* sum(gbfree) / sum(gbTotal) sPerc_free 
from
(
select  ts.tablespace_name 
     , df.free gbFree 
     , ts.total - df.free as gbused
     , ts.total gbtotal
from ( select sum ( t.bytes /( 1024*1024*1024 )) total, t.tablespace_name tablespace_name  
       from dba_data_files t
       group by t.tablespace_name ) ts
   , ( select sum ( f.bytes / ( 1024*1024*1024)) free, f.tablespace_name
       from dba_free_space f
       group by f.tablespace_name ) df
where df.tablespace_name = ts.tablespace_name        )
;

set heading on
set feedback on
clear columns

prompt

prompt next: usage per schema, in KB for better presision

-- beware : KiloBytes per user and per user-tablespace

col owner      format a15
col username   format a30
col tablespace format a20
col kb_used    format 9999999999

select d.owner                    -- as username
,      sum(blocks*v.value/(1024)) as kb_used
from dba_segments d
,    v$parameter  v
where v.name='db_block_size'
group by d.owner
order by owner
;

select 
       d.tablespace_name          as tablespace
,      sum(blocks*v.value/(1024)) as kb_used
from dba_segments d
,    v$parameter  v
where v.name='db_block_size'
group by d.tablespace_name
order by tablespace_name
;

doc

	The number of Kb per User per Tablespace.
#

col username   format a30
col tablespace format a20
col kb_used    format 9999999999

select d.owner                    -- as username
,      d.tablespace_name          as tablespace
,      sum(blocks*v.value/(1024)) as kb_used
from dba_segments d
,    v$parameter  v
where v.name='db_block_size'
group by d.owner, d.tablespace_name
order by tablespace_name, owner
;

set feedback on
prompt


-- part-2, Top-users
-- top-5 GB users
-- top-10 large objects
-- top-10 large tables (excluding lobs)

prompt Top-5 biggest Schemas

select d.owner                    -- as username
,      sum(blocks*v.value/(1024)) as kb_used
from dba_segments d
,    v$parameter  v
where v.name='db_block_size'
group by d.owner
order by 2 desc
fetch first 5 rows only
;

prompt Top-15 biggest Segments


doc

	Biggest segments Top 15, ordered by size (Kb)
#

column	owner	format a10
column	name	format a18
column	created	format a10
column  ext     format 999
column  maxt    format 9999
column  kb_used format 9999999
column  kb_init format 9999999
column  kb_next format 999999
column	t_space	format a10
column	type	format a1

set feedback off
set serveroutput on

declare 
    cursor c1 is
    SELECT  	rpad ( substr ( owner			, 1, 10 ), 10 )	     -- owner
    || ' ' || 	rpad ( substr ( segment_name	, 1, 18 ), 18 ) 	     -- name
    || ' ' ||          SUBSTR ( segment_type	, 1,  1 )    		     -- type
    || ' ' || 	rpad ( substr ( tablespace_name, 1,  7 ),  7 ) 		     -- t_space
    || ' ' || 	to_char ( bytes 		/ 1024, '999999999' )        --	kb_used
    || ' ' || 	to_char ( initial_extent 	/ 1024, '99999999' )  	     --	kb_init
    || ' ' || 	NVL(to_char ( next_extent 		/ 1024, '99999999' ), '         ') -- kb_next
    || ' ' || 	to_char ( extents  				  , '999' )  -- ext
    || ' ' || decode(max_extents,'2147483645',' UNL', to_char(max_extents, 999) ) as text -- maxt
    FROM sys.dba_segments
    WHERE 1 = 1 
    ORDER BY bytes desc;

    cursor c2 is
    SELECT  	rpad ( substr ( owner			, 1, 10 ), 10 )	     -- owner
    || ' ' || 	rpad ( substr ( segment_name	, 1, 18 ), 18 ) 	     -- name
    || ' ' ||          SUBSTR ( segment_type	, 1,  1 )    		     -- type
    || ' ' || 	rpad ( substr ( tablespace_name, 1,  7 ),  7 ) 		     -- t_space
    || ' ' || 	to_char ( bytes 		/ 1024, '999999999' )        --	kb_used
    || ' ' || 	to_char ( initial_extent 	/ 1024, '99999999' )  	     --	kb_init
    || ' ' || 	NVL(to_char ( next_extent 		/ 1024, '99999999' ), '         ') -- kb_next
    || ' ' || 	to_char ( extents  				  , '999' )  -- ext
    || ' ' || decode(max_extents,'2147483645',' UNL', to_char(max_extents, 999) ) as text -- maxt
    FROM sys.dba_segments
    WHERE 1 = 1 
      AND segment_type not like 'LOB%'
    ORDER BY bytes desc;

	c_result 	 c1%rowtype ;
	c2_result 	 c2%rowtype ;
	vc2_text		varchar2 (80) ;
	
begin
	-- heading, max 80!
	dbms_output.put_line ( '. ' );
	vc2_text :=
	'owner      segment         type tabspc          Kb      init      next  ext  max';
	dbms_output.put_line ( vc2_text );
	vc2_text :=
	'--------------------------------------------------------------------------------';
	dbms_output.put_line ( vc2_text );
 
	
	open c1;

	fetch c1 into vc2_text ;
		
	while 	(		(c1%found			)
		 	and 	(c1%rowcount < 16 	)
		 	) 
	loop
	
		dbms_output.put_line ( vc2_text );
		fetch c1 into vc2_text ;
	
	end loop ;

	close c1;

	dbms_output.put_line ( '. ' );

    -- and the non-LOBs	

    dbms_output.put_line ( '-- excluding the LOB segments ---- ' ) ; 

	open c2;

	fetch c2 into vc2_text ;
		
	while 	(		(c2%found			)
		 	and 	(c2%rowcount < 16 	)
		 	) 
	loop
	
		dbms_output.put_line ( vc2_text );
		fetch c2 into vc2_text ;
	
	end loop ;

	close c2;

end;
/

