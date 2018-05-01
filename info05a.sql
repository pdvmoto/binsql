
-- check grants
select grantee, owner, count (*)  
from dba_tab_privs 
group by grantee, owner 
order by owner, grantee 
/

-- check synonyms
select owner, table_owner , count (*)  
from dba_synonyms
group by owner, table_owner
order by owner, table_owner
/

column table_owner format A10

select owner, synonym_name, table_owner, table_name  
from dba_synonyms 
where table_owner not in ( 'SYS', 'SYSTEM','WMSYS', 'PERFSTAT' )
order by table_owner, synonym_name 
/

