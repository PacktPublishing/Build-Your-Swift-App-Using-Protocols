
// Volume 2 – Section 4 – Video 3: Class existentials

protocol P {}
protocol P1 {}

class A : P, P1 {}

class C : P1 {}
class D : C, P {}
class E : D {}

// class existential that expresses that pc holds an instance of some type that must inherit from C and conform to both P and P1.
var pc: C & P & P1

// pc = C() // illegal, C doesn't conform to P
// pc = A() // illegal, A doesn't inherit from C
pc = D() // legal, D both inherits from C and conforms to P and P1

var pd: D & P
pd = E()


func foo<T : P>(_ t: T) {/* ... */}

// because existentials don't conform to the protocols they contain, we cannot say:
// foo(pd) // Compiler error: Cannot invoke 'foo' with an argument list of type '(D & P)'
// (but really we *should* be able to)

// simple workaround is to upcast to the concrete type in the composition:
foo(pd as D)





