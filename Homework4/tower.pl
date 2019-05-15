% -----
% Function to create the transpose of a matrix
% https://stackoverflow.com/questions/4280986/how-to-transpose-a-matrix-in-prolog
transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
        lists_firsts_rests(Ms, Ts, Ms1),
        transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
        lists_firsts_rests(Rest, Fs, Oss).
% -----

% -----
% Helper methods
% Rule definition to check if N is nonnegative
% http://www.cse.unsw.edu.au/~billw/dictionaries/prolog/comparison.html
check_nonnegative(N) :-
    N >= 0.

check_domain_range()
% -----

% -----
/* GNU Prolog finite domain solver
http://www.gprolog.org/manual/html_node/ */

% Rule definition for tower
tower(N, T, counts(Top,Bottom,Left,Right)) :-
    % Ensure N is nonnegative
    check_nonnegative(N),
    /* http://www.swi-prolog.org/pldoc/man?predicate=length/2
    The predicate is non-deterministic, producing lists of increasing 
    length if List is a partial list and Int is unbound. */
    % Ensure size of list of lists T == N.
    length(T,N),
    % Ensure each of the rows Top Bottom Left and Right have N elements
    maplist(length(T,N),
    % https://stackoverflow.com/questions/6682987/prolog-map-procedure-that-applies-predicate-to-list-elements
    % Check if all elements in each row of T are unique
    maplist(fd_all_different, T),
    % Next we want to ensure all of them are within the range 1..N
    % fd_domain(Vars, Lower, Upper) constraints each element X of Vars to take a value in Lower..Upper.
    maplist(fd_domain(N,1,)).
% -----

% -----
% Rule definition for plain tower
plain_tower(N, T, counts(Top,Bottom,Left,Right)) :-
    check_nonnegative(N),
    1=1.
% -----

% -----
% Performance based on CPU Time
% http://gprolog.univ-paris1.fr/manual/html_node/gprolog048.html#statistics%2F2
% https://stackoverflow.com/questions/34970061/display-the-execution-times-for-each-goal-of-a-predicate-clause

%Function to run a test case and determine CPU time for the tower rule
tower_test(Total_time) :-
    statistics(cpu_time, [Start|_]),
    tower(5,_,counts([2,2,3,5,1],[2,3,2,1,4],[3,1,2,3,2],[1,4,2,3,2])),
    statistics(cpu_time, [Stop|_]),
    Total-time is Stop - Start. 
    
%Function to run a test case and determine CPU time for the plain tower rule
plain_tower_test(Total_time) :-
    statistics(cpu_time, [Start|_]),
    plain_tower(5,_,counts([2,2,3,5,1],[2,3,2,1,4],[3,1,2,3,2],[1,4,2,3,2])),
    statistics(cpu_time, [Stop|_]),
    Total-time is Stop - Start. 

%Function that actually computes the required ratio
speedup(ratio_of_cpu_time) :-
    % TT and PTT get bound to the respective CPU times returned.
    tower_test(TT),
    plain_tower_test(PTT),
    % Unifies the above arguments to the floating-point ratio
    ratio_of_cpu_time is PTT/TT.   
% -----

% -----
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
% -----
