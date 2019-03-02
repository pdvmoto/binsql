

-- extra fix : jump from loc -> port -> visit

-- index on location to favour un_code
--drop index pcs.pil_loc_un_id ;
create index pcs.pil_loc_un_id 
on pcs.pil_locations (un_code, id) 
tablespace pcs_index; 

-- index on port to favour jump from loc - > port -> vist
-- consider also : discriminator ?
--drop index pcs.pil_por_loc_fk_xtra ;
create index pcs.pil_por_loc_fk_xtra on pcs.pil_ports ( loc_id, id) tablespace pcs_index ; 

-- note: other fixes already in place since 18Feb. (issue.. nr . ) 

