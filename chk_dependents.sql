
set pagesize 50
set linesize 120
set trimspool on

column owner format A25
column table_name format A25

-- no rows and no pl-sql dependencies
select owner, table_name from dba_tables t
where 1=1
  and t.owner like 'XXYSS%'
  and ( t.table_name not like 'MLOG$%' and  t.table_name not like 'RUP%'  )
  and exists ( select 'x'   /* does it have 0 rows in last count */
                 from chk_counts c
                where c.owner = t.owner
                 and  c.table_name = t.table_name
                 and c.sampled_dt = (select max ( sampled_dt) from chk_counts )
                 and c.num_rows_counted = 0
             )
and not exists ( select 'x'  /* does it have dependents exclude own-triggers and own-sequence */
                  from dba_dependencies d
                where d.referenced_owner = t.owner
                and d.referenced_name = t.table_name
                and d.referenced_type = 'TABLE' 
                /* exclude triggers on same table, and exclude seq with table-name) */
                /* and not exists */ 
                )
order by t.owner, t.table_name ; 

