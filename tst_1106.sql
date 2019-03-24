

-- testing 1106 and VCP in general

/**** 

-- two index-entries: 
--    xtra1 : uses the dates to limit a set on VCP
--    vis_fk_arr_dept: uses the vis-id to enter: and selects too much when  R-dam

--drop index pcs.em_vcp_vis_fk_arr_dep_id_ind ;
create index pcs.em_vcp_vis_fk_arr_dep_id_ind
  on pcs.em_vessel_call_processes ( vis_id, arrival_time_drv, departure_time_drv, id )
  tablespace pcs_index online ;

-- s1. original, index on dates + vis_id + id: find all relevant link-ids via index
--drop index pcs.em_vcp_dates_xtra1 ;
create index pcs.em_vcp_dates_xtra1 on
  pcs.em_vessel_call_processes ( arrival_time_drv, departure_time_drv, vis_id, id )
  tablespace pcs_index ;

***/

Variable b1 varchar2;
Variable b10 NUMBER; 
Variable b11 VARCHAR2(32);
Variable b12 VARCHAR2(32);
Variable b13 VARCHAR2(32);
Variable b2 VARCHAR2(32); 
Variable b3 varchar2;
Variable b4 VARCHAR2(32);
Variable b5 NUMBER;      
Variable b6 varchar2;
Variable b7 VARCHAR2(32);
Variable b8 varchar2;
Variable b9 VARCHAR2(32);

now all varibles are declared, we will try to assign from cursor-0

BEGIN

--  b1 :=  to_timestamp ( '18-FEB-19 12.00.00.000000000 AM', 'YYYY-MM-DD HH24:MI:SS' )   ;
--  b10 := .9994  ;
  :b11 := 'NLRTM'  ;
  :b12 := 'VCP'  ; 
  :b13 := 'VE'  ; 
--  :b2 := 'DD'  ; 
--  :b3 :=  to_timestamp ( '04-MAR-19 12.00.00.000000000 AM', 'YYYY-MM-DD HH24:MI:SS' )   ;
--  :b4 := 'DD'  ; 
--  :b5 := .9994  ;
--  :b6 :=  to_timestamp ( '18-FEB-19 12.00.00.000000000 AM', 'YYYY-MM-DD HH24:MI:SS' )   ;
--  :b7 := 'DD'  ;
--  :b8 :=  to_timestamp ( '04-MAR-19 12.00.00.000000000 AM', 'YYYY-MM-DD HH24:MI:SS' )   ;
--  b9 := 'DD'  ;

END;
/

/* --                                                          */
/* -- Paste formatted statement here, followed by semicolon... */
/* --                                                          */
/* --   SQL goes HERE, with semicolon added!                   */
/* --                                                          */
/* -- use this file to run stmnt with variables defined above  */
/* -- SQL> @rerun_9dz4twussxjg7.lst                                      */
/* --                                                          */

set autotrace off


set timin on
set autotrace on
set linesize 120 

spool tst_nnnn

select count (*) from (
SELECT
    t0.id,
    t0.discriminator,
    t0.locked_ind,
    t0.process_id,
    t0.state,
    t0.version,
    t0.wrapper_class,
    t0.date_created,
    t0.date_modified,
    t0.sep_id,
    t1.id,
    t1.creation_date,
    t1.webservice_ind,
    t1.arrival_time_drv,
    t1.departure_time_drv,
    t1.state_drv,
    t1.ogn_id_delegate,
    t1.ogn_id_owner,
    t1.vis_id
FROM
    pcs.pil_visit t4,
    pcs.pil_ports t3,
    pcs.pil_locations t2,
    pcs.em_vessel_call_processes t1,
    pcs.pil_service_processes t0
WHERE
    ( ( ( ( ( ( t1.arrival_time_drv >= (systimestamp - 10) )
              AND ( t1.arrival_time_drv < ( systimestamp + 10)   ) )
            AND ( ( t1.departure_time_drv >= (systimestamp - 10 ) )
                  AND ( t1.departure_time_drv < ( ( systimestamp + 10 )  ) ) ) )
          AND ( t2.un_code = :b11 ) )
        AND ( ( t1.id = t0.id )
              AND ( t0.discriminator = :b12 ) ) )
      AND ( ( ( ( t4.id = t1.vis_id )
                AND t4.discriminator (+) = :b13 )
              AND ( t3.id = t4.por_id ) )
            AND ( t2.id = t3.loc_id ) ) )
ORDER BY
    t1.arrival_time_drv
)
;

set autotrace off

select t2.id, t2.un_code, t1.id, t1.creation_date
from pcs.pil_locations  t2
   , pcs.pil_ports      t3
   , pcs.pil_visit      t4
   , pcs.em_vessel_call_processes t1
where 1=1
  and  t4.discriminator (+) = 'VE' 
  and  t2.name like 'Rotter%'
  and  t2.un_code = 'NLRTM'
  and t2.id = t3.loc_id 
  and t3.id = t4.por_id
  and t4.id = t1.vis_id
  and  t1.arrival_time_drv >= (systimestamp - 10) 
  AND  t1.arrival_time_drv < ( systimestamp + 10)  
  ANd t1.departure_time_drv >= (systimestamp - 10 ) 
  AND  t1.departure_time_drv < ( systimestamp + 10 )
  order by t1.arrival_time_drv; 

set autotrace on

/

set autotrace off 

spool off

