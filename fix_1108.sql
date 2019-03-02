
-- 1. aim to replace the fk index PRL -> LOC_VIS, 4 steps: drop, drop, create, create.
-- potentially: only drop/create of index is needed.

-- 2. aim to replace the PK no LOC_VISIT by an inflated version..
-- 

set timing on
set echo on

spool fix1

-- option remove original:   
--   drop index pcs.rd_eqp_ogn_reg_fk_ind ; 
-- create index pcs.rd_eqp_ogn_reg_fk_ind on pcs.rd_equipments (ogn_reg_id) ;

-- drop index pcs.rd_eqp_ogn_reg_fk_xtra3 ;
 create index pcs.rd_eqp_ogn_reg_fk_xtra3 on pcs.

-- not needed: drop the FK on LOC_VIS
-- alter table pcs.location_visits drop constraint rd__lvi_prl_fk ;

-- drop the FK-index on PRL_ID
     drop index pcs.rd_lvi_prl_fk_ind ; 
-- CREATE INDEX PCS.RD_LVI_PRL_FK_IND ON PCS.RD_LOCATION_VISITS (PRL_ID ASC)    tablespace pcs_index ; 


-- recreate FK-index : PRL + ID + tim + arr.
-- drop index  pcs.rd_lvi1_prl_fk_xtra1 ;
 CREATE INDEX PCS.RD_LVI1_prl_fk_XTRA1 ON PCS.RD_LOCATION_VISITS 
    (PRL_ID ASC, ID ASC, TIMESLOT_START_TIME ASC, ESTIMATED_ARRIVAL_TIME ASC) tablespace pcs_index ;

-- re-create FK and validate it.. 

prompt to reverse: un-comment the below..

/* 

-- drop index pcs.rd_eqp_ogn_reg_fk_xtra3 ;
-- drop index  pcs.rd_lvi1_prl_fk_xtra1 ;
-- CREATE INDEX PCS.RD_LVI_PRL_FK_IND ON PCS.RD_LOCATION_VISITS (PRL_ID ASC)	tablespace pcs_index ; 
*/


-- now replace a pk..(and temporary disable the incoming FKs)

-- saftey catch
prompt dont mess with keys unless you are prepared...
prompt if yo do: locks needed here!
exit

-- two constraints point to the lvi_pk, remove those constri .
alter table pcs.rd_equipments drop constraint rd_eqp_rd_lvi_fk ;
alter table pcs.rd_processes  drop constraint rd_pro_rd_lvi_fk ;

alter table pcs.rd_location_visits drop constraint rd_lvi_pk;
drop index pcs.rd_lvi_pk ;

create index pcs.rd_lvi_pk_xtra2 on pcs.rd_location_visits 
	( id, prl_id, timeslot_start_time, estimated_arrival_time) tablespace pcs_index; 
alter table pcs.rd_location_visits 
	add constraint pcs.rd_lvi_pk primary key ( id ) 
	using index pcs.rd_lvi_pk_xtra2 ; 


--re-enable incoming fks
alter table pcs.rd_equipments add constraint rd_eqp_rd_lvi_fk foreign key
( rd_lvi_id ) references pcs.rd_location_visits ( id ) enable ; 

alter table pcs.rd_processes  add constraint rd_pro_rd_lvi_fk foreign key
( rd_lvi_id ) references pcs.rd_location_visits ( id ) enable ; 

-- end of 
/* to reverse, uncomment

alter table pcs.rd_equipments drop constraint rd_eqp_rd_lvi_fk ;
alter table pcs.rd_processes  drop constraint rd_pro_rd_lvi_fk ;

alter table pcs.rd_location_visits drop constraint pcs.rd_lvi_pk ;
drop index pcs.rd_lvi_pk_xtra2 ; 

create unique index pcs.rd_lvi_pk on pcs.rd_location_visits ( id ) tablespace pcs_index ;
alter table pcs.rd_location_visits add constraint pcs.rd_lvi_pk primary key ( id ) using index pcs.rd_lvi_pk;

-re-enable incoming fks
alter table pcs.rd_equipments add constraint rd_eqp_rd_lvi_fk foreign key
( rd_lvi_id ) references pcs.rd_location_visits ( id ) enable ; 

alter table pcs.rd_processes  add constraint rd_pro_rd_lvi_fk foreign keY
( rd_lvi_id ) references pcs.rd_location_visits ( id ) enable ; 

*/

spool off

