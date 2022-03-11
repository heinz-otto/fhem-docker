#!/bin/bash
# load functions
. /functions.sh

# set HOME ENV
export HOME=$(pwd)

# make serial Devices accessible by user fhem. 
# I found this kind in official fhem-docker/src/entry.sh . I don't found this as recommandation on other sites
find /dev/ -name "tty[A|S|U]*" -exec chown fhem: {} \;

# run internal cmd or execute the code from commandline 
if [ "$1" = 'init' ]; then
   InitFHEM $@
   exit 0
fi
if [ "$1" = 'start' ]; then
    if [ "$2" = 'demo' ]; then
       StartDemo
    else
       StartFHEM
    fi
else
    exec "$@"
fi
