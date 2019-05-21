
// Volume 2 – Section 1 – Video 2: The importance of protocol semantics


// A protocol without semantics.
protocol Plusable {
    static func +(lhs: Self, rhs: Self) -> Self
}

extension Int : Plusable {}
extension Array : Plusable {}

extension Sequence where Iterator.Element : Plusable {
    
    func plusAllTheThings() -> Iterator.Element? {
        
        var iterator = makeIterator()
        
        guard var first = iterator.next() else {
            return nil
        }
        
        while let next = iterator.next() {
            first = first + next
        }
        
        return first
    }
}

let numbers = [1, 2, 3, 4, 5]

let sum = numbers.plusAllTheThings()
print(sum as Any) // Optional(15)

let nestedArray = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

let flattened = nestedArray.plusAllTheThings()
print(flattened as Any) // Optional([1, 2, 3, 4, 5, 6, 7, 8, 9])

// Different semantics!


// use the Numeric protocol as a constraint in Swift 4, which also includes floating point numbers
extension Sequence where Iterator.Element : Integer {
    
    func sum() -> Iterator.Element {
        return reduce(0, +)
    }
}

print(numbers.sum()) // 15

extension Sequence where Iterator.Element : RangeReplaceableCollection {
    func eagerlyJoined() -> Iterator.Element {
        
        var result = Iterator.Element()
        
        for element in self {
            result += element
        }
        
        return result
    }
}

print(nestedArray.eagerlyJoined()) // [1, 2, 3, 4, 5, 6, 7, 8, 9]


print([2, 0, 3].sorted()) // [0, 2, 3]

// not conforming to the semantic requirements of sorted(by:) (and Comparable)
// therefore the resulting array is in an unspecified order.
print([2, 3, 0].sorted(by: {lhs, rhs in lhs == 0 || lhs > rhs})) // [0, 3, 2]
print([2, 0, 3].sorted(by: {lhs, rhs in lhs == 0 || lhs > rhs})) // [3, 0, 2]


// what if this conformed to CustomStringConvertible implicitly?
struct Achievement {
    var title: String
    var description: String
}

let a = Achievement(title: "Flying High", description: "Earn 600 points")

print(a) // Achievement(title: "Flying High", description: "Earn 600 points")



