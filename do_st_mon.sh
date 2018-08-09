#!/bin/sh

# workaround for Mac :
export DYLD_LIBRARY_PATH=/Users/pdvbv/Downloads/instantclient_11_2

sqlplus -s /nolog <<EOF 

set feedb off

@cvscott

@do_st_mon

EOF

