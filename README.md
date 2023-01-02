# fhem-docker
Test my own Dockerfile

Some Scripts (entry.sh, functions.sh) will be loaded from this github during docker build, no docker build context needed!

There are two Versions: 
- Dockerfile is from Alpine:latest, very small, very basic.
- DockerfileDeb is from Debian:latest, fit for my used FHEM Modules and for using serial connected Hardware (e.g. ttyAMA0)


## Usage
- build your image
- make a working folder e.g. /home/pi/docker/fhem
- restore your fhem backup there or start your container the first time with init tar|svn for a fresh copy from official FHEM repository
- start your container on command line or use a docker-compose.yml


#### Build example
```
docker build -t minifhem https://raw.githubusercontent.com/heinz-otto/fhem-docker/main/Dockerfile
docker build -t minifhem https://raw.githubusercontent.com/heinz-otto/fhem-docker/main/Dockerfile --build-arg PACKAGE_SIZE=full
```
#### Init FHEM Path
init tar|svn [clean]                # svn needs PACKAGE_SIZE=full
```
docker run -v "/home/pi/docker/fhem:/opt/fhem" minifhem init tar
docker run -v "/home/pi/docker/fhem:/opt/fhem" minifhem init tar clean
```
#### Start FHEM or FHEM demo
```
docker run -v "/home/pi/docker/fhem:/opt/fhem" -p "8083:8083" minifhem
docker run -v "/home/pi/docker/fhem:/opt/fhem" -p "8083:8083" minifhem start demo
```
#### Start interactive Shell
```
docker run -v "/home/pi/docker/fhem:/opt/fhem" -p "8083:8083" -it minifhem sh
```
## Features
Docker
- build arguments PACKAGE_SIZE=small|full|full_audio, PACKAGE_LANG='en_US.UTF-8 de_DE.UTF-8'
- support "Status": "healthy" (basic)
- start with optional command start [demo], init tar|svn [clean|force], any other command will directly executed
 - clean delete the path first, force will overwrite the existing
- map serial devices, volumes, ports, use ENV Variables to set timezone, language, configType, control interface
- Imagesize about 318|348|678 MB

System
- based on debian:latest
- timezone easy over TZ configurable
- en_US and de_DE language preinstalled (more during build process possible)
- no python at this time (add python3 python3-pi to package list in Dockerfile ?)

FHEM
- configFile, configDB, demo mode supported
- start with fresh install, last official release or existing content (fhem path) 
- automatic configuration during start for pidfile, telnetPort
- installermodul developermode for pre testing existing fhem.cfg
- some perl libs wich required for FHEM Modules preinstalled
- controlinterface over http or telnet port configurable
