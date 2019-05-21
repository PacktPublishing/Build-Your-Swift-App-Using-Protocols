
// Volume 2 – Section 3 – Video 1: Type Erasers

// 1. Realising associated types as generic placeholders
// e.g AnySequence, AnyCollection

let array = [1, 2, 3]
let range = 4 ... 6

// var anySeq: Sequence // Protocol 'Sequence' can only be used as a generic constraint because it has Self or associated type requirements
// var anySeq: Sequence where Iterator.Element == Int // also illegal
var anySeq: AnySequence<Int>

anySeq = AnySequence(array)
anySeq = AnySequence(range)

for element in anySeq {
    print(element)
}


protocol P {
    associatedtype Foo : Integer
    var foo: Foo { get set }
    func doSomething()
}

// The general type eraser pattern:
// - A box that wraps an instance of some type that conforms to P
// - The box itself conforms to P
// - The box forwards requirements onto the underlying P-conforming instance

struct AnyP<Foo : Integer> : P {
    
    private let _fooGetter: () -> Foo
    private let _fooSetter: (Foo) -> ()
    
    var foo: Foo {
        get { return _fooGetter() }
        set { _fooSetter(newValue) }
    }
    
    private let _doSomething: () -> Void
    
    init<Base : P>(_ base: Base) where Base.Foo == Foo {
        var base = base // if you need mutability
        _fooGetter = { base.foo }
        _fooSetter = { base.foo = $0 }
        _doSomething = { base.doSomething() } // be careful with _doSomething = base.doSomething
    }
    
    func doSomething() {
        _doSomething()
    }
}

struct S : P {
    
    var foo: Int
    
    func doSomething() {
        print(foo)
    }
}

// var anyP: P
var anyP = AnyP(S(foo: 5))

anyP.doSomething() // 5
anyP.foo += 1
anyP.doSomething() // 6


// 2. Workaround for protocols not conforming to themselves

protocol HasAFoo {
    var foo: Int { get set }
}

struct S1 : HasAFoo {
    var foo: Int
}

protocol DoesSomething {
    associatedtype ConcreteHasAFoo : HasAFoo
    func doSomething() -> ConcreteHasAFoo
}

/*
// Type 'DoesSomethingWithAnyFoo' does not conform to protocol 'DoesSomething',
// as HasAFoo is not a type that conforms to HasAFoo.
struct DoesSomethingWithAnyFoo : DoesSomething {
    func doSomething() -> HasAFoo {
        // ...
    }
}*/

// Solution: Type eraser!

struct AnyHasAFoo : HasAFoo {
    
    // because HasAFoo has no associated type requirements, we can store the base directly.
    // no need to work with function values.
    private var base: HasAFoo
    
    var foo: Int {
        get { return base.foo }
        set { base.foo = newValue }
    }
    
    init(_ base: HasAFoo) {
        self.base = base
    }
}

struct DoesSomethingWithAnyFoo : DoesSomething {
    func doSomething() -> AnyHasAFoo {
        
        // ...
        
        // obviously hasAFoo should be an arbitrary HasAFoo conforming type.
        let hasAFoo = S1(foo: 5)
        
        // wrap in type eraser.
        return AnyHasAFoo(hasAFoo)
    }
}


