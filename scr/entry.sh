#!/bin/bash
### original from here https://github.com/krannich/dkDockerFHEM/blob/master/fhem/core/start-fhem.sh 
###
### Functions to start FHEM ###

function StartFHEM {
	LOGFILE=/opt/fhem/log/fhem-%Y-%m.log
	PIDFILE=/opt/fhem/log/fhem.pid
	SLEEPINTERVAL=0.5
	TIMEOUT="${TIMEOUT:-15}"
	CONFIGTYPE=${CONFIGTYPE:-"fhem.cfg"}
	FHEMPORT='8083'

	echo
	echo '-------------------------------------------------------------------------------------------------------------------'
	echo
	echo "FHEM_VERSION = $FHEM_VERSION"
	echo "TZ = $TZ"
	echo "TIMEOUT = $TIMEOUT"
	echo "ConfigType = $CONFIGTYPE"
	echo
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
            if PID=$(<"$PIDFILE")
            then 
                echo 'shutdown'|/fhemcl.sh $FHEMPORT
                echo 'Waiting for FHEM process to terminate before stopping container:'
		echo
		until $FOUND; do					## Wait for FHEM to shutdown
			sleep $SLEEPINTERVAL
                        PrintNewLines "Server shutdown"
		done
		while ( kill -0 "$PID" 2> /dev/null ); do		## Wait for FHEM to end process
			sleep $SLEEPINTERVAL
		done
	     fi
	     PrintNewLines
	     echo
	     echo 'FHEM process terminated, stopping container. Bye!'
	     exit 0
	}

	trap "StopFHEM" 0
	
	cd /opt/fhem
	### if the /opt/fhem is empty load a new FHEM from svn
	  if [ ! -e /opt/fhem/fhem.pl ]
             then
                svn checkout https://svn.fhem.de/fhem/trunk/fhem .
          fi
        
	chown -R fhem: .                                                # set proper rights
	
	### start FHEM
	perl fhem.pl "$CONFIGTYPE"
	
	## Wait for FHEM is started
	until $FOUND; do
		sleep $SLEEPINTERVAL
        PrintNewLines "Server started"
	done
	
	## set fhem.pid file if is not in place
        if [ ! -e ./log/fhem.pid ]
            then
               echo 'attr global pidfilename ./log/fhem.pid'|/fhemcl.sh $FHEMPORT
               echo '{qx(echo $$ > ./log/fhem.pid)}'|/fhemcl.sh $FHEMPORT
        fi
 	
	PrintNewLines

	## Monitor FHEM during runtime
	while true; do
		if [ ! -f $PIDFILE ] || ! kill -0 "$(<"$PIDFILE")"; then					## FHEM isn't running
			PrintNewLines
			COUNTDOWN=$TIMEOUT
			echo
			echo "FHEM process terminated, waiting for $COUNTDOWN seconds before stopping container..."
			while ( [ ! -f $PIDFILE ] || ! kill -0 "$(<"$PIDFILE")" ) && (( COUNTDOWN > 0 )); do	## FHEM exited unexpectedly
				echo "waiting - $COUNTDOWN"
				(( COUNTDOWN-- ))
				sleep 1
			done
			if [ ! -f $PIDFILE ] || ! kill -0 "$(<"$PIDFILE")"; then				## FHEM didn't reappeared
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

### Start of Script ###

StartFHEM

#EOF
