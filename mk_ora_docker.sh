#!/bin/bash
#
# mk_ora_docker.sh: create a docker container, and run some init scirpts

docker run -d --name o23t --hostname o23t \
          -p 1521:1521 \
          -e ORACLE_PASSWORD=oracle \
      gvenzl/oracle-free:full-faststart

#           -v ~/zz_startdb:/container-entrypoint-startdb.d \
