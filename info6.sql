

COLUMN	owner		FORMAT A10
COLUMN	name		FORMAT A18
COLUMN	created		FORMAT A10
COLUMN	last_ddl	FORMAT A10
COLUMN	type		FORMAT A3
-- COLUMN	max_ext		FORMAT 999999
COLUMN  ext         FORMAT 999
COLUMN  maxt      	FORMAT 9999
COLUMN  kb_used     FORMAT 999999
COLUMN  kb_init     FORMAT 999999
COLUMN  kb_next     FORMAT 999999
COLUMN	t_space		FORMAT A10


DOC
	Biggest segments (top 10), ordered by size (kb)
#

rem really needed pl/sql here to fetch top-10 records, 
rem preferred pl/sql-parsing over potentially large create-table,
rem sorry.

set serveroutput on

declare 
    cursor c1 is
    SELECT  	rpad ( substr ( owner			, 1, 10 ), 10 )	--  owner
    || ' ' || 	rpad ( substr ( segment_name	, 1, 18 ), 18 ) --	name
    || ' ' ||          SUBSTR ( segment_type	, 1,  3 )    	-- 	type
    || ' ' || 	rpad ( substr ( tablespace_name, 1,  7 ),  7 ) 	--	t_space
    || ' ' || 	to_char ( bytes 			/ 1024, '999999' ) 	-- 	kb_used
    || ' ' || 	to_char ( initial_extent 	/ 1024, '999999' )  -- 	kb_init
    || ' ' || 	to_char ( next_extent 		/ 1024, '999999' )  --  kb_next
    || ' ' || 	to_char ( extents  				  , '9999' )    --  ext
    || ' ' || 	to_char ( max_extents 			  , '9999' )  as text --	maxt
    FROM sys.dba_segments
    WHERE 1 = 1 
    ORDER BY bytes desc;

	c_result 	 c1%rowtype ;
	vc2_text		varchar2 (80) ;
	
begin
	-- heading, max 80!
	dbms_output.put_line ( '. ' );
	vc2_text :=
	'owner      segment            type tabspc      Kb    init    next   ext  maxt';
	dbms_output.put_line ( vc2_text );
	vc2_text :=
	'-----------------------------------------------------------------------------';
	dbms_output.put_line ( vc2_text );
	
	open c1;

	fetch c1 into vc2_text ;
		
	while 	(		(c1%found			)
		 	and 	(c1%rowcount < 10 	)
		 	) 
	loop
	
		dbms_output.put_line ( vc2_text );
		fetch c1 into vc2_text ;
	
	end loop ;

	close c1;
	dbms_output.put_line ( '. ' );
end;
/

doc
	Most fragmented segments (top 10), ordered by nr of extents
		These segments have grown outside their storage definition.
	
		note on SYS segments: do not be alarmed if < 20 ext.
#


declare 
    cursor c1 is
    SELECT  	rpad ( substr ( owner			, 1, 10 ), 10 )	--  owner
    || ' ' || 	rpad ( substr ( segment_name	, 1, 18 ), 18 ) --	name
    || ' ' ||          SUBSTR ( segment_type	, 1,  3 )    	-- 	type
    || ' ' || 	rpad ( substr ( tablespace_name, 1,  7 ),  7 ) 	--	t_space
    || ' ' || 	to_char ( bytes 			/ 1024, '999999' ) 	-- 	kb_used
    || ' ' || 	to_char ( initial_extent 	/ 1024, '999999' )  -- 	kb_init
    || ' ' || 	to_char ( next_extent 		/ 1024, '999999' )  --  kb_next
    || ' ' || 	to_char ( extents  				  , '9999' )    --  ext
    || ' ' || 	to_char ( max_extents 			  , '9999' )  as text --	maxt
    FROM sys.dba_segments
    WHERE 1 = 1 
    ORDER BY extents desc;

	c_result 	 c1%rowtype ;
	vc2_text		varchar2 (80) ;
	
begin
	-- heading, max 80!
	dbms_output.put_line ( '. ' );
	vc2_text :=
	'owner      segment            type tabspc      Kb    init    next   ext  maxt';
	dbms_output.put_line ( vc2_text );
	vc2_text :=
	'-----------------------------------------------------------------------------';
	dbms_output.put_line ( vc2_text );
	
	open c1;

	fetch c1 into vc2_text ;
		
	while 	(		(c1%found			)
		 	and 	(c1%rowcount < 10 	)
		 	) 
	loop
	
		dbms_output.put_line ( vc2_text );
		fetch c1 into vc2_text ;
	
	end loop ;

	close c1;
	dbms_output.put_line ( '. ' );
end;
/

doc
	Segments close to maximum extents
		These segments may soon reach their growth limit!
#

set feedback on

SELECT  sys.dba_segments.owner          owner
     , segment_name                     name
     , SUBSTR ( segment_type, 1, 3 )    type
     , substr ( tablespace_name, 1, 7 )	t_space
     , bytes / 1024                     kb_used
     , initial_extent / 1024            kb_init
     , next_extent / 1024               kb_next
     , extents                          ext
     , max_extents 						maxt
FROM sys.dba_segments
WHERE 1 = 1 
and   ( (extents * 100 ) / max_extents ) >  75
and segment_type <> 'CACHE' -- cache always 1 ext, and zero maxextents!
ORDER BY ext desc
/