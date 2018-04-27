
doc
	spin.sql : spin for &1 sec

  notes:
    - see spinf.sql for stored-function
    - race against pg. check spin/spinf in pg_scripts, pg = faster

#

DECLARE 
	dt_starttime	date ;
        i_counter       number ( 9,0) := 0;
        n_sec           number ( 9,0); 
        n_persec 	number ;
BEGIN

    n_sec := &1 ;
    dbms_output.put_line ( 'spin (oracle, block): spinning for ' || n_sec || ' sec'); 

    dt_starttime := sysdate ;

    -- the actual loop
    WHILE (sysdate - dt_starttime) < &1 / (24 * 3600) 
    LOOP

        i_counter := i_counter + 1; 

    END LOOP ;

    n_persec := i_counter / n_sec ;
    dbms_output.put_line ( 'spin (oracle, block): seconds ' || to_char (n_sec)
           || ' exec: ' || to_char ( i_counter, '999,999,999.9')
           || ' exec/sec: ' || to_char ( n_persec , '999,999.999' ) || '.' );  

   -- when function: return ;
END ;
/

