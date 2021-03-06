#lang racket
(require lang/htdp-intermediate-lambda)

(define MC 3)
(define BOAT-CAPACITY 2)

;; A distribution is
;; (make-distribution number number)
(define-struct distribution (mis can))

;; A boat is
;; (make-boat symbol distribution)
(define-struct boat (at-dock load))

;; A board is
;; (make-board distribution boat distribution
(define-struct board (beg boat end))

;; make-BOAT-LOAD : number -> (listof distribution)
;; Creates a list of all possible boat loads.
(define (make-BOAT-LOAD capacity)
  ;; Better Approach
  ;; make-limit-triangle : number -> (listof distribution)
  (local ((define (make-limit-triangle limit)
    (local ((define (make-distributions m c)
              (cond
               [(> m limit) empty]
               [(> (+ m c) limit) (make-distributions (add1 m) 0)]
               [else (cons (make-distribution m c) (make-distributions m (add1 c)))])))
      (make-distributions 0 1))))
  (make-limit-triangle (min capacity MC))))

(define BOAT-LOADS (make-BOAT-LOAD BOAT-CAPACITY))

;; draw-board : board -> (listof (listof symbol) (listof (listof symbol)) (listof symbol))
;; Draws the given board on console.
(define (draw-board lay-of-land)
  (list (draw-land (board-beg lay-of-land)) (draw-boat (board-boat lay-of-land)) (draw-land (board-end lay-of-land))))

;; draw-land : distribution -> (listof symbol)
;; Draws a given distribution
(define (draw-land dist)
  (local ((define priest-count (distribution-mis dist))
          (define cannibal-count (distribution-can dist))
          (define (draw-remaining-elements x) (draw-representation (- MC x) '_)))
    (append (draw-representation priest-count '+) (draw-remaining-elements priest-count)
            (draw-representation cannibal-count '^) (draw-remaining-elements cannibal-count))))

;; draw-can : distribution -> (listof symbol)
;; Draws cannibals as ^s
(define (draw-can dist)
  (draw-representation (distribution-can dist) '+))

;; draw-mis : distribution -> (listof symbol)
;; Draws missionaries as +s
(define (draw-mis dist)
  (draw-representation (distribution-mis dist) '+))

;; draw-representation : count symbol -> (listof symbol)
;; Draws a given symbol count times.
(define (draw-representation count symbol)
  (build-list count (lambda (x) symbol)))

;; draw-boat : boat -> (listof (listof symbol))
;; Draws a boat as list of list of symbols.
(define (draw-boat boat)
  (local ((define (draw-boat-load dist)
            (append (draw-mis dist) (draw-can dist))))
    (cond [(boat-at-dock boat) (list (draw-boat-load (boat-load boat)) '~)]
          [else (list '~ (draw-boat-load (boat-load boat)))])))


;; next-board : board boat -> board
;; Creates the next state of the board with the given boat state
(define (next-board board boat)
  (cond
   [(boat-at-dock boat) (manip-board distribution- distribution+ boat board)]
   [else (manip-board distribution+ distribution- boat board)]))

(define (manip-board beg-op end-op boat board)
  (make-board (beg-op (board-beg board) (boat-load boat))
              (make-boat (not (boat-at-dock boat)) (make-distribution 0 0))
              (end-op (board-end board) (boat-load boat))))

;; distribution-op : distribution distribution (number number -> number) -> distribution
;; Performs an operation that combines two distributions
(define (distribution-op dist1 dist2 op)
  (make-distribution (op (distribution-mis dist1) (distribution-mis dist2))
                     (op (distribution-can dist1) (distribution-can dist2))))

;; distribution- : distribution distribution -> distribution
(define (distribution- dist1 dist2) (distribution-op dist1 dist2 -))

;; distribution+ : distribution distribution -> distribution
(define (distribution+ dist1 dist2) (distribution-op dist1 dist2 +))

;; generate-possible-boards : board -> (listof board)
;; Creates all possible board combinations from the given one with
;; one boat transport to the other side.
(define (generate-possible-boards board)
  (map (lambda (x) (next-board board (make-boat (boat-at-dock (board-boat board)) x))) BOAT-LOADS))

(define (draw-boards boards)
  (for-each (lambda (x) (pretty-print (draw-board x))) boards))

;; TESTS
(define start (make-board (make-distribution 3 3) (make-boat true (make-distribution 0 0)) (make-distribution 0 0)))
(define end (make-board (make-distribution 0 0) (make-boat false (make-distribution 0 0)) (make-distribution 3 3)))

(draw-boards (generate-possible-boards start))
