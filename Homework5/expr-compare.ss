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
        ((or (pair? x) (list? x)) (length x))
        (else 1)
    )
)

;Function to compare the length of two lists
(define (compare-lengths x y)
    (let ((first (length-l x))
         (second (length-l y)))
        (equal? first second)
    )
)

;Function to merge x and y into x!y
;https://www.gnu.org/software/guile/manual/html_node/Reversing-and-Appending-Strings.html
(define (merge-xy x y)
    (string->symbol (string-append (symbol->string x) "!" (symbol->string y))))

;Function to process lambda's parameters
(define (compare-lambda-arguments x y)
    ;Receives lambda's parameters (both of which are lists)
    (let ((head-x (car x))
          (head-y (car y))
          (tail-x (cdr x))
          (tail-y (cdr y))) 
        (cond 
            ;Base case for recursion
            ((or (empty? x) (empty? y) '()))
            ;If x is a symbol, then we should merge it with y
            ((symbol? x) (if (equal? x y) y (merge-xy x y)))
            ;If they're the same, keep one and move on to the next set of arguments in the parameter list
            ((equal? head-x head-y) (cons head-x (compare-lambda-arguments tail-x tail-y)))
            ;If they're not the same, they must be different 
            ((let ((binding (merge-xy head-x head-y)))
                (cons binding (compare-lambda-arguments tail-x tail-y))))
        )
    )
)

;Helper method for update-lambda-body to actually update the body incase of a 
;discrepancy/detected binding 
(define (update binding params body)
    (cond 
        ;Base case to recurse over elements in body
        ((empty? body) '())
        ;
    )
)

;Helper function to update the parameters and body of the lambda function
;and then process the remainder of the code as needed
(define (update-lambda-body binding params body)
    (cond
        ;If argument list is empty, then just return the processed param-list
        ((empty? params) binding)
        ((symbol? params) (if (equal? params binding) binding (update binding params body)))
        ;If the bindings are not the same, then we want to update the body because there was a change
        ;that we detected (the discrepancy between new bindings created and the OG param list)
        ((not (equal? (car binding) (car params))) 
            (update-lambda-body (cdr binding) (cdr params) (update (car binding) (car params) body)))
        ;Otherwise, the heads are equal (no binding) so we can try the next elements in both lists
        ((update-lambda-body (cdr binding) (cdr params) body))
    )
)

;Helper Function helps split the remainder of the lambda function into its arguments 
;and body and processes each one of them separately |#
(define (lambda-helper x y)
    ;Receive lambda parameters and body
    ;car -> arguments, cdr -> body
    (cond 
        ((not (equal? (length-l x) (length-l y))) (generate-output x y))
        ;binding contains the list of processed arguments
        ((let ((binding (compare-lambda-arguments (car x) (car y))))
            ;Now need to process the body of the lambda expressions
            ;However, the bodies need to be updated with the new parameter list
            (list binding (expr-compare 
                ;car-> arguments, cdr->body
                (update-lambda-body binding (car x) (car (cdr x)))
                (update-lambda-body binding (car y) (car (cdr y)))
                    ))
        ))
    )
)

;Helper function to process expressions with lambda in them
(define (process-lambda x y)
    (let ((head-x (car x))
          (head-y (car y))
          (tail-x (cdr x))
          (tail-y (cdr y)))
        (cond 
            ;Check if the length of lambda function's arguments is the same
            ((not (compare-lengths (car tail-x) (car tail-y))) (generate-output x y))
            ;Ensure that they are actually lists incase the previous conditional fails
            ((not (and ((list? (car tail-x)) (list? (cat tail-y)))))
                (generate-output x y))
            ;Check if the first element in the parameter list is the same
            ((equal? head-x head-y) 
                ;Keep one of the lambdas and process the arguments of whatever is remaining
                (if (equal? head-x 'lambda)
                    (cons 'lambda (lambda-helper tail-x tail-y))
                    (cons lambda-sym (lambda-helper tail-x tail-y))))
            ;If the first elements are not the same, then just use the lambda symbol 
            ;and pass the remainder (including argument list for the lambda function)
            ;to lambda-helper
            (else (cons lambda-sym (lambda-helper tail-x tail-y)))
        )
    )
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
            ;If the head is quote, then generate an output ''
            ((equal? head 'quote) (generate-output x y))
            ;If the head is either a lambda or lambda symbol, then process is separately
            ((or (equal? head 'lambda) (equal? head lambda-sym)) (process-lambda x y))
            ;Otherwise, just pass the head elements and tail elements into expr-compare for
            ;further processing, and fuse their results into a single list
            ((cons (expr-compare head (car y)) (expr-compare (cdr x) (cdr y))))
        )
    )
)

#| Helper function for expr-compare to process lists in an
instance where both of them don't have the same first elements |#
(define (compare-head-not-equal x y)
    ;Define local variables
    (let ((head-x (car x))
          (head-y (car y)))
        (cond 
            ;See if the head of either lists are a combination of lambdas, and if yes, process them
            ((check_lambdas head-x head-y) (process-lambda x y))
            ;If either of them have a keyword at the beginning, immediately generate a % output
            ((or (check_keywords head-x) (check_keywords head-y)) (generate-output x ))
            ;Otherwise, just pass these back to our main expr-compare function, but fuse the return 
            ;values of the head and tail of either list into one list. Essentially, process them differently.
            ((cons (expr-compare head-x head-y) (expr-compare (cdr x) (cdr y))))
        )
    )
)

;Main driver function
;x -> LDA, y -> SVM
(define (expr-compare x y)
    (cond
        ;If they're equal, return any of them
        ((equal? x y) x)
        ;Check for the #t #f, and #f #t conditions
        ((inverse-check-tf x y))
        ((check-tf x y))
        ;If the lengths are not there, immedidately print % statement
        ((not (compare-lengths x y)) (generate-output x y))
        ;Check to see if they're lists 
        ((and (list? x) (list? y))
            (if 
                (equal? (car x) (car y)) ;test-expr
                (compare-head-equal x y) ;then-expr
                (compare-head-not-equal x y) ;else-expr
            ))
        ;If none of the the conditions are met, just terminate and move ahead
        (else (generate-output x y))
    )
)

;
(define (test-expr-compare x y)
    #t
)