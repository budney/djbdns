#!/bin/sh
SERVICE="$1"

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
        NET=$( netstat -rn | egrep UG | awk '{print $2}' | cut -f1 -d. )
        touch "/srv/$SERVICE/root/ip/$NET"

        # Options 3 & 4 are identical in this setup: a
        # forward-only cache that accepts queries over
        # the network.
        if [ -n "$forwardto" ]; then
            echo 1 > "/srv/$SERVICE/env/FORWARDONLY"
            echo "$forwardto" > "/srv/$SERVICE/root/servers/@"
        fi

        # Delegate the specified domains, if any, to
        # tinydns for resolution.
        if [ -n "$delegate" ]; then
            for DOMAIN in $( echo "$delegate" | tr : ' ' ); do
                dnsip tinydns > "/srv/$SERVICE/root/servers/$DOMAIN"
            done
        fi
        ;;

    *)
        echo "Usage: /start.sh [ tinydns | dnscache ]"
        exit 1
        ;;
esac

# Run the service. The container exits
# when the service dies for any reason.
cd "/srv/$SERVICE" && exec ./run
