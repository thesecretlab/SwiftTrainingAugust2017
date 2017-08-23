
// We can create functions in swift to do work. However, Swift lets us program in a
// _functional_ way.

func add(number: Int, to otherNumber: Int) -> Int {
    return number + otherNumber
}

// ----

// we can store a function in a variable
var addFunction = add

// we can call this variable as a function
print(addFunction(1,2))

// ----

// we can receive a function as a parameter
func applyOperation(firstNumber: Int, secondNumber: Int, operation: (Int,Int) -> Int) -> Int {
    return operation(firstNumber, secondNumber)
}

var operationResult : Int

operationResult = applyOperation(firstNumber: 1,
                                 secondNumber: 2,
                                 operation: { (num1, num2) in return num1 + num2 })
print(operationResult)

// ----

// any function will work - even the function we defined earlier
operationResult = applyOperation(firstNumber: 1, secondNumber: 2, operation: add)
print(operationResult)

// ----

// did you know that + will also fit the bill? after all, when you use it with integers,
// it's basically a function that takes two Ints and returns an Int
operationResult = applyOperation(firstNumber: 1, secondNumber: 2, operation: +)
print(operationResult)

// ----

let data = [1,2,3,4]

let doubled = data.map { $0 * 2 }
print(doubled)

// reduce starts with an initial value
let sum = data.reduce(0) { $0 + $1 }
print(sum)

// filtered only includes stuff that passes a test
let filtered = data.filter { $0 > 2 }
print(filtered)

// map doesn't have to return the same type as the input
let squares = data.map { [$0, $0 * $0] }
print(squares)

// and neither does reduce
let digits = data.reduce("") { $0 + String($1) }
print(digits)

// flatMap flattens the result by one level
let flatSquares = data.flatMap { [$0, $0 * $0] }
print(flatSquares)

// ----

// We can give a certain function type a label
// In this case, a 'NumberChanger' is any function that takes an integer and returns an integer
typealias NumberChanger = (Int) -> Int

// Functions can return OTHER functions
func makeAdder(number : Int) -> NumberChanger {
    let adder = { $0 + number }
    return adder
}

let plusTen = makeAdder(number: 10)

print(plusTen(2))

// ----

// Functions can also capture variables

typealias Counter = (Void) -> Int

func makeCounter() -> Counter {
    var count = 0
    let counter : Counter = {
        count += 1
        return count
    }
    
    return counter
}

// ----

// The counter will now return a new value every time it's called
let counter = makeCounter()
print(counter())
print(counter())
print(counter())

// The counters are independent
let secondCounter = makeCounter()
print(secondCounter())
print(secondCounter())
print(counter())

// ----

// Let's take our 'number changer' example. Say we want to apply the changer twice:
func change(number: Int, twiceUsing closure: NumberChanger) -> Int {
    let firstResult = closure(number)
    let secondResult = closure(firstResult)
    return secondResult
}

// This works, but wouldn't it be nice to take two functions and combine them into a single one?

// Here's how we do that
func combine(numberChanger firstChanger: @escaping NumberChanger, with secondChanger: @escaping NumberChanger) -> NumberChanger {
    let combinedChanger : NumberChanger = {
        return secondChanger(firstChanger($0))
    }
    return combinedChanger
}

// The '@escaping' keyword there indicates to the compiler that closure parameters
// may 'escape' the function that uses them - that is, they may get saved somewhere and called by something else.

let addOneAndMultiplyByTwo = combine(numberChanger: { $0 + 1 }, with: { $0 * 2})
print(addOneAndMultiplyByTwo(5))

// ----

// OKAY SO 

// we have a tool for combining functions that work with integers

// but what about other types?

// this is where generics come into it

// generics let you work with data types in a more abstract (or 'generic') way

func combine<T>(changer firstChanger: @escaping (T) -> T, with secondChanger: @escaping (T) -> T) -> (T) -> T {
    
    return {
        (x : T) -> T in
        return secondChanger(firstChanger(x))
    }
}

// Now we can create a combined function
var uppercaseAndReverse : (String)->String = combine(changer: { $0.uppercased() }, with: {String($0.characters.reversed())})

print(uppercaseAndReverse("hello there"))


// ----

// finally, we can ALSO create a combine function that works with MULTIPLE types
func combine<T, U, V>(changer firstChanger: @escaping (T) -> U, with secondChanger: @escaping (U) -> V) -> (T) -> V {
    
    return {
        (x : T) -> V in
        return secondChanger(firstChanger(x))
    }
}

// ----

// Here's a function that converts an integer into an array of its digits
var numberToDigits = { (num : Int) -> [Int] in
    var localNum = num // make a copy that we can modify in this function
    var result : [Int] = []
    
    while (localNum > 0) {
        result.append(localNum % 10)
        localNum /= 10
    }
    
    return result.reversed()
}

// And here's one that converts an array of digits to a string containing words
var digitsToWords = { (digits : [Int]) -> String in
    
    // The lookup table that maps digits to words
    let wordDictionary = [
        0: "zero",
        1: "one",
        2: "two",
        3: "three",
        4: "four",
        5: "five",
        6: "six",
        7: "seven",
        8: "eight",
        9: "nine"
    ]
    
    // Convert each digit to a word, and join the result up with spaces
    return digits
        .map { wordDictionary[$0] ?? "" }
        .joined(separator: " ")
    
}

// We can now create a function that converts a number to words
let numberToWords = combine(changer: numberToDigits, with: digitsToWords)

print(numberToWords(61368))

// ----

// Custom operators!

// The 'combine' function is ok, but it's similar to writing code like this:
// add(1, 2) 
// Instead of this:
// 1 + 2

// What if we had a way to write this:

// numberToDigits • digitsToWords

// We can do this by declaring a new operator

infix operator •

// Then we define what this operator means - here, we're actually just reusing the same
// code we did for 'combine'
func •<T,U,V>(lhs: @escaping (T) -> U, rhs: @escaping (U) -> V) -> (T) -> V {
    return {
        (x : T) -> V in
        return rhs(lhs(x))
    }
}

// We can now use • to combine functions!
print((numberToDigits • digitsToWords)(123))

