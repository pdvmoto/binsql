

column  usr_tbl format A35 heading user_and_table
column i1 format A30 heading index1
column i2 format A30 heading index2

/*** 

tips:
 - include num_rows and blocks on first pass
 - inlcude dist-keys
 
pre-calculate nr cols, and other notes

-- ignore table_owner-name... assume same as index
-- better: use analytics+windows to get all data from ind_columns... 
-- find : nr_cols-over-indexname, 
-- 
with i1 as ( select i1.owner, i1.table_name, i1.index_name , count (*) nr_cols
    from all_indexes i1
       , all_ind_columns ic1
    where ic1.index_owner = i1.owner
      and ic1.table_owner = i1.table_owner
      and ic1.index_name = i1.index_name
      group by i1.owner, i1.table_name, i1.index_name )
select i1.owner, i1.table_name , i1.index_name , i1.nr_cols as more_cols, i2.index_name, i2.nr_cols  
  from i1  i1 
     , i1  i2
where i1.owner = i2.owner
  and i1.table_name = i2.table_name
  and i1.index_name <> i2.index_name 
  and i1.nr_cols > i2.nr_cols 
;

***/


set linesize 120
set headin on
set pagesize 50

spool find_dbl_ind


SELECT
    i1.table_owner || '.' || i1.table_name as usr_tbl , 
    i1.index_name as i1,
    i2.index_name as i2
    --,
    --i1.*,
    --i2.*
FROM
    dba_indexes i1,
    dba_indexes i2
WHERE
    1 = 1
    AND i1.table_owner = 'PCS'
    AND i1.table_owner = i2.table_owner
    and i1.table_name  = i2.table_name 
    AND i1.index_name <> i2.index_name
    and i1.index_name > i2.index_name  -- (saves half the results)
        AND  exists (-- all fields of i1 covered by same fields of i2
               SELECT
                     ic1.column_name
                 FROM
                     dba_ind_columns ic1,
                     dba_ind_columns ic2
                 WHERE 1=1
                     and ic1.table_owner = i1.table_owner
                     and ic1.index_name  = i1.index_name
                     and ic2.table_owner = i2.table_owner
                     and ic2.index_name  = i2.index_name
                     AND ic1.column_name = ic2.column_name
                     AND ic1.column_position = ic2.column_position
)
order by i1.table_name, i1.index_name, i2.index_name ;

spool off




prompt, now try more precise

column  usr_tbl format A35 heading user_and_table
column i1 format A30 heading index1
column i2 format A30 heading index2


set linesize 120
set headin on
set pagesize 50

spool find_dbl_ind


create table chk_dbl_ind as 
SELECT
    i1.table_owner, i1.table_name,
    i1.index_name as i1,
    i2.index_name as i2
    --,
    --i1.*,
    --i2.*
FROM
    dba_indexes i1,
    dba_indexes i2
WHERE
    1 = 1
    AND i1.table_owner = 'PCS'
    AND i1.table_owner = i2.table_owner
    and i1.table_name  = i2.table_name 
    AND i1.index_name <> i2.index_name
    and i1.index_name > i2.index_name  -- (saves half the results)
        AND  exists (-- all fields of i1 covered by same fields of i2
               SELECT
                     ic1.column_name
                 FROM
                     dba_ind_columns ic1,
                     dba_ind_columns ic2
                 WHERE 1=1
                     and ic1.table_owner = i1.table_owner
                     and ic1.index_name  = i1.index_name
                     and ic2.table_owner = i2.table_owner
                     and ic2.index_name  = i2.index_name
                     AND ic1.column_name = ic2.column_name
                     AND ic1.column_position = ic2.column_position
)
order by i1.table_name, i1.index_name, i2.index_name ;

spool off

