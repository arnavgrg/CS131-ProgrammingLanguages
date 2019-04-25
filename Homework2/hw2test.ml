let accept_all string = Some string

let accept_empty_suffix = function
   | _::_ -> None
   | x -> Some x

let convert x = Some x;;

type typesOfDays = 
  | Saturday | Sunday | Monday | Days | Tuesday
;;

let daysFragment = ["random string that should not match"; "notTuesday"; "notTuesday"];;

let daysGrammar =
  (Days,
   function
     | Days ->
         [[N Tuesday; N Monday];
          [N Tuesday; N Tuesday; N Monday];
          [N Sunday];
          [N Saturday];
          [N Tuesday; N Tuesday]]
     | Tuesday -> [[T "notTuesday"]]
     | Monday -> [[T "Tuesday"]]
     | Sunday -> [[T "random string that should not match"]]
     | Saturday -> [[N Monday; N Sunday];
	              [T "notTuesday"; N Tuesday; N Sunday; T "Tuesday"];
      [N Sunday]])
;;

let make_matcher_test = ((make_matcher daysGrammar convert daysFragment) = Some ["notTuesday"; "notTuesday"]);;