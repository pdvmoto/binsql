
rem following defines prompt as :
rem    user [schema] @ database @ host (env)

set heading off
set feedback off

spool sqlstart

SELECT 'set sqlprompt "' 
       || to_char ( sys_context ( 'USERENV', 'SID' ) ) ||'-' 
       || user
       || decode ( user
           , sys_context('userenv','current_schema') , ''
           , ' ['|| sys_context('userenv','current_schema') || ']'
          )
       --|| '-' || to_char ( sys_context ( 'USERENV', 'SID' ) )
       || ' @ ' ||db.name
       || ' @ '|| SYS_CONTEXT('USERENV','SERVER_HOST')       
       || decode  (SYS_CONTEXT('USERENV','SERVER_HOST') 
            , 'alp-dbs00004',    ' (PROD)'
            , 'ip-172-20-2-131', ' (KT)'
            , 'ip-172-20-0-99' , ' (TEMP)'
            , 'ip-172-20-0-194' , ' (TEMP)'
            , 'ala-dbs00004',     ' (ACC)'
            , 'ip-172-20-0-205', ' (ACC)'
            , 'ip-172-20-2-216', ' (STC-old)'
            , 'ip-172-20-1-87',  ' (STC)'
            , 'ald-dbs00016',    ' (Dev-19)'
            , 'alt-dbs00016',    ' (Tst-19)'
            , ' (-chk-env-)')       
       || ' > "'
FROM    v$database      db
;

SELECT 'host title "' 
       || to_char ( sys_context ( 'USERENV', 'SID' ) ) ||'-' 
       || user
       || decode ( user
           , sys_context('userenv','current_schema') , ''
           , ' ['|| sys_context('userenv','current_schema') || ']'
          )
       --|| '-' || to_char ( sys_context ( 'USERENV', 'SID' ) )
       || ' @ ' ||db.name
       || ' @ '|| SYS_CONTEXT('USERENV','SERVER_HOST')       
       || decode  (SYS_CONTEXT('USERENV','SERVER_HOST') 
            , 'alp-dbs00004',    ' (PROD)'
            , 'ip-172-20-2-131', ' (KT)'
            , 'ip-172-20-0-99' , ' (TEMP)'
            , 'ip-172-20-0-194' , ' (TEMP)'
            , 'ala-dbs00004',     ' (ACC)'
            , 'ip-172-20-0-205', ' (ACC)'
            , 'ip-172-20-2-216', ' (STC-old)'
            , 'ip-172-20-1-87',  ' (STC)'
            , 'ald-dbs00016',    ' (Dev-19)'
            , 'alt-dbs00016',    ' (Tst19)'
            , ' (-chk-env-)')       
       || ' > "'
FROM    v$database      db
;


spool off

@sqlstart.lst

prompt "The SQL Prompt is set by pr5.sql"

set heading on
set feedback on
