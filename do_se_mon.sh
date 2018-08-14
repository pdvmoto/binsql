#!/bin/sh

# workaround for Mac :
export DYLD_LIBRARY_PATH=/Users/pdvbv/Downloads/instantclient_11_2

sqlplus -s /nolog <<EOF 

set feedb off

-- connection needed.

connect scott/tiger@( DESCRIPTION= (ADDRESS = (PROTOCOL = TCP)(HOST = 127.0.0.1)(PORT = 1521))(connect_data=(service_name=ORCLPDB1)) )

@do_se_mon

EOF

