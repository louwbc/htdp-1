#lang racket
(require lang/htdp-beginner)

;; word3 is a structure:
;; (make-word3 number number number)
(define-struct word3 (letter1 letter2 letter3))

;; EXAMPLES
(make-word3 's 'i 't)
(make-word3 'f 'o 'r)
(make-word3 't 'w 'o)
