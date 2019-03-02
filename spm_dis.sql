
-- fill in a sql_handle, possibly with plan_name, 
-- plan-name = null -> delete all with sql_handle

set serveroutput on

declare
  L_PLANS_DROPPED PLS_INTEGER;
begin

  /**
  L_PLANS_DROPPED := dbms_spm.drop_sql_plan_baseline( SQL_HANDLE  => 'SQL_61c0e14131d4abe4'
                                                    , PLAN_NAME  => null  );
  **/

  L_PLANS_DROPPED := dbms_spm.ALTER_SQL_PLAN_BASELINE( 
      SQL_HANDLE  => '&1'
--     , PLAN_NAME  => '&2'  
    , ATRRIBUTE_NAME => 'enabled'  
    , ATRRIBUTE_VALUE => 'NO'  
     );

  dbms_output.put_line( 'Plans Disabled: ' || L_PLANS_DROPPED );
end;
/

