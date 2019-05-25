;Use % to represent a subexpression that is #t in LDA's version and #f in SVM's version
(define (check-tf x y)
    (and (equal? x #t) (equal? y #f) '%))

;Use (not %) to represent inverse of above case
(define (inverse-check-tf x y)
    (and (equal? x #f) (equal? y #t) '(not %)))

;Function to generate an output string
(define (generate-output x y)
    (quasiquote (if % (unquote x) (unquote y))))

;Get the length of a list
;Serves as a helper for compare-lengths
(define (length-l x)
    (cond 
        ((or (list? x) (pair? x)) 
            (length x))
        (else 1)
    )
)

;Function to compare the length of two lists
(define (compare-lengths x y)
    (let 
        ((first (length-l x))
        (second (length-l y)))
            (equal? first second)
    )
)

;Main driver function
;x -> LDA, y -> SVM
(define (expr-compare x y)
    (cond
        ((equal? x y) x)
        ((check-tf x y))
        ((inverse-check-tf x y))
        ((not (compare-lengths x y)) (generate-output x y))
        ((and (list? x) (list? y))
            (if (equal? (car x) (car y))
                (let ((car x) head)
                    (cond 

                    )
                )
            )
        )
        ((generate-output x y))
    )
)

(define test-expr-x '(+ 3 ((lambda (a b) (list a b)) 1 2)))
(define test-expr-y '(+ 2 ((lambda (a c) (list a c)) 1 2)))

;
(define (test-expr-compare x y)
    #t
)