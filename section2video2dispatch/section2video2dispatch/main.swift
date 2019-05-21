
// Volume 2 – Section 2 – Video 2: Dispatch of protocol requirements

protocol P {
    // as foo() and bar() are protocol requirements,
    // they get listed in the protocol witness table for conforming types.
    func foo()
    func bar()
}


extension P {
    
    func foo() {
        print("Extension foo()")
    }
    
    func bar() {
        print("Extension bar()")
    }
    
    func qux() {
        print("Extension qux()")
    }
}

struct S : P {
    
    func foo() {
        print("S foo()")
    }
    
    // as bar() not implemented, S's protocol witness table for conformance to P
    // will contain the extension implementation of bar()
    
    func qux() {
        print("S qux()")
    }
}

// static dispatch
let s = S()
s.foo() // S foo()
s.bar() // Extension bar()
s.qux() // S qux()


let p: P = S()

// dispatch via protocol witness table
p.foo() // S foo()
p.bar() // Extension bar()

// static dispatch, as not a protocol requirement
p.qux() // Extension qux()



