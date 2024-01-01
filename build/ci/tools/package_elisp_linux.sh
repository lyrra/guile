#!/usr/bin/env bash

ls -ltr
echo "------- build -------"
ls -ltr build

echo "------ Files to zip: ---------"

echo "------ URSLOCAL: ---------"

find /usr/local

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
          -e '^./libguile/.libs/guile$' \
          -e '^./libguile/.libs/gen-scmconfig$' \
          -e '^./libguile/.libs/guile_filter_doc_snarfage$' \
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
     | tar cvf linux-x86_64-guile3-elisp.tar.xz --files-from=-

ls -ltr linux-x86_64-guile3-elisp.tar.xz
