-- need table with pk, uk, fk, fat-index, lob, and FBI)
drop table demoseg;
create table demoseg 
( id number 
, demotype_id number 
, attrib_name varchar2(20) 
, payload clob 
) ;

create index demoseg_pk on demoseg ( id, demotype_id  );
alter table demoseg add constraint demoseg_pk primary key ( id ) using index demoseg_pk;

create unique index demoseg_att_uk on demoseg ( attrib_name ) ;
create index demoseg_lookup on demoseg ( attrib_name, id, demotype_id ) ;
create index demoseg_upname on demoseg ( upper (attrib_name ) ); 

