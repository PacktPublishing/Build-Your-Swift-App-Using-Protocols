
// Volume 2 – Section 3 – Video 4: Avoiding Expensive Casts

import Foundation

extension Array {
    
    /// Gets the total number of elements in a given homogenous array of arrays.
    func inefficientFlatCount() -> Int {
        
        var iterator = makeIterator()
        
        if let first = iterator.next() as? [Any] {
            return iterator.reduce(first.inefficientFlatCount()) { $0 + ($1 as! [Any]).inefficientFlatCount() }
        } else {
            return count
        }
    }
}


let a = [[[1, 2, 3]], [[4, 5, 6], [7, 8, 9]]]

print(a.inefficientFlatCount()) // 9


protocol ArrayProtocol {
    func flatCount() -> Int
}

extension Array : ArrayProtocol {}

extension Array {
    
    /// Gets the total number of elements in a given homogenous array of arrays.
    func flatCount() -> Int {
        
        var iterator = makeIterator()
        
        if let first = iterator.next() as? ArrayProtocol {
            return iterator.reduce(first.flatCount()) { $0 + ($1 as! ArrayProtocol).flatCount() }
        } else {
            return count
        }
    }
}

print(a.flatCount()) // 9


let array = Array(repeating: Array(repeating: Array(repeating: Array(repeating: 0, count: 50), count: 50), count: 50), count: 50)

do {
    let d = Date()
    let count = array.inefficientFlatCount()
    print(count, Date().timeIntervalSince(d)) // 6250000 1.13835901021957
}

do {
    let d = Date()
    let count = array.flatCount()
    print(count, Date().timeIntervalSince(d)) // 6250000 0.113689005374908
}

print("---")

do {
    let d = Date()
    let count = array.inefficientFlatCount()
    print(count, Date().timeIntervalSince(d)) // 6250000 1.15311998128891
}

do {
    let d = Date()
    let count = array.flatCount()
    print(count, Date().timeIntervalSince(d)) // 6250000 0.104122996330261
}

