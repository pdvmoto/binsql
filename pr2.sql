rem following defines prompt as user @ database
set heading off
set feedback off

spool sqlstart

SELECT 'set sqlprompt "' || user || ' @ ' ||global_name||' '
       || ' > "'
FROM        global_name     gn
/

SELECT 'host title "' || user || ' @ ' ||global_name||' '
       || ' > "'
FROM        global_name     gn
/
spool off

@sqlstart.lst

set heading on
set feedback on
