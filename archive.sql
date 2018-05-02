rem
rem to chance archive-log-mode : must be mounted exclusive,
rem therefore : need to stop first.
rem Uncomment the alter statement as you please.

set echo on
set timing on

connect internal

shutdown immediate 

startup mount 

alter database noarchivelog  ;
# alter database archivelog  ;

shutdown immediate ;

startup ;

