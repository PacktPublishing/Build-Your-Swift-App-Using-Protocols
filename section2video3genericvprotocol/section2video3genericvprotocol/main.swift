
// Volume 2 – Section 2 – Video 3: Constrained generic placeholder vs. protocol type

protocol P {}
struct S : P {}

func withGenericParameter<T : P>(_ t: T) {}
func withProtocolParameter(_ t: P) {}


// #1: Specialisation


// #2: Constrained generic placeholders must be satisfied by concrete types.

let s = S()
let p: P = S()

withGenericParameter(s)
// withGenericParameter(p) // illegal

// both legal
withProtocolParameter(s)
withProtocolParameter(p)


// protocols don't conform to themselves...

protocol P1 {
    init()
}

func createP1<T : P1>(_ type: T.Type) -> T {
    return T()
}

// let p1 = createP1(P1.self) // what instance should we create here?


// #3: Overload Resolution

func foo<T : P>(_ t: T) {}
func foo(_ t: P) {} // preferred

foo(S())


// #4: Generics enforce the same type

func genericFunc<T : P>(_ t: T) -> T { return t }

func nonGenericFunc(_ p: P) -> P { return p }

//    : S
let s2    = genericFunc(S())

//    : P
let p2    = nonGenericFunc(S())


struct Homogeneous<T : P> {
    var array: [T]
}

struct Heterogeneous {
    var array: [P]
}

struct S1 : P {}

// wrapper of an array that holds instances of *any* given type that conforms to P.
let heterogeneous = Heterogeneous(array: [S(), S1()])

// wrapper of an array that holds instances of any *one* concrete type that conforms to P.
let homogeneous = Homogeneous(array: [S()/*, S1()*/])




