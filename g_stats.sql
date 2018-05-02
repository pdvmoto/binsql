
set timin on
set echo on

begin

  dbms_stats.gather_schema_stats (
    ownname          => '&1'
  , estimate_percent => 100		         -- null=compute
  , block_sample     => false                    -- false=slow, better
  , method_opt       => 'FOR ALL INDEXED COLUMNS SIZE 1 ' -- slow, complete
                                                 -- size 1 for parallel, auto ?
  , granularity      => 'ALL'                    --   
  , cascade          => true                     -- true for completeness
  );

end;
/
