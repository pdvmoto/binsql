/*
 
usage : segsizes USER% SEGMENT%

result will be storage used by the user(s) for given segments.

*/

column table_name    format A10
column num_rows      format 99,999,999
column blocks        format 999,999   
column empty_blocks  format 9,999    head empblck
column avg_space     format 9,999    head avgspc
column chain_cnt     format 9,999    head chncnt
column avg_rowlen    format 9,999    head avgrow

column segment_name     format A20
column partition_name   format A25
column bytes         format 99,999,999 
column kbytes        format 99999999 
column extents	     format 9,999

set verify off

/*
Wishlist:
 - enter user.obj, use upper(beforedot) = owner and upper (afterdot||%) like object
 - enter schema as well..

begin

select 'segsize:  Please specify a USERNA[%] and a SEGM[%]'
from dual
where '&1'||'&2' is null ;

end;
/

*/

-- tables, to have rows + chain-info
select 
table_name, num_rows, blocks, empty_blocks, avg_space, chain_cnt, avg_row_len, compression
from all_tables
where table_name like upper ( '&2'||'%' )
  and owner      like upper ( '&1'||'%') 
order by table_name
/

-- segments
select 
segment_name,  partition_name, bytes / 1024 as kbytes, blocks, extents
from dba_segments
where segment_name like upper ( '&2'||'%' )
  and owner        like upper ( '&1'||'%') 
order by segment_name, partition_name
/


select 
  'Total ' as segment_name, ' ' as partition_name
--, segment_name            ,  partition_name
, sum ( bytes / 1024 ) as kbytes
, sum ( blocks ) as blocks
, sum (extents ) as extents
from dba_segments
where segment_name like upper ( '&2'||'%' )
  and owner        like upper ( '&1'||'%') 
and 1=1 -- owner = user
--group by 'Total ', ' ' 
/
