
rem sets retention (days, dflt 7 days = 10080 min) and interval (minutes, dflt 60)
rem 3 days is approx 5000 min, 2 weeks = 20K min

rem my prefered settings for more careful monitored systems:
exec dbms_workload_repository.modify_snapshot_settings( 10000, 10  );

commit ;

prompt .
prompt Verify by viewing these tabbles
prompt select * from dba_hist_wr_control ; -- parameters
prompt select * from dba_hist_wr_settings ; -- need more info
prompt . 
