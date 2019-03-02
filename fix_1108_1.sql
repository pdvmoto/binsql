
-- 1. replace pk on lvi with extra-fields in index.
-- there is a part-2 for fk from ...


set timing on
set echo on

spool fix_1108_1


-- saftey catch
prompt dont mess with keys unless you are prepared...
prompt if yo do: locks needed here!
-- exit

-- two constraints point to the lvi_pk, remove those constri .
alter table pcs.rd_equipments drop constraint rd_eqp_rd_lvi_fk ;
alter table pcs.rd_processes  drop constraint rd_pro_rd_lvi_fk ;

alter table pcs.rd_location_visits drop constraint rd_lvi_pk2 ;
drop index pcs.rd_lvi_pk ;
--drop index pcs.rd_lvi_pk_xtra2 ;

create index pcs.rd_lvi_pk_xtra2 on pcs.rd_location_visits 
	( id, prl_id, timeslot_start_time, estimated_arrival_time) tablespace pcs_index; 
alter table pcs.rd_location_visits 
	add constraint rd_lvi_pk primary key ( id ) 
	using index pcs.rd_lvi_pk_xtra2 ; 


--re-enable incoming fks
alter table pcs.rd_equipments add constraint rd_eqp_rd_lvi_fk foreign key
( rd_lvi_id ) references pcs.rd_location_visits ( id ) enable ; 

alter table pcs.rd_processes  add constraint rd_pro_rd_lvi_fk foreign key
( rd_lvi_id ) references pcs.rd_location_visits ( id ) enable ; 

-- end of 

prompt : go read the spoolfile..

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

