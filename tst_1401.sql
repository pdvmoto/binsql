
Variable b1 varchar2;                                                          
Variable b10 NUMBER;                                                            
Variable b11 NUMBER;                                                            
Variable b12 VARCHAR2(128);                                                     
Variable b13 VARCHAR2(32);                                                      
Variable b14 VARCHAR2(128);                                                     
Variable b15 VARCHAR2(32);                                                      
Variable b16 VARCHAR2(32);                                                      
Variable b17 VARCHAR2(32);                                                      
Variable b18 VARCHAR2(32);                                                      
Variable b19 VARCHAR2(32);                                                      
Variable b2 VARCHAR2(32);                                                       
Variable b20 VARCHAR2(32);                                                      

Variable b3 varchar2;                                                          
Variable b4 VARCHAR2(32);                                                       
Variable b5 NUMBER;                                                             
Variable b6 varchar2;                                                          
Variable b7 VARCHAR2(32);                                                       
Variable b8 varchar2;                                                          
Variable b9 VARCHAR2(32);                                                       

now all varibles are declared, we will try to assign from cursor-0

BEGIN

  -- :b1 :=  to_timestamp ( '17-FEB-19 12.00.00.000000000 AM', 'YYYY-MM-DD HH24:MI:SSXFF' )   ;                                                                       
                                                                                
  :b10 := .9994  ;                                                              
  :b11 := 74759  ;                                                              
  :b12 := 'ote.cargohandlingagent'  ;                                           
  :b13 := 'Y'  ;                                                                
  :b14 := 'ote.carrier'  ;                                                      
  --:b15 := 'CMA-CGM'  ;                                                          
  :b15 := 'BEKVERBURG'  ;                                                          
  :b16 := 'NLRTM'  ;                                                            
  :b17 := 'VCP'  ;                                                              
  :b18 := 'VE'  ;                                                               
  :b19 := 'VSA'  ;                                                              

  :b2 := 'DD'  ;                                                                
  :b20 := 'VSA'  ;                                                              
  -- :b3 :=  to_timestamp ( '28-FEB-19 12.00.00.000000000 AM', 'YYYY-MM-DD HH24:MI:SSXFF' )   ;                                                                       
                                                                                
  :b4 := 'DD'  ;                                                                
  :b5 := .9994  ;                                                               
  -- :b6 :=  to_timestamp ( '17-FEB-19 12.00.00.000000000 AM', 'YYYY-MM-DD HH24:MI SSXFF' )   ;                                                                       
                                                                                
  :b7 := 'DD'  ;                                                                
  -- :b8 :=  to_timestamp ( '28-FEB-19 12.00.00.000000000 AM', 'YYYY-MM-DD HH24:MI:SSXFF' )   ;                                                                       

                                                                                
  :b9 := 'DD'  ;                                                                

END;                                                                            

/                                                                               
set autotrace on
/* --                                                          */
/* -- Paste formatted statement here, followed by semicolon... */
/* --                                                          */
/* --   SQL goes HERE, with semicolon added!                   */
/* --                                                          */
/* -- use this file to run stmnt with variables defined above  */
/* -- SQL> @rerun_8w6sxarc0m8jf.lst                                      */
/* --                                                          */

set linesize 150

set timing on

set autotrace off

SELECT DISTINCT
    t0.id,
    t0.date_created,
    t0.date_modified,
    t1.arrival_time_drv,
/**    t0.discriminator,
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
***/
    t1.ogn_id_delegate,
    t1.ogn_id_owner,
    t1.vis_id
FROM
    pcs.pil_ports t11,
    pcs.pil_locations t10,
    pcs.pil_addresses t9,
    pcs.pil_organisation_roles t8,
    pcs.pil_organisation_types t7,
    pcs.pil_organisation_types t6,
    pcs.pil_visit t5,
    pcs.pil_addresses t4,
    pcs.pil_organisation_roles t3,
    pcs.pil_organisations t2,
    pcs.em_vessel_call_processes t1,
    pcs.pil_service_processes t0
WHERE
    ( ( ( ( ( ( ( ( t1.arrival_time_drv       >= trunc( to_timestamp ( '2019-02-17 12.00.00.000000000', 'YYYY-MM-DD HH24:MI:SSXFF' ) , :b2) )
                  AND ( t1.arrival_time_drv   < ( trunc(to_timestamp ( '2019-02-28 12.00.00.000000000', 'YYYY-MM-DD HH24:MI:SSXFF' ), :b4) + :b5 ) ) )
              AND ( ( t1.departure_time_drv   >= trunc( to_timestamp ( '2019-02-17 12.00.00.000000000', 'YYYY-MM-DD HH24:MI SSXFF' ) , :b7) )
                 AND ( t1.departure_time_drv < ( trunc( to_timestamp ( '2019-02-28 12.00.00.000000000', 'YYYY-MM-DD HH24:MI:SSXFF' ) , :b9) + :b10 ) ) ) )
              AND ( ( ( t2.id = :b11 )
                      AND ( t6.code IN (
        :b12
    ) ) )
                    AND ( t2.active = :b13 ) ) )
            AND ( ( t7.code = :b14 )
                  AND ( t9.name = :b15  ) ) )
          AND ( t10.un_code = :b16 ) )
        AND ( ( t1.id = t0.id )
              AND ( t0.discriminator = :b17 ) ) )
      AND ( ( ( ( ( ( ( ( ( ( ( t5.id = t1.vis_id )
                              AND t5.discriminator (+) = :b18 )
                            AND ( ( t4.vis_id = t5.id )
                                  AND ( t4.discriminator = :b19 ) ) )
                          AND ( t3.id = t4.orr_id ) )
                        AND ( t2.id = t3.ogn_id ) )
                      AND ( t6.id = t3.ote_id ) )
                    AND ( ( t9.vis_id = t5.id )
                          AND ( t9.discriminator = :b20 ) ) )
                  AND ( t8.id = t9.orr_id ) )
                AND ( t7.id = t8.ote_id ) )
              AND ( t11.id = t5.por_id ) )
            AND ( t10.id = t11.loc_id ) ) )
ORDER BY
    t1.arrival_time_drv;


set autotrace on

/

set autotrace off

