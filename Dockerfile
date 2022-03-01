###########################################################
## Testing FHEM
## inspired from https://github.com/krannich/dkDockerFHEM/blob/master/fhem/Dockerfile
###########################################################

FROM alpine:latest

MAINTAINER Heinz-Otto Klas

ENV \
    TERM=xterm\
    TZ=Europe/Berlin

RUN apk add --no-cache --update \
    tzdata \
    bash \
    sudo \
    sed \
    ca-certificates \
    wget \
    nano \
    perl \
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
    perl-device-serialport \
    perl-net-telnet \
    perl-dbi \
    perl-dbd-mysql \
    busybox-extras \
    subversion

## Cleaning up APK
RUN \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

## Customizing console
RUN \
    echo "alias ll='ls -lah --color=auto'" >> /root/.bashrc

## Setting timezone
RUN \
    cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Berlin" > /etc/timezone

# Installing backup script for local backup

#COPY ./core/backup.sh /opt/fhem/backup.sh

#RUN chmod +x /opt/fhem/backup.sh
# RUN chmod +x /opt/fhem/start-fhem.sh
RUN adduser fhem -h /opt/fhem -D
RUN addgroup fhem dialout
RUN chown -R fhem: /opt/fhem

## Starting container

WORKDIR "/opt/fhem"

EXPOSE 8083 7072

ENTRYPOINT ["/opt/fhem/start-fhem.sh"]
