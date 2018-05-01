doc
	info06.sql

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

	c_result 	 c1%rowtype ;
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
end;
/


doc
	info06.sql section 2

	Most fragmented segments Top 15, ordered by nr of extents
		These segments have grown outside their storage definition.
	
		note on SYS segments: do not be alarmed if < 20 ext.
#


declare 
    cursor c1 is
    SELECT  	rpad ( substr ( owner			, 1, 10 ), 10 )	     -- owner
    || ' ' || 	rpad ( substr ( segment_name	, 1, 18 ), 18 ) 	     --	name
    || ' ' ||          SUBSTR ( segment_type	, 1,  1 )    		     -- type
    || ' ' || 	rpad ( substr ( tablespace_name, 1,  7 ),  7 ) 		     --	t_space
    || ' ' || 	to_char ( bytes 		/ 1024, '999999999' ) 	     -- kb_used
    || ' ' || 	to_char ( initial_extent 	/ 1024, '99999999' )  	     -- kb_init
    || ' ' || 	NVL(to_char ( next_extent 		/ 1024, '99999999' ), '         ') -- kb_next
    || ' ' || 	to_char ( extents  		      , '999' )    	     -- ext
    || ' ' || 	decode(max_extents,'2147483645',' UNL', to_char(max_extents, 999) )  as text -- maxt
    FROM sys.dba_segments
    WHERE 1 = 1 
    ORDER BY extents desc;

	c_result 	 c1%rowtype ;
	vc2_text		varchar2 (80) ;
	
begin
	-- heading, max 80!
	dbms_output.put_line ( '. ' );
	vc2_text :=
	'owner      segment         type   tabspc        Kb      init      next  ext  max';
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
end;
/


doc
	info06.sql section 3

	Segments close to maxextents (> 75%)
		These segments may soon reach their growth limit!
#

set feedback on

select  sys.dba_segments.owner          owner
     , segment_name                     name
     , substr ( segment_type, 1, 1 )    type
     , substr ( tablespace_name, 1, 7 )	t_space
     , bytes / 1024                     kb_used
     , initial_extent / 1024            kb_init
     , next_extent / 1024               kb_next
     , extents                          ext
     , max_extents 			maxt
from sys.dba_segments
where 1 = 1 
and   ( (extents * 100 ) / max_extents ) >  75
and segment_type <> 'CACHE' -- cache always 1 ext, and zero maxextents!
order by ext desc
/

clear columns
prompt
