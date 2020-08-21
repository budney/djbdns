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

        # Authorize the default gateway to talk to us
        cd "/srv/$SERVICE/root/ip" && \
        touch `route -n | grep 'UG[ \t]' | awk '{print $2}' | cut -f1 -d.`
        ;;

    *)
        echo "Usage: /start.sh [ tinydns | dnscache ]"
        exit 1
        ;;
esac

# Run the service. The container exits
# when the service dies for any reason.
cd "/srv/$SERVICE" && exec ./run
