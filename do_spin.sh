#!/bin/bash

# workaround for Mac :
export DYLD_LIBRARY_PATH=/Users/pdvbv/Downloads/instantclient_11_2

sqlplus /nolog <<EOF

@cvscott

@spin_par 120

@sleep 5

@spin 60

@sleep 5

@spin_commit 60

@sleep 5

@spin_par 60

@sleep 5 

@spin_par 30

@sleep 5

@spin 30

@sleep 5

@spin_commit 30

@spin_par 30

@sleep 5

@spin 30

@sleep 5

@spin_commit 30

@sleep 5 

@spin_dyn 30


EOF




