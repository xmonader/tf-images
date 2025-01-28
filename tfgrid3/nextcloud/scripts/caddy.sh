#!/bin/bash
export DOMAIN=$NEXTCLOUD_DOMAIN

if $IPV4 && ! $GATEWAY; then
  export PORT=443

  # Wait for DNS to propagate
  interface=$(ip route show default | cut -d " " -f 5)
  ipv4_address=$(ip a show $interface | grep -Po 'inet \K[\d.]+')
  while ! dig $DOMAIN | grep -q $ipv4_address; do
    sleep 5
  done
else
  export PORT=80
fi

if $IPV4; then
  export BODY="\`<body onload=\"if (document.getElementById('domain-submit')) {document.getElementById('domain-submit').click()}\">\`"

else
  export BODY="\`<body onload=\"if (document.getElementById('domain-submit')) {document.getElementById('domain-submit').click()}; if (document.getElementById('talk') && document.getElementById('talk').checked) {document.getElementById('talk').checked = false; document.getElementById('options-form-submit').click()}\">\`"

  export REPLACEMENTS='			`name="talk"` `name="talk" disabled`
			`needs ports 3478/TCP and 3478/UDP open/forwarded in your firewall/router` `running the Talk container requires a public IP and this VM does not have one. It is still possible to use Talk in a limited capacity. Please consult the documentation for details`'
fi

caddy run --config /etc/caddy/Caddyfile
