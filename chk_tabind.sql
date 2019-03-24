
/*
 
usage : chk_tabind  USER% SEGMENT%

result will be indexed-columsn on table 

*/

column table_name    format A20 trunc
column index_name    format A30 trunc
column num_rows      format 9,999,999,999
column blocks        format    99,999,999   
column empty_blocks  format 9,999    head emblck
column avg_space     format 999      head spc
column chain_cnt     format 999      head chai
column avg_row_len   format 999      head rlen
column compression   format A4 trunc head comp

column index_type    format A4 trunc head type
column uniqueness    format A3 trunc head unq
column blevel        format 99       head bl
column distinct_keys format 999,999,999 head dist_keys

column segment_name     format A30 trunc
column segment_type     format A1  trunc head t
column partition_name   format A15 trunc
column bytes         format 99,999,999 
column kbytes        format 99,999,999 
column mb            format 999,999.9
column extents	     format 9,999    head xtnds

column pos            format 999 
column column_name    format A30 trunc

set verify off

/*
Wishlist:
 - enter user.obj, use upper(beforedot) = owner and upper (afterdot||%) like object
 - enter schema as well..
 - lobindexes and lob-columns ?
 - FBIs

begin

select 'chk_tabind:  Please specify a USERNA[%] and a SEGM[%]'
from dual
where '&1'||'&2' is null ;

end;
/

*/

-- ruler
prompt ....,....1....,....2....,....3....,....4....,....5....,....6....,....7....,....8

-- indexes on those tables
select table_name, index_name, index_type, uniqueness, blevel, distinct_keys
from all_indexes
where table_name   like upper ( '&2'||'%' )
  and table_owner  like upper ( '&1'||'%')
order by table_name, index_name
/

-- segments

select -- s.owner, 
  s.table_name  -- , s.seq
, s.segment_type, s.segment_name, s.partition_name, s.bytes/ (1024*1024)  as  mb
, s.blocks
from 
(SELECT 1 as seq                         -- need this for ordering, nodisplay
    , owner, segment_name as table_name  --  owner and table for order/group
    , segment_type, segment_name
    , partition_name, bytes              -- this the actual segment_info
    , blocks
 FROM dba_segments
 WHERE segment_type = 'TABLE'
 UNION ALL
 SELECT 2 as seq
      , i.owner, i.table_name
      , s.segment_type, s.segment_name
      , s.partition_name , s.bytes
      , s.blocks
 FROM dba_indexes i, dba_segments s
 WHERE s.segment_name = i.index_name
 AND   s.owner = i.owner
 AND   s.segment_type = 'INDEX' 
 UNION ALL
 SELECT 3 as seq
      , l.owner, l.table_name
      , s.segment_type, s.segment_name
      , s.partition_name, s.bytes
      , s.blocks
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.segment_name
 AND   s.owner = l.owner
 AND   s.segment_type = 'LOBSEGMENT'
 UNION ALL
 SELECT 3.seq, l.owner, l.table_name
      , s.segment_type, s.segment_name
      , s.partition_name, s.bytes
      , s.blocks
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.index_name
 AND   s.owner = l.owner
 AND   s.segment_type = 'LOBINDEX')  s
WHERE s.owner      like upper ( '&1'||'%')
  and s.table_name like upper ( '&2'||'%' ) 
order by s.owner, s.table_name, s.seq, s.segment_name, s.partition_name
/

-- later: create a total per table.

select 
  'Total:' as table_name  
, ' ' as segment_type, ' ' as segment_name, ' ' as partition_name, sum ( s.bytes) / (1024*1024)  as  mb
from 
(SELECT 1 as seq                         -- need this for ordering, nodisplay
    , owner, segment_name as table_name  --  owner and table for order/group
    , segment_type, segment_name
    , partition_name, bytes              -- this the actual segment_info
 FROM dba_segments
 WHERE segment_type = 'TABLE'
 UNION ALL
 SELECT 2 as seq
      , i.owner, i.table_name
      , s.segment_type, s.segment_name
      , s.partition_name , s.bytes
 FROM dba_indexes i, dba_segments s
 WHERE s.segment_name = i.index_name
 AND   s.owner = i.owner
 AND   s.segment_type = 'INDEX' 
 UNION ALL
 SELECT 3 as seq
      , l.owner, l.table_name
      , s.segment_type, s.segment_name
      , s.partition_name, s.bytes
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.segment_name
 AND   s.owner = l.owner
 AND   s.segment_type = 'LOBSEGMENT'
 UNION ALL
 SELECT 3.seq, l.owner, l.table_name
      , s.segment_type, s.segment_name
      , s.partition_name, s.bytes
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.index_name
 AND   s.owner = l.owner
 AND   s.segment_type = 'LOBINDEX')  s
WHERE s.owner      like upper ( '&1'||'%')
  and s.table_name like upper ( '&2'||'%' ) 
group by 'Total', ' ' 
/

-- index columns

break on index_name

select ic.index_name, ic.column_position , ic.column_name  
from dba_ind_columns  ic
where 1=1
  and ic.table_owner      like upper ( '&1'||'%')
  and ic.table_name like upper ( '&2'||'%' ) 
order by ic.index_owner, ic.table_name, ic.index_name , ic.column_position
;
