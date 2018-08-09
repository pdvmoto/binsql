#!/bin/sh

# workaround for Mac :
export DYLD_LIBRARY_PATH=/Users/pdvbv/Downloads/instantclient_11_2

sqlplus -s /nolog <<EOF 

set feedb off

connect superuser/nWXPAH0weHNwWDg7wZiPMtWU6PjLrm@pbtemp

rem conn superuser/nWXPAH0weHNwWDg7wZiPMtWU6PjLrm@naomi
rem @cvscott

@do_st_mon

EOF

