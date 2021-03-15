;;; Dezyne --- Dezyne command line tools
;;;
;;; Copyright © 2019,2020,2021 Jan (janneke) Nieuwenhuizen <janneke@gnu.org>
;;;
;;; This file is part of Dezyne.
;;;
;;; Dezyne is free software: you can redistribute it and/or modify it
;;; under the terms of the GNU Affero General Public License as
;;; published by the Free Software Foundation, either version 3 of the
;;; License, or (at your option) any later version.
;;;
;;; Dezyne is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; Affero General Public License for more details.
;;;
;;; You should have received a copy of the GNU Affero General Public
;;; License along with Dezyne.  If not, see <http://www.gnu.org/licenses/>.

(define-module (mingw)
  #:use-module (srfi srfi-1)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages bdw-gc)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages hurd)
  #:use-module (gnu packages mingw)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages pkg-config)
  #:use-module (guile-patched))

(define-public libgc-mingw
  (package
   (name "libgc-mingw")
   (version "7.6.12")
   (source (origin
            (method url-fetch)
            (uri (string-append "https://github.com/ivmai/bdwgc/releases"
                                "/download/v" version "/gc-" version ".tar.gz"))
            (sha256
             (base32
              "10jhhi79d5brwlsyhwgpnrmc8nhlf7aan2lk9xhgihk5jc6srbvc"))))
   (build-system gnu-build-system)
   (arguments
    `(#:strip-binaries? #f
      #:configure-flags
      (list
       ;; Install gc_cpp.h et al.
       "--enable-cplusplus"
       ;; In GNU/Hurd systems during the 'Check' phase,
       ;; there is a deadlock caused by the 'gctest' test.
       ;; To disable the error set "--disable-gcj-support"
       ;; to configure script. See bug report and discussion:
       ;; <https://lists.opendylan.org/pipermail/bdwgc/2017-April/006275.html>
       ;; <https://lists.gnu.org/archive/html/bug-hurd/2017-01/msg00008.html>
       ,@(if (hurd-triplet? (or (%current-system)
                                (%current-target-system)))
             '("--disable-gcj-support")
             '()))
      #:phases (modify-phases %standard-phases
                 (add-after 'unpack 'adjust-pc-file
                   (lambda* (#:key inputs #:allow-other-keys)
                     (let ((libatomic-ops (assoc-ref inputs "libatomic-ops")))
                       ;; GC 7.6.10 and later includes -latomic_ops in the
                       ;; pkg-config file.  To avoid propagation, insert an
                       ;; absolute reference so dependent programs can find it.
                       (substitute* "bdw-gc.pc.in"
                         (("@ATOMIC_OPS_LIBS@" match)
                          (string-append "-L" libatomic-ops "/lib "
                                         match)))
                       #t))))))
   (native-inputs `(("pkg-config" ,pkg-config)))
   (inputs `(("libatomic-ops" ,libatomic-ops)))
   (outputs '("out" "debug"))
   (synopsis "The Boehm-Demers-Weiser conservative garbage collector
for C and C++")
   (description
    "The Boehm-Demers-Weiser conservative garbage collector can be used
as a garbage collecting replacement for C malloc or C++ new.  It allows
you to allocate memory basically as you normally would, without
explicitly deallocating memory that is no longer useful.  The collector
automatically recycles memory when it determines that it can no longer
be otherwise accessed.

The collector is also used by a number of programming language
implementations that either use C as intermediate code, want to
facilitate easier interoperation with C libraries, or just prefer the
simple collector interface.

Alternatively, the garbage collector may be used as a leak detector for
C or C++ programs, though that is not its primary goal.")
   (home-page "http://www.hboehm.info/gc/")

   (license (license:x11-style (string-append home-page "license.txt")))))

(define-public guile-3.0-mingw
  (package
    (inherit guile-3.0-patched)
    (name "guile-mingw")
    (native-inputs
     `(("self" ,guile-3.0-patched)
       ,@(alist-delete "self" (package-native-inputs guile-3.0-patched))))
    (propagated-inputs
     `(("bdw-gc" ,libgc-mingw)
       ,@(alist-delete "bwd-gc" (package-propagated-inputs guile-3.0-patched))))
    (arguments
     `(#:tests? #f
       #:strip-binaries? #f
       ,@(if (%current-target-system)
             (substitute-keyword-arguments (package-arguments guile-3.0-patched)
               ((#:configure-flags flags '())
                `(cons* "--disable-jit"
                        "--enable-mini-gmp"
                        ,flags))
               ((#:phases phases '%standard-phases)
                `(modify-phases ,phases
                   (add-after 'unpack 'bootstrap
                     (lambda _
                       (invoke "sh" "autogen.sh")))
                   (add-after 'unpack 'patch-version-gen
                     (lambda _
                       (substitute* "build-aux/git-version-gen"
                         (("#!/bin/sh") (string-append "#! " (which "sh")))))))))
             (package-arguments guile-3.0-patched))))))
