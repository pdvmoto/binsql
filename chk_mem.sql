
-- chk_mem: server memory and allocated components.

column stat_name format a20 trunc
column pool_name format A20 
column sga_cmpnt format A20 
column mb   format 999,999
column cpus format 999,999

select o.stat_name, o.value as cpus
--o.* 
from v$osstat o 
where stat_name like 'NUM%' 
order by stat_name;

select o.stat_name, o.value /(1024*1024) as mb
--o.* 
from v$osstat o 
where ( stat_name like '%FREE%' or stat_name like '%MEMOR%' )
order by stat_name;

select  name as sga_cmpnt, bytes/(1024*1024) as mb
from v$sgastat
where pool is null
order by name ;

select nvl (pool, ' -none-' ) pool_name
, round ( sum (bytes)/(1024*1024)) MB
from v$sgastat 
group by nvl (pool, ' -none-' )
order by 1;  

select 'Total',round ( sum (bytes)/(1024*1024)) MB from v$sgastat ;



