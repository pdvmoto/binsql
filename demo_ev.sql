
drop table event;
create table event 
(  id number
         , etype varchar2(10)
         , ts date ) ; 


insert into event values ( 1, 'START', sysdate-2 ) ;
insert into event values ( 1, 'END', sysdate ) ;

insert into event values ( 2, 'START', sysdate-1 ) ;
insert into event values ( 2, 'END', sysdate ) ;

commit ;


select e1.id event_id
     , (e2.ts - e1.ts ) * 24 * 3600 as timediff
from event e1
   , event e2 
where 1=1
and e1.id = e2.id
and e1.etype = 'START'
and e2.etype = 'END'
and e1.id = 1  -- this is your input value
;


