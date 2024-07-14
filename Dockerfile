# Create a build image to compile djbdns. We'll copy the binaries to a final
# image, to keep the size down.
FROM alpine:latest AS build

USER root

COPY resolv.conf /etc/resolv.conf
COPY install-daemontools.sh /tmp/install-daemontools.sh

# Make sure we're pulling the latest packages, then update
RUN sed -i 's}/alpine/[^/]*/}/alpine/latest-stable/}' /etc/apk/repositories && \
    apk --update add --no-cache make gcc g++ ucspi-tcp6 ca-certificates wget && \
    update-ca-certificates && \
    chmod 0755 /tmp/install-daemontools.sh && \
    /tmp/install-daemontools.sh

RUN mkdir /src ; cd /src ; \
    wget -O - https://cr.yp.to/djbdns/djbdns-1.05.tar.gz | tar xzf - ; \
    cd djbdns-1.05 ; \
    echo gcc -O2 -include /usr/include/errno.h > conf-cc ; \
    make && make setup check

#
#===============================================================================
#
FROM alpine:latest
LABEL maintainer="Len Budney (len.budney@gmail.com)"

COPY --from=build /etc/dnsroots.global /etc/
COPY --from=build /usr/local/bin/* /usr/local/bin/
COPY --from=build /package /package
COPY --from=build /command /command


RUN sed -i 's}/alpine/[^/]*/}/alpine/latest-stable/}' /etc/apk/repositories && \
    apk --update add --no-cache ucspi-tcp6 && \
    apk upgrade --no-cache --available --no-progress && \
    tinydns-conf nobody nobody /srv/tinydns 0.0.0.0 && \
    dnscache-conf nobody nobody /srv/dnscache 0.0.0.0

COPY start.sh rebuild.sh /
COPY test.dns /srv/tinydns/root/data
COPY resolv.conf /etc/resolv.conf

CMD ["/start.sh"]
