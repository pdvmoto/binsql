#!/bin/sh

# either use watch -n5 or construct a while-loop..

# workaround for Mac :
export DYLD_LIBRARY_PATH=/Users/pdvbv/Downloads/instantclient_11_2

sqlplus -s /nolog <<EOF 

-- connection needed.

connect scott/tiger@( DESCRIPTION= (ADDRESS = (PROTOCOL = TCP)(HOST = 127.0.0.1)(PORT = 1521))(connect_data=(service_name=ORCLPDB1)) )


@do_ev_mon

EOF

