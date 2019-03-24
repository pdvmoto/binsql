
-- fill in a sql_handle, possibly with plan_name, 
-- plan-name = null -> delete all with sql_handle

set serveroutput on

declare
  L_PLANS_DROPPED PLS_INTEGER;
begin


  L_PLANS_DROPPED := dbms_spm.drop_sql_plan_baseline( SQL_HANDLE  => '&1'
                                                    , PLAN_NAME  => null  );

  dbms_output.put_line( 'Plans Unpacked: ' || L_PLANS_DROPPED );
end;
/

