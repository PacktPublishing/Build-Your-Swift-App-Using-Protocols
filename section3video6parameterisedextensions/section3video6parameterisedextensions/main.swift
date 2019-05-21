
// Volume 2 – Section 3 – Video 6: Using protocols to allow parameterised extensions


// We cannot currently introduce new placeholders in an extension, so cannot say:
/*
extension <T> Sequence where Iterator.Element == T? {
    
    func removingNil() -> [T] {
        return flatMap { $0 }
    }
}*/

protocol OptionalProtocol {
    associatedtype WrappedType
    var `self`: WrappedType? { get }
    // func map<U>(_ transform: (WrappedType) throws -> U) rethrows -> U?
}

extension Optional : OptionalProtocol {
    typealias WrappedType = Wrapped
    var `self`: Wrapped? { return self }
}

extension Sequence where Iterator.Element : OptionalProtocol {
    
    func removingNil() -> [Iterator.Element.WrappedType] {
        return flatMap { $0.`self` }
    }
    
    /*
    func removingNil() -> [Iterator.Element.WrappedType] {
        return flatMap { $0.map { $0 } }
    }*/
}

var array = [5, nil, 3, 4, nil, 1, nil, nil]

print(array.removingNil()) // [5, 3, 4, 1]



