

rem following defines prompt as user @ database
set heading off
set feedback off

spool sqlstart

SELECT 'set sqlprompt "'
  || to_char ( sys_context ( 'USERENV', 'SID' ) ) ||'-'
  || user
  || decode ( user                 -- if not same, show'[curr_schema]
            , sys_context('userenv','CURRENT_SCHEMA') , ''
            , '['|| sys_context('userenv','CURRENT_SCHEMA') || ']'
            )
  --|| '.' ||db.name
  --|| '.' || sys_context ('userenv','DB_UNIQUE_NAME')
  --|| '.' || sys_context ('userenv','DB_NAME')
  || '.' || decode ( sys_context ('userenv','DB_UNIQUE_NAME') -- only if differ
                   , sys_context ('userenv','DB_NAME')
                     , sys_context ('userenv','DB_NAME') || '(cdb$root)'
                   , sys_context ('userenv','DB_UNIQUE_NAME') 
                      || '.' || sys_context ('userenv','DB_NAME')
                   )
  --|| '.' ||gn.global_name
  || '.'|| SYS_CONTEXT('USERENV','SERVER_HOST')
  || ' > "'
FROM dual ;

spool off

@sqlstart.lst

set heading on
set feedback on

