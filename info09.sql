rem following fires correct version of the script
set heading off
set feedback off

spool info09.lst

select decode (
               substr(banner, (instr(banner,'.') -1), 1) -- Returns version number (7,8,9 or 0=10 or 1=11)
		, '7', '@info09_vo.sql'
                , '8', '@info09_vo.sql'
                , '9', '@info09_vo.sql'
                , '0', '@info09_v10.sql'
                , '1', '@info09_v10.sql'
		, '@info01_vo.sql' ) 
from v$version where rownum <2; 

spool off

@info09.lst

set heading on
set feedback on