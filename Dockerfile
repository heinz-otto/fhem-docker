###########################################################
## Testing FHEM
## inspired from https://github.com/krannich/dkDockerFHEM/blob/master/fhem/Dockerfile
###########################################################

FROM alpine:latest

MAINTAINER Heinz-Otto Klas

ENV \
    TERM=xterm\
    TZ=Europe/Berlin

# absolute minimum
RUN apk add --no-cache --update \
    tzdata \
    bash \
    sed \
    ca-certificates \
    wget \
    perl \
    perl-device-serialport
# more packages
RUN apk add --no-cache --update \
    perl-socket \
    perl-switch \
    perl-sys-hostname-long \
    perl-json \
    perl-io-socket-ssl \
    perl-crypt-openssl-rsa \
    perl-crypt-openssl-dsa \
    perl-xml-simple \
    perl-socket \
    perl-crypt-rijndael \
    perl-lwp-protocol-https \
    perl-net-telnet \
    perl-dbi \
    perl-dbd-mysql \
    busybox-extras \
    subversion

## Cleaning up APK
RUN rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

## Customizing console
RUN echo "alias ll='ls -lah --color=auto'" >> /root/.bashrc

## Setting timezone
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
    && echo "Europe/Berlin" > /etc/timezone

####################### add user fhem Copy some Files
RUN adduser -G dialout -h /opt/fhem -s /bin/false -D fhem \
    cd / \
    && wget -q https://raw.githubusercontent.com/heinz-otto/fhem-docker/main/scr/entry.sh \
    && wget -q https://raw.githubusercontent.com/heinz-otto/fhemcl/master/fhemcl.sh \
    && chmod +x /*.sh

## Starting container

WORKDIR "/opt/fhem"

EXPOSE 8083

ENTRYPOINT ["/entry.sh"]
