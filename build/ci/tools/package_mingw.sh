#!/usr/bin/env bash

cp ../r/PKGBUILD . # copy PKGBUILD from other branch
echo "--- CLRF in PKGBUILD, remote it"
sed -i 's/\r//g' PKGBUILD
echo "-------- hexdump PKGBUILD ------------"
hexdump -C PKGBUILD | grep 0d
echo "--------------------------------------"

echo "------- before calling makepgk-mingw -------"
ls -ltr
makepkg-mingw -L --skipinteg --noconfirm --noprogressbar --noextract --noprepare

echo "------- after calling makepgk-mingw, rc=$? -------"
ls -ltr
echo "------- build -------"
ls -ltr build


echo "------ Files to zip: ---------"

echo "------ zipping files: ---------"

find . | \
     grep -e '^./bootstrap/.*\.go$' \
          -e '^./doc/' \
          -e '^./emacs/' \
          -e '^./examples/' \
          -e '^./guix/' \
          -e '^./meta/' \
          -e '^./guile-readline/.libs/guile-readline.a$' \
          -e '^./guile-readline/.*\.go$' \
          -e '^./lib/.libs/libgnu.a$' \
          -e '^./libguile/.libs/guile.exe$' \
          -e '^./libguile/.libs/gen-scmconfig.exe$' \
          -e '^./libguile/.libs/guile_filter_doc_snarfage.exe$' \
          -e '^./libguile/.libs/libguile-3.0-1.dll$' \
          -e '^./libguile/.libs/libguile-3.0.a$' \
          -e '^./libguile/.libs/libguile-3.0.dll.a$' \
          -e '^./libguile/.*\.h$' \
          -e '^./libguile.h$' \
          -e '^./module/.*\.go$' \
          -e '^./*.tar.zst$' \
          -e '^./README$' \
          -e '^./COPYING$' \
          -e '^./INSTALL$' \
          -e '^./THANKS$' \
     | zip guile-3-mingw64.zip -@

ls -ltr guile-3-mingw64.zip
