
doc
	find_empties.sql : generate list of empty tables.
  
    optional: to stdout or to table, or both.
    optional: specify list of schemas to check, DEFINE or arg?
    optional: warning for really large segments (100G?)

notes:
 - actual counts may take forever on really large systems, 
    pre-check on dba_tables.num_rows


-- need table
create table chk_empties as 
  select owner, table_name, num_rows, avg_row_len, blocks as segsize_bytes
  from dba_tables
  where 1=0;

create unique index chk_empties_pk on chk_empties ( owner, table_name );
alter table chk_empties add constraint chk_empties_pk primary key (owner, table_name ) using index chk_empties_pk; 

#


-- note code is adjusted from spin_pio: counting al tables to generate PIO

declare 
	starttime	    date ;
	str 		    varchar2(1000);
	x 		        number;
    n_counter       number := 0 ; -- count total nr of tables checked.
    n_actual_rows   number ; -- the count..
begin

      starttime := sysdate ;

      <<outer_for>>
      for i in 1..1 loop

       	for t in (select owner, table_name, avg_row_len 
                 from all_tables 
                 where (owner,table_name) not in 
                                                (select owner,table_name 
                                                from all_external_tables) 
                 and owner not in  ('SYS', 'SYSTEM' )
                 and owner not in ( select username from dba_users_with_defpwd) 
                 )

        loop

          begin

            -- only do more work if still inside requested time-window.
            IF  (sysdate - starttime) > &1 / (24 * 3600)
            THEN
              dbms_output.put_line ( 'find_empties: exit on timer.' ) ;
              exit outer_for ; 

            End IF ; -- timer

            -- exit outer_for when (sysdate - starttime) > &1 / (24 * 3600);

            -- do counting  
            execute immediate 
                ' select /*+ FULL(t) */ count(*) ' ||  
                ' from '||t.owner||'.'||t.table_name||' t ' || 
                ' where rownum < 100000000' into n_actual_rows;


          exception   -- overkill, for the moment...

            when others then null;
          end;


          insert into chk_empties ( 
            owner  , table_name  , num_rows     , avg_row_len  , segsize_bytes) 
          values ( 
            t.owner, t.table_name, n_actual_rows, t.avg_row_len, null) ;

          n_counter := n_counter + 1 ; 

          commit ; -- hmmm?

        end loop; -- t
      end loop; -- i, named as "outer_for"

      dbms_output.put_line ( 'find_empties: did ' || n_counter || ' tables.' ) ;

end ;
/

prompt 'List tables with no records in them'

column owner        format A20
column empty_tab    format A30

select owner, table_name  empty_tab
from chk_empties
where num_rows = 0 
order by owner, table_name
/


prompt 'List table with no records AND no known Dependencies'

select e.owner, e.table_name  empty_tab
from chk_empties e
where e.num_rows = 0 
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
where e.num_rows = 0 
order by e.owner, e.table_name
/

