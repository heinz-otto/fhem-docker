# fhem-docker
Test my own Dockerfile

This Version is from Alpine, very small, very basic
## Build example
```
docker build -t minifhem https://raw.githubusercontent.com/heinz-otto/fhem-docker/main/Dockerfile
docker build -t minifhem https://raw.githubusercontent.com/heinz-otto/fhem-docker/main/Dockerfile --build-arg PACKAGE_SIZE=big
```
## Init FHEM Path
init tar|svn [clean]     # svn needs PACKAGE_SIZE=big
```
docker run -v "/home/pi/docker/fhem:/opt/fhem" -p "8083:8083" minifhem init tar
docker run -v "/home/pi/docker/fhem:/opt/fhem" -p "8083:8083" minifhem init tar clean
```
## Start FHEM or FHEM demo
```
docker run -v "/home/pi/docker/fhem:/opt/fhem" -p "8083:8083" minifhem
docker run -v "/home/pi/docker/fhem:/opt/fhem" -p "8083:8083" minifhem start demo
```
## start interactive Shell
```
docker run -v "/home/pi/docker/fhem:/opt/fhem" -p "8083:8083" -it minifhem sh
```
Some Scripts (entry.sh, functions.sh) will be loaded from this github during docker build, no context needed!
