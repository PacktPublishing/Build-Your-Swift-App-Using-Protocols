

// Section 1 – Video 6: Collection


// Simply an array wrapper, but gives a simple example of how to conform to (RandomAccess)Collection.
// You can also conform to MutableCollection & RangeReplaceableCollection,
// as Array also conforms to these.
struct FakeArray<Element> : Collection {
    
    var elements: [Element]
    
    let startIndex = 0
    
    var endIndex: Int {
        return elements.count
    }
    
    func index(after i: Int) -> Int {
        return elements.index(after: i)
    }
    
    // to conform to RandomAccessCollection, uncomment the below.
    // (and you can then remove index(after:))
    /*
     func index(_ i: Int, offsetBy n: Int) -> Int {
     return elements.index(i, offsetBy: n)
     }*/
    
    subscript(index: Int) -> Element {
        precondition(0 <= index && index < count, "Index out of bounds")
        return elements[index]
    }
}

let a = FakeArray(elements: [1, 2, 3])

for element in a {
    print(element)
}

// 1
// 2
// 3

// the above iteration is equivalent to...
// (as it uses IndexingIterator)

var index = a.startIndex

while index < a.endIndex {
    print(a[index])
    a.formIndex(after: &index)
}

// 1
// 2
// 3


// -- Slices -- //

let array = ["foo", "bar", "baz", "qux"]
let slice = array[2 ..< 4]

print(slice) // ["baz", "qux"]

// slices share indices with their base collection.
print(slice[2]) // "baz"
print(slice[3]) // "qux"


struct LinkedList<Element> : Collection {
    
    // Usually this should be private to hide the implementation details of the node
    // from the caller (they should only deal with indices), but is internal
    // here in order to simplify the example (you'll need an index wrapper to hide the
    // node associated value in Index, for example).
    class Node {
        
        var element: Element
        
        private var _next: Node?
        
        var next: Node? {
            get {
                // Ensure that the next node always has a greater depth than the current.
                // (this could, for example, get invalidated upon a middle insert)
                //
                // Any stored references to a given Node in the linked list MUST
                // also update the depth upon any mutations that would invalidate it.
                //
                _next?.depth = depth + 1
                return _next
            }
            set {
                _next = newValue
            }
        }
        
        private var _previous: Node?
        
        var previous: Node? {
            get {
                _previous?.depth = depth - 1
                return _previous
            }
            set {
                _previous = newValue
            }
        }
        
        
        // A quick and simple way for us to implement Comparable
        // for the linked list's indices.
        fileprivate(set) var depth: Int
        
        init(element: Element, depth: Int) {
            self.element = element
            self.depth = depth
        }
    }
    
    private var head: Node?
    private var tail: Node?
    
    init() {}
    
    init<S : Sequence>(_ s: S) where S.Iterator.Element == Element {
        for element in s {
            append(element)
        }
    }
    
    mutating func append(_ newElement: Element) {
        
        // The new tail node will either have a depth of oldTail + 1, or 0 if it's the head.
        //
        let newNode = Node(element: newElement, depth: count)
        
        if let tail = tail {
            tail.next = newNode
        } else {
            head = newNode
        }
        
        tail = newNode
    }
    
    // Notice how we can remove the makeIterator() implementation,
    // as Collection provides us with a default implementation using IndexingIterator.
    
    // Simple wrapper for a Node, or endIndex.
    enum Index : Comparable {
        
        static func == (lhs: Index, rhs: Index) -> Bool {
            switch (lhs, rhs) {
            case let (.node(lhsNode), .node(rhsNode)):
                return lhsNode === rhsNode
            case (.endIndex, .endIndex):
                return true
            default:
                return false
            }
        }
        
        static func < (lhs: Index, rhs: Index) -> Bool {
            switch (lhs, rhs) {
            case let (.node(lhsNode), .node(rhsNode)):
                return lhsNode.depth < rhsNode.depth
            case (.node, .endIndex):
                return true
            default:
                return false
            }
        }
        
        case node(Node)
        case endIndex
        
        var node: Node? {
            switch self {
            case let .node(node):
                return node
            case .endIndex:
                return nil
            }
        }
        
        init(_ node: Node?) {
            if let node = node {
                self = .node(node)
            } else {
                self = .endIndex
            }
        }
    }
    
    var startIndex: Index {
        // Wrap the head node in an Index, or give the endIndex if nil.
        return Index(head)
    }
    
    let endIndex = Index.endIndex
    
    func index(after i: Index) -> Index {
        
        guard case let .node(node) = i else {
            fatalError("Cannot advance past endIndex")
        }
        
        return Index(node.next)
    }
    
    // required for BidirectionalCollection.
    func index(before i: Index) -> Index {
        
        guard i != startIndex, let previous = i.node?.previous ?? tail else {
            fatalError("Cannot advance before start index")
        }
        
        return .node(previous)
    }
    
    subscript(index: Index) -> Element {
        get {
            guard case let .node(node) = index else {
                fatalError("Index out of bounds")
            }
            
            // Simply return the node's element.
            return node.element
        }
        set { // required for MutableCollection
            
            guard case let .node(node) = index else {
                fatalError("Index out of bounds")
            }
            
            node.element = newValue
        }
    }
}

extension LinkedList : BidirectionalCollection, MutableCollection {}

var linkedList = LinkedList([1, 2, 3])
linkedList.append(5)

for element in linkedList {
    print(element)
}

// 1
// 2
// 3
// 5


let linkedListSlice = linkedList[linkedList.index(after: linkedList.startIndex) ..< linkedList.endIndex]

print(linkedListSlice[linkedList.index(linkedList.startIndex, offsetBy: 2)]) // 3


linkedList[linkedList.index(after: linkedList.startIndex)] = 7

for element in linkedList {
    print(element)
}

// 1
// 7
// 3
// 5




