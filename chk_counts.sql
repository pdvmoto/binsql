
doc
	chk_counts.sql : generate + store count of tables

    use num_rows first, add actual count later.

    optional: specify list of schemas to check, DEFINE or arg?
    optional: avoid really large segments (100G?)
    optional: include GTT tables ?

todo:
    - separate LOBSEG and LOBIND
    - sum size of INDEXES on table (and exclude LOBIND)
    - speed up by combining the 3 update-stmnts to 1.

notes:
 - actual counts may take forever on really large systems, 


-- need table

-- drop table chk_counts; 
create table chk_counts as 
  select o.created as sampled_dt          /* preferably truncated date */
       , o.owner, t.table_name            /* pk is sample + owner + table */
       , t.num_rows, t.avg_row_len, t.blocks
       , t.num_rows as num_rows_counted
       , t.blocks as segsize_bytes, t.blocks as lobsize_bytes  
       , t.num_rows as num_indexes, t.num_rows as num_constraints
       , o.last_ddl_time
       , t.last_analyzed
  from dba_tables t
     , dba_objects o
  where 1=0
    and t.owner = o.owner
    and t.table_name = o.object_name 
    and o.object_type = 'TABLE' ;

create unique index chk_counts_pk on chk_counts (owner, table_name, sampled_dt);
alter table chk_counts 
    add constraint chk_counts_pk primary key (owner, table_name , sampled_dt) 
    using index chk_counts_pk; 

note: running can take up to 1 min.

#

set serveroutput on
set feedback on

declare 
	dt_starttime	    date ;
    dt_sample_dt        date ;
	str 		    varchar2(1000);
	x 		        number;
    n_counter       number := 0 ; -- count total nr of tables checked.
    n_recs          number := 0 ; -- counter
    n_actual_rows   number ; -- the count..
begin

  dt_starttime := sysdate ;
  dt_sample_dt := sysdate ; -- trunc ( sysdate ) ; /* consider trunc */

  -- start easy, beware: positional columns
  insert into chk_counts 
  select dt_sample_dt as sampled_dt  /* preferably truncated date */
       , o.owner, t.table_name            /* pk is sample + owner + table */
       , t.num_rows, t.avg_row_len, t.blocks
       , null as num_rows_counted
       , null as segsize_bytes, null as lobsize_bytes
       , null as num_indexes, null as num_constraints
       , o.last_ddl_time
       , t.last_analyzed
  from dba_tables t
     , dba_objects o
  where 1=1
    and t.owner = o.owner
    and t.table_name = o.object_name
    and o.object_type = 'TABLE' 
    and t.temporary = 'N' ;

    n_actual_rows := SQL%rowcount ; 

    dbms_output.put_line ( 'chk_counts: found ' || n_actual_rows || ' tables.' ) ;

  update chk_counts c
  set c.num_indexes =  (select count (*)   /* consider nullif, to 0 -> NULL */
                       from dba_indexes i
                       where c.owner = i.table_owner 
                       and c.table_name = i.table_name )
  where c.sampled_dt = dt_sample_dt ;

  update chk_counts c
  set c.num_constraints =  (select count (*)  
                           from dba_constraints tc
                           where c.owner = tc.owner 
                           and c.table_name = tc.table_name )
  where c.sampled_dt = dt_sample_dt ;


  -- add: Segsizes and lobsizes..
  
  update chk_counts c 
  set segsize_bytes = 
  ( select 
      /* s.owner, s.segment_name , */ 
      nullif ( sum ( s.bytes ), 0 ) bytes /* consider NULLIFF to 0 -> null  */
    from dba_segments s
       , ( select t.owner, t.table_name
           from dba_tables t
           where t.table_name   = c.table_name 
           and   t.owner        = c.owner
  ) t
  where s.owner = t.owner
    and s.segment_name = t.table_name 
    group by s.owner, s.segment_name 
  ) 
  where c.sampled_dt =  dt_sample_dt ;

  -- lobs, but exclude the lob-index, we catch lob-indexes later.
  update chk_counts c 
  set lobsize_bytes = 
  ( select
    -- s.owner, l.table_name
    --, l.column_name, s.segment_name,  nvl( s.partition_name, '-' ) part
      nullif ( sum (s.bytes), 0 )  as bytes
    from dba_segments s
    , ( select t.owner, t.table_name,  t.segment_name, t.index_name
        from dba_lobs t
        where t.table_name   = c.table_name 
          and t.owner        = c.owner 
      ) l
    where s.owner = l.owner
    and ( /* s.segment_name = l.index_name or */ /* can skip the lob-ind */
             s.segment_name = l.segment_name  
        )
  ) 
  where c.sampled_dt = dt_sample_dt 
  and 1=1 -- disable bcse too slow
  ; 



  -- finally, for segments under or over certain size: COUNT

  commit ;
 
end ;
/

prompt 'List tables with no records in them'

column owner        format A20
column empty_tab    format A30

select owner, table_name  empty_tab
from chk_empties
where 1=0
and num_rows = 0 
order by owner, table_name
/


prompt 'List table with no records AND no known Dependencies'

select e.owner, e.table_name  empty_tab
from chk_empties e
where 1=0
and e.num_rows = 0 
and not exists ( select 'x' from dba_dependencies d
where d.referenced_owner = e.owner 
  and d.referenced_type = 'TABLE'
  and d.referenced_name = e.table_name )
order by e.owner, e.table_name
/

prompt 'List tables that do have dependencies'

column nr_depts format 9999 

select e.owner
, e.table_name  empty_tab
, ( select  count (*) as nr_depts from dba_dependencies d1 
    where d1.referenced_owner = e.owner
      and d1.referenced_type = 'TABLE' 
      and d1.referenced_name = e.table_name ) as nr_depts
from chk_empties e
where 1=0
and e.num_rows = 0 
order by e.owner, e.table_name
/

