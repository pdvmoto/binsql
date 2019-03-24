
-- fix 1122, 
-- 1. jump over visit, withn index only
-- 2. facilitate entry into VCP over vis_id


-- ruler
prompt           ....,....1....,....2....,....3....,....4....,....5....,....6....,....7....,....8

--drop index pcs.pil_vis_por_fk_disc_id_ind;
create index pcs.pil_vis_por_fk_disc_id_ind 
  on pcs.pil_visit ( por_id, discriminator, id )
  tablespace pcs_index;


--drop index pcs.em_vcp_vis_fk_arr_dep_id_ind ;
create index pcs.em_vcp_vis_fk_arr_dep_id_ind 
  on pcs.em_vessel_call_processes ( vis_id, arrival_time_drv, departure_time_drv, id )
  tablespace pcs_index online ;

-- s1. original, index on dates + vis_id + id: find all relevant link-ids via index
--drop index pcs.em_vcp_dates_xtra1 ;
create index pcs.em_vcp_dates_xtra1 on
  pcs.em_vessel_call_processes ( arrival_time_drv, departure_time_drv, vis_id, id )
  tablespace pcs_index ;

--drop index pcs.pil_ads_orr_vis_ind
--drop index pcs.pil_ads_orr_dis_vis_ind ; 
create index pcs.pil_ads_orr_dis_vis_ind on pcs.pil_addresses ( orr_id, discriminator, vis_id ) online tablespace pcs_index ; 
