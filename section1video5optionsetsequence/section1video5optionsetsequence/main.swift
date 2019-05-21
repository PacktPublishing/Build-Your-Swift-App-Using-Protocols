

// -- OptionSet -- //

struct SomeOptions : OptionSet {
    
    // list the options as static stored properties.
    // each unique option should have a rawValue that's
    // a unique power of 2 (e.g 1, 2, 4, 8, ...)
    // here, expressed as bitwise shifts of 1.
    
    static let a = SomeOptions(rawValue: 1 << 0) // 0b000001
    static let b = SomeOptions(rawValue: 1 << 1) // 0b000010
    static let c = SomeOptions(rawValue: 1 << 2) // 0b000100
    static let d = SomeOptions(rawValue: 1 << 3) // 0b001000
    
    // convenience combination of options.
    static let abc: SomeOptions = [.a, .b, .c] // 0b000111
    
    let rawValue: Int
}

var opt = SomeOptions.a

print(opt.contains(.a)) // true
print(opt.contains(.d)) // false

opt.formUnion(.d)

print(opt.contains(.d)) // true

print(SomeOptions.abc.intersection([.d, .a, .c])) // SomeOptions(rawValue: 5)


let empty: SomeOptions = []





// -- Sequence -- //

struct CountingIterator : IteratorProtocol {
    
    // the starting value of the counter.
    private var startingValue: Int
    
    init(startingValue: Int) {
        self.startingValue = startingValue
    }
    
    mutating func next() -> Int? {
        
        defer {
            startingValue += 1
        }
        
        // return the starting value, then increment by 1 (as defer happens "after")
        return startingValue
    }
}

var countingIterator = CountingIterator(startingValue: 5)

print(countingIterator.next() as Any) // Optional(5)
print(countingIterator.next() as Any) // Optional(6)
print(countingIterator.next() as Any) // Optional(7)
print(countingIterator.next() as Any) // Optional(8)


struct CountingSequence : Sequence {
    
    // just hold onto a constant copy of the startingValue,
    // and pass off to the iterator upon an iterator being created.
    let startingValue: Int
    
    func makeIterator() -> Iterator {
        return Iterator(startingValue: startingValue)
    }
    
    // simply a duplication of the iterator we defined above,
    // but demonstrates how nested types can be used here.
    struct Iterator : IteratorProtocol {
        
        private var startingValue: Int
        
        init(startingValue: Int) {
            self.startingValue = startingValue
        }
        
        mutating func next() -> Int? {
            
            defer {
                startingValue += 1
            }
            
            return startingValue
        }
    }
}

let countingSequence = CountingSequence(startingValue: 7)

for element in countingSequence.prefix(3) {
    print(element)
}

// 7
// 8
// 9


// the above iteration is the equivalent of doing...

var iterator = countingSequence.prefix(3).makeIterator()

while let element = iterator.next() {
    print(element)
}

// 7
// 8
// 9


class DestructiveCountingSequence : Sequence, IteratorProtocol {
    
    // destructive, as the sequences and iterators share the same starting value.
    
    private var startingValue: Int
    
    init(startingValue: Int) {
        self.startingValue = startingValue
    }
    
    func next() -> Int? {
        
        defer {
            startingValue += 1
        }
        
        return startingValue
    }
}

let destCountingSequence = DestructiveCountingSequence(startingValue: 10)

for element in destCountingSequence.prefix(3) {
    print(element)
}

// 10
// 11
// 12

for element in destCountingSequence.prefix(3) {
    print(element)
}

// 13
// 14
// 15
