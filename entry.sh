#!/bin/bash
# load functions
. /functions.sh

# set ENV
export HOME="$(pwd)"
export CONFIGTYPE=${CONFIGTYPE:-"fhem.cfg"}                 # for configDB https://forum.fhem.de/index.php?topic=54055.0
export LANG="${LANG:-de_DE.UTF-8}" 
export LANGUAGE="${LANGUAGE:-de:en}"
export LC_ALL="${LC_ALL:-de_DE.UTF-8}"
export TZ="${TZ:-Europe/Berlin}"
export FHEM_CTRL_INTERFACE="${FHEM_CTRL_INTERFACE:-http}"
export FHEM_CTRL_URL="${FHEM_CTRL_URL:-8083}"             # [http://[user:password@]hostname:]portnumber
export RELEASE_FILE="${RELEASE_FILE:-fhem-6.1.tar.gz}"

# make serial Devices accessible by user fhem. 
# I found this kind in official fhem-docker/src/entry.sh . I don't found this as recommandation on other sites
find /dev/ -name "tty[A|S|U]*" -exec chown fhem: {} \;

# run internal cmd or execute the code from commandline 
if [ "$1" = 'init' ]; then
   InitFHEM $@
   chown -R fhem: $(pwd)              # set proper rights
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
