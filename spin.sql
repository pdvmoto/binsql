
doc
	spin.sql : spin for &1 sec

  notes:
    - see spinf.sql for stored-function
    - race against pg. check spin/spinf in pg_scripts, pg = faster

#

-- set serveroutput on 

DECLARE 
  /* spin */ 
  dt_starttime	date ;
  i_counter       number ( 9,0) := 0;
  n_sec           number ( 9,0); 
  n_persec 	      number ;
BEGIN

  n_sec         := &1  ;
  dt_starttime  := sysdate ;

  -- the actual loop
  WHILE (sysdate - dt_starttime) < n_sec / (24 * 3600) 
  LOOP
      i_counter := i_counter + 1; 
  END LOOP ;

  n_persec := i_counter / n_sec ;
  dbms_output.put_line ( 'spin (pl/sql block): ' 
         || to_char ( n_sec ) || 'sec, ' 
         || to_char ( i_counter, '999,999,999.9') || ' loops, '
         || to_char ( n_persec , '999,999.999' ) || ' loops/sec.' );  

END ;
/
