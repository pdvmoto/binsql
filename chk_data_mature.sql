

/*

technical check on data-model maturity

items and todolist:
. using: all_* views, so no dba_grants needed... 
. allow for >1 user... username in ( ): Edit the Defines!
. display-format.. combine list of table with : 1-no-pk, 2-no-UK, 3-no-idex_at_all
. yes or no include views ? 
. nr-indexe per table, when >15.. flag up ... ?
. tables with only 1-field indexes?


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
define usr3=OPS_VLTRADER
define usr4=XXYSS_FINANCIAL
define usr5=SCOTT

set verify off


column owner format A20
column object_type  format A10
column table_name format A25
column constr_x_schemas format A78
column constraint_name format A20 
column column_name format A15 
column data_type format A10

-- collect: nr-tables, nr-indexes, nr views

prompt count tables, indexes and objects in general

select owner, count (*) nr_tables
from all_tables 
where 1=1
and owner in ( user, '&usr1', '&usr2', '&usr3', '&usr4', '&usr5' )
group by owner;

select owner, count (*) nr_indexes
from all_indexes
where 1=1
and owner in ( user, '&usr1' , '&usr2')
group by owner;

select owner, object_type, count (*) nr_objs
from all_objects 
where 1=1
and owner in ( user, '&usr1', '&usr2', '&usr3', '&usr4', '&usr5' )
group by owner, object_type
order by owner, object_type;


-- tables without PK or UK

prompt tables whitout Unique-columnt (PK or UNIQUE-idx)

select t.owner, t.table_name  
from all_tables t 
where 1=1
and owner in ( user, '&usr1', '&usr2', '&usr3', '&usr4', '&usr5' )
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
where 1=1
and owner in ( user, '&usr1', '&usr2', '&usr3', '&usr4', '&usr5' )
and not exists ( select 'x' from all_indexes i
                  where i.table_owner = t.owner
                    and i.table_name = t.table_name )
and owner not like 'APEX%' 
order by owner, table_name;


-- tables without relations (in or out)

prompt Tables not used in FK-relatiohns, not "connected"

select t.owner, t.table_name from all_tables t
where 1=1
and owner in ( user, '&usr1', '&usr2', '&usr3', '&usr4', '&usr5' )
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
and owner in ( user, '&usr1', '&usr2', '&usr3', '&usr4', '&usr5' )
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
and owner in ( user, '&usr1', '&usr2', '&usr3', '&usr4', '&usr5' )
-- and t.owner in (select username from all_users ) 
and i.table_owner = t.owner
and i.table_name = t.table_name
and i.owner <> t.owner
order by t.owener, t.table_name


-- relations across schemas

prompt Relations across schemas (extra complexity)

select c.owner|| '.'|| c.constraint_name || 
'  -->  ' || c.r_owner || '.' || c.r_constraint_name as Constr_x_schemas
from  all_constraints c
where 1=1
and c.owner in  ( user, 'XXYSS_C_HUISMAN', '&usr1', '&usr2' )
and c.owner <> c.r_owner
order by c.owner, c.table_name, c.constraint_name, c.r_owner, c.r_constraint_name
;

-- columns name "date" with non-date type

prompt Columns that Might have to be of TYPE date/time.

select c.owner, c.table_name, c.column_name, c.data_type
from all_tab_columns c
where 1=1
and owner in ( user, '&usr1', '&usr2', '&usr3', '&usr4', '&usr5' )
and data_type not like 'DATE'
and data_type not like 'TIMEZ%'
and ( c.column_name like '%DATE' or c.column_name like '%DT' or c.column_name like '%TIME%' )
order by c.owner, c.table_name, c.column_name;

-- columns named num/nr/no with non-numeric type..

prompt Columns that Might need to be "Numeric".

select c.owner, c.table_name, c.column_name, c.data_type
from all_tab_columns c
where 1=1
and owner in ( user, '&usr1', '&usr2', '&usr3', '&usr4', '&usr5' )
and data_type not like 'NUMBER'
and data_type not like 'TIMEZ%'
and ( c.column_name like '%NUMBER%' or c.column_name like '%NR' or c.column_name like '%NO' 
   or c.column_name like 'NR%' or c.column_name like '%NO'  )
order by c.owner, c.table_name, c.column_name;

-- fk without index (only relevant if parent is upudated)

prompt FK whithout index, risk of deadlock, Only if parent needs update.

select c.owner, c.table_name, c.constraint_name
from all_constraints c
where 1=1
and owner in ( user, '&usr1', '&usr2', '&usr3', '&usr4', '&usr5' )
and c.constraint_type='R'
and exists 
       (select cc.position, cc.column_name
        from all_cons_columns cc
        where cc.owner = c.owner
          and cc.constraint_name=c.constraint_name  
        minus
        select ic.column_position as position, ic.column_name
        from user_ind_columns ic
        where ic.table_name=c.table_name
      ); 

-- grants directly from tables to other schemas (e.g. not via roles or public)

prompt Direct-Grants (too much inter-connected schemas?)

select 'Later, too many false-positives here...' as "Nah_TBD_later"
from Dual;


prompt '----- end of Report, for now -------'



