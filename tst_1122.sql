 
-- testing: 
-- 1. re-run against pbtemp
-- 2. test index on vis_id + dates + id
-- 3. testcase with extreme nr of visits.. (and only por_iud -> vis -> vcp -> sep.

--Variable b1 TIMESTAMP;
Variable b10 NUMBER;
Variable b11 NUMBER;
Variable b12 VARCHAR2(128);
Variable b13 VARCHAR2(32);
Variable b14 VARCHAR2(32);
Variable b15 VARCHAR2(128);
Variable b16 VARCHAR2(32);
Variable b17 VARCHAR2(32);
Variable b18 VARCHAR2(32);
Variable b19 VARCHAR2(32);
Variable b2 VARCHAR2(32);
--Variable b3 TIMESTAMP;
Variable b4 VARCHAR2(32);
Variable b5 NUMBER;
--Variable b6 TIMESTAMP;
Variable b7 VARCHAR2(32);
-- Variable b8 TIMESTAMP;
Variable b9 VARCHAR2(32);

now all varibles are declared, we will try to assign from cursor-0

BEGIN

  -- :b1 :=  to_timestamp ( '2019-FEB-28', 'YYYY-MM-DD' )   ;
  :b10 := .9994  ;
  :b11 := 82  ;
  :b12 := 'ote.cargohandlingagent'  ;
  :b13 := 'Y'  ;
  :b14 := 'NLRTM'  ;
  :b15 := 'SANTA ROSA'  ;
  :b16 := 'VCP'  ;
  :b17 := 'VE'  ;
  :b18 := 'VSA'  ;
  :b19 := 'VE'  ;
  :b2 := 'DD'  ;
  -- :b3 :=  to_timestamp ( '2019-MAR-14', 'YYYY-MM-DD' )   ;
  :b4 := 'DD'  ;
  :b5 := .9994  ;
  -- :b6 :=  to_timestamp ( '2019-FEB-28', 'YYYY-MM-DD' )   ;
  :b7 := 'DD'  ;
  -- :b8 :=  to_timestamp ( '2019-MAR-14', 'YYYY-MM-DD' )   ;
  :b9 := 'DD'  ;

END;

/
set autotrace off
/* --                                                          */
/* -- Paste formatted statement here, followed by semicolon... */
/* --                                                          */
/* --   SQL goes HERE, with semicolon added!                   */
/* --                                                          */
/* -- use this file to run stmnt with variables defined above  */
/* -- SQL> @rerun_0xq9d6utckzfw.lst                                      */
/* --                                                          */
set autotrace off

SELECT DISTINCT
    t0.id ,
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
    pcs.pil_vessel_register        t10,
    pcs.pil_transport_unit         t9,
    pcs.pil_ports                  t8,
    pcs.pil_locations              t7,
    pcs.pil_organisation_types     t6,
    pcs.pil_visit                  t5,
    pcs.pil_addresses              t4,
    pcs.pil_organisation_roles     t3,
    pcs.pil_organisations          t2,
    pcs.em_vessel_call_processes   t1,
    pcs.pil_service_processes      t0
WHERE
    ( ( ( ( ( ( ( ( t1.arrival_time_drv >= trunc( to_timestamp ( '2019-FEB-28', 'YYYY-MM-DD' ) , :b2) )
                  AND ( t1.arrival_time_drv < ( trunc( to_timestamp ( '2019-MAR-14', 'YYYY-MM-DD' ) , :b4) + :b5 ) ) )
                AND ( ( t1.departure_time_drv >= trunc( to_timestamp ( '2019-FEB-28', 'YYYY-MM-DD' ) , :b7) )
                      AND ( t1.departure_time_drv < ( trunc( to_timestamp ( '2019-MAR-14', 'YYYY-MM-DD' ) , :b9) + :b10 ) ) ) )
              AND ( ( ( t2.id = :b11 )
                      AND ( t6.code IN (
        :b12
    ) ) )
                    AND ( t2.active = :b13 ) ) )
            AND ( t7.un_code = :b14 ) )
          AND ( upper(nvl(t9.tu_display_name, t10.vessel_display_name)) = :b15 ) )
        AND ( ( t1.id = t0.id )
              AND ( t0.discriminator = :b16 ) ) )
      AND ( ( ( ( ( ( ( ( ( ( t5.id = t1.vis_id )
                            AND t5.discriminator (+) = :b17 )
                          AND ( ( t4.vis_id = t5.id )
                                AND ( t4.discriminator = :b18 ) ) )
                        AND ( t3.id = t4.orr_id ) )
                      AND ( t2.id = t3.ogn_id ) )
                    AND ( t6.id = t3.ote_id ) )
                  AND ( t8.id = t5.por_id ) )
                AND ( t7.id = t8.loc_id ) )
              AND ( ( t9.id = t5.tnt_id )
                    AND ( t9.discriminator = :b19 ) ) )
            AND ( t10.id = t9.pvr_id ) ) )
ORDER BY
    t1.arrival_time_drv;


set autotrace on
set timing on

/

prompt .
prompt test done with original SQL..
accept press_enter_to_cont

set autotrace off

-- extra test-query , test entry via large nr of vis_ids.
SELECT DISTINCT
    t0.id,
    t0.discriminator,
    t0.locked_ind,
    t0.process_id,
/*    t0.state,
    t0.version,
    t0.wrapper_class,
    t0.date_created,
    t0.date_modified,
    t0.sep_id,
    t1.id,
    t1.creation_date,
    t1.webservice_ind,
*/    t1.arrival_time_drv,
    t1.departure_time_drv,
/*    t1.state_drv,
    t1.ogn_id_delegate,
*/    t1.ogn_id_owner,
    t1.vis_id
FROM
    -- pcs.pil_vessel_register        t10,
    -- pcs.pil_transport_unit         t9,
    pcs.pil_ports                  t8,
    -- pcs.pil_locations              t7,
    -- pcs.pil_organisation_types     t6,
    pcs.pil_visit                  t5,
    -- pcs.pil_addresses              t4,
    -- pcs.pil_organisation_roles     t3,
    -- pcs.pil_organisations          t2,
    pcs.em_vessel_call_processes   t1,
    pcs.pil_service_processes      t0
WHERE 1=1
and  t1.arrival_time_drv >=   to_timestamp ( '2019-FEB-20', 'YYYY-MM-DD' ) 
AND  t1.arrival_time_drv <    to_timestamp ( '2019-MAR-08', 'YYYY-MM-DD' ) 
AND  t1.departure_time_drv >= to_timestamp ( '2019-FEB-20', 'YYYY-MM-DD' ) 
AND  t1.departure_time_drv <  to_timestamp ( '2019-MAR-01', 'YYYY-MM-DD' ) 
and  t1.id = t0.id                       
AND  t8.id = t5.por_id 
AND  t0.discriminator = :b16
AND  t5.id = t1.vis_id 
and t8.loc_id = 6570 -- 0=rotterdam 8=terneuzen
ORDER BY
    t1.arrival_time_drv
fetch first 5 rows only;

set autotrace on

/

set autotrace off

