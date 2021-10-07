#lang racket

;;;;
;;;; Generic reader and expander.  Load in the program instructions
;;;; as a string, and call execute in turing/execute.
;;;;
(module reader racket
  (require syntax/strip-context)
 
  (provide (rename-out [turing-read read]
                       [turing-read-syntax read-syntax]))
 
  (define (turing-read in)
    (syntax->datum
     (turing-read-syntax #f in)))
 
  (define (turing-read-syntax src in)
    (with-syntax ([str (port->string in)])
      (strip-context
       #'(module anything racket
           (provide data)
           (define data 'str)
           (require turing/execute)
           (execute 'str))))))