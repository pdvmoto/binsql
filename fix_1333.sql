-- fix item 1333, index on PIL_CES_LEQ

--
-- fix is index on call_ref + ces_id + leq_id: find all info+links via 1 index

spool fix_1333

set timing on
set echo on

create index pcs.pil_ces_leq_crn_xtra6  on 
  pcs.pil_ces_leq ( call_ref_nr_drv, leq_id, ces_id )
  tablespace pcs_index;

create index pcs.ces_id_dty_ogn_xtra7 
  on pcs.pil_customs_export_shipments ( id, ogn_id, dty_id ) 
  tablespace pcs_index;

-- reverse the fix: drop the new index
-- drop index pcs.pil_ces_leq_crn_xtra6; 
-- drop index pcs.ces_id_dty_ogn_xtra7 ;

spool off

