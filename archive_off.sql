rem
rem Script: archive_off.sql
rem
rem Usage : To chance archive-log-mode to noarchivelog, 
rem         the database must be mounted in exclusive mode.
rem         Therefore a shutdown immediate is done!
rem
rem         After the archive-log-mode switch the database is shutdown and
rem         started up again in normal mode.
rem
rem Note  : This script should be run in sqldba
rem

set echo on
set timing on

connect internal

shutdown immediate 

startup mount exclusive

alter database noarchivelog  ;

shutdown immediate ;

startup ;

