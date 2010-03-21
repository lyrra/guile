;;; conditions.scm --- The R6RS conditions library

;;      Copyright (C) 2010 Free Software Foundation, Inc.
;;
;; This library is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public
;; License as published by the Free Software Foundation; either
;; version 3 of the License, or (at your option) any later version.
;; 
;; This library is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; Lesser General Public License for more details.
;; 
;; You should have received a copy of the GNU Lesser General Public
;; License along with this library; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA


(library (rnrs conditions (6))
  (export &condition
	  condition
	  simple-conditions
	  condition?
	  condition-predicate
	  condition-accessor
	  define-condition-type
	  
	  &message
	  make-message-condition
	  message-condition?
	  condition-message

	  &warning
	  make-warning
	  warning?

	  &serious
	  make-serious-condition
	  serious-condition?

	  &error
	  make-error
	  error?

	  &violation
	  make-violation
	  violation?

	  &assertion
	  make-assertion-violation
	  assertion-violation?

	  &irritants
	  make-irritants-condition
	  irritants-condition?
	  condition-irritants

	  &who
	  make-who-condition
	  who-condition?
	  condition-who

	  &non-continuable
	  make-non-continuable-violation
	  non-continuable-violation?

	  &implementation-restriction
	  make-implementation-restriction
	  implementation-restriction-violation?

	  &lexical
	  make-lexical-violation
	  lexical-violation?

	  &syntax
	  make-syntax-violation
	  syntax-violation?
	  syntax-violation-form
	  syntax-violation-subform

	  &undefined
	  make-undefined-violation
	  undefined-violation?)
  (import (rnrs base (6))
	  (rnrs records procedural (6))
	  (rnrs syntax-case (6)))
	  
  (define &compound-condition (make-record-type-descriptor 
			       '&compound-condition #f #f #f #f
			       '#((immutable components))))
  (define compound-condition? (record-predicate &compound-condition))
  
  (define make-compound-condition 
    (record-constructor (make-record-constructor-descriptor 
			 &compound-condition #f #f)))
  (define compound-condition-components (record-accessor &compound-condition 0))

  (define-syntax define-condition-type
    (lambda (stx)
      (syntax-case stx ()
	((_ condition-type supertype constructor predicate
	    (field accessor) ...)
	 (let*
	   ((fields (let* ((field-spec-syntax #'((field accessor) ...))
			  (field-specs (syntax->datum field-spec-syntax)))
		     (list->vector (map (lambda (field-spec)
					  (cons 'immutable field-spec))
					field-specs))))
	    (fields-syntax (datum->syntax stx fields)))
	  #`(begin
	      (define condition-type 
		(make-record-type-descriptor 
		 #,(datum->syntax
		    stx (list 'quote (syntax->datum #'condition-type)))
		 supertype #f #f #f #,fields-syntax))
	      (define constructor
		(record-constructor 
		 (make-record-constructor-descriptor condition-type #f #f)))
	      (define predicate (record-predicate condition-type))
	      #,@(let f ((accessors '())
			 (counter 0))
		   (if (>= counter (vector-length fields))
		       accessors
		       (f (cons #`(define #,(datum->syntax 
					     stx (caddr (vector-ref fields 
								    counter)))
				    (record-accessor condition-type #,counter))
				accessors)
			  (+ counter 1))))))))))
		       
  (define &condition (@@ (rnrs records procedural) &condition))
  (define &condition-constructor-descriptor
    (make-record-constructor-descriptor &condition #f #f))
  (define condition-internal? (record-predicate &condition))

  (define condition
    (lambda conditions
      (define (flatten cond)
	(if (compound-condition? cond)
	    (fold append '() (map flatten (compound-condition-components cond)))
	    cond))
      (or (for-all condition? conditions)
	  (raise (make-assertion-violation)))
      (make-compound-condition (flatten conditions))))

  (define (simple-conditions condition) (record-accessor &compound-condition 0))
  (define (condition? obj) 
    (or (compound-condition? obj) (condition-internal? obj)))
  (define (condition-predicate rtd)
    (let ((rtd-predicate (record-predicate rtd)))
      (lambda (obj)
	(cond ((compound-condition? obj) 
	       (find rtd-predicate (compound-condition-components obj)))
	      ((condition-internal? obj) (rtd-predicate obj))
	      (else #f)))))

  (define (condition-accessor rtd proc)
    (let ((rtd-predicate (record-predicate rtd)))
      (lambda (obj)
	(cond ((rtd-predicate obj) (proc obj))
	      ((compound-condition? obj) 
	       (and=> (find rtd-predicate simple-conditions obj) proc))
	      (else #f)))))

  (define-condition-type &message &condition 
    make-message-condition message-condition? 
    (message condition-message))

  (define-condition-type &warning &condition make-warning warning?)

  (define &serious (@@ (rnrs records procedural) &serious))
  (define make-serious-condition 
    (@@ (rnrs records procedural) make-serious-condition))
  (define serious-condition? (@@ (rnrs records procedural) serious-condition?))

  (define-condition-type &error &serious make-error error?)

  (define &violation (@@ (rnrs records procedural) &violation))
  (define make-violation (@@ (rnrs records procedural) make-violation))
  (define violation? (@@ (rnrs records procedural) violation?))

  (define &assertion (@@ (rnrs records procedural) &assertion))
  (define make-assertion-violation 
    (@@ (rnrs records procedural) make-assertion-violation))
  (define assertion-violation? 
    (@@ (rnrs records procedural) assertion-violation?))

  (define-condition-type &irritants &condition 
    make-irritants-condition irritants-condition?
    (irritants condition-irritants))

  (define-condition-type &who &condition
    make-who-condition who-condition?
    (who condition-who))

  (define-condition-type &non-continuable &violation
    make-non-continuable-violation
    non-continuable-violation?)

  (define-condition-type &implementation-restriction
    &violation
    make-implementation-restriction-violation
    implementation-restriction-violation?)

  (define-condition-type &lexical &violation
    make-lexical-violation lexical-violation?)

  (define-condition-type &syntax &violation
    make-syntax-violation syntax-violation
    (form syntax-violation-form)
    (subform syntax-violation-subform))

  (define-condition-type &undefined &violation
    make-undefined-violation undefined-violation?)
  
  ;; Condition types that are used by (rnrs files), (rnrs io ports), and
  ;; (rnrs io simple).  These are defined here so as to be easily shareable by
  ;; these three libraries.
  
  (define-condition-type &i/o &error make-i/o-error i/o-error?)
  (define-condition-type &i/o-read &i/o make-i/o-read-error i/o-read-error?)
  (define-condition-type &i/o-write &i/o make-i/o-write-error i/o-write-error?)
  (define-condition-type &i/o-invalid-position
    &i/o make-i/o-invalid-position-error i/o-invalid-position-error?
    (position i/o-error-position))
  (define-condition-type &i/o-filename 
    &i/o make-i/o-filename-error i/o-filename-error?
    (filename i/o-error-filename))
  (define-condition-type &i/o-file-protection
    &i/o-filename make-i/o-file-protection-error i/o-file-protection-error?)
  (define-condition-type &i/o-file-is-read-only
    &i/o-file-protection make-i/o-file-is-read-only-error 
    i/o-file-is-read-only-error?)
  (define-condition-type &i/o-file-already-exists
    &i/o-filename make-i/o-file-already-exists-error 
    i/o-file-already-exists-error?)
  (define-condition-type &i/o-file-does-not-exist
    &i/o-filename make-i/o-file-does-not-exist-error
    i/o-file-does-not-exist-error?)
  (define-condition-type &i/o-port &i/o make-i/o-port-error i/o-port-error?
    (port i/o-error-port))
)
