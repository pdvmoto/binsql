

set ver off
set feedb off
set head off

@set_nls

spool rerun_&1


-- try picking bind-vars from memory: define + assign

-- define variables

select 'Variable ' || replace ( bvc.name, ':', 'b' ) ||  ' ' || bvc.datatype_string ||';'  
from v$sql_bind_capture bvc
where 1=1 
and sql_id = '&1'
and child_number = 0
order by name, child_number, name;

prompt  /*  */
prompt  /* -- now all varibles declared, will try to assign from cursor-0 */
prompt  /*  */

prompt BEGIN

select  --bvc.sql_id
-- , bvc.child_number     chld
--, bvc.name             bind_variable
--, bvc.datatype_string  datatype
--, bvc.value_string     bind_value
--bvc.*
--ANYDATA.AccessTimestamp(bvc.value_anydata)
-- ANYDATA.Accessdate(bvc.value_anydata)
  '  ' ||  replace ( bvc.name, ':', ':b' ) ||  ' := '
  || decode ( substr ( bvc.datatype_string, 1, 3)
            ,  'NUM' , nvl ( bvc.value_string, '''''' )
            ,  'VAR' , '''' || bvc.value_string || ''''
            ,  'DAT' , '      to_date ( ' || '''' || ANYDATA.Accessdate(bvc.value_anydata) || ''', ''YYYY-MM-DD HH24:MI:SSXFF'' ) '
            ,  'TIM' , ' to_timestamp ( ' || '''' || ANYDATA.AccessTimestamp(bvc.value_anydata) || ''', ''YYYY-MM-DD HH24:MI:SSXFF'' ) '
            ,  bvc.value_string
            ) || '  ;'  from v$sql_bind_capture bvc
where 1=1
-- and child_number = 1
and child_number = 0
and sql_id = '&1'
order by name, child_number;


select 'END;'from dual ;
select '/'   from dual ;



prompt set autotrace off

prompt /* --                                                          */ 
prompt /* -- Paste formatted statement here, followed by semicolon... */
prompt /* --                                                          */
prompt /* --   SQL goes HERE, with semicolon added!                   */ 
promp  /* --   Will include explain to catch stmnt.                   */
prompt /* --                                                          */
prompt /* -- use this file to edit + run stmnt with variables         */
prompt /* -- SQL> ed rerun_&1..lst                                      */
prompt /* -- SQL> @rerun_&1..lst                                        */
prompt /* --                                                          */


prompt /*  first execute goes here, can use output from xplan to get SQL */
prompt /*  please remove plan...                                     */
SELECT plan_table_output FROM table(DBMS_XPLAN.DISPLAY_CURSOR('&1', 0, 'BASIC' ));


-- and repeat with autotrace on

prompt 
prompt  
prompt set autotrace on
prompt set timing on
prompt set linesize 150 
prompt set feedback on
prompt 
prompt /* -- and 2nd run with autotrace on */

prompt /
 
prompt set autotrace off
prompt set timing off

prompt /* --                                                          */
prompt /* -- use this file to edit and run stmnt with variables       */
prompt /* -- SQL> ed rerun_&1..lst                                      */
prompt /* -- SQL> @rerun_&1..lst                                      */
prompt /* --                                                          */

spool off
set feedb on
