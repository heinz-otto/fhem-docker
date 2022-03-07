#!/bin/bash
. /functions.sh

if [ "$1" = 'init' ]; then
    if [ ! -e /opt/fhem/fhem.pl ]; then
      InitFHEM
    fi
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

#EOF
