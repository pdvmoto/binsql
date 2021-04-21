

define DEF_DIR=/opt/oracle/diag/rdbms/calp/CALP/trace/
define DEF_FIL=CALP_ora_53638.trc

create directory TRACEDIR as '&DEF_DIR' ;
-- create directory TRACEDIR as '/opt/oracle/diag/rdbms/calp/CALP/trace/' ; 

REM create an external table that corresponds to the trace file

DROP TABLE tracefile ;

CREATE TABLE tracefile 
( trace_line VARCHAR2(4000) )
ORGANIZATION EXTERNAL
( TYPE ORACLE_LOADER DEFAULT DIRECTORY TRACEDIR
  ACCESS PARAMETERS 
  ( RECORDS DELIMITED BY NEWLINE NOBADFILE NODISCARDFILE NOLOGFILE
    FIELDS MISSING FIELD VALUES ARE NULL
    REJECT ROWS WITH ALL NULL FIELDS
    (trace_line CHAR(4000))
  )
  LOCATION ('CALP_ora_53638.trc')
);

set pagesize 0
set linesize 200

spool &DEF_FIL

select * from tracefile ; 

spool off

drop table tracefile ; 

drop directory tracedir ; 

