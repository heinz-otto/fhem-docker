#!/bin/bash
### inspired from here https://github.com/krannich/dkDockerFHEM/blob/master/fhem/core/start-fhem.sh 
###

### Function to control FHEM ###
## todo: integrate test in cmd2FHEM ?
function cmd2FHEM { 
  if [ "${FHEM_CTRL_INTERFACE}" = "http" ] ; then 
     /fhemcl.sh ${FHEM_CTRL_URL}
  else 
     nc -w 1 localhost 7072
  fi
}

### Function to start FHEM ###
function StartFHEM {
	LOGFILE=$(pwd)/log/fhem-%Y-%m.log
	PIDFILE=$(pwd)/log/fhem.pid
	SLEEPINTERVAL=0.5
	TIMEOUT="${TIMEOUT:-15}"

	echo
	echo '-------------------------------------------------------------------------------------------------------------------'
	echo "LOGFILE = $LOGFILE"
	echo "TZ = $TZ"
	echo "TIMEOUT = $TIMEOUT"
	echo "ConfigType = $CONFIGTYPE"
	echo "FHEM control Interface is ${FHEM_CTRL_INTERFACE}"
	echo '-------------------------------------------------------------------------------------------------------------------'
	echo

	## Function to print FHEM log in incremental steps to the docker log.
	test -f "$(date +"$LOGFILE")" && OLDLINES=$(wc -l < "$(date +"$LOGFILE")") || OLDLINES=0
	NEWLINES=$OLDLINES
	FOUND=false

	function PrintNewLines {
    	   NEWLINES=$(wc -l < "$(date +"$LOGFILE")")
    	   (( OLDLINES <= NEWLINES )) && LINES=$(( NEWLINES - OLDLINES )) || LINES=$NEWLINES
    	   tail -n "$LINES" "$(date +"$LOGFILE")"
    	   test ! -z "$1" && grep -q "$1" <(tail -n "$LINES" "$(date +"$LOGFILE")") && FOUND=true || FOUND=false
    	   OLDLINES=$NEWLINES
	}

	## Docker stop sinal handler
	function StopFHEM {
	    echo
	    echo 'SIGTERM signal received, sending "shutdown" command to FHEM!'
	    echo
            if PID=$(cat $PIDFILE 2>/dev/null)
            then 
                echo 'shutdown'|cmd2FHEM
                echo 'Waiting for FHEM process to terminate before stopping container:'
		echo
		until $FOUND; do					## Wait for FHEM to shutdown
			sleep $SLEEPINTERVAL
                        PrintNewLines "Server shutdown"
		done
		while ( kill -0 "$PID" 2>/dev/null ); do		## Wait for FHEM to end process
			sleep $SLEEPINTERVAL
		done
	     fi
	     PrintNewLines
	     echo
	     echo 'FHEM process terminated, stopping container. Bye!'
	     exit 0
	}

	trap "StopFHEM" 0
	
        chown -R fhem: $(pwd)                                        # set proper rights
	
	### start FHEM
	perl fhem.pl "$CONFIGTYPE"
	
	## Wait for FHEM is started
	until $FOUND; do
		sleep $SLEEPINTERVAL
        PrintNewLines "Server started"
	done
	
	## define telnetPort if it's needed and not in place
	## todo: integrate test in cmd2FHEM ?
	if [ "${FHEM_CTRL_INTERFACE}" != "http" ] ; then 
	   if ! nc -z -w 1 localhost 7072 ; then 
	      echo "define telnetPort telnet 7072"|/fhemcl.sh
	      echo "  control Interface is not http - telnetPort defined"
	   fi
        fi
	
	## set fhem.pid file if it's not in place
        if [ ! -e ./log/fhem.pid ]
            then
               echo 'attr global pidfilename ./log/fhem.pid'|cmd2FHEM
               echo '{qx(echo $$ > ./log/fhem.pid)}'|cmd2FHEM
	       echo '   pidFile is missing - pidfilename defined'
        fi
 	
	PrintNewLines

	## Monitor FHEM during runtime
	while true; do
		if [ ! -f $PIDFILE ] || ! kill -0 "$(<"$PIDFILE")"; then					## FHEM isn't running
			PrintNewLines
			COUNTDOWN=$TIMEOUT
			echo
			echo "FHEM process terminated, waiting for $COUNTDOWN seconds before stopping container..."
			while ( [ ! -f $PIDFILE ] || ! kill -0 "$(<"$PIDFILE")" &>/dev/null ) && (( COUNTDOWN > 0 )); do	## FHEM exited unexpectedly
                                printf "waiting - $COUNTDOWN \r"
				(( COUNTDOWN-- ))
				sleep 1
			done
			if [ ! -f $PIDFILE ] || ! kill -0 "$(<"$PIDFILE")" &>/dev/null; then				## FHEM didn't reappeared
				echo '0 - Stopping Container. Bye!'
				exit 1
			else		        ## FHEM reappeared
				echo 'FHEM process reappeared, kept container alive!'
			fi
			echo
			echo 'FHEM is up and running again:'
			echo
		fi
		PrintNewLines			## Printing log lines in intervalls
		sleep $SLEEPINTERVAL
	done
}

### Function init the workdir with a fresh FHEM version from svn or latest build version from fhem.de  ###
function InitFHEM {
  ### if the /opt/fhem is empty load a new FHEM from svn or fhem.de
  if [ "$3" = "clean" ] ; then
     echo "clean path $(pwd)"
     rm -r *
  fi
  if [ ! -e $(pwd)/fhem.pl ] || [ $3=force ] ; then
     if [ "$2" = "svn" ] ; then
        echo "try to init path $(pwd) from svn"
        svn checkout https://svn.fhem.de/fhem/trunk/fhem .
     fi
     if [ "$2" = "tar" ] ; then
        echo "try to init path $(pwd) from $RELEASE_FILE"
        wget -q http://fhem.de/$RELEASE_FILE
        tar xvf $RELEASE_FILE --strip-components=1             # the first path structure /fhem-6.1/ is removed during expand
	rm $RELEASE_FILE
     fi
   else 
     echo "$(pwd) not empty, use: init svn|tar force"
  fi
}

### Start FHEM in demo mode  ###
function StartDemo {
  perl fhem.pl fhem.cfg.demo
}
