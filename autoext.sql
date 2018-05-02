rem
rem Script: autoext.sql
rem
rem Usage : This script list autoextend information
rem
rem Rights: Select rights on dba_data_files
rem
rem Author: OCC (YVB)
rem
rem Date  : 18-June-2001
rem

set pagesize 50
set linesize 96
col file_name format a36 head "Datafile Name"
col tablespace format a8 head Table|Space
col status format a9 head Status
col mb format 99999 head FSize|in-Mb
col aut format a4 head Auto|Extd
col maxb format 99999 head Max|Mb
col inc format 9999 head Incr|Size
col sum format 9999 head Free|Mb
col fil format a3 head File|Id
col rel format a3 head Rel|FNo

select rtrim(ddf.FILE_NAME) file_name
, rtrim(ddf.TABLESPACE_NAME) tablespace
, ddf.BYTES/(1024*1024) mb
-- , ddf.STATUS
, ddf.AUTOEXTENSIBLE aut
, ddf.MAXBYTES/(1024*1024) maxb
, ddf.INCREMENT_BY*8/1024 inc
, sum(dfs.bytes) / (1024*1024) sum
, to_char(ddf.FILE_ID) fil
-- , to_char(ddf.RELATIVE_FNO) rel
from 
--  dba_data_files ddf
  (          select * from dba_temp_files 
   union all select * from dba_data_files ) ddf
, dba_free_space    dfs
where ddf.file_id = dfs.file_id
group by dfs.file_id
, rtrim(ddf.FILE_NAME)
, rtrim(ddf.TABLESPACE_NAME)
, ddf.BYTES/(1024*1024)
, ddf.STATUS
, ddf.AUTOEXTENSIBLE
, ddf.MAXBYTES/(1024*1024)
, ddf.INCREMENT_BY*8/1024
, to_char(ddf.FILE_ID)
, to_char(ddf.RELATIVE_FNO)
order by rtrim(ddf.file_name)
;
