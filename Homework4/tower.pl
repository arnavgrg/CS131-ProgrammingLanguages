/* GNU Prolog finite domain solver: http://www.gprolog.org/manual/html_node/ */

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
/* Rule that takes in a number N and a List L and returns true if the
number of elements in the list equals N */
check_length(N,L) :- length(L,N).
    
/* Rule that takes in a number N and a List L and returns true if all
elements in the list fall within the range 1..N inclusive */
check_domain(N,L) :- fd_domain(L,1,N).

/*Function that verifies that the edge count = row count from that side*/
verify_row(0,_,[]).
verify_row(Counter,Maximum_value,[Head|Tail]) :- 
    Maximum_value >= Head,
    verify_row(Counter,Maximum_value,Tail).
verify_row(Counter,Maximum_value,[Head|Tail]) :-
    Maximum_value < Head,
    verify_row(New_counter,Head,Tail),
    Counter is New_counter+1.

/*Helps match the C constraints left and top with the corresponding rows/columns */
check([],[]).
/*Takes Constraint List, Matrix in this format*/
check([Head_of_constraint_list|Tail_of_constraint_list],[Head_of_matrix|Tail_of_matrix]) :-
    verify_row(Counter,0,Head_of_matrix),
    Counter #= Head_of_constraint_list,
    check(Tail_of_constraint_list,Tail_of_matrix).

/*Helps match the C constraints right and bottom with the corresponding rows/columns */
reverse_check([],[]).
/*Takes Constraint List, Matrix in this format*/
reverse_check([Head_of_constraint_list|Tail_of_constraint_list],[Head_of_matrix|Tail_of_matrix]) :-
    reverse(Head_of_matrix,Reversed_head_of_matrix),
    verify_row(Counter,0,Reversed_head_of_matrix),
    Counter #= Head_of_constraint_list,
    reverse_check(Tail_of_constraint_list,Tail_of_matrix).
% -----

% -----
% Rule definition for tower
tower( N, T, counts(Top,Bottom,Left,Right)) :-
    % Ensure N is nonnegative
    N >= 0,
    % Ensure size of list of lists T == N.
    check_length(N,T),
    % Ensure each of the rows Top Bottom Left and Right have N elements
    maplist(check_length(N),[Top,Bottom,Left,Right]),
    maplist(check_length(N), T),
    % Next we want to ensure all of them are within the range 1..N
    maplist(check_domain(N), T),
    % Check if all elements in each row of T are unique
    maplist(fd_all_different, T),
    % Transpose the matrix
    % Take the transponse and use the fd_all_different predicate to ensure columns also have unique values
    transpose(T, T_transpose),
    maplist(fd_all_different, T_transpose),
    /*In order to have GNU Prolog report specific instances that satisfy the criteria, we need to use 
    'fd_labeling(list of variables)' predicate as follows*/
    /*Creates a list of lists T where each list has the constraints, that is, numbers between 1..N*/
    maplist(fd_labeling, T),
    % Need to check if the edge/tower heights condition in counts matches each of columns
    check(Top, T_transpose),
    reverse_check(Bottom, T_transpose),
    % Need to check if the edge/tower heights condition in counts matches each of rows
    check(Left, T),
    reverse_check(Right, T),
    /* Finally, generate Top, Bottom, Left and Right using the constraints defined incase they haven't
    already been defined */
    maplist(fd_labeling,[Top,Bottom,Left,Right]).
% -----

% -----
% Rule definition for plain tower
plain_tower(N, T, counts(Top,Bottom,Left,Right)) :-
    N >= 0,
    check_length(N,T),
    maplist(check_length(N),[Top,Bottom,Left,Right]),
    maplist(check_length(N), T),
    transpose(T, T_transpose).
% -----

% -----
% Rule definition for ambiguous
ambiguous(N, C, T1, T2) :-
    check_nonnegative(N),
    tower(N,T1,C),
    tower(N,T2,C),
    T1 \== T2.
% -----

% -----
% Performance based on CPU Time
% http://gprolog.univ-paris1.fr/manual/html_node/gprolog048.html#statistics%2F2

%Function to run a test case and determine CPU time for the tower rule
tower_test(Total_time) :-
    statistics(cpu_time,[Start|_]),
    tower(5,_,counts([2,2,3,5,1],[2,3,2,1,4],[3,1,2,3,2],[1,4,2,3,2])),
    statistics(cpu_time, [Stop|_]),
    Total_time is Stop - Start.
    
%Function to run a test case and determine CPU time for the plain tower rule
plain_tower_test(Total_time) :-
    statistics(cpu_time, [Start|_]),
    plain_tower(5,_,counts([2,2,3,5,1],[2,3,2,1,4],[3,1,2,3,2],[1,4,2,3,2])),
    statistics(cpu_time, [Stop|_]),
    Total_time is Stop - Start. 

%Function that actually computes the required ratio
speedup(Ratio_of_cpu_time) :-
    % TT and PTT get bound to the respective CPU times returned.
    tower_test(TT),
    plain_tower_test(PTT),
    % Unifies the above arguments to the floating-point ratio
    Ratio_of_cpu_time is PTT/TT.   
% -----