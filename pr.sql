
rem following defines prompt as user @ database
set heading off
set feedback off

spool sqlstart

SELECT 'set sqlprompt "' || user || ' @ ' ||db.name||' @ '||
       RTRIM(SUBSTR ( p.program, INSTR ( p.program, '@' ) + 1
                        ,   INSTR ( p.program, ' ' )
                            -  INSTR ( p.program, '@' )  ) )
       || ' > "'
FROM    v$database      db
,       global_name     gn
,       v$process       p
where p.program LIKE '%(PMON)%'
/

spool off

@sqlstart.lst

set heading on
set feedback on
