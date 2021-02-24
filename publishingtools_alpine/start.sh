#!/bin/sh

# fix /etc/hosts
if ! grep -q "localhost" /etc/hosts; then
	touch /etc/hosts
	chmod  644 /etc/hosts
	echo $HOSTNAME  localhost >> /etc/hosts
	echo "127.0.0.1 localhost" >> /etc/hosts
fi

SRCDIR=${SRCDIR:-src}

cat > /config.toml << EOF
[server]
addr = "0.0.0.0"
port = 3000

[[$TYPE]]
name = "$NAME"
title = "$TITLE"
url = "$URL"
branch = "$BRANCH"
srcdir = "$SRCDIR"
domain = "$DOMAIN"
EOF

cd /sandbox/code/github/crystaluniverse/publishingtools
./bin/tfweb -c /config.toml
