
-- do some io... 

set timing on
set echo on

/*** 
create table xx_content (
   id          number   generated always as identity not null primary key
,  created_dt timestamp default systimestamp 
,  payload    varchar2(1000)
);

create index xx_content_dt on xx_content ( created_dt, id );

***/

select /* d42: cnt */ count (*) from all_source where text like '%xyz%'  ;

insert /* get payload */ into xx_content ( payload) 
select substr ( text, 1, 999 ) 
from all_source 
where text like '%xyz%'
;

/

/

/

/

/

/

select /* sleep-demo */ sleepf ( 2.1 ) from dual ;

select /* spin-demo */ spinf_n ( 0.5 ) from dual ;

set timing on
set echo on

exec dbms_lock.sleep ( 2.1 ) ; 
exec dbms_lock.sleep ( 1.8 ) ; 


