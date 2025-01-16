#!/bin/bash

. /etc/jitsi/videobridge/config

echo -n "Starting jvb: "

SCRIPT_DIR="$(dirname "$(readlink -f /usr/share/jitsi-videobridge/jvb.sh)")"
mainClass="org.jitsi.videobridge.MainKt"
cp=$SCRIPT_DIR/jitsi-videobridge.jar:$SCRIPT_DIR/lib/*

if [ -z "$VIDEOBRIDGE_MAX_MEMORY" ]; then VIDEOBRIDGE_MAX_MEMORY=3072m; fi
if [ -z "$VIDEOBRIDGE_GC_TYPE" ]; then VIDEOBRIDGE_GC_TYPE=G1GC; fi

exec java -Xmx$VIDEOBRIDGE_MAX_MEMORY $VIDEOBRIDGE_DEBUG_OPTIONS -XX:+Use$VIDEOBRIDGE_GC_TYPE -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp -Djdk.tls.ephemeralDHKeySize=2048 -Djdk.net.usePlainDatagramSocketImpl=true $JAVA_SYS_PROPS -cp $cp $mainClass "$@"