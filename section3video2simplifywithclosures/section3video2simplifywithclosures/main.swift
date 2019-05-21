
// Volume 2 – Section 3 – Video 2: Simplify protocol architectures with closures


// -- Type erasers without using closures -- //

protocol P {
    associatedtype Foo : Integer
    var foo: Foo { get set }
    func doSomething()
}

fileprivate class _AnyPBase<Foo : Integer> : P {
    
    private func _mustOverride() -> Never {
        fatalError("Must override")
    }
    
    var foo: Foo {
        get { _mustOverride() }
        set { _mustOverride() }
    }
    
    func doSomething() {
        _mustOverride()
    }
}

fileprivate class _AnyPBox<Base : P> : _AnyPBase<Base.Foo> {
    
    private var base: Base
    
    init(_ base: Base) {
        self.base = base
    }
    
    override var foo: Base.Foo {
        get { return base.foo }
        set { base.foo = newValue }
    }
    
    override func doSomething() {
        base.doSomething()
    }
}

struct AnyPWithoutClosures<Foo : Integer> : P {
    
    private let base: _AnyPBase<Foo>
    
    init<Base : P>(_ base: Base) where Base.Foo == Foo {
        self.base = _AnyPBox(base)
    }
    
    var foo: Foo {
        get { return base.foo }
        set { base.foo = newValue }
    }
    
    func doSomething() {
        base.doSomething()
    }
}


// But with closures...

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


// -- Simplifying generic code with closures -- //


// Before simplifying by using closures...
/*
protocol PipelineProducer {
    associatedtype Data
    func produce() -> Data
}

protocol PipelineTransform {
    associatedtype Input
    associatedtype Output
    func transform(_ input: Input) -> Output
}

protocol PipelineConsumer {
    associatedtype Data
    func consume(_ input: Data)
}

struct PipelineIntProducer : PipelineProducer {
    
    var value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    func produce() -> Int {
        return value
    }
}

struct PipelineIntAdder : PipelineTransform {
    
    var increment: Int
    
    init(increment: Int) {
        self.increment = increment
    }
    
    func transform(_ input: Int) -> Int {
        return input + increment
    }
}

struct PipelineIntConsumer : PipelineConsumer {
    func consume(_ data: Int) { print(data) }
}

struct AnyPipelineProducer<Data> : PipelineProducer {
    
    private let _produce: () -> Data
    
    init<I : PipelineProducer>(_ base: I) where I.Data == Data {
        self._produce = base.produce
    }
    
    func produce() -> Data {
        return _produce()
    }
}

struct AnyPipelineTransform<Input, Output> : PipelineTransform {
    
    private let _transform: (Input) -> Output
    
    init<T : PipelineTransform>(_ base: T) where T.Input == Input, T.Output == Output {
        self._transform = base.transform
    }
    
    func transform(_ input: Input) -> Output {
        return _transform(input)
    }
}

struct AnyPipelineConsumer<Data> : PipelineConsumer {
    
    private let _consume: (Data) -> Void
    
    init<O : PipelineConsumer>(_ base: O) where O.Data == Data {
        self._consume = base.consume
    }
    
    func consume(_ input: Data) {
        _consume(input)
    }
}

struct Pipeline<Input, Output> {
    
    private let producer: AnyPipelineProducer<Input>
    private let transform: AnyPipelineTransform<Input, Output>
    private let consumer: AnyPipelineConsumer<Output>
    
    init<Producer : PipelineProducer, Transform : PipelineTransform, Consumer : PipelineConsumer>
        (producer: Producer, transform: Transform, consumer: Consumer)
        where Producer.Data == Input, Transform.Input == Input, Transform.Output == Output, Consumer.Data == Output {
            
        self.producer = AnyPipelineProducer(producer)
        self.transform = AnyPipelineTransform(transform)
        self.consumer = AnyPipelineConsumer(consumer)
    }
    
    func execute() {
        consumer.consume(transform.transform(producer.produce()))
    }
}

let pipeline = Pipeline(
    producer: PipelineIntProducer(value: 1),
    transform: PipelineIntAdder(increment: 5),
    consumer: PipelineIntConsumer()
)

pipeline.execute() // 6
 */

// After simplifying with closures...

struct PipelineIntProducer {
    
    var value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    func produce() -> Int {
        return value
    }
}

struct PipelineIntAdder {
    
    var increment: Int
    
    init(increment: Int) {
        self.increment = increment
    }
    
    func transform(_ input: Int) -> Int {
        return input + increment
    }
}

struct PipelineIntConsumer {
    func consume(_ data: Int) {
        print(data)
    }
}

struct Pipeline {
    
    private let _execute: () -> Void
    
    init<Input, Output>(producer: @escaping () -> Input, transform: @escaping (Input) -> Output, consumer: @escaping (Output) -> Void) {
        
        self._execute = {
            consumer(transform(producer()))
        }
    }
    
    func execute() {
        _execute()
    }
}


let p1 = Pipeline(
    producer: PipelineIntProducer(value: 1).produce,
    transform: PipelineIntAdder(increment: 5).transform,
    consumer: PipelineIntConsumer().consume
)
p1.execute() // 6

// if the implementations of any of them are simple, we can
// now just use closure expressions in order to define them.
let p2 = Pipeline(
    producer: { 1 },
    transform: { $0 + 5 },
    consumer: { print($0) }
)
p2.execute() // 6


