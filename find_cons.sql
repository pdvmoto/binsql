
/*

  select * from dba_constraints; 

*/
spool find_cons

column owner format A25
column table_name format A25
column nr_prnts 999
column nr_chlds 999

prompt Count nr of outgoing constraints per table..

select c.owner , c.table_name, count (*) nr_prnts
--, c.constraint_name, r.constraint_name as rcon , rc.column_name , c.* 
from dba_constraints c
   , dba_constraints r
   , dba_cons_columns cc
   , dba_cons_columns rc
where 1=1
  and c.r_owner = r.owner 
  and c.r_constraint_name = r.constraint_name
  and cc.owner = c.owner
  and cc.table_name = c.table_name
  and cc.constraint_name = c.constraint_name
  and rc.owner = r.owner
  and rc.table_name = r.table_name
  and rc.constraint_name = r.constraint_name
  and c.constraint_type = 'R' 
  and ( c.owner like 'XX%' or c.owner like 'STAR%' )
  group by c.owner, c.table_name 
order by c.owner, c.table_name -- , c.constraint_name, cc.column_name
  ;


prompt nr of children per table.. need to clean children first..

select r.owner , r.table_name, count (*) nr_chlds
--, c.constraint_name, r.constraint_name as rcon , rc.column_name , c.* 
from dba_constraints c
   , dba_constraints r
   , dba_cons_columns cc
   , dba_cons_columns rc
where 1=1
  and c.r_owner = r.owner 
  and c.r_constraint_name = r.constraint_name
  and cc.owner = c.owner
  and cc.table_name = c.table_name
  and cc.constraint_name = c.constraint_name
  and rc.owner = r.owner
  and rc.table_name = r.table_name
  and rc.constraint_name = r.constraint_name
  and c.constraint_type = 'R' 
  and ( c.owner like 'XX%' or c.owner like 'STAR%' )
  group by r.owner, r.table_name 
order by r.owner, r.table_name -- , c.constraint_name, cc.column_name
  ;

prompt show relations and join conditions for copy/past

set linesize 150
column par_to_child format A60
column joincond format A60
  
select  
  r.owner || '.' ||  r.table_name || 
    ' -< ' ||  c.owner || '.' || c.table_name  as par_to_child
, 'par.' || rc.column_name || ' = chld.' || cc.column_name || '  /* p -> c */' as joincond
--, c.owner , c.table_name, cc.column_name , r.owner, r.table_name, rc.column_name
--, c.constraint_name, r.constraint_name as rcon , rc.column_name , c.* 
from dba_constraints c
   , dba_constraints r
   , dba_cons_columns cc
   , dba_cons_columns rc
where 1=1
  and c.r_owner = r.owner 
  and c.r_constraint_name = r.constraint_name
  and cc.owner = c.owner
  and cc.table_name = c.table_name
  and cc.constraint_name = c.constraint_name
  and rc.owner = r.owner
  and rc.table_name = r.table_name
  and rc.constraint_name = r.constraint_name
  and c.constraint_type = 'R' 
  and ( c.owner like 'XX%' or c.owner like 'STAR%' )
  --group by c.owner, c.table_name 
order by r.owner, r.table_name , rc.column_name
  ;

spool off
