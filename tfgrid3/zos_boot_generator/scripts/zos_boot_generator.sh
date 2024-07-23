#!/bin/bash

cd /code/0-bootstrap

cp config.py.sample config.py

domain_name=$(echo $DOMAIN | cut -d. -f1)
domain_tld=$(echo $DOMAIN | cut -d. -f2)

sed -i "s/http:\/\/default\.tld/https:\/\/$domain_name\.$domain_tld/g" config.py

cat db/schema.sql | sqlite3 db/bootstrap.sqlite3