set doc on
set heading off
set feedback off

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
        Version: 8.1.5 Date: 1/1/2000

#

set linesize 80
-- set pagesize 200
set heading on
set feedback on

@@info01_v8.sql

@@info02.sql
@@info03_v8.sql
@@info04.sql
@@info05.sql
@@info06.sql
@@info07.sql

spool off

prompt Listfile is in &listfile..lst



