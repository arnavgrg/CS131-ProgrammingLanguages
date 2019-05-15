/* GNU Prolog finite domain solver
http://www.gprolog.org/manual/html_node/ */

% Rule definition to check if N is nonnegative
% http://www.cse.unsw.edu.au/~billw/dictionaries/prolog/comparison.html
check_nonnegative(N) :-
    N >= 0.

check_domain_range()

% Rule definition for tower
tower(N, T, counts(Top,Bottom,Left,Right)) :-
    % Ensure N is nonnegative
    check_nonnegative(N),
    /* http://www.swi-prolog.org/pldoc/man?predicate=length/2
    The predicate is non-deterministic, producing lists of increasing 
    length if List is a partial list and Int is unbound. */
    % Ensure size of list of lists T == N.
    length(T,N),
    % https://stackoverflow.com/questions/6682987/prolog-map-procedure-that-applies-predicate-to-list-elements
    % Check if all elements in each row of T are unique
    maplist(fd_all_different, T),
    % Next we want to ensure all of them are within the range 1..N
    % fd_domain(Vars, Lower, Upper) constraints each element X of Vars to take a value in Lower..Upper.
    maplist(fd_domain(N,1,)).

% Rule definition for plain tower
plain_tower(N, T, counts(Top,Bottom,Left,Right)) :-
    check_nonnegative(N),
    1=1.

% Rule definition for ambiguous
ambiguous(N, C, T1, T2) :-
    check_nonnegative(N),
    % T1 and T2 get bound to different solutions 
    /* This will always fail the first time as T1 and T2 will be the 
    same. From here, it will backtrack and find another solution for 
    T2 if there is a second solution to begin with. */
    tower(N,T1,C),
    tower(N,T2,C),
    T1 \== T2.