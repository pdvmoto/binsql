#!/bin/sh
#
#
# mk_oracont.sh : create a container running oracle (freepdb1)
#
# note: 
#   mkdir initdb.d and put scripts there to create scott etc..
#   may need "docker login" to pull images.
#
# later:
# - test mapping of oradata
#
#

# which one..
# IMAGE=gvenzl/oracle-free:slim
  IMAGE=gvenzl/oracle-free:full

LOGFILE=mk_oracont.log

echo `date` $0 : creating new container... >> $LOGFILE

# optional: separate net
# docker network rm ora_net
#  docker network create --subnet=172.22.0.0/16 --ip-range=172.22.0.0/24  ora_net
# echo .
# echo network ora_net created, next loop over nodes
# echo .
# sleep 2

# define all relevant pieces (no spaces!)
hname=ora236
oraport=1521

# optinally: define volume or mapping.

# define the command
crenode=` \
echo docker run -d               \
--hostname $hname --name $hname  \
-e ORACLE_PASSWORD=oracle        \
-p${oraport}:1521                \
-v ./initdb.d:/container-entrypoint-initdb.d \
$IMAGE                           `

# to map volume, add this line just above IMAGE..
#  -v /Users/pdvbv/oradata/$hname:/opt/oracle/oradata \

echo $hname ... creating container:
echo $crenode
echo $crenode >> $LOGFILE

# do it..
$crenode


# now add components.. : 
# git, jq, binsql, syssatat, procps, which, .bash_profile
# create scott..

echo $hname :  adding components.

cat <<EOF | docker exec -i -u root $hname sh
  microdnf install jq
  microdnf install procps
  microdnf install which
  microdnf install sysstat
  microdnf install vi
  microdnf install git
  cd /tmp
  git clone https://github.com/pdvmoto/uxutil
  cd uxutil
  chown root:root *
EOF

# some actions as oracle, also try create scott here..
cat <<EOF | docker exec -i $hname sh
  echo "alias ll='ls -la '"                         >> .bash_profile 
  echo "alias ltm='ls -lra '"                       >> .bash_profile 
  echo "alias dum='du -sm * | sort -ns '"           >> .bash_profile 
  echo "export SQLPATH=/opt/oracle/admin/binsql"    >> .bash_profile
  cd /opt/oracle/admin
  git clone https://github.com/pdvmoto/binsql
EOF

echo "."
echo Container $hname Created, check logfiles, and logon to verify
echo "."

