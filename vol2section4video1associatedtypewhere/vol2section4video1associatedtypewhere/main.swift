
// Volume 2 – Section 4 – Video 1: Associated type where clauses

// A very (very!) simplified look at how the Sequence and Collection protocols can benefit from associated type where clauses.

protocol Sequence {
    
    associatedtype Element
    
    associatedtype SubSequence
    associatedtype Iterator : IteratorProtocol where Iterator.Element == Element
    
    func makeIterator() -> Iterator
}

extension Sequence where Element : Equatable {
    
    func contains(_ element: Element) -> Bool {
        
        var i = makeIterator()
        
        while let next = i.next() {
            if next == element {
                return true
            }
        }
        return false
    }
}


// workaround for lack of recursive protocol requirements - to be fixed in a future version of the language!
protocol _Indexable {
    
    associatedtype Element
    associatedtype SubSequence
    associatedtype Index : Comparable
    
    var startIndex: Index { get }
    var endIndex: Index { get }
    
    func index(after: Index) -> Index
    
    subscript(index: Index) -> Element { get }
    subscript(range: Range<Index>) -> SubSequence { get }
}

protocol Collection : _Indexable, Sequence where SubSequence : _Indexable,
                                                 SubSequence : Sequence,
                                                 SubSequence.Element == Element,
                                                 SubSequence.Index == Index {
    
    associatedtype Indices : _Indexable, Sequence where Indices.Element == Index
    
    var indices: Indices { get }
    
    func index(where predicate: (Element) throws -> Bool) rethrows -> Index?
    
    subscript(index: Index) -> Element { get }
}

// What Collection should look more like... (again, this is very simplified)
/*
protocol Collection : Sequence where SubSequence : Collection, SubSequence.Element == Element {
    
    associatedtype Index : Comparable where SubSequence.Index == Index

    var startIndex: Index { get }
    var endIndex: Index { get }
    
    func index(after: Index) -> Index
    func index(where predicate: (Element) throws -> Bool) rethrows -> Index?

    associatedtype Indices : Collection where Indices.Element == Index

    var indices: Indices { get }

    subscript(index: Index) -> Element { get }
    subscript(range: Range<Index>) -> SubSequence { get }
}
*/


extension CountableRange : Collection {}
extension Array          : Collection {}
extension ArraySlice     : Collection {}

// in Swift 3, we had to have the additional constraints "SubSequence.Iterator.Element == Iterator.Element, SubSequence.Index == Index"
extension Collection where SubSequence : Collection { // <- once we have recursive protocol constraints, where SubSequence : Collection can be removed.
    
    // adapted from @dfri's answer at https://stackoverflow.com/q/42981122/2976878
    func chunked(
        // in Swift 3, we had to refer to Iterator.Element rather than just Element
        by predicate: (Element, Element) throws -> Bool
        ) rethrows -> [SubSequence] {
        
        var results: [SubSequence] = []
        
        var i = startIndex
        
        while i < endIndex {
            
            let nextIndex = try self[i ..< endIndex]
                .index(where: { try !predicate($0, self[i]) }) ?? endIndex
            
            results.append(self[i ..< nextIndex])
            i = nextIndex
        }
        
        return results
    }
}

// in Swift 3, we had to have the additional constraints "SubSequence.Iterator.Element == Iterator.Element, SubSequence.Index == Index"
extension Collection where SubSequence : Collection, Element : Equatable {
    
    func chunked() -> [SubSequence] {
        return chunked(by: ==)
    }
}

let arr = [1, 1, 1, 2, 5, 6, 6, 6, 5, 5, 7, 8]

print(arr.chunked())

// [
//   ArraySlice([1, 1, 1]),
//   ArraySlice([2]),
//   ArraySlice([5]),
//   ArraySlice([6, 6, 6]),
//   ArraySlice([5, 5]),
//   ArraySlice([7]),
//   ArraySlice([8])
// ]

extension Collection { // in Swift 3, we had to have the additional constraint "where Indices.Iterator.Element == Index"
    
    subscript(maybeIndex index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

let a = [1, 2, 3]

print(a[maybeIndex: 2] as Any) // Optional(3)
print(a[maybeIndex: 3] as Any) // nil



