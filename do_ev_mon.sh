#!/bin/sh

# either use watch -n5 or construct a while-loop..

# workaround for Mac :
export DYLD_LIBRARY_PATH=/Users/pdvbv/Downloads/instantclient_11_2


sqlplus -s /nolog <<EOF 

-- connection needed.

rem connect scott/tiger@( DESCRIPTION= (ADDRESS = (PROTOCOL = TCP)(HOST = 127.0.0.1)(PORT = 1521))(connect_data=(service_name=ORCLPDB1)) )

connect superuser/nWXPAH0weHNwWDg7wZiPMtWU6PjLrm@pbtemp

rem conn superuser/nWXPAH0weHNwWDg7wZiPMtWU6PjLrm@naomi

@do_ev_mon

EOF

