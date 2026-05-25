

column stmnt format A50 newline;
column gb format 999,999.999
column max_gb format 999,999.999
column incr_gb format 999,999.999

select
  tablespace_name
--df.file_name
, df.tablespace_name
, 'alter tablespace ' || tablespace_name || ' resize ' || to_char (round ( df.increment_by /(1024*1024*1024))) || 'G;'
, 'alter tablespace ' || tablespace_name
   || ' autoextend on next 1G maxsize ' || to_char (round ( df.maxbytes /(1024*1024*1024))) || 'G;'
, df.bytes / (1024*1024*1024)  GB
, df.maxbytes / (1024*1024*1024) max_gb
, df.increment_by / (1024*1024*1024) incr_gb
-- , df.*
from dba_data_files df;

