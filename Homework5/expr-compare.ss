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
(define (length-l x)
    (cond 
        ((or 
            (list? x)
            (pair? x)) (length x))
        (else 1)
    )
)

;Main driver function
;x -> LDA
;y -> SVM
(define (expr-compare x y)
    (cond
        ((equal? x y) x)
        ((check-tf x y))
        ((inverse-check-tf x y))
        ((not (equal? (length-l x) (length-l y))) (generate-output x y))
        ((generate-output x y))
    )
)