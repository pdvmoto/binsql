
drop sequence robert.data_chk_seq ;

drop table robert.data_chk;


create sequence robert.data_chk_seq;

create table robert.data_chk ( 
id number
,data_ts date
,data_chk varchar2(32) 
);

alter tABLE robert.data_chk add constraint data_chk_pk primary key ( id ) ;


insert into robert.data_chk values 
(  robert.data_chk_seq.nextval, sysdate, 'first insert...' ) ;

commit ;

