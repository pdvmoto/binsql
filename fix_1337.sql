/*** 

SELECT DISTINCT
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
    pcs.pil_vessel_register t10,
    pcs.pil_transport_unit t9,
    pcs.pil_ports t8,
    pcs.pil_locations t7,
    pcs.pil_organisation_types t6,
    pcs.pil_visit t5,
    pcs.pil_addresses t4,
    pcs.pil_organisation_roles t3,
    pcs.pil_organisations t2,
    pcs.em_vessel_call_processes t1,
    pcs.pil_service_processes t0
WHERE   t1.arrival_time_drv >= trunc(:1, :2)
    AND t1.arrival_time_drv < ( trunc(:3, :4) + :5 )
    AND t1.departure_time_drv >= trunc(:6, :7)
    AND t1.departure_time_drv < ( trunc(:8, :9) + :10 )
    AND t2.id = :11
    AND t6.code IN ( :12,                         :13,                         :14 )  
    AND  t2.active = :15   
    AND  t7.un_code = :16 
      AND  upper(nvl(t9.tu_display_name, t10.vessel_display_name)) = :17  
    AND  t1.id = t0.id 
    AND  t0.discriminator = :18   
    AND         t5.id = t1.vis_ID 
    AND t5.DISCRIMINATOR (+) = :19  
    AND t4.VIS_ID = t5.ID
AND t4.DISCRIMINATOR = :20  
AND t3.ID = t4.ORR_ID 
AND t2.ID = t3.OGN_ID
AND t6.ID = t3.OTE_ID 
AND t8.ID = t5.POR_ID 
AND t7.ID = t8.LOC_ID 
AND t9.ID = t5.TNT_ID 
AND t9.DIScriminator = :21 
AND t10.id = t9.pvr_id 
order by t1.arrival_time_drv;

***/ 

