
-- usage: SQL> @spm_load sql_id plan_hash_val

-- notes: the sql_id and plan_hash can be picked from explain-plan.

-- load plans for given SQL_id,
-- fix => 'YES' should fix the plan 
--  question : test fixing correct plan straight away.


set serveroutput on

declare
    v_result pls_integer;
begin
    v_result := dbms_spm.load_plans_from_cursor_cache(
              sql_id => '&1'                   -- 'g59s8dj44w454'
            , plan_hash_value => '&2'  -- '1977243187'
                                               -- , plan_hash_value => '4208312999'
            , fixed => 'YES' 
     );

  dbms_output.put_line (' nr basewlines : ' || v_result);
end;
/

