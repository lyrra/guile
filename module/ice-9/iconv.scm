;;; Encoding and decoding byte representations of strings

;; Copyright (C) 2013 Free Software Foundation, Inc.

;;;; This library is free software; you can redistribute it and/or
;;;; modify it under the terms of the GNU Lesser General Public
;;;; License as published by the Free Software Foundation; either
;;;; version 3 of the License, or (at your option) any later version.
;;;; 
;;;; This library is distributed in the hope that it will be useful,
;;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;;; Lesser General Public License for more details.
;;;; 
;;;; You should have received a copy of the GNU Lesser General Public
;;;; License along with this library; if not, write to the Free Software
;;;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

;;; Code:

(define-module (ice-9 iconv)
  #:use-module (rnrs bytevectors)
  #:use-module (ice-9 binary-ports)
  #:use-module ((ice-9 rdelim) #:select (read-delimited))
  #:export (string->bytevector
            bytevector->string
            call-with-encoded-output-string))

;; Like call-with-output-string, but actually closes the port.
(define (call-with-output-string* proc)
  (let ((port (open-output-string)))
    (proc port)
    (let ((str (get-output-string port)))
      (close-port port)
      str)))

(define (call-with-output-bytevector* proc)
  (call-with-values (lambda () (open-bytevector-output-port))
    (lambda (port get-bytevector)
      (proc port)
      (let ((bv (get-bytevector)))
        (close-port port)
        bv))))

(define* (call-with-encoded-output-string encoding proc
                                          #:key (conversion-strategy 'error))
  (if (string-ci=? encoding "utf-8")
      ;; I don't know why, but this appears to be faster; at least for
      ;; serving examples/debug-sxml.scm (1464 reqs/s versus 850
      ;; reqs/s).
      (string->utf8 (call-with-output-string* proc))
      (call-with-output-bytevector*
       (lambda (port)
         (set-port-encoding! port encoding)
         (if conversion-strategy
             (set-port-conversion-strategy! port conversion-strategy))
         (proc port)))))

;; TODO: Provide C implementations that call scm_from_stringn and
;; friends?

(define* (string->bytevector str encoding #:key (conversion-strategy 'error))
  (if (string-ci=? encoding "utf-8")
      (string->utf8 str)
      (call-with-encoded-output-string
       encoding
       (lambda (port)
         (display str port))
       #:conversion-strategy conversion-strategy)))

(define* (bytevector->string bv encoding #:key (conversion-strategy 'error))
  (if (string-ci=? encoding "utf-8")
      (utf8->string bv)
      (let ((p (open-bytevector-input-port bv)))
        (set-port-encoding! p encoding)
        (if conversion-strategy
            (set-port-conversion-strategy! p conversion-strategy))
        (let ((res (read-delimited "" p)))
          (close-port p)
          (if (eof-object? res)
              ""
              res)))))