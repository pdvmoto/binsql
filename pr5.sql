
rem following defines prompt as :
rem    user [schema] @ database @ host (env)

set heading off
set feedback off

spool sqlstart

SELECT 'set sqlprompt "' 
       || user
       || decode ( user
           , sys_context('userenv','current_schema') , ''
           , ' ['|| sys_context('userenv','current_schema') || ']'
          )
       || ' @ ' ||db.name
       || ' @ '|| SYS_CONTEXT('USERENV','SERVER_HOST')       
       || decode  (SYS_CONTEXT('USERENV','SERVER_HOST') 
            , 'ip-172-20-2-109', ' (PROD)'
            , 'ip-172-20-2-131', ' (KT)'
            , 'ip-172-20-0-99' , ' (TEMP)'
            , 'ip-172-20-0-194' , ' (TEMP)'
            , 'ip-172-20-1-142', ' (ACC)'
            , 'ip-172-20-0-226', ' (ACC)'
            , 'ip-172-20-0-253', ' (ACC)'
            , 'ip-172-20-2-216', ' (STC-old)'
            , 'ip-172-20-1-87',  ' (STC)'
            , 'ip-172-20-0-23',  ' (SC)'
            , ' (-check-env-)')       
       || ' > "'
FROM    v$database      db
;

spool off

@sqlstart.lst

prompt "The SQL Prompt is set by pr5.sql"

set heading on
set feedback on
