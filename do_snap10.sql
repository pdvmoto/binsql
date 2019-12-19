rem
rem adhoc snapshots for AWR
rem

rem execute perfstat.statspack.snap ( i_ucomment => 'my snapshot' );   

--BEGIN
 execute  sys.DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT ();
--END;