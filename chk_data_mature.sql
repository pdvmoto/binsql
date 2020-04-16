

/*

technical check on data-model maturity

items and todolist:
. using: all_* views, 
. allow for >1 user... username in ( )
. exclude default users, apex, CTXSYS etc..(use dflt-pwd-view for those?)
. combine list of table with : 1-no-pk, 2-no-UK, 3-no-idex_at_all



- collect: nr-tables, nr-indexes, nr views

-- total nr of tables

-- tables without PK or UK

-- tables without indexes

-- tables without relations (in or out)

-- tables without constraints (other than PK, U)

-- disabled or non-validated constraints.

-- tables without relations (in or out)

-- indexs on table in different schema

-- relations across schemas

-- columns name "date" with non-date type

-- columns named num/nr/no with non-numeric type..

-- fk without index (only relevant if parent is upudated)

-- grants directly from tables to other schemas (e.g. not via roles or public)


***/ 

define usr1=PCS
define usr2=XXYSS_C_HUISMAN
define usr3=SCOTT
define usr4=ABC
define usr5=DEF

set verify off


column owner format A25
column object_type  format A10
column table_name format A25


-- collect: nr-tables, nr-indexes, nr views

prompt count tables, indexes and objects in general

select owner, count (*) nr_tables
from all_tables 
where 1=1
and owner in ( user, '&usr1', '&usr2' )
group by owner;

select owner, count (*) nr_indexes
from all_indexes
where 1=1
and owner in ( user, '&usr1' , '&usr2')
group by owner;

select owner, object_type, count (*) nr_objs
from all_objects 
where 1=1
and owner in ( user, 'XXYSS_C_HUISMAN', '&usr1' '&usr2' ) 
group by owner, object_type
order by owner, object_type;


-- tables without PK or UK

prompt tables whitout Unique-columnt (PK or UNIQUE-idx)

select t.owner, t.table_name  
from all_tables t 
where 1=1
and owner in ( user, 'XXYSS_C_HUISMAN', '&usr1', '&usr2' ) 
and not exists ( select 'x' from all_constraints c
                   where c.owner = t.owner 
                   and t.table_name = c.table_name 
                   and constraint_type = 'P')
and not exists ( select 'x' from all_indexes i
                  where i.table_owner = t.owner
                    and i.table_name = t.table_name
                    and i.uniqueness = 'UNIQUE' )
and owner not like 'APEX%' 
order by owner, table_name;



-- tables without indexes

prompt Tables without indexes at all

select t.owner, t.table_name 
from all_tables t 
where owner in ( user, 'XXYSS_C_HUISMAN', '&usr1', '&usr2' ) 
and not exists ( select 'x' from all_indexes i
                  where i.table_owner = t.owner
                    and i.table_name = t.table_name )
and owner not like 'APEX%' 
order by owner, table_name;


-- tables without relations (in or out)

prompt Tables not used in FK-relatiohns, not "connected"

select t.owner, t.table_name from all_tables t
where 1=1
and owner in ( user, 'XXYSS_C_HUISMAN', '&usr1', '&usr2' ) 
and not exists ( select 'no_R_constraint' from all_constraints c
                  where c.constraint_type = 'R'
                  and c.owner = t.owner
                  and c.table_name = t.table_name)
and not exists ( select 'not_used_in_R_constraint' 
                   from all_constraints pk, all_constraints fk
                  where pk.constraint_type = 'P'
                    and pk.owner = t.owner
                    and pk.table_name = t.table_name
                    and fk.r_owner = t.owner
                    and fk.r_constraint_name = pk.constraint_name)
order by t.owner, t.table_name;


-- tables without constraints (other than PK)

prompt Tables without constraints (C or R)

select t.owner, t.table_name from all_tables t
where 1=1
and owner in ( user, 'XXYSS_C_HUISMAN' ) 
and not exists ( select 'no_C_or_R_constraint' from all_constraints c
                  where c.constraint_type in ( 'C', 'R' )
                  and c.owner = t.owner
                  and c.table_name = t.table_name)
order by t.owner, t.table_name;


-- disabled or non-validated constraints.

prompt Tables with Disabled or Non-Validated Constraints.
prompt TBD

-- indexs on table in different schema

prompt Tables with an index in another schema.

select t.owner, t.table_name, i.index_owner , i.index_name
from all_tables t
   , all_indexes i
where 1=1
and owner in ( user, 'XXYSS_C_HUISMAN', '&usr1', '&usr2' ) 
-- and t.owner in (select username from all_users ) 
and i.table_owner = t.owner
and i.table_name = t.table_name
and i.owner <> t.owner
order by t.owener, t.table_name


-- relations across schemas


-- columns name "date" with non-date type

-- columns named num/nr/no with non-numeric type..

-- fk without index (only relevant if parent is upudated)

-- grants directly from tables to other schemas (e.g. not via roles or public)


***/ 


