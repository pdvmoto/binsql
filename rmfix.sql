


-- extra fix : loc -> port -> visit

-- index on location to favour un_code
drop index pcs.pil_loc_un_id ;


-- index on port to favour jump from loc - > port -> vist
-- consider also : discriminator ?
drop index pcs.pil_por_loc_fk_xtra ;

-- note: other fixes already in place since 18Feb. (issue.. nr . ) 




-- fix 1377, several indexes.. 
-- concept is : start from rd_location_visits, filtere on dates..


-- 1st option, entry via date-condition, and improved index over rd_equip.
drop index pcs.rd_lvi_dates_prl_id_xtra1 ;

  drop index pcs.rd_eqp_lvi_pick_con_ogn_xtra3 ;


-- 2nd try: enter via t5-port_locations, and use fat index on loc_vis
-- seemed to work better

drop index pcs.prl_dis_pk_xtra1 ;

drop index pcs.rd_lvi_prl_dates_id_xtra2 ;

-- 3rd try: entry from org..jump over equip..
drop index pcs.rd_eqp_ogn_pick_cont_rd_lvi
