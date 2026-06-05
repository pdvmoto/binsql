#!/bin/ksh 

for i in {1..1024}
do
    LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 1024
    echo
done > random.txt

