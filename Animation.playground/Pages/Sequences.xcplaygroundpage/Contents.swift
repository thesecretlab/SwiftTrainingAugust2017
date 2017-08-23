//: [Previous](@previous)

import Foundation

// Here's a string
var str = "Hello, playground 😻"

// Strings are sequences; we can iterate
// over each character
for character in str {
    print(character)
}

// Ranges are sequences, too
let oneToFive = 1...5

// When we zip two sequences together,
// we get a new sequence that's as long
// as the shortest of the two
let firstFiveCharacters = zip(str, oneToFive)

print("First five characters:")
for entry in firstFiveCharacters {
    // 'entry' is a tuple; we access
    // its members via .0 and .1
    print("\(entry.0): \(entry.1)")
}

// This can be useful when we're dealing with
// a half-open range
let numbersFromOne = 1...

let numberedCharacters = zip(str, numbersFromOne)

// When iterating over this sequence we can
// unpack the tuple into separate variables,
// which means they get names
print("All characters:")
for (num, char) in numberedCharacters {
    print("\(num): \(char)")
}

// We can convert the sequence into an array,
// too, if we don't want to iterate over it
// immediately, or want to get a specific
// item from it (note that this immediately
// evaluates all items in the sequence! may
// not be what you want when the sequence is
// large!)
Array(numberedCharacters)

//: [Next](@next)
