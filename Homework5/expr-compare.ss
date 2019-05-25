;Lambda symbol 
;https://www.fileformat.info/info/unicode/char/3bb/index.htm
(define lambda-sym (string->symbol "\u03BB"))

;Defined as mentioned in the spec
(define test-expr-x '(+ 3 ((lambda (a b) (list a b)) 1 2)))
(define test-expr-y '(+ 2 ((lambda (a c) (list a c)) 1 2)))

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

;Function to merge x and y into x!y
;https://www.gnu.org/software/guile/manual/html_node/Reversing-and-Appending-Strings.html
(define (merge_xy x y)
    (string->symbol (string-append (symbol->string x) "!" (symbol->string y))))

;Helper function to process expressions with lambda in them
(define (lambda-helper x y)
    #t
)

;Look for specific keywords and if they exist, return true else return false
(define (check_keywords x)
    (if 
        (or (equal? x 'lambda)
            (equal? x lambda-sym)
            (equal? x 'quote)
            (equal? x 'if))
        #t
        #f
    )
)

;Function to check possible combination of lambdas that could be passed in
(define (check_lambdas x y)
    (if 
        ;lambda lambda and lambda-sym lambda-sym are already covered in expr-compare
        (or 
            (and (equal? x 'lambda) (equal? y lambda-sym))
            (and (equal? x lambda-sym) (equal? y 'lambda)))
        #t
        #f
    )
)

#| Helper function for expr-compare to process lists in an
instance where both of them have the same first elements |#
(define (compare-head-equal x y)
    (let ((head (car x)))
        (cond 
            ((equal? head 'quote) (generate-output x y))
            ((or (equal? head 'lambda) (equal? head lambda-sym)) (lambda-helper x y))
            ((cons (expr-compare head (car y)) (expr-compare (cdr x) (cdr y))))
        )
    )
)

#| Helper function for expr-compare to process lists in an
instance where both of them don't have the same first elements |#
(define (compare-head-not-equal x y)
    (let ((head-x (car x))
          (head-y (car y)))
        (cond 
            ((check_lambdas head-x head-y) (lambda-helper x y))
            ((or (check_keywords head-x) (check_keywords head-y)) (generate-output x y))
            ((cons (expr-compare head-x head-y) (expr-compare (cdr x) (cdr y))))
        )
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
            (if 
                (equal? (car x) (car y)) ;test-expr
                (compare-head-equal x y) ;then-expr
                (compare-head-not-equal x y) ;else-expr
            ))
        (else (generate-output x y))
    )
)

;
(define (test-expr-compare x y)
    #t
)