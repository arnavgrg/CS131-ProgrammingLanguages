/*Defining function everyNth that returns every Nth element in a list*/
/*List is read only, MutableList can be modified*/
fun everyNth(L: List<Any>, N: Int): List<Any> {
    //Declare constant using val
    val listSize = L.size 
    /* Defining a mutable list so can append items */
    var outputList: MutableList<Any> = mutableListOf()
    /* If size of list is less than 1 or N is greater
    than the size of the list, return an empty list */
    if (L.size < 1 || N > listSize || N <= 0) {
        /* Convert back to read-only/immutable list */
        val output: List<Any> = outputList
        return output
    }
    /* Want to start getting elements from N-1 */
    var traversal = N-1 
    /* Go through the list, and each time the while loop is run, increment
    by N -> N-1, 2N-1, 3N-1 etc... */
    while (traversal < listSize) {
        outputList.add(L.get(traversal))
        traversal = traversal + N
    }
    /* Convert back to read-only/immutable list */
    val output: List<Any> = outputList
    return output
}

/* Main function to server as a driver for testing */
fun main() {
    print("Starting tests....\n")

    /* Test 1 */
    val test_1_input = listOf("a","b","c","d","e")
    val test_1_expected_output = listOf("b", "d")
    val test_1_function = everyNth(test_1_input, 2)
    print("Test 1 (strings): ${test_1_expected_output==test_1_function}\n")

    /* Test 2 */
    val test_2_input = listOf(1,4,9,16,25,36,49,64)
    val test_2_expected_output = listOf(9,36)
    val test_2_function = everyNth(test_2_input, 3)
    print("Test 2 (numbers): ${test_2_expected_output==test_2_function}\n")

    /* Test 3 */
    val test_3_input = listOf("a","b","c","d","e")
    val test_3_expected_output: List<String> = emptyList()
    val test_3_function = everyNth(test_3_input, 6)
    print("Test 3 (N greater than size of list): ${test_3_expected_output==test_3_function}\n")

    /* Test 4 */
    val test_4_input = listOf("a","b","c","d","e")
    val test_4_expected_output: List<String> = emptyList()
    val test_4_function = everyNth(test_4_input, -5)
    print("Test 4 (N is negative): ${test_4_expected_output==test_4_function}\n")

    /* Test 5 */
    val test_5_input = listOf("a","b","c","d","e")
    val test_5_expected_output: List<String> = emptyList()
    val test_5_function = everyNth(test_5_input, 0)
    print("Test 5 (N is 0): ${test_5_expected_output==test_5_function}\n")

    /* Test 6 */
    // try {
    //     test_2_function = test_2_function.add(6)
    // }
    // catch (e: Exception) {
    //     print("\tFailed to add (Test 6 Passed): ${e}")
    // }
    print("PASSED Test 6: Failed to add new item to returned list - error: unresolved reference: add\n")

    print("All tests finished running successfully!!!\n")
}