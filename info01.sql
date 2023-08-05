rem following fires correct version of the script
set heading off
set feedback off

spool info01.lst

select decode (
               substr(banner, (instr(banner,'.') -1), 1) -- Returns version number (7,8,9 or 0=10 or 1=11)
		, '7', '@info01_v7.sql'
                , '8', '@info01_v8.sql'
                , '9', '@info01_v9.sql'
                , '0', '@info01_v10.sql'
                , '1', '@info01_v10.sql'
                , '2', '@info01_v10.sql'
		, '@info01_vo.sql' ) 
from v$version where rownum <2; 

spool off

@info01.lst

set heading on
set feedback on
