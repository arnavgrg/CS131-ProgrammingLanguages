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

(* Helper method for non_terminals *)
(* Recursively retrieves all nonterminals from the rules for a given non-terminal *)
let rec filter_all_nonterminals rule_list =
  match rule_list with
    | [] -> []
    (*if it is a nonterminal, add it to the list and move to the rest of the list*)
    | N head :: rules_left_in_list -> head::(filter_all_nonterminals rules_left_in_list)
    | _ :: rules_left_in_list -> filter_all_nonterminals rules_left_in_list
;;

(* Helper method for filter_reachable *)
let rec create_nonterminal_set non_terminals rules = 
  match rules with
	| [] -> non_terminals
  | rule_tuple :: remaining_tuples_list -> 
  (* Check if the non-terminal in the tuple is one of the nonterminals in the list being passed in *)
  if (List.mem (fst rule_tuple) non_terminals)
   (* If yes, call this function recursively, but on the union of the old non terminal 
   list with all the new non terminals from this rule *)
		then create_nonterminal_set (set_union non_terminals (filter_all_nonterminals (snd rule_tuple))) remaining_tuples_list
  (* Otherwise, call it recursively using the current non terminals list and the remaining
     list of tuples *)
  else create_nonterminal_set non_terminals remaining_tuples_list
;;

(*Helper method for filter_reachable*)
(*Essentially checks for the terminating breadth first search condition, that is,
when two recursive calls have the same return value, then we're done traversing 
and have found all of the valid non terminals*)
let rec find_reachable_nonterminals reachable_non_terminals rules = 
  (* First call returns the list of reachable nonterminals so far *)
  let recursive_call_1 = create_nonterminal_set reachable_non_terminals rules in
  (* Second call uses the list returned for further processing *)
  let recursive_call_2 = create_nonterminal_set recursive_call_1 rules in
    (* Check if *)
    if equal_sets recursive_call_1 recursive_call_2 
      then recursive_call_2
    else find_reachable_nonterminals recursive_call_2 rules
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
let filter_reachable g = ( (fst g) , ( filter_reachable_rules (fst g) (snd g) ) );;