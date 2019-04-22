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
let rec get_rules nonterminal rules =
	match rules with
	| [] -> []
	| (nonterm, rule)::remaining_rules -> 
    if nonterm == nonterminal 
      then rule::(get_rules nonterminal remaining_rules)
		else get_rules nonterminal remaining_rules
;;

(*Convert grammar from HW1-style to HW2-style*)
let convert_grammar gram1 = 
  (*fst gram1 -> starting symbol*)
  (*function that get a list of all rules for a given non-terminal*)
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

let make_matcher gram =
  match gram with 
  | (start_nonterminal, rule_list) -> 
  | _ -> gram
;;

(*let make_parser gram = 
  
;;*)