
doc
	spin_utf8.sql : spin and insert utf8 chars

  notes:
    - try collect all UTF8 chars..
    - also check: https://chatgpt.com/c/696b884d-ffc0-8327-9647-328a2e7ea170
    - make sure the DB is UTF8

  The table is minimal, but has the dec + codepoint.
  Consider virtual column(s) for HEX 
  Consider UK and indexes on char and codepoint as well
  ( consider IOT...)
  Later: make re-startable by finding MAX, and continue from there.

-- drop table utf8_chars ;
create  table utf8_chars ( 
  dec_id     number   -- decimal. hex and bin can be derived, or virtual columns
, ucodepoint number   -- in decimal. the HEX can be a vertual column ?
, the_char   varchar2(1 char)
);

alter table utf8_chars add constraint utf8_chars_pk primary key ( dec_id) ;

#

set serveroutput on 

DECLARE 
  /* utf8 */ 
  dt_starttime	date ;
  i_counter       number ( 9,0) := 0;
  n_sec           number ( 9,0); 
  n_persec 	      number ;
  n_startpoint    number := 0 ; -- start from..
  n_nextstart     number ;
  n_maxint        number := power (2, 32) ; 
  n_incr          number ;
BEGIN

  n_sec         := &1  ;
  dt_starttime  := sysdate ;

  -- the actual loop
  WHILE (sysdate - dt_starttime) < n_sec / (24 * 3600) 
  LOOP

      -- first incr will be Zero..
      n_incr     := i_counter * (1024 * 1024 ) ;

      -- some optimization is possible.. only do the level+inc once?
      insert into utf8_chars ( dec_id, ucodepoint, the_char )
                        select dec_id, ucodepoint, the_char from
      ( select                         level + n_incr     as dec_id
             , utf8_int_to_codepoint ( level + n_incr )   as ucodepoint
             ,                   chr ( level + n_incr )   as the_char
        from dual connect by level <= ( 1024 * 1024 )
      )  lvl
      where is_valid_utf8_int ( dec_id ) = 1 ;

      i_counter  := i_counter + 1; 
      commit ;  -- exceptionally, commit inside loop, monitor progres...

  END LOOP ;

  n_persec := i_counter / n_sec ;
  dbms_output.put_line ( 'spin_utf8 (pl/sql block): ' 
         || to_char ( n_sec ) || 'sec, ' 
         || to_char ( i_counter, '999,999,999.9') || ' loops, '
         || to_char ( n_persec , '999,999.999' ) || ' loops/sec.' );  

  dbms_output.put_line (
    'spin_utf8: max was : ' || to_char ( n_incr, '999,999,999,999' )  || '.' 
    );
END ;
/
