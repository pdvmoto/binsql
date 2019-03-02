

-- declare all the variables, outside the pl/sql block... 

variable b1 NUMBER;                                                              
Variable b10 VARCHAR2(32);                                                       
Variable b11 VARCHAR2(32);                                                       
Variable b12 VARCHAR2(32);                                                       
Variable b13 VARCHAR2(32);                                                       
Variable b14 VARCHAR2(32);                                                       
Variable b15 VARCHAR2(32);                                                       
Variable b16 VARCHAR2(32);                                                       
Variable b17 VARCHAR2(32);                                                       
Variable b18 VARCHAR2(32);                                                       
-- Variable b2 TIMESTAMP;                                                           
-- Variable b3 TIMESTAMP;                                                           
-- Variable b4 TIMESTAMP;                                                           
-- Variable b5 TIMESTAMP;                                                           

Variable b6 VARCHAR2(32);                                                        
Variable b7 NUMBER;                                                              
Variable b8 VARCHAR2(32);                                                        
Variable b9 VARCHAR2(32);                                                        

prompt all varaiables declared.

begin 

  :b1 := 177757  ;                                                               
  :b10 := 'CPR'  ;                                                               
  :b11 := 'SNA'  ;                                                               
  :b12 := 'SPR'  ;                                                               
  :b13 := 'SST'  ;                                                               
  :b14 := 'SSF'  ;                                                               
  :b15 := 'UPD'  ;                                                               
  :b16 := 'URJ'  ;                                                               
  :b17 := 'RDP'  ;                                                               
  :b18 := 'TE'  ;                                                                

    --:b2 :=   sysdate ;                                                                     
    --:b3 :=   sysdate ;                                                                     
    --:b4 :=   sysdate ;                                                                     
    --:b5 :=   sysdate ;                                                                     

  :b6 := 'D'  ;                                                                  
  :b7 := 91588  ;                                                                
  :b8 := 'ACC'  ;                                                                
  :b9 := 'CAC'  ;                                                                

end;
/ 

-- test some bind var
select 'bind var b9 = ' || :b9 from dual ; 


/* --                                                          */
/* -- Paste formatted statement here, followed by semicolon... */
/* --                                                          */
/* --   SQL goes HERE, with semicolon added!                   */
/* --                                                          */
/* -- use this file to run stmnt with variables defined above  */
/* -- SQL> @rerun_gts060fkc3x7n.lst                                      */
/* --                                                          */
set autotrace off

SELECT
    t0.id,
    t0.id
FROM
    pcs.pil_port_locations t5,
    pcs.pil_organisations t4,
    pcs.rd_location_visits t3,
    pcs.rd_equipments t2,
    pcs.rd_processes t1,
    pcs.pil_service_processes t0
WHERE
    ( ( ( ( ( ( ( t4.id = :b1 )
                AND ( ( ( ( ( t3.timeslot_start_time IS NULL )
                            AND ( t3.estimated_arrival_time >= ( sysdate - 10 )  ) )
                          AND ( ( t3.timeslot_start_time IS NULL )
                                AND ( t3.estimated_arrival_time <= ( sysdate + 10 ) ) ) )
                        OR ( ( NOT ( ( t3.timeslot_start_time IS NULL ) )
                                   AND ( t3.timeslot_start_time >= (sysdate - 10) ) )
                             AND ( NOT ( ( t3.timeslot_start_time IS NULL ) )
                                       AND ( t3.timeslot_start_time <= (sysdate + 10 ) ) ) ) )
                      OR ( ( t3.estimated_arrival_time IS NULL )
                           AND ( t3.timeslot_start_time IS NULL ) ) ) )
              AND ( t2.pickup_delivery_indicator = :b6 ) )
            AND ( t5.id = :b7 ) )
          AND ( t0.state IN (  :b8, :b9, :b10, :b11, :b12, :b13, :b14, :b15, :b16
    ) ) )
        AND ( ( t1.id = t0.id )
              AND ( t0.discriminator = :b17 ) ) )
      AND ( ( ( ( t3.id = t1.rd_lvi_id )
                AND ( t2.rd_lvi_id = t3.id ) )
              AND ( t4.id = t2.ogn_reg_id ) )
            AND ( ( t5.id = t3.prl_id )
                  AND ( t5.discriminator = :b18 ) ) ) )
ORDER BY
    t2.container_number ASC;

