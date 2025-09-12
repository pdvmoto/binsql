
rem sets retention (days, dflt 7 days = 10080 min) and interval (minutes, dflt 60)
rem 3 days is approx 5000 min, 2 weeks = 20K min

rem my prefered settings for more careful monitored systems:
exec dbms_workload_repository.modify_snapshot_settings( 10000, 10  );

rem when retention-moving-window error occurs: fix is..
rem execute dbms_workload_repository.modify_baseline_window_size(window_size=> 2);

rem -- 00note : from PDB, the session cannot adjust settings for parent-CDB.
begin
 dbms_workload_repository.modify_snapshot_settings(
    interval => 10
  , retention => 2880
  -- , dbid => 281453300   ]
);
end;
/


commit ;

prompt .
prompt Verify by viewing these tabbles
prompt select * from dba_hist_wr_control ; -- parameters
prompt select * from dba_hist_wr_settings ; -- need more info
prompt . 
