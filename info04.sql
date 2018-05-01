rem following fires correct version of the script
set heading off
set feedback off

spool info04.lst

select decode (
               substr(banner, (instr(banner,'.') -1), 1) -- Returns version number (7,8,9 or 0=10 or 1=11)
		, '7', '@info04_v7.sql'
                , '8', '@info04_v8.sql'
                , '9', '@info04_v0.sql'
                , '0', '@info04_v0.sql'
                , '1', '@info04_v0.sql'
                , '2', '@info04_v0.sql'
		, '@info01_vo.sql' ) 
from v$version where rownum <2; 

spool off

@info04.lst

set heading on
set feedback on
