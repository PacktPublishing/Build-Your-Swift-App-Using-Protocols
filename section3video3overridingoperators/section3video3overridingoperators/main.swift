
// Volume 2 – Section 3 – Video 3: Overriding operator conformances


class Foo : Equatable {
    
    static func ==(lhs: Foo, rhs: Foo) -> Bool {
        return lhs.a == rhs.a
    }
    
    var a: Int
    
    init(a: Int) {
        self.a = a
    }
}

class Bar : Foo {
    
    static func ==(lhs: Bar, rhs: Bar) -> Bool {
        return lhs as Foo == rhs && lhs.b == rhs.b
    }
    
    var b: String
    
    init(a: Int, b: String) {
        self.b = b
        super.init(a: a)
    }
}

// direct usage (via static dispatch) works
print(Bar(a: 1, b: "foo") == Bar(a: 1, b: "baz")) // false

let bars = [Bar(a: 1, b: "foo")]

// "indirect" usage dispatches the Equatable requirement == via Foo's PWT for conformance to Equatable,
// therefore Bar's implementation of == doesn't get called.
print(bars.contains(Bar(a: 1, b: "baz"))) // true (!!)


class Baz : Equatable {
    
    static func ==(lhs: Baz, rhs: Baz) -> Bool {
        return lhs.isEqual(to: rhs)
    }
    
    var a: Int
    
    init(a: Int) {
        self.a = a
    }
    
    func isEqual(to other: Baz) -> Bool {
        return self.a == other.a
    }
}

class Qux : Baz {
    
    var b: String
    
    init(a: Int, b: String) {
        self.b = b
        super.init(a: a)
    }
    
    override func isEqual(to other: Baz) -> Bool {
        
        guard let other = other as? Qux else {
            return false
        }
        
        return super.isEqual(to: other) && self.b == other.b
    }
}

// direct usage (via static dispatch) still works
print(Bar(a: 1, b: "foo") == Bar(a: 1, b: "baz")) // false

let quxes = [Qux(a: 1, b: "foo")]

// "indirect" usage dispatches via Baz's PWT for conformance to Equatable, which then dispatches
// onto isEqual(to:), which then dynamically dispatches via the class' vtable, which Qux has an
// entry for (it's implementation of isEqual).
print(quxes.contains(Qux(a: 1, b: "baz"))) // false




