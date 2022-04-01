###########################################################
## Testing FHEM with a small as possible Alpine Linux
## inspired from https://github.com/krannich/dkDockerFHEM/blob/master/fhem/Dockerfile
###########################################################
FROM alpine:latest

LABEL org.opencontainers.image.authors="heinz-otto@klas.de"

ENV \
    TERM=xterm\
    TZ=Europe/Berlin

ARG PACKAGE_SIZE=small

RUN apk add --no-cache --update \
    bash \
    ca-certificates \
    perl \
    perl-device-serialport \
    sed \
    tzdata \
    wget \
    && if [ "${PACKAGE_SIZE}" = "full" ]; then \
         apk add --no-cache --update \
         busybox-extras \
         perl-dbd-mysql \
         perl-dbi \
         perl-crypt-openssl-dsa \
         perl-crypt-openssl-rsa \
         perl-crypt-rijndael \
         perl-io-socket-ssl \
         perl-json \
         perl-lwp-protocol-https \
         perl-net-telnet \
         perl-socket \
         perl-switch \
         perl-sys-hostname-long \
         perl-xml-simple \
         subversion \
     ; fi \
     && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

### ToDo combine the following parts for better building
## Customizing console
RUN echo "alias ll='ls -lah --color=auto'" >> /root/.bashrc

## Setting timezone
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
    && echo "Europe/Berlin" > /etc/timezone

## add user fhem, copy some files from github instead of using docker context
RUN adduser -G dialout -h /opt/fhem -s /bin/false -D fhem \
    && cd / \
    && wget -q https://raw.githubusercontent.com/heinz-otto/fhem-docker/main/functions.sh \
    && wget -q https://raw.githubusercontent.com/heinz-otto/fhem-docker/main/entry.sh \
    && wget -q https://raw.githubusercontent.com/heinz-otto/fhemcl/master/fhemcl.sh \
    && chmod +x /*.sh

## Starting container, EXPOSE is more Doku :-)

EXPOSE 8083

## HEALTHCHECK --interval=20s --timeout=10s --start-period=60s --retries=5 CMD /health-check.sh

WORKDIR "/opt/fhem"
ENTRYPOINT ["/entry.sh"]
# start is default and can be overwritten per commandline
CMD [ "start" ]
