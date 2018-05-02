
set timin on
set echo on

begin 
  dbms_stats.gather_index_stats (
    ownname          => '&1'
  , indname          => '&2'  
  , estimate_percent => 0.1		         -- null=compute
  , degree           => 4
  , granularity      => 'ALL'
  );
end;
/  

