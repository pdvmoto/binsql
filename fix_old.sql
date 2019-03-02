
-- notes from 01 Mar.

-- index on location to favour un
drop index  pcs.pil_loc_un_id ;
create index pcs.pil_loc_un_id 
on pcs.pil_locations (un_code, id) 
tablespace pcs_index; 

-- index on port to favour jump from loc - > port -> vist
-- consider also : discriminator ?
--drop index pcs.pil_por_loc_fk_xtra ;
create index pcs.pil_por_loc_fk_xtra on pcs.pil_ports ( loc_id, id) tablespace pcs_index ; 

---- -- - -1377

  drop index pcs.rd_eqp_ogn_reg_fk_xtra3 ;
  drop index pcs.rd_eqp_lvi_pick_con_ogn_xtra3 ;
create index pcs.rd_eqp_lvi_pick_con_ogn_xtra3 
  on pcs.rd_equipments ( rd_lvi_id, pickup_delivery_indicator, container_number, ogn_reg_id)
  tablespace pcs_index ;

--drop index pcs.prl_dis_pk_xtra1 ;
create index pcs.prl_dis_pk_xtra1 
  on pcs.pil_port_locations ( discriminator, id )
  tablespace pcs_index ;

--drop index pcs.rd_lvi_dates_prl_id_xtra1 ;
create index pcs.rd_lvi_dates_prl_id_xtra1 on pcs.rd_location_visits ( timeslot_start_time, estimated_arrival_time, prl_id, id )
  tablespace pcs_index ;
  
--drop index pcs.rd_lvi_prl_dates_id_xtra2 ;
create index pcs.rd_lvi_prl_dates_id_xtra2 on pcs.rd_location_visits ( prl_id, timeslot_start_time, estimated_arrival_time, id )        
  tablespace pcs_index ;
  
  -- 3rd try: entry from org..jump over equip..
--drop index pcs.rd_eqp_ogn_pick_cont_rd_lvi
create index pcs.rd_eqp_ogn_pick_cont_rd_lvi 
  on pcs.rd_equipments ( ogn_reg_id, pickup_delivery_indicator, container_number, rd_lvi_id )
  tablespace pcs_index ;

