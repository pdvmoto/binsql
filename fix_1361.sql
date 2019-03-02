

set timing on
set echo on

spool fix_1361


-- s1. index on dates + vis_id + id: find all relevant link-ids via index
create index pcs.em_vcp_dates_xtra1 on 
  pcs.em_vessel_call_processes ( arrival_time_drv, departure_time_drv, vis_id, id )
  tablespace pcs_index ; 

-- dont forget : remove the old one..
  drop index pcs.em_vcs_dates_ind ; 

-- s2: and link over visit using just this index...(tnt from issue 1342 check)
create index pcs.pil_visit_xtra1 on 
  pcs.pil_visit ( id, discriminator, por_id, tnt_id )
  tablespace pcs_index ; 

-- s3: link over address.
create index pcs.pil_ads_vis_disc_orr_xtra1 on 
  pcs.pil_addresses ( vis_id, discriminator, orr_id )
  tablespace pcs_index;

-- can remove, double check FK:  
-- drop index pcs.pil_ads_vis_fk_ind ; 

-- s4: port index on ID + LOC_ID, we want to jump over port to loc_id 
create index pcs.pil_por_pk_loc_xtra1 on 
  pcs.pil_ports ( id, loc_id ) 
  tablespace pcs_index ; 

-- s5: port_loc_visit.
create index pcs.pil_plv_vis_disc_prl_xtra1 on 
  pcs.pil_port_location_visit  ( vis_id, discriminator, prl_id ) 
  tablespace pcs_index ; 


spool off

-- saftey valve
exit 

-- reverse...
/**** 
-- drop index pcs.em_vcp_xtra1 ; 
-- drop index pcs.pil_visit_xtra1 ; 
-- drop index pcs.em_vcs_dates_ind ; 
create index pcs.em_vcs_dates_ind on   -- re-add old one
  pcs.em_vessel_call_processes ( arrival_time_drv, departure_time_drv ) 
  tablespace pcs_index ; 

-- drop index pcs.pil_ads_vis_disc_orr_xtra1 ;  
-- drop index pcs.pil_por_pk_loc_xtra1 ;
-- drop index pcs.pil_plv_vis_disc_prl_xtra1 ; 
***/

