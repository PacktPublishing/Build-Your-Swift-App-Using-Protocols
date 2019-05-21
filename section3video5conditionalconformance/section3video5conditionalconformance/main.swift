
// Volume 2 - Section 3 – Video 5: Working around the lack of conditional conformances

/// A fixed-size collection containing a pair of elements.
struct CollectionOfTwo<Element> : RandomAccessCollection, MutableCollection {
    
    typealias Index = Int
    
    var startIndex: Int { return 0 }
    var endIndex: Int { return 2 }
    
    var first: Element
    var last: Element
    
    init(first: Element, last: Element) {
        self.first = first
        self.last = last
    }
    
    func index(after i: Index) -> Index {
        precondition(i >= startIndex && i < endIndex, "Cannot advance past endIndex.")
        return i + 1
    }
    
    subscript(index: Index) -> Element {
        get {
            precondition(index >= startIndex && index < endIndex, "Index \(index) out of bounds.")
            return index == 0 ? first : last
        }
        set {
            precondition(index >= startIndex && index < endIndex, "Index \(index) out of bounds.")
            if index == 0 {
                first = newValue
            } else {
                last = newValue
            }
        }
    }
}

// Cannot say this yet...
/*
extension CollectionOfTwo : Equatable where Element : Equatable {
    static func == (lhs: CollectionOfTwo, rhs: CollectionOfTwo) -> Bool {
        return lhs.first == rhs.first && lhs.last == rhs.last
    }
}*/

// Workaround #1: Define additional overloads (without conforming the type)

extension CollectionOfTwo where Element : Equatable {
    
    static func == (lhs: CollectionOfTwo, rhs: CollectionOfTwo) -> Bool {
        return lhs.first == rhs.first && lhs.last == rhs.last
    }
}

// or...
/*
func == <T : Equatable>(lhs: CollectionOfTwo<T>, rhs: CollectionOfTwo<T>) -> Bool {
    return lhs.first == rhs.first && lhs.last == rhs.last
}*/

print(CollectionOfTwo(first: 1, last: 2) == CollectionOfTwo(first: 1, last: 2)) // true

class NotEquatable {}

// won't work, as expected:
// print(CollectionOfTwo(first: NotEquatable(), last: NotEquatable()) == CollectionOfTwo(first: NotEquatable(), last: NotEquatable()))



protocol DeepCopyable {
    func copy() -> Self
}

class C : DeepCopyable, CustomStringConvertible {
    
    var i: Int
    
    required init(i: Int) {
        self.i = i
    }
    
    var description: String {
        return "C(i: \(i))"
    }
    
    func copy() -> Self {
        return type(of: self).init(i: i)
    }
}

extension Sequence where Iterator.Element : DeepCopyable {
    
    func copyingFilter(by predicate: (Iterator.Element) throws -> Bool) rethrows -> [Iterator.Element] {
        return try flatMap { try predicate($0) ? $0.copy() : nil }
    }
}

// so we can either define a new overload for sequences of sequences...
/*
extension Sequence where Iterator.Element : Sequence, Iterator.Element.Iterator.Element : DeepCopyable {
    
    func copyingFilter(by predicate: (Iterator.Element) throws -> Bool) rethrows -> [[Iterator.Element.Iterator.Element]] {
        return try flatMap { try predicate($0) ? $0.map { $0.copy() } : nil }
    }
}


let arr = [[C(i: 1), C(i: 2)], [C(i: 3), C(i: 7)]]

let filtered = arr.copyingFilter(by: { $0.contains { $0.i == 1 } })
filtered[0][0].i = 7

print(arr)      // [[C(i: 1), C(i: 2)], [C(i: 3), C(i: 7)]]
print(filtered) // [[C(i: 7), C(i: 2)]]
*/

// or, workaround #2: Create a wrapper type

struct DeepCopyableArray<Element> : DeepCopyable where Element : DeepCopyable {
    
    var base: [Element]
    
    init() { self.base = [] }
    
    init(_ base: [Element]) {
        self.base = base
    }
    
    func copy() -> DeepCopyableArray {
        return DeepCopyableArray(base.map { $0.copy() })
    }
}

extension DeepCopyableArray : CustomStringConvertible {
    var description: String {
        return base.description
    }
}

extension DeepCopyableArray : ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Element...) {
        self.base = elements
    }
}

extension DeepCopyableArray : RandomAccessCollection, MutableCollection, RangeReplaceableCollection {
    
    typealias Index = Array<Element>.Index
    
    var startIndex: Index { return base.startIndex }
    var endIndex: Index { return base.endIndex }
    func index(_ i: Index, offsetBy n: Int) -> Index { return base.index(i, offsetBy: n) }
    func index(_ i: Index, offsetBy n: Int, limitedBy limit: Index) -> Index? { return base.index(i, offsetBy: n, limitedBy: limit) }
    
    mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C) where C : Collection, Element == C.Iterator.Element {
        base.replaceSubrange(subrange, with: newElements)
    }
    
    subscript(index: Index) -> Element {
        get { return base[index] }
        set { base[index] = newValue }
    }
}

do {
    let arr: DeepCopyableArray<DeepCopyableArray> = [[C(i: 1), C(i: 2)], [C(i: 3), C(i: 7)]]
    
    let filtered = arr.copyingFilter(by: { $0.contains { $0.i == 1 } })
    filtered[0][0].i = 7
    
    print(arr) // [[C(i: 1), C(i: 2)], [C(i: 3), C(i: 7)]]
    
    print(filtered) // [[C(i: 7), C(i: 2)]]
    
    print(arr.copy()) // [[C(i: 1), C(i: 2)], [C(i: 3), C(i: 7)]]
}

