#!/bin/bash

ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 10000/udp
ufw allow 22/tcp
ufw allow 3478/udp
ufw allow 5349/tcp
echo y | ufw enable