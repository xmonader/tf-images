#!/bin/bash
systemctl start xrdp
cd ~
echo "xfce4-session" | tee .xsession
systemctl restart xrdp