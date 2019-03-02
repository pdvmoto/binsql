-- fix item 1290, index on PIL_CES_LEQ

--
-- fix is index on call_ref + ces_id + leq_id: find all info+links via 1 index

spool fix_1290

set timing on

create index pcs.pil_ces_leq_crf_xtra7  on 
  pcs.pil_ces_leq ( call_ref_nr_drv, leq_id, ces_id )
  tablespace pcs_index;

-- reverse the fix: drop the new index
-- drop index pcs.pil_ces_leq_crf_xtra7; 

spool off

