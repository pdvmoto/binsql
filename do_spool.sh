#!/bin/ksh
#
# do_spool.sh: read list of tables and spool their content, csv
# use sqlcl to allow /*csv*/ and get "double quotes doubled" 
#
# todo
# - allow random passwords with funny chars
# - allow better order-by, not all sets start with a proper key, 
# - allow for more than 1 key to order
#

#
# sqlplus-executable
# note: for CSV and "", pick an recent sql-cl version
# 
SQLEXEC=/opt/oracle/product/26ai/dbhome_1/bin/sql
SQLEXEC=/Users/pdvbv/ora_233/sqlcl/bin/sql

#
# connect str, later: take care of random-passwords
#
CONNSTR="scott/tiger@orclpdb1" 

# env
export LANG=en_US.UTF-8
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8


# optionally: generate the file to read sources (tables, views) from ...
cat<<EOF>tabs.tospool
  DBA_TABLES
  dba_tab_columns
  DBA_users
  tst_demo
EOF

# now loop over the tables
for THE_TAB in `cat tabs.tospool`
do
  echo $0 about to spool is ${THE_TAB}
  ${SQLEXEC} -s ${CONNSTR}<<EOF

    set heading off
    set feedback off
    alter session set nls_date_format="YYYY-MM-DD HH24:MI:SS";
    spool out_${THE_TAB}
    select /*csv*/ * from ${THE_TAB} order by 1 ;
EOF

done

ls -l out*.lst

echo $0 : end. spoolfiles created
 
