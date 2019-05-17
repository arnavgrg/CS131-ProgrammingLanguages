% -----
% Helper methods
/* Rule that takes in a number N and a List L and returns true if the
number of elements in the list equals N */
check_length(N,L) :- length(L,N).
    
/* Rule that takes in a number N and a List L and returns true if all
elements in the list fall within the range 1..N inclusive */
check_domain(N,L) :- fd_domain(L,1,N).

% Function to create the transpose of a matrix
%http://blog.ivank.net/prolog-matrices.html
% trans(+M1, -M2) - transpose of square matrix
transpose([[H|T] |Tail], [[H|NT] |NTail]) :- 
	firstCol(Tail, NT, Rest), 
    transpose(Rest, NRest), 
    firstCol(NTail, T, NRest).
transpose([], []).
% firstCol(+Matrix, -Column, -Rest)  or  (-Matrix, +Column, +Rest)
firstCol([[H|T] |Tail], [H|Col], [T|Rows]) :- 
    firstCol(Tail, Col, Rows).
firstCol([], [], []).

/*Function that verifies that the edge count = row count from that side*/
/*Base case: Set counter to 0*/
verify_row(0,_,[]).
/*Rule that compares the maximum value yet to the current head of the row.
If it is greater, then we just continue because this element is not visible*/
verify_row(Counter,Maximum_value,[Head|Tail]) :- 
    Maximum_value >= Head,
    verify_row(Counter,Maximum_value,Tail).
/*Rule that compares the maximum value yet to the current head of the row.
If it is less than the current head, then we want to update current maximum to 
this value and increment counter by 1 because this is a new tower we can see.*/
verify_row(Counter,Maximum_value,[Head|Tail]) :-
    Maximum_value < Head,
    verify_row(New_counter,Head,Tail),
    Counter is New_counter+1.

/*Helps match the C constraints left and top with the corresponding rows/columns */
check_row([],[]).
/*Takes Constraint List, Matrix in this format*/
check_row([Head_of_constraint_list|Tail_of_constraint_list],[Head_of_matrix|Tail_of_matrix]) :-
    /* Call helper function*/
    verify_row(Counter,0,Head_of_matrix),
    % Ensures that the verification and constraint value are the same for this row
    Counter #= Head_of_constraint_list,
    check_row(Tail_of_constraint_list,Tail_of_matrix).

/*Helps match the C constraints right and bottom with the corresponding rows/columns */
reverse_check_row([],[]).
/*Takes Constraint List, Matrix in this format*/
reverse_check_row([Head_of_constraint_list|Tail_of_constraint_list],[Head_of_matrix|Tail_of_matrix]) :-
    % Reverses the row so that it's easier to call verify_row instead of having to rewrite logic
    reverse(Head_of_matrix,Reversed_head_of_matrix),
    verify_row(Counter,0,Reversed_head_of_matrix),
    % Ensures that the verification and constraint value are the same for this row
    Counter #= Head_of_constraint_list,
    reverse_check_row(Tail_of_constraint_list,Tail_of_matrix).
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
    check_row(Top, T_transpose),
    reverse_check_row(Bottom, T_transpose),
    % Need to check if the edge/tower heights condition in counts matches each of rows
    check_row(Left, T),
    reverse_check_row(Right, T),
    /* Finally, generate Top, Bottom, Left and Right using the constraints defined incase they haven't
    already been defined */
    maplist(fd_labeling,[Top,Bottom,Left,Right]).
% -----

% -----
/* A substitute for fd_domain. Since it generates unique/distinct numbers
it also accounts for fd_all_different */
p_domain(N,L) :-
    findall(Num, between(1, N, Num), L).

/* Generator function that generates all permutations. Generates it 
one row and one column at a time, thereby cutting down the possible 
number of combinations rapidly and reducing the search space. */
p_labeling(_,[],[]).
p_labeling(Domain,[T_Head|T_Tail],[Transpose_Head|Transpose_Tail]) :-
    permutation(Domain,T_Head),
    permutation(Domain,Transpose_Head),
    p_labeling(Domain,T_Tail,Transpose_Tail).

% Rule definition for plain tower
plain_tower(N, T, counts(Top,Bottom,Left,Right)) :-
    N >= 0,
    check_length(N,T),
    maplist(check_length(N), T),
    maplist(check_length(N),[Top,Bottom,Left,Right]),
    p_domain(N, T_Domain),
    transpose(T, T_transpose),
    p_labeling(T_Domain,T,T_transpose),
    check_row(Top, T_transpose),
    reverse_check_row(Bottom, T_transpose),
    check_row(Left, T),
    reverse_check_row(Right, T).
% -----

% -----
% Rule definition for ambiguous
ambiguous( N, C, T1, T2) :-
    N >= 0,
    tower(N,T1,C),
    tower(N,T2,C),
    T1 \== T2.
% -----

% -----
% Performance based on CPU Time
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