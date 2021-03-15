;;; Dezyne --- Dezyne command line tools
;;;
;;; Copyright © 2020,2021 Jan (janneke) Nieuwenhuizen <janneke@gnu.org>
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

(define-module (guile-patched)
  #:use-module (gnu packages)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages flex)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages gperf)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages texinfo)
  #:use-module (guix build utils)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils))

(define-public guile-3.0-patched
  (let ((commit "6a1d76036ee6e4e472d1acc536d25c0239378476")
        (revision "14"))
    (package
      (inherit guile-3.0-latest)
      (name "guile-patched")
      (version (string-append "3.0.5" "-" revision "." (string-take commit 7)))
      (native-inputs
       `(("autoconf" ,autoconf)
         ("automake" ,automake)
         ("libtool" ,libtool)
         ("flex" ,flex)
         ("texinfo" ,texinfo)
         ("gettext" ,gettext-minimal)
         ("gperf" ,gperf)
         ,@(package-native-inputs guile-3.0-latest)))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://gitlab.com/janneke/guile.git")
                      (commit commit)))
                (file-name (string-append name "-" version "-checkout"))
                (sha256
                 (base32
                  "0azwabkl88mqzgfcsarj8sh65jrxg22nplxhn2j7xr84h5hbnmrf"))))
      (arguments
       (substitute-keyword-arguments (package-arguments guile-3.0-latest)
         ((#:phases phases '%standard-phases)
          `(modify-phases ,phases
             (add-after 'unpack 'disable-some-tests
               (lambda _
                 (delete-file "test-suite/tests/asyncs.test")
                 (delete-file "test-suite/tests/ftw.test")
                 (substitute* "test-suite/standalone/Makefile.am"
                   (("check_SCRIPTS \\+= test-out-of-memory" all)
                    (string-append "# " all))
                   (("TESTS \\+= test-out-of-memory" all)
                    (string-append "# " all))))))))))))
