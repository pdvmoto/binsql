
-- find the SPM handles, preferably in SQLDEV
-- verify that this is the sql ()or likely sql) that causes thed ORA-13831 
-- next: use spm_drop to remove the plan

-- this was the onlyh thing that worked.
select b.origin, b.created, last_executed
, '@spm_drop ' || sql_handle as cmd
, b.* 
from dba_sql_plan_baselines b 
where  -- sql_text like '%AND (t10.ID = t9.PVR_ID)))%ORDER BY t1.ARRIVAL_TIME_DRV'
and origin = 'MANUAL-LOAD'
order by b.created desc ; 


