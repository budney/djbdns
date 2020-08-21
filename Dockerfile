# Create a build image to compile djbdns. We'll copy the binaries to a final
# image, to keep the size down.
FROM alpine as build

RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf && \
    echo "http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk --update add --no-cache make gcc g++ ucspi-tcp6 daemontools ca-certificates wget && \
    update-ca-certificates

RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf && \
    mkdir /src ; cd /src ; \
    wget -O - https://cr.yp.to/djbdns/djbdns-1.05.tar.gz | tar xzf - ; \
    cd djbdns-1.05 ; \
    echo gcc -O2 -include /usr/include/errno.h > conf-cc ; \
    make && make setup check

#
#===============================================================================
#
FROM alpine
LABEL maintainer="Len Budney (len.budney@gmail.com)"

COPY --from=build /etc/dnsroots.global /etc/
COPY --from=build /usr/local/bin/* /usr/local/bin/


RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf && \
    echo "http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk --update add --no-cache ucspi-tcp6 daemontools && \
    tinydns-conf nobody nobody /srv/tinydns 0.0.0.0 && \
    dnscache-conf nobody nobody /srv/dnscache 0.0.0.0

COPY start.sh rebuild.sh /
COPY test.dns /srv/tinydns/root/data

CMD ["sh", "-c", "/start.sh ${service}"]
