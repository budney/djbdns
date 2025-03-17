#!/bin/sh

DNSNAME=${DNSNAME:-tinydns}

case "$SERVICE" in
    tinydns)
        echo "Running tinydns."

        # Rebuild the DNS data every time before running
        cd "/srv/$SERVICE/root" && /usr/local/bin/tinydns-data
        ;;

    dnscache)
        echo "Running dnscache."

        # Options 1 & 2 are identical in this setup: a
        # cache that accepts queries over the network.
        if [ -z "$ALLOW_NETWORKS" ]; then
            # At least allow the network we're on
            NET=$( ip r | egrep default | awk '{print $3}' | cut -f1 -d. )
            touch "/srv/$SERVICE/root/ip/$NET"
        else
            # Accept the specified networks from the environment
            IFS=':' set -f; set -- $ALLOW_NETWORKS; set +f
            NETWORKS="$@"

            for NETWORK in $NETWORKS; do
                touch "/srv/$SERVICE/root/ip/$NETWORK"
            done
        fi

        # Options 3 & 4 are identical in this setup: a
        # forward-only cache that accepts queries over
        # the network.
        if [ -n "$FORWARDTO" ]; then
            echo 1 > "/srv/$SERVICE/env/FORWARDONLY"
            echo "$FORWARDTO" > "/srv/$SERVICE/root/servers/@"
        fi

        # Delegate the specified domains, if any, to
        # tinydns for resolution.
        if [ -n "$DELEGATE" ]; then
            IFS=':' set -f; set -- $DELEGATE; set +f
            DOMAINS="$@"

            for DOMAIN in $DOMAINS; do
                dnsip "$DNSNAME" > "/srv/$SERVICE/root/servers/$DOMAIN"
            done
        fi
        ;;

    *)
        echo "Fatal: SERVICE environment variable must be 'dnscache' or 'tinydns'" 1>&2
        exit 1
        ;;
esac

# Run the service. The container exits
# when the service dies for any reason.
cd "/srv/$SERVICE" && exec ./run
