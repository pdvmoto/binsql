
rem following defines prompt as user @ database
set heading off
set feedback off

spool sqlstart

SELECT 'set sqlprompt "' || user || ' @ ' ||db.name||' @ '|| i.instance_name
       || ' > "'
FROM    v$database      db
,       v$instance      i
/

spool off

@sqlstart.lst

set heading on
set feedback on
