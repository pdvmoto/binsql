
doc
    Fragmentation: Tablespaces versus Free extents,
         should give general impression of fragmentation.
#

column "TabSp. Vs KBytes -->" format a20
column count format 99999
select tablespace_name                                  "TabSp. Vs KBytes -->"
,      count(bytes)                                             count
,      to_char(min(bytes) / 1024            , '999,999,999')    min
,      to_char(round(avg(bytes) ,0) / 1024  , '999,999,999')    avg
,      to_char(max(bytes) / 1024            , '999,999,999')    max
,      to_char(sum(bytes) / 1024            , '999,999,999')    sum
from dba_free_space
group by tablespace_name
/


doc
	Immediate Risks due to fragmentation:
    	All next_extents over 50 percent of the max free_space.
#

COLUMN	segment_type FORMAT A12
COLUMN	owner        FORMAT A12
COLUMN	warning      FORMAT A8
COLUMN	segment_name FORMAT A24
COLUMN	next_extent	 FORMAT 9999999999
COLUMN	sid          FORMAT A5
select ds.segment_type
,      ds.owner
,      ds.segment_name
,      ds.tablespace_name warning
,      to_char(ds.next_extent,'999,999,999') next_extent
,      db.name sid
from dba_segments ds
,    v$database db
where ds.next_extent > (select max(df.bytes)/2
                        from dba_free_space df
                        where df.tablespace_name = ds.tablespace_name
                        group by df.tablespace_name)
and   ds.segment_type IN ('TABLE','INDEX','CLUSTER')
order by ds.owner, ds.tablespace_name, ds.segment_type
/
