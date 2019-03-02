
prompt .
prompt showing plan from AWR ...
prompt .


select   *
from     table( DBMS_XPLAN.DISPLAY_AWR( SQL_ID => '&1'
                                      , PLAN_HASH_VALUE => '&2'
                                      , FORMAT => 'ALL' ) );
