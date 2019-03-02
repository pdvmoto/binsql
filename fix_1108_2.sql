

-- part 2. aim to replace the PK no LOC_VISIT by an inflated version..
-- 

set timing on
set echo on

spool fix_1108_2


-- not needed: drop the FK on LOC_VIS
-- alter table pcs.location_visits drop constraint rd_lvi_prl_fk ;

-- drop the FK-index on PRL_ID
     drop index pcs.rd_lvi_prl_fk_ind ; 
-- CREATE INDEX PCS.RD_LVI_PRL_FK_IND ON PCS.RD_LOCATION_VISITS (PRL_ID ASC)    tablespace pcs_index ; 


-- recreate FK-index : PRL + ID + tim + arr.
-- drop index  pcs.rd_lvi1_prl_fk_xtra1 ;
 CREATE INDEX PCS.RD_LVI1_prl_fk_XTRA1 ON PCS.RD_LOCATION_VISITS 
    (PRL_ID ASC, ID ASC, TIMESLOT_START_TIME ASC, ESTIMATED_ARRIVAL_TIME ASC) tablespace pcs_index ;

-- re-create FK and validate it.. 

spool off

prompt to reverse: un-comment the below..

/* 

-- drop index pcs.rd_eqp_ogn_reg_fk_xtra3 ;
-- drop index  pcs.rd_lvi1_prl_fk_xtra1 ;
-- CREATE INDEX PCS.RD_LVI_PRL_FK_IND ON PCS.RD_LOCATION_VISITS (PRL_ID ASC)	tablespace pcs_index ; 
*/


