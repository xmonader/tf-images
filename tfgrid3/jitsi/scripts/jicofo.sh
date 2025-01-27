#!/bin/bash
echo "" > /etc/jitsi/jicofo/config
cat <<EOF >>  /etc/jitsi/jicofo/config
# adds java system props that are passed to jicofo (default are for home and logging config file)
JAVA_SYS_PROPS="-Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION=/etc/jitsi -Dnet.java.sip.communicator.SC_HOME_DIR_NAME=jicofo -Dnet.java.sip.communicator.SC_LOG_DIR_LOCATION=/var/log/jitsi -Djava.util.logging.config.file=/etc/jitsi/jicofo/logging.properties -Dconfig.file=/etc/jitsi/jicofo/jicofo.conf"
EOF
. /lib/lsb/init-functions
. /etc/jitsi/jicofo/config

set -e

echo -n "Starting jicofo: "
export JICOFO_AUTH_PASSWORD JICOFO_MAX_MEMORY

SCRIPT_DIR="$(dirname "$(readlink -f /usr/share/jicofo/jicofo.sh)")"
mainClass="org.jitsi.jicofo.Main"
cp=$(JARS=($SCRIPT_DIR/jicofo*.jar $SCRIPT_DIR/lib/*.jar); IFS=:; echo "${JARS[*]}")

if [ -z "$JICOFO_MAX_MEMORY" ]; then JICOFO_MAX_MEMORY=3072m; fi

cd /usr/share/jicofo/		
exec java -Xmx$JICOFO_MAX_MEMORY -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp -Djdk.tls.ephemeralDHKeySize=2048 $JAVA_SYS_PROPS -cp $cp $mainClass "$@"
