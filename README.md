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
docker build -t minifhem https://raw.githubusercontent.com/heinz-otto/fhem-docker/main/Dockerfile --build-arg PACKAGE_SIZE=big
```
#### Init FHEM Path
init tar|svn [clean]                # svn needs PACKAGE_SIZE=big
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
