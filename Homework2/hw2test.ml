(*filter reachable*)
type awksub_nonterminals =
  | T1 | T2 | T3 | T4 

let awksub_rules = 
  [T1, [N T2; T"AAB"];
    T1, [T"AAB"];
    T1, [N T3; T"AAB"; N T4];
    T2, [N T3; N T2; T"CCD"];
    T3, [T"EEF"];
    T4, [T"++"]]

let awksub_grammar = T1, awksub_rules

let new_grammar = convert_grammar awksub_grammar