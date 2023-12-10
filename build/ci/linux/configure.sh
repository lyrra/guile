#!/bin/sh

set -e

./autogen.sh

./configure --with-threads --enable-jit=no --enable-guile-debug --enable-debug-malloc


