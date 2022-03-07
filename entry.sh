#!/bin/sh
. /functions.sh
if [ "$1" = 'init' ]; then
    if [ ! -e /opt/fhem/fhem.pl ]; then
      InitFHEM
    fi
fi
if [ "$1" = 'start' ]; then
    if [ "$2" = 'demo' ]; then
       echo 'exec "perl fhem.pl fhem.cfg.demo"'
    else
      StartFHEM
	fi
else
    exec "$@"
fi
