
-- fix 1377, several indexes.. 
-- concept is : start from rd_location_visits, filtere on dates..


-- 1st option, entry via date-condition, and improved index over rd_equip.
--drop index pcs.rd_lvi_dates_prl_id_xtra1 ;
create index pcs.rd_lvi_dates_prl_id_xtra1 on pcs.rd_location_visits ( timeslot_start_time, estimated_arrival_time, prl_id, id )  
  tablespace pcs_index ;

  drop index pcs.rd_eqp_ogn_reg_fk_xtra3 ;
  drop index pcs.rd_eqp_lvi_pick_con_ogn_xtra3 ;
create index pcs.rd_eqp_lvi_pick_con_ogn_xtra3 
  on pcs.rd_equipents ( rd_lvi_id, pickup_delivery_indicator, container_number, ogn_reg_id) 
  tablespace pcs_index ;


-- 2nd try: enter via t5-port_locations, and use fat index on loc_vis
-- seemed to work better

--drop index pcs.prl_dis_pk_xtra1 ;
create index pcs.prl_dis_pk_xtra1 
  on pcs.pil_port_locations ( discriminator, id ) 
  tablespace pcs_index ;

--drop index pcs.rd_lvi_prl_dates_id_xtra2 ;
create index pcs.rd_lvi_prl_dates_id_xtra2 
  on pcs.rd_location_visits ( prl_id, timeslot_start_time, estimated_arrival_time, id )  
  tablespace pcs_index ;

-- 3rd try: entry from org..jump over equip..
--drop index pcs.rd_eqp_ogn_pck_con_rd_lvi_1377
create index pcs.rd_eqp_ogn_pck_con_rd_lvi_1377
  on pcs.rd_equipments ( ogn_reg_id, pickup_delivery_indicator, container_number, rd_lvi_id )
  tablespace pcs_index ;
