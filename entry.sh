#!/bin/bash
. /functions.sh

if [ "$1" = 'init' ]; then
   InitFHEM "$@"
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

#EOF
