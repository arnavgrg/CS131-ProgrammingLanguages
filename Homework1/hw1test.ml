(*subset test cases*)
let subset_test0 = subset [] []
let subset_test1 = subset [] [1;2;3]
let subset_test2 = subset [3;1;3;3;1] [1;3]
let subset_test3 = not (subset [4;1;3] [1;3;7;5;6])

(*equal sets*)
let my_equal_sets_test0 = equal_sets [] []
let my_equal_sets_test1 = equal_sets [1;2;3;4;5] [5;4;3;2;1]
let my_equal_sets_test2 = not (equal_sets [1;2;3] [2;3;4])

(*set union*)
let my_set_union_test0 = equal_sets (set_union [1;2] [3]) [1;2;3]
let my_set_union_test1 = equal_sets (set_union ["abc"; "def"] ["def"; "ghi"]) ["abc"; "def"; "ghi"]
let my_set_union_test2 = equal_sets (set_union [1;1] [1;1;1;1]) [1]

(*set intersection*)
let my_set_intersection_test0 = equal_sets [] (set_intersection [1;3;5] [2;4])
let my_set_intersection_test1 = equal_sets (set_intersection [1;3;5;8] [5;9;8;9]) [5;8]
let my_set_intersection_test2 = equal_sets (set_intersection [1;1;1] [1]) [1]

(*set difference*)
let my_set_diff_test0 = equal_sets (set_diff [9;8;7;6;5;4;3;2;1] [9;7;5;3;1]) [8;6;4;2]
let my_set_diff_test1 = equal_sets (set_diff [1;1;1;1;1] [1;2;3;4;5]) []

(*computed fixed point*)
let computed_fixed_point_test0 = computed_fixed_point (=) (fun x -> x / 4) 1000000000 = 0
let computed_fixed_point_test0 = computed_fixed_point (=) (fun x -> x / 4) 98 = 0

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

let awksub_test0 = 
  filter_reachable awksub_grammar = awksub_grammar