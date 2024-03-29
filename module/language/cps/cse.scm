;;; Continuation-passing style (CPS) intermediate language (IL)

;; Copyright (C) 2013, 2014, 2015, 2017, 2018 Free Software Foundation, Inc.

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

;;; Commentary:
;;;
;;; Common subexpression elimination for CPS.
;;;
;;; Code:

(define-module (language cps cse)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (language cps)
  #:use-module (language cps utils)
  #:use-module (language cps effects-analysis)
  #:use-module (language cps intmap)
  #:use-module (language cps intset)
  #:export (eliminate-common-subexpressions))

(define (compute-available-expressions succs kfun effects)
  "Compute and return a map of LABEL->ANCESTOR..., where ANCESTOR... is
an intset containing ancestor labels whose value is available at LABEL."
  (let ((init (intmap-map (lambda (label succs) #f) succs))
        (kill (compute-clobber-map effects))
        (gen (intmap-map (lambda (label succs) (intset label)) succs))
        (subtract (lambda (in-1 kill-1)
                    (if in-1
                        (intset-subtract in-1 kill-1)
                        empty-intset)))
        (add intset-union)
        (meet (lambda (in-1 in-1*)
                (if in-1
                    (intset-intersect in-1 in-1*)
                    in-1*))))
    (let ((in (intmap-replace init kfun empty-intset))
          (out init)
          (worklist (intset kfun)))
      (solve-flow-equations succs in out kill gen subtract add meet worklist))))

(define (intset-pop set)
  (match (intset-next set)
    (#f (values set #f))
    (i (values (intset-remove set i) i))))

(define-syntax-rule (make-worklist-folder* seed ...)
  (lambda (f worklist seed ...)
    (let lp ((worklist worklist) (seed seed) ...)
      (call-with-values (lambda () (intset-pop worklist))
        (lambda (worklist i)
          (if i
              (call-with-values (lambda () (f i seed ...))
                (lambda (i* seed ...)
                  (let add ((i* i*) (worklist worklist))
                    (match i*
                      (() (lp worklist seed ...))
                      ((i . i*) (add i* (intset-add worklist i)))))))
              (values seed ...)))))))

(define worklist-fold*
  (case-lambda
    ((f worklist seed)
     ((make-worklist-folder* seed) f worklist seed))))

(define (compute-truthy-expressions conts kfun)
  "Compute a \"truth map\", indicating which expressions can be shown to
be true and/or false at each label in the function starting at KFUN..
Returns an intmap of intsets.  The even elements of the intset indicate
labels that may be true, and the odd ones indicate those that may be
false.  It could be that both true and false proofs are available."
  (define (true-idx label) (ash label 1))
  (define (false-idx label) (1+ (ash label 1)))

  (define (propagate boolv succ out)
    (let* ((in (intmap-ref boolv succ (lambda (_) #f)))
           (in* (if in (intset-intersect in out) out)))
      (if (eq? in in*)
          (values '() boolv)
          (values (list succ)
                  (intmap-add boolv succ in* (lambda (old new) new))))))

  (define (visit-cont label boolv)
    (let ((in (intmap-ref boolv label)))
      (define (propagate0)
        (values '() boolv))
      (define (propagate1 succ)
        (propagate boolv succ in))
      (define (propagate2 succ0 succ1)
        (let*-values (((changed0 boolv) (propagate boolv succ0 in))
                      ((changed1 boolv) (propagate boolv succ1 in)))
          (values (append changed0 changed1) boolv)))
      (define (propagate-branch succ0 succ1)
        (let*-values (((changed0 boolv)
                       (propagate boolv succ0
                                  (intset-add in (false-idx label))))
                      ((changed1 boolv)
                       (propagate boolv succ1
                                  (intset-add in (true-idx label)))))
          (values (append changed0 changed1) boolv)))

      (match (intmap-ref conts label)
        (($ $kargs names vars term)
         (match term
           (($ $continue k)   (propagate1 k))
           (($ $branch kf kt) (propagate-branch kf kt))
           (($ $prompt k kh)  (propagate2 k kh))
           (($ $throw)        (propagate0))))
        (($ $kreceive arity k)
         (propagate1 k))
        (($ $kfun src meta self tail clause)
         (if clause
             (propagate1 clause)
             (propagate0)))
        (($ $kclause arity kbody kalt)
         (if kalt
             (propagate2 kbody kalt)
             (propagate1 kbody)))
        (($ $ktail) (propagate0)))))

  (intset-fold
   (lambda (kfun boolv)
     (worklist-fold* visit-cont
                     (intset kfun)
                     (intmap-add boolv kfun empty-intset)))
   (intmap-keys (compute-reachable-functions conts kfun))
   empty-intmap))

(define (intset-map f set)
  (persistent-intmap
   (intset-fold (lambda (i out) (intmap-add! out i (f i)))
                set
                empty-intmap)))

;; Returns a map of label-idx -> (var-idx ...) indicating the variables
;; defined by a given labelled expression.
(define (compute-defs conts kfun)
  (intset-map (lambda (label)
                (match (intmap-ref conts label)
                  (($ $kfun src meta self tail clause)
                   (if self (list self) '()))
                  (($ $kclause arity body alt)
                   (match (intmap-ref conts body)
                     (($ $kargs names vars) vars)))
                  (($ $kreceive arity kargs)
                   (match (intmap-ref conts kargs)
                     (($ $kargs names vars) vars)))
                  (($ $ktail)
                   '())
                  (($ $kargs names vars term)
                   (match term
                     (($ $continue k)
                      (match (intmap-ref conts k)
                        (($ $kargs names vars) vars)
                        (_ #f)))
                     (($ $branch)
                      '())
                     ((or ($ $prompt) ($ $throw))
                      #f)))))
               (compute-function-body conts kfun)))

(define (compute-singly-referenced succs)
  (define (visit label succs single multiple)
    (intset-fold (lambda (label single multiple)
                   (if (intset-ref single label)
                       (values single (intset-add! multiple label))
                       (values (intset-add! single label) multiple)))
                 succs single multiple))
  (call-with-values (lambda ()
                      (intmap-fold visit succs empty-intset empty-intset))
    (lambda (single multiple)
      (intset-subtract (persistent-intset single)
                       (persistent-intset multiple)))))

(define (intmap-select map set)
  (intset->intmap (lambda (label) (intmap-ref map label)) set))

(define (compute-equivalent-subexpressions conts kfun)
  (define (visit-fun kfun body equiv-labels var-substs)
    (let* ((conts (intmap-select conts body))
           (effects (synthesize-definition-effects (compute-effects conts)))
           (succs (compute-successors conts kfun))
           (singly-referenced (compute-singly-referenced succs))
           (avail (compute-available-expressions succs kfun effects))
           (defs (compute-defs conts kfun))
           (equiv-set (make-hash-table)))
      (define (subst-var var-substs var)
        (intmap-ref var-substs var (lambda (var) var)))
      (define (subst-vars var-substs vars)
        (let lp ((vars vars))
          (match vars
            (() '())
            ((var . vars) (cons (subst-var var-substs var) (lp vars))))))

      (define (compute-term-key var-substs term)
        (match term
          (($ $continue k src exp)
           (match exp
             (($ $const val) (cons 'const val))
             (($ $prim name) (cons 'prim name))
             (($ $fun body) #f)
             (($ $rec names syms funs) #f)
             (($ $const-fun label) #f)
             (($ $code label) (cons 'code label))
             (($ $call proc args) #f)
             (($ $callk k proc args) #f)
             (($ $primcall name param args)
              (cons* name param (subst-vars var-substs args)))
             (($ $values args) #f)))
          (($ $branch kf kt src op param args)
           (cons* op param (subst-vars var-substs args)))
          ((or ($ $prompt) ($ $throw)) #f)))

      (define (add-auxiliary-definitions! label var-substs term-key)
        (let ((defs (and=> (intmap-ref defs label)
                           (lambda (defs) (subst-vars var-substs defs)))))
          (define (add-def! aux-key var)
            (let ((equiv (hash-ref equiv-set aux-key '())))
              (hash-set! equiv-set aux-key
                         (acons label (list var) equiv))))
          (define-syntax add-definitions
            (syntax-rules (<-)
              ((add-definitions)
               #f)
              ((add-definitions
                ((def <- op arg ...) (aux <- op* arg* ...) ...)
                . clauses)
               (match term-key
                 (('op arg ...)
                  (match defs
                    ((def) (add-def! (list 'op* arg* ...) aux) ...)))
                 (_ (add-definitions . clauses))))
              ((add-definitions
                ((op arg ...) (aux <- op* arg* ...) ...)
                . clauses)
               (match term-key
                 (('op arg ...)
                  (add-def! (list 'op* arg* ...) aux) ...)
                 (_ (add-definitions . clauses))))))
          (add-definitions
           ((scm-set! p s i x)               (x <- scm-ref p s i))
           ((scm-set!/tag p s x)             (x <- scm-ref/tag p s))
           ((scm-set!/immediate p s x)       (x <- scm-ref/immediate p s))
           ((word-set! p s i x)              (x <- word-ref p s i))
           ((word-set!/immediate p s x)      (x <- word-ref/immediate p s))
           ((pointer-set!/immediate p s x)   (x <- pointer-ref/immediate p s))

           ((u <- scm->f64 #f s)             (s <- f64->scm #f u))
           ((s <- f64->scm #f u)             (u <- scm->f64 #f s))
           ((u <- scm->u64 #f s)             (s <- u64->scm #f u))
           ((s <- u64->scm #f u)             (u <- scm->u64 #f s)
                                             (u <- scm->u64/truncate #f s))
           ((s <- u64->scm/unlikely #f u)    (u <- scm->u64 #f s)
                                             (u <- scm->u64/truncate #f s))
           ((u <- scm->s64 #f s)             (s <- s64->scm #f u))
           ((s <- s64->scm #f u)             (u <- scm->s64 #f s))
           ((s <- s64->scm/unlikely #f u)    (u <- scm->s64 #f s))
           ((u <- untag-fixnum #f s)         (s <- s64->scm #f u)
                                             (s <- tag-fixnum #f u))
           ;; NB: These definitions rely on U having top 2 bits equal to
           ;; 3rd (sign) bit.
           ((s <- tag-fixnum #f u)           (u <- scm->s64 #f s)
                                             (u <- untag-fixnum #f s))
           ((s <- u64->s64 #f u)             (u <- s64->u64 #f s))
           ((u <- s64->u64 #f s)             (s <- u64->s64 #f u))

           ((u <- untag-char #f s)           (s <- tag-char #f u))
           ((s <- tag-char #f u)             (u <- untag-char #f s)))))

      (define (visit-label label equiv-labels var-substs)
        (define (term-defs term)
          (match term
            (($ $continue k)
             (and (intset-ref singly-referenced k)
                  (intmap-ref defs label)))
            (($ $branch) '())))
        (match (intmap-ref conts label)
          (($ $kargs names vars term)
           (match (compute-term-key var-substs term)
             (#f (values equiv-labels var-substs))
             (term-key
              (let* ((equiv (hash-ref equiv-set term-key '()))
                     (fx (intmap-ref effects label))
                     (avail (intmap-ref avail label)))
                (define (finish equiv-labels var-substs)
                  ;; If this expression defines auxiliary definitions,
                  ;; as `cons' does for the results of `car' and `cdr',
                  ;; define those.  Do so after finding equivalent
                  ;; expressions, so that we can take advantage of
                  ;; subst'd output vars.
                  (add-auxiliary-definitions! label var-substs term-key)
                  (values equiv-labels var-substs))
                (let lp ((candidates equiv))
                  (match candidates
                    (()
                     ;; No matching expressions.  Add our expression
                     ;; to the equivalence set, if appropriate.  Note
                     ;; that expressions that allocate a fresh object
                     ;; or change the current fluid environment can't
                     ;; be eliminated by CSE (though DCE might do it
                     ;; if the value proves to be unused, in the
                     ;; allocation case).
                     (when (and (not (causes-effect? fx &allocation))
                                (not (effect-clobbers? fx (&read-object &fluid))))
                       (let ((defs (term-defs term)))
                         (when defs
                           (hash-set! equiv-set term-key
                                      (acons label defs equiv)))))
                     (finish equiv-labels var-substs))
                    (((and head (candidate . vars)) . candidates)
                     (cond
                      ((not (intset-ref avail candidate))
                       ;; This expression isn't available here; try
                       ;; the next one.
                       (lp candidates))
                      (else
                       ;; Yay, a match.  Mark expression as equivalent.  If
                       ;; we provide the definitions for the successor, mark
                       ;; the vars for substitution.
                       (finish (intmap-add equiv-labels label head)
                               (let ((defs (term-defs term)))
                                 (if defs
                                     (fold (lambda (def var var-substs)
                                             (intmap-add var-substs def var))
                                           var-substs defs vars)
                                     var-substs))))))))))))
          (_ (values equiv-labels var-substs))))

      ;; Traverse the labels in fun in reverse post-order, which will
      ;; visit definitions before uses first.
      (fold2 visit-label
             (compute-reverse-post-order succs kfun)
             equiv-labels
             var-substs)))

  (intmap-fold visit-fun
               (compute-reachable-functions conts kfun)
               empty-intmap
               empty-intmap))

(define (apply-cse conts equiv-labels var-substs truthy-labels)
  (define (true-idx idx) (ash idx 1))
  (define (false-idx idx) (1+ (ash idx 1)))

  (define (subst-var var)
    (intmap-ref var-substs var (lambda (var) var)))

  (define (visit-exp exp)
    (rewrite-exp exp
      ((or ($ $const) ($ $prim) ($ $fun) ($ $rec) ($ $const-fun) ($ $code)) ,exp)
      (($ $call proc args)
       ($call (subst-var proc) ,(map subst-var args)))
      (($ $callk k proc args)
       ($callk k (and proc (subst-var proc)) ,(map subst-var args)))
      (($ $primcall name param args)
       ($primcall name param ,(map subst-var args)))
      (($ $values args)
       ($values ,(map subst-var args)))))

  (define (visit-term label term)
    (match term
      (($ $branch kf kt src op param args)
       (match (intmap-ref equiv-labels label (lambda (_) #f))
         ((equiv) ; A branch defines no values.
          (let* ((bool (intmap-ref truthy-labels label))
                 (t (intset-ref bool (true-idx equiv)))
                 (f (intset-ref bool (false-idx equiv))))
            (if (eqv? t f)
                (build-term
                  ($branch kf kt src op param ,(map subst-var args)))
                (build-term
                  ($continue (if t kt kf) src ($values ()))))))
         (#f
          (build-term
            ($branch kf kt src op param ,(map subst-var args))))))
      (($ $continue k src exp)
       (match (intmap-ref equiv-labels label (lambda (_) #f))
         ((equiv . vars)
          (build-term ($continue k src ($values vars))))
         (#f
          (build-term
            ($continue k src ,(visit-exp exp))))))
      (($ $prompt k kh src escape? tag)
       (build-term
         ($prompt k kh src escape? (subst-var tag))))
      (($ $throw src op param args)
       (build-term
         ($throw src op param ,(map subst-var args))))))

  (intmap-map
   (lambda (label cont)
     (rewrite-cont cont
       (($ $kargs names vars term)
        ($kargs names vars ,(visit-term label term)))
       (_ ,cont)))
   conts))

(define (eliminate-common-subexpressions conts)
  (call-with-values (lambda () (compute-equivalent-subexpressions conts 0))
    (lambda (equiv-labels var-substs)
      (let ((truthy-labels (compute-truthy-expressions conts 0)))
        (apply-cse conts equiv-labels var-substs truthy-labels)))))
