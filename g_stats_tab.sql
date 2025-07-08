
set timin on
set echo on

begin 

  dbms_stats.delete_table_stats (
    ownname          => '&1'
  , tabname          => '&2' 
  );

end;
/

-- accept pause &abc

begin 

  dbms_stats.gather_table_stats (
    ownname          => '&1'
  , tabname          => '&2' 
  , estimate_percent => null		         -- null=compute
  , block_sample     => false                    -- false=slow, better
  , method_opt       => 'FOR ALL INDEXED COLUMNS SIZE 1 ' -- all/auto = slow, complete
                                                 -- seems to yield avglen=100 .... ??
  , degree           => 4
  , granularity      => 'ALL'                    --   
  , cascade          => true                     -- true for completeness
  );

end;
/  

-- exec dbms_stats.unlock_table_stats('EPPACCEPT', 'KOERSEN');
-- exec dbms_stats.gather_table_stats ( ownname => 'EPPACCEPT' , tabname => 'KOERSEN', estimate_percent=>1 ); 
