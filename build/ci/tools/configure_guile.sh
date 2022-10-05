#!/usr/bin/env bash

set -e

C=`pwd`

echo using directory root for msys64 $C/msys64

#export CFLAGS="-I$C/msys64/mingw64/x86_64-w64-mingw32/include -g"
#export LIBS=-L$C/msys64/mingw64/x86_64-w64-mingw32/lib
#export PKG_CONFIG_PATH=$C/msys64/mingw64/lib/pkgconfig

export BDW_GC_LIBS="/d/a/_temp/msys64/mingw64/lib/libgc.a -lgc"

#echo __________ files in $C/msys64/mingw64/x86_64-w64-mingw32/include _______________
#ls $C/msys64/mingw64/x86_64-w64-mingw32/include
#echo _________________________

#echo __________ files in $C/msys64/mingw64/x86_64-w64-mingw32/lib     _______________
#ls $C/msys64/mingw64/x86_64-w64-mingw32/lib
#echo _________________________

$GITSRCDIR/configure --prefix=/mingw64 --host=x86_64-w64-mingw32 \
            --disable-silent-rules --enable-jit=no \
            --enable-guile-debug --enable-mini-gmp --with-bdw-gc=bdw-gc \
            host_alias=x86_64-w64-mingw32

echo __________ CONFIG.LOG _______________
cat config.log
echo __________ __________ _______________
