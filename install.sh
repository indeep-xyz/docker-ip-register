#!/bin/bash

MY_DIR=`readlink -f "$0" | sed 's!/[^/]*$!!'`
cp "$MY_DIR/docker-ip-register.sh" "/usr/local/bin/docker-ip-register"
