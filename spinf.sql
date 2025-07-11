
/* 
  spinf.sql: the oracle, function version of spin.

  update: 
    allow broken numbers, for smaller intervals, precision
    allow sleep for milliseconds or microsec

*/

create or replace function spinf ( n_sec_run number )
  return number
AS
        dt_starttime    date ;
        i_counter       number ( 9,0) := 0;
        n_sec           number ;
        n_per_sec       number ;
BEGIN

    n_sec := n_sec_run ;
    -- dbms_output.put_line ( 'spinf: spinning for ' || n_sec || ' sec');

    dt_starttime := sysdate ;

    -- the actual loop
    WHILE (sysdate - dt_starttime) < n_sec / (24 * 3600)
    LOOP

        i_counter := i_counter + 1;

    END LOOP ;

    n_per_sec := i_counter / n_sec ;
    dbms_output.put_line ( 'spinf: ' || to_char (n_sec) || ' sec, '
           || to_char ( i_counter, '999,999,999.9') || ' loops, '
           || to_char ( n_per_sec , '999,999.999' ) || ' loops/sec.' );

   -- when function: return ;
  return n_per_sec ; 

END;
/
show errors


/* 
  new version, pretend nanosecond precision...
*/

create or replace function spinf_n ( n_sec_run number )
  return number
AS
        -- epoch precision, unit is still Seconds...
        now_ep          number ;
        end_ep          number ; 
        i_counter       number ( 9,0) := 0;
        n_per_sec       number ;
BEGIN

    -- dbms_output.put_line ( 'spinf_n: spinning for ' || n_sec || ' sec');

    now_ep :=   to_number ( '0' ) 
                + to_number ( 
                    to_char   (
                      (trunc ( sysdate ) - TO_date('1970-01-01', 'YYYY-MM-DD')) * 86400
                            ) )
                + to_number ( to_char (      systimestamp, 'SSSSS.FF9' ) )  ;

    now_ep := to_number ( 
                (trunc ( sysdate ) - TO_date('1970-01-01', 'YYYY-MM-DD')) * 86400
                        )
              + to_number ( to_char ( systimestamp, 'SSSSS.FF9' ) ) ;

    end_ep := now_ep + n_sec_run ; 

    -- dbms_output.put_line ( 'spinf_n, '
    --     || 'now_ep: ' || to_char ( now_ep, '9999999999.999999999' ) || ' sec, ' 
    --     || 'end_ep: ' || to_char ( end_ep, '9999999999.999999999' ) || ' sec.' ) ;

    -- the actual loop
    WHILE now_ep < end_ep 
    LOOP

        now_ep :=   to_number ( '0' ) 
                    + to_number ( 
                        to_char   (
                          (trunc ( sysdate ) - TO_date('1970-01-01', 'YYYY-MM-DD')) * 86400
                                ) )
                    + to_number ( to_char (      systimestamp, 'SSSSS.FF9' ) )  ;

        i_counter := i_counter + 1;

    END LOOP ;

    n_per_sec := i_counter / n_sec_run ;

    dbms_output.put_line ( 'spinf_n: ' || to_char (n_sec_run) || ' sec, '
           || to_char ( i_counter, '999,999,999.9') || ' loops, '
           || to_char ( n_per_sec , '999,999.999' ) || ' loops/sec.' );

   -- when function: return ;
  return n_per_sec ; 

END;
/
show errors

set timin on

select spinf ( 1 )        loops_p_sec from dual ; 
select spinf ( 3 )        loops_p_sec from dual ; 
select spinf_n ( 0.0005 ) loops_p_sec from dual ; 
select spinf_n ( 0.5 )    loops_p_sec from dual ; 
select spinf_n ( 2.5 )    loops_p_sec from dual ; 

