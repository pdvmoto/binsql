

set timing on
set echo on

-- old... create index pcs.pil_vis_por_fk_xtra5 on pcs.pil_visit (por_id, discriminator) tablespace pcs_index ; 

-- index on dates + vis_id + id: find all relevant link-ids via index
create index pcs.em_vcp_xtra1 on 
  pcs.em_vessel_call_processes ( arrival_time_drv, departure_time_drv, vis_id, id )
  tablespace pcs_index ; 


-- remove the old one..
  drop index pcs.em_vcs_dates_ind ; 

-- and link over visit using just this index...
create index pcs.pil_visit_xtra1 on 
  pcs.pil_visit ( id, discriminator, por_id, tnt_id )
  tablespace pcs_index ; 

-- reverse...
/**** 
-- drop index pcs.em_vcp_xtra1 ; 
-- drop index pcs.pil_visit_xtra1 ; 
-- drop index pcs.em_vcs_dates_ind ; 
create index pcs.em_vcs_dates_ind on  
  pcs.em_vessel_call_processes ( arrival_time_drv, departure_time_drv ) 
  tablespace pcs_index ; 
***/

