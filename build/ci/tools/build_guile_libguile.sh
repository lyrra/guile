#!/usr/bin/env bash

set -e

echo Building libguile

echo make scmconfig.h
make -C libguile scmconfig.h
echo make lib/
make -C lib
echo make meta/
make -C meta

echo make libguile/
make -C libguile

