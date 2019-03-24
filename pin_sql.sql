
-- 
-- &1 is sqlid, &2 is plan... what happens.>?
--
-- test on @pin_sql a415npv0h5s1v 2344105768 


set echo on 

DECLARE
 i number;
BEGIN
   -- i := sys.dbms_spm.load_plans_from_cursor_cache (‘a415npv0h5s1v’, 2344105768);
   i := sys.dbms_spm.load_plans_from_cursor_cache ( ‘a415npv0h5s1v’ );
END;
/
