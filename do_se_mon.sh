#!/bin/sh

# workaround for Mac :
export DYLD_LIBRARY_PATH=/Users/pdvbv/Downloads/instantclient_11_2

sqlplus -s /nolog <<EOF 

set feedb off

-- connection needed.

rem connect scott/tiger@( DESCRIPTION= (ADDRESS = (PROTOCOL = TCP)(HOST = 127.0.0.1)(PORT = 1521))(connect_data=(service_name=ORCLPDB1)) )

connect superuser/nWXPAH0weHNwWDg7wZiPMtWU6PjLrm@pbtemp
rem conn superuser/nWXPAH0weHNwWDg7wZiPMtWU6PjLrm@naomi

@do_se_mon

EOF

