

// A stack that can "undo" and "redo" elements pushed to it.
struct UndoRedoStack<Element> : ExpressibleByArrayLiteral, RandomAccessCollection {
    
    // the current elements in the stack.
    private var undoStack = [Element]()
    
    // the elements that have been undone.
    private var redoStack = [Element]()
    
    // conformance to ExpressibleByArrayLiteral.
    init(arrayLiteral elements: Element...) {
        self.undoStack = elements
    }
    
    // convenience initialiser for creating a stack from a given sequence.
    init<S : Sequence>(_ sequence: S) where S.Iterator.Element == Element {
        self.undoStack = Array(sequence)
    }
    
    
    // conformance to RandomAccessCollection...
    
    var startIndex: Int {
        return undoStack.startIndex
    }
    
    var endIndex: Int {
        return undoStack.endIndex
    }
    
    func index(_ i: Int, offsetBy n: Int) -> Int {
        return undoStack.index(i, offsetBy: n)
    }
    
    subscript(index: Int) -> Element {
        return undoStack[index]
    }
    
    mutating func push(_ newElement: Element) {
        // remove the undone elements,
        // and append a new element.
        redoStack.removeAll()
        undoStack.append(newElement)
    }
    
    @discardableResult
    mutating func undoPush() -> Element? {
        // if we can pop an element off the undoStack, then append to redoStack.
        // (transferring from current elements to redoStack)
        guard let element = undoStack.popLast() else { return nil }
        redoStack.append(element)
        return element
    }
    
    @discardableResult
    mutating func redoPush() -> Element? {
        // pass element back to undoStack.
        guard let element = redoStack.popLast() else { return nil }
        undoStack.append(element)
        return element
    }
    
    @discardableResult
    mutating func pop() -> Element? {
        // remove all redoStack elements,
        // and pop off the last element of the undoStack
        // (non-undo-able)
        redoStack.removeAll()
        return undoStack.popLast()
    }
    
    mutating func popAll() {
        // remove all elements.
        redoStack.removeAll()
        undoStack.removeAll()
    }
}
