//: [Previous](@previous)

import Foundation

// Enumerations let you create a list of
// possible cases
enum Furniture {
    case chair, table, sink, bed
}

let myFurniture = Furniture.chair

// You can use a switch statement to run
// different code based on the specific case
switch myFurniture {
case .chair:
    print("Sitting in a chair!")
case .table:
    print("Putting my laptop on a table!")
case .sink:
    print("Washing my hands in the sink!")
case .bed:
    print("Having a nap on the bed!")
}

//: [Next](@next)
