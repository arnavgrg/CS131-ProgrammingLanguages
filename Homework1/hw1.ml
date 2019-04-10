type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal
;;

(*For every element in a, check if exists as an element in b.
At any point, if this is not true, return false*)
let rec subset a b =
  match a with
    (* Base Case *)
    | [] -> true
    (* hd :: tl splits the list *)
    (* List.mem : mem a l is true if and only if a is equal to an element of l. *)
    | hd :: tl -> if List.mem hd b then subset tl b else false
;;

(*For two sets to be equal, they must be subsets of each other
otherwise one set contains more/less elements than the other*)
let equal_sets a b = 
  subset a b && subset b a 
;;

(*For each element a, if it is in b, then add it to the list. The list is created by the filter*)
let set_intersection a b = 
  List.filter (fun x -> (List.mem x b)) a
;; 

(*For each element in a, if it is not in b, then add it to the list and return this list
Filter creates a list match this condition.*)
let set_diff a b = 
  List.filter (fun x -> not (List.mem x b)) a
;;

(*To create the union, we need to get the unique elements from each of the sets, as well as 
the common elements from each of the sets, and just merge these into one set.*)
let set_union a b =
  if equal_sets a b then a 
  else (set_intersection a b) @ (set_diff a b) @ (set_diff b a)
;;

(*If f(x) = x, return x, otherwise try and calculate f(f(x)) = x etc. recursively. 
If no fixed point is found, the program will spin into an infinite recursive loop 
and will eventually result in a stack overflow*)
let rec computed_fixed_point eq f x = 
  if eq (f x) x then x else computed_fixed_point eq f (f x)
;;

let find_reachable_nonterminals reachable_non_terminals rules = 
  
;;

(*Helper method for filter_reachable to help parse grammar rules*)
(*Basic logic: Call find_reachable_nonterminals to get a list of all the reachable non-terminals.
We pass in start_expression in a list because we want to include it as the first non-terminal that 
can be reached and so has valid grammar rules. We then want to filter out all the rules that can be 
reached and return it to filter_reachable*)
(*fst *)
let filter_reachable_rules start_expression rules =
  let reachable_nonterminals = (find_reachable_nonterminals [start_expression] rules) in 
    List.filter (fun x -> List.mem (fst x) reachable_nonterminals) rules
;;

(*G: Start Expression, List of tuples of the form non-terminal, rule *)
(*We want to return Start Expression, List of valid grammar rules *)
let filter_reachable g = 
  match g with 
    | start_expression, rules -> start_expression, (filter_reachable_rules start_expression rules)
    | _ -> g
;;