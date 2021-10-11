#lang racket

;;;; Quick description of the language:
;;;;
;;;; First line : #lang turing
;;;; Second line: <tape> with "_" for blanks
;;;; Third line : <starting state> <starting position of head>
;;;;              <step to start printing> <step to stop printing>
;;;; Instructions (subsequent lines): <m-configuration> <symbol> <operations> <final m-configuration>
;;;;
;;;; For <symbol>, use "*" for any (to match any symbol execpt "_").
;;;; If <final m-configuration> is "halt" then the machine will halt after that instruction is run.
;;;;

;;;;
;;;; Where all the heavy lifting of the Turing machine is done.  Execute kicks
;;;; things off and does some parsing.  The main loop is taken care of by the
;;;; run function.
;;;; 
(provide execute)

;;;
;;; Execute the code by:
;;;
;;; (i) Preparing the input
;;; (ii) Displaying the initial state (when start is 0)
;;; (iii) Calling the run function
;;;
(define (execute str)
  ;; prg             : convenience for following elements except step
  ;; step            : initialise step counter
  ;; tape            : initial tape state (string)
  ;; config-set      : convenience for four following elements (string)
  ;; m-configuration : initial m-configuration (string)
  ;; head            : starting position of head (integer)
  ;; start           : start printing output at step (integer)
  ;; end             : end execution at step (integer)
  ;; instructions    : list of instructions
  (let* ([prg (prepare-data str)]
         [step 0]
         [tape (first prg)]
         [config-set (string-split (second prg))]
         [m-configuration (first config-set)]
         [head (string->number (second config-set))]
         [start (string->number (third config-set))]
         [end (string->number (fourth config-set))]
         [instructions (parse-instructions (cddr prg))])
    ;; show starting position (when start is 0)
    (when (zero? start) (show-results tape m-configuration head -1))
    ;; call run function with the parsed information
    (run step tape m-configuration head start end instructions)))

;;;
;;; Convert input to list of strings.  Filter out strings that are blank
;;; or lines that begin with ";" (to allow comments).
;;;
(define (prepare-data str)
  (let ([strings (string-split str "\n")])
    (filter (lambda (x)
              (not (or (equal? "" x)
                       (equal? #\; (first (string->list x))))))
            strings)))

;;;
;;; Go through instructions and parse, splitting each into a hash table
;;; so tha we can easily refer to the components.
;;;
(define (parse-instructions instructions)
  (map (lambda (x)
         (let ([split (string-split x)])
           (hash "starting" (first split)
                 "symbol" (second split)
                 "operations" (string-split (third split) ",")
                 "final" (fourth split))))
       instructions))

;;;
;;; Run loop.
;;;
(define (run step tape m-configuration head start end instructions)
  ;; Exit when end - step = 0 or "halt" m-configuration.  Otherwise, recurse.
  (if (or (zero? (- end step)) (equal? m-configuration "halt"))
      (display "halt")
      ;; instruction: found from current m-configuration and symbol under head
      ;; operations : list of operations (comma delimited) in instruction
      ;; result     : result of carrying out operation
      (let* ([instruction (find-instruction instructions
                                            m-configuration
                                            (symbol-under-head tape head))]
             [operations (hash-ref instruction "operations")]
             [result (operate tape m-configuration head operations step start)])
        ;; Call run recursively.  Increment step so we know when to stop.
        (run (add1 step)
             (first result)
             (hash-ref instruction "final")
             (second result)
             start end instructions))))

;;;
;;; Show results.  Template:
;;;
;;; b(5): 01010 | For m-configuration b, step 5, the tape reads
;;;          ^  |  "01010" and the head is at position 3.
;;;
(define (show-results tape m-configuration position step)
  (let ([prefix (string-append m-configuration
                               "("
                               (number->string (add1 step))
                               "): ")])
    (display prefix)
    (display tape)
    (display "\n")
    ;; Place caret based in the right position, including the length of the prefix
    (display (make-string (+ position (string-length prefix)) #\space))
    (display "^")
    (display "\n")))
   
;;;
;;; Return instruction based on current m-configuration and symbol under head
;;;
(define (find-instruction instructions m-configuration symbol)
  (let ([instruction
         ;; Filter all instructions except keep:
         ;; (i) the case where the instruction's "starting" element matches the current
         ;;     m-configuration, and the instruction's "symbol" element matches the
         ;;     current symbol under the head
         ;; OR
         ;; (ii) the case where the instruction's "starting" element matches the current
         ;;      m-configuration and the instruction's "symbol" is "*" and the current
         ;;      symbol under the head is not a blank ("_").
         (filter (lambda (x)
                   (and (equal? (hash-ref x "starting") m-configuration)
                        (or (equal? (hash-ref x "symbol") symbol)
                            (and (equal? (hash-ref x "symbol") "*")
                                 (not (equal? "_" symbol))))))
                 instructions)])
    (if (empty? instruction)
        (error "Instruction not found for m-configuration" m-configuration "and symbol" symbol)
        (first instruction))))

;;;
;;; Return symbol under head
;;;
(define (symbol-under-head tape head)
  (substring tape head (add1 head)))

;;;
;;; Carry out operations
;;;
(define (operate tape m-configuration head operations step start)
  (if (or (empty? operations) (equal? (first operations) "_"))
      (list tape head)
      (let* ([target 
              (cond [(equal? (first operations) "L") l]
                    [(equal? (first operations) "R") r]
                    [(equal? (first operations) "E") e]
                    [else p])]
             [result (target tape head (first operations))])
        (unless (< step (sub1 start)) (show-results (first result) m-configuration (second result) step))
        (operate (first result) m-configuration (second result) (cdr operations) step start))))

;;;
;;; Move head right
;;;
(define (r tape head operation)
  (if (= (string-length tape) (add1 head))
      (list (string-append tape "_") (add1 head))
      (list tape (add1 head))))

;;;
;;; Move head left
;;;
(define (l tape head operation)
  (if (= 0 head)
      (list (string-append "_" tape) head)
      (list tape (sub1 head))))

;;;
;;; Print to square under head
;;;
(define (p tape head operation)
  (list (string-append (substring tape 0 head)
                       (substring operation 1 2)
                       (substring tape (add1 head) (string-length tape)))
        head))

;;;
;;; Erase square under head
;;;
(define (e tape head operation)
  (p tape head "P_"))