
spool demo_inmem
set linesize 120
set trimspool on
set echo on
set feeback on

select * from v$version;

show parameter inmemory 

drop table t_inmem ;
create table t_inmem as select object_name from dba_objects where rownum < 2001; 

alter table t_inmem inmemory ; 

-- if needed: analyze table t_inmem calculate statistics ;

set autotrace on explain

select count (*) 
from t_inmem 
where object_name like 'C%';

select /*+ no_inmemory */ count (*) 
from t_inmem 
where object_name like 'C%';

set autotrace off

spool off



