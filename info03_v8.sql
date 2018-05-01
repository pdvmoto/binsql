doc
    info3_v8.sql

    Fragmentation: Tablespaces versus Free extents,
    should give general impression of fragmentation.
#

set head on
column "TabSp. Vs KBytes -->" format a20
column count format 99999
set feedback off
set pagesize 100
select tablespace_name                                  "TabSp. Vs KBytes -->"
,      count(bytes)                                             count
,      to_char(min(bytes) / 1024            , '999,999,999')    min
,      to_char(round(avg(bytes) ,0) / 1024  , '999,999,999')    avg
,      to_char(max(bytes) / 1024            , '999,999,999')    max
,      to_char(sum(bytes) / 1024            , '999,999,999')    sum
from dba_free_space
group by tablespace_name
/

prompt

doc
    info03_v8_v9.sql section 2

    Immediate Risks due to fragmentation:
    All next_extents over 50 percent of the max free_space.
    For Non Autoextensible datafiles.

#

column	seg_type     format a9
column	owner        format a12
column	tabspace     format a9
column	segment_name format a20
column	next_ext_kb  format 99999999999
column	sid          format a6
column  autoextensible format a4 heading Auto|Ext
set feedback on
-- Only possible in Oracle 8 otherwise the column autoextensible is not known.
select ds.segment_type			seg_type
,      ds.owner
,      ds.segment_name
,      ds.tablespace_name tabspace
,      to_char(ds.next_extent / 1024 ,'999,999,999') next_ext_kb
,      db.name sid
,      df.autoextensible 
from dba_segments ds
,    v$database db
,    dba_data_files df
where ds.next_extent > (select max(df.bytes)/2
                        from dba_free_space df
                        where df.tablespace_name = ds.tablespace_name
                        group by df.tablespace_name)
and   ds.segment_type IN ('TABLE','INDEX','CLUSTER')
and   df.autoextensible = 'NO'
order by ds.owner, ds.tablespace_name, ds.segment_type
/

set pagesize 14
clear columns
prompt
