
set timing on

-- DBMS_STATS.DELETE_INDEX_STATS ;

BEGIN
 DBMS_STATS.GATHER_SYSTEM_STATS(
  gathering_mode => 'START',
--   interval => 2,
   -- stattab => 'mystats',
   statid => 'first');
END;
/


-- @count dba_objects

prompt  now sleep for 4 min..

@sleep 240

@count dba_source 

BEGIN
 DBMS_STATS.GATHER_SYSTEM_STATS(
  gathering_mode => 'STOP',
--   interval => 2,
   -- stattab => 'mystats',
   statid => 'first');
END;
/
