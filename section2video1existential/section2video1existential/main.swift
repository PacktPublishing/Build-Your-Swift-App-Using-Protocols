
// Volume 2 – Section 2 – Video 1: Existential Containers


// A (machine) word: Bits of a fixed length native to the given architecture
// (32 bits on a 32-bit machine, 64 bits on a 64-bit machine, etc. you get the idea)


protocol P {
    func doSomething()
}

// 3 words in size
struct A : P {
    var foo: String
    func doSomething() {}
}

// 1 word in size
struct B : P {
    var bar: Int
    func doSomething() {}
}


// how can we represent the following in memory?
var p: P

p = A(foo: "hello world")
p = B(bar: 5)

// is it 1 or 3 words in length?

p.doSomething() // we must be able to call protocol requirements on it



// -- Protocol Composition --//

protocol P1 {
    func doSomethingElse()
}
extension A : P1 {
    func doSomethingElse() {}
}

// how do we now represent this?
var pnp1: (P & P1)


// we simply add on the additional protocol witness table to the
// end of the existential container

print(MemoryLayout<P>.size) // 40
print(MemoryLayout<P & P1>.size) // 48




