set doc on
set heading off
set feedback off
set verify off
column listfile heading "Listfile"  new_value listfile format a40;

spool db_info_spool.lst
select 'spool db_info_'||name||'_'||to_char(sysdate,'YYYYMMDD_HH24_MI') listfile 
from v$database;

spool off
@db_info_spool.lst

variable listfile varchar2(40);
begin 
  :listfile := '&listfile';
end;
/

remark AAA$READ.ME
doc

	Generate quick database overview
	spoolfile : db_info.lst
        Version 10g: 01/12/2005002

#

set linesize 80
-- set pagesize 200
set heading on

@@info01_v8.sql

@@info02.sql
@@info03_v8.sql
@@info04_v8.sql
@@info05_v8.sql
@@info06.sql
@@info07.sql
@@info08_v8.sql

spool off

prompt Listfile is in &listfile..lst


