(*subset test cases*)
let subset_test0 = subset [] []
let subset_test1 = subset [] [1;2;3]
let subset_test2 = subset [3;1;3;3;1] [1;3]
let subset_test3 = not (subset [4;1;3] [1;3;7;5;6])

(*equal sets*)
let my_equal_sets_test0 = [] []
let my_equal_sets test1 = [1;2;3;4;5] [5;4;3;2;1]
let my_equal_sets_test2 = not (equal_sets [1;2;3] [2;3;4])

(*set union*)
let my_set_union_test0 = equal_sets (set_union [1;2] [3]) [1;2;3]
let my_set_union_test1 = equal_sets (set_union ["abc"; "def"] ["def"; "ghi"]) ["abc"; "def"; "ghi"]
let my_set_union_test2 = equal_sets (set_union [1;1] [1;1;1;1]) [1]

(*set intersection*)
let my_set_intersection_test0 = equal_set [] (set_intersection [1;3;5] [2;4])
let my_set_intersection_test1 = equal_sets (set_intersection [1;3;5;8] [5;9;8;9]) [5;8]
let my_set_intersection_test2 = equal_sets (set_intersection [1;1;1] [1]) [1]

(*set difference*)
let my_set_diff_test0 = equal_sets (set_diff [9;8;7;6;5;4;3;2;1] [9;7;5;3;1]) [8;6;4;2]
let my_set_diff_test1 = equal_sets (set_diff [1;1;1;1;1] [1;2;3;4;5]) []

(*computed fixed point*)


(*filter reachable*)
