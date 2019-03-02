

set ver off
set feedb off
set head off

spool rerun_&1


-- try picking bind-vars from memory: define + assign

-- define variables

select 'Variable ' || replace ( bvc.name, ':', '' ) ||  ' ' || bvc.datatype_string ||';'  
from v$sql_bind_capture bvc
where 1=1 
and sql_id = '&1'
order by name, child_number, name;

prompt 
prompt

prompt BEGIN

select -- bvc.sql_id, 
--  bvc.child_number     chld
--, bvc.name             bind_variable
--, bvc.datatype_string  datatype
--, bvc.value_string     bind_value
--, bvc.* 
  '  ' ||  bvc.name ||  ' := ' 
  || decode ( substr ( bvc.datatype_string, 1, 3)  
            ,  'NUM' , nvl ( bvc.value_string, '''''' )
            ,  'VAR' , '''' || bvc.value_string || '''' 
            ,  'DAT' , ' to_date ( ' || '''' || bvc.value_string || ''', ''''YYYY-MM-DD HH24:MI:SS'''' ) '
            ,  bvc.value_string
            ) || '  ;'  from v$sql_bind_capture bvc
where 1=1 
-- and child_number = 1 
and sql_id = '&1'
order by name, child_number;


select 'END;'from dual ;
select '/'   from dual ;


prompt set autotrace on

prompt /* --                                                          */ 

prompt /* -- Paste formatted statement here, followed by semicolon... */
prompt /* --                                                          */
prompt /* --   SQL goes HERE, with semicolon added!                   */ 
promp  /* --                                                          */
prompt /* -- use this file to run stmnt with variables defined above  */
prompt /* -- SQL> @rerun_&1..lst                                      */
prompt /* --                                                          */

prompt set autotrace off

spool off

set feedb on
