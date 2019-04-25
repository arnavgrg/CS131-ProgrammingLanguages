(*Type declarations can be parameterized by type variables. A type variable name always begins 
with an apostrophe (the ' character). When there are several of them, the type parameters are 
declared as a tuple in front of the name of the type
  type ('a1 ...'an) name = typedef;;*)

(*Type definitions needed to process HW1 grammar*)
type ('nonterminal, 'terminal) symbol =
	| N of 'nonterminal
  | T of 'terminal
;;

(*Type definitions needed to process HW2 grammar and generate the 
required parse tree that consists of Nodes and Leaves.*)
type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal
;;

(*Helper method to get all the rules for a non terminal and place them into a list*)
(*This function essentially generates an alternative list for a given non-terminal in a grammar*)
let rec get_rules nonterminal rules =
	match rules with
	| [] -> []
  | (nonterm, rule)::remaining_rules -> 
  (*If the nonterminal in the tuple matches the one we're trying to get the rules
  for, then append the rule to the list of rules being created recursively for
  this non-terminal while preserving order*)
    if nonterm == nonterminal 
      then rule::(get_rules nonterminal remaining_rules)
	else get_rules nonterminal remaining_rules
;;

(*Convert grammar from HW1-style to HW2-style*)
let convert_grammar gram1 = 
  (*fst gram1 -> starting symbol*)
  (*function that generates a list of all rules for a given non-terminal in order*)
  let start_symbol = (fst gram1) in 
  let rules_ = (snd gram1) in
  let production_function = (function nonterminal -> get_rules nonterminal rules_) in
  start_symbol, production_function
;;

(*Function to generate a parse*)
let rec parse_tree_leaves tree = 
  match tree with 
    (*If if it is a leaf node, then just place it in a list and end recursion here*)
    | Leaf leaf_terminal -> [leaf_terminal]
    (*Nodes have non_terminal and the remainder of the list that still needs to be processed*)
    | Node (non_terminal, rem) -> process_list rem
  (*Use 'and' as a substitute for 'let rec' incase we're defining mutually recursive functions*)
  and process_list = function 
    (* Three possible cases (in order of the way they're defined) *)
    (*1. While further processing the list, we've eventually hit a final leaf node so we just put 
      it in its own list and continue to processs the remainder of the list*)
    | (Leaf leaf_terminal)::remainder -> List.concat [[leaf_terminal]; process_list remainder]
    (*2. While further processing the list, we found another non-terminal, so we want to mutually
        recurse with the parse_tree_leaves so we can process the non-terminal, but then also continue
        with the original terminal's list.*)
    | new_nonterminal::remainder -> List.concat [(parse_tree_leaves new_nonterminal); (process_list remainder)]
    (*3. Empty list, in which case we're done processing the node, so we just return an empty list*)
    | [] -> []
;;

(*Helper method for make_matcher that actually does all the work. *)
let rec actual_make_matcher rule_func rules accept frag = 
  match rules with
  (*Base Case*)
  | [] -> None 
  (*Pattern matching to split list of rules for the non-terminal*)
  | head_rule::remaining_rules -> 
    (**)
    let match_head_rule = (symbol_matcher rule_func head_rule)
    and match_tail_rule = (actual_make_matcher rule_func remaining_rules) in
    (*Either returns some or none*)
    let other_match = match_head_rule accept frag in 
      match other_match with 
      | None -> match_tail_rule accept frag
      | _ -> other_match
    (*Matches the symbols in a rule for a non-terminal*)
    and symbol_matcher rule_func rules accept frag =
      match rules with 
      | (T x)::remainder -> 
          if (List.length frag = 0) then None else 
            (if (List.hd(frag) = x) 
                then (symbol_matcher rule_func remainder accept (List.tl(frag))) else None)
      (* *)
      | (N y)::remainder -> 
          actual_make_matcher rule_func (rule_func y) (symbol_matcher rule_func remainder accept) frag
      (*If the list is empty, just pass frag to the acceptor function*)
      | [] -> accept frag
;;

(*Function that returns a matcher for the grammar 'gram' passed into the function*)
let make_matcher gram =
  match gram with
  (*fun defines a function with any number of arguments that can each be given by one pattern. 
  On the other hand, function defines a function with one argument that can be given by any number of patterns.*)
  (*Pass the rule function, the rules for the starting non-terminal, the acceptor function and the fragments to 
  a helper method that will do all the work.*)
  | (start_nonterminal, altlist_func) -> 
      (fun acceptor_accept fragment_frag -> 
        actual_make_matcher altlist_func (altlist_func start_nonterminal) acceptor_accept fragment_frag)
;;