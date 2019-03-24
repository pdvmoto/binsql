/**
the view looks like this:

  CREATE OR REPLACE no no no !  VIEW "PCS"."PIL_CONSIGNMENT_ADOPTIONS_V" ("ID", "ADOPTION_START_DATE", "OGN_ID") AS
  select p.id, p.adoption_start_date, p.ogn_id
   from (select p.*, max(p.adoption_start_date) over(partition by p.csm_id, p.ogn_id) as maximum
         from pil_consignment_adoptions p
        ) p
   where p.adoption_start_date = maximum;


****/

/*** 

-- some attempts to improve.. not needed when V2 + whereclause is used
--drop index pcs.pil_cad_csm_ogn_ads_id_1107a;
create index pcs.pil_cad_csm_ogn_ads_id_1107a
on pcs.PIL_CONSIGNMENT_ADOPTIONS ( csm_id, ogn_id, adoption_start_date, id ) 
tablespace pcs_index ;

--drop index pcs.pil_cad_csm_ogn_ads_id_1107b
create index pcs.pil_cad_csm_ogn_ads_id_1107b
on pcs.PIL_CONSIGNMENT_ADOPTIONS ( csm_id, ogn_id, id, adoption_start_date ) 
tablespace pcs_index ;

***/

CREATE OR REPLACE VIEW PCS.PIL_CONSIGNMENT_ADOPTIONS_V_V2 (ID, ADOPTION_START_DATE, OGN_ID, csm_id) AS
  select p.id, p.adoption_start_date, p.ogn_id, p.csm_id -- added csm_id to allow whereclause
   from (select p.*, max(p.adoption_start_date) over(partition by p.csm_id, p.ogn_id) as maximum
         from pil_consignment_adoptions p
         -- where csm_id > 80*1000*1000
        ) p
   where p.adoption_start_date = maximum;

grant select on PCS.PIL_CONSIGNMENT_ADOPTIONS_V_V2 to pcsread_r ;  
grant select , insert, update, delete on PCS.PIL_CONSIGNMENT_ADOPTIONS_V_V2 to pcsfix_r ;  

