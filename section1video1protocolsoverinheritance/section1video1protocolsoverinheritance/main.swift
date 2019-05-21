
// Volume 2 – Section 1 – Video 1: Using protocols over inheritance

import Foundation

// -- Purely "abstract" classes -- //

// Better done with protocols.

// A RandomGenerator protocol that describes a type that can produce random elements.
// The semantics of next() is that is must be able to be repeatedly called
// without exhausting the generator, and generated elements must _appear_ to be "random".
protocol RandomGenerator {
    associatedtype Output
    func next() -> Output
}

// A random generator for doubles in a given range.
struct RandomDoubleGenerator : RandomGenerator {
    
    /// The range over which to generate the random doubles.
    var range: ClosedRange<Double>
    
    init(range: ClosedRange<Double>) {
        self.range = range
    }
    
    init(range: Range<Double>) {
        
        precondition(!range.isEmpty, "Cannot generate a random Double in an empty range")
        
        // if we're being initialised with a Range (non-inclusive of upper bound),
        // we need to get the next Double down from the upper bound in order to express as
        // a ClosedRange (inclusive of upper bound).
        self.range = range.lowerBound ... range.upperBound.nextDown
    }
    
    func next() -> Double {
        // r is a random Double in the range 0 ... 1
        let r = Double(arc4random()) / Double(UInt32.max)
        return range.lowerBound + r * (range.upperBound - range.lowerBound)
    }
}

let r = RandomDoubleGenerator(range: 40 ..< 70)
print(r.next()) // 63.292846929583

// A simple RGB color with floating-point components.
// Components should be in the range 0 ... 1
struct RGBColor {
    var red: Double
    var green: Double
    var blue: Double
}

struct RandomRGBColorGenerator : RandomGenerator {
    
    // Using composition in order to express RandomRGBColorGenerator in terms of
    // RandomDoubleGenerator, using it in order to generate each component.
    private let componentGenerator = RandomDoubleGenerator(range: 0 ... 1)
    
    func next() -> RGBColor {
        return RGBColor(red: componentGenerator.next(), green: componentGenerator.next(), blue: componentGenerator.next())
    }
}


// -- Composition over inheritance -- //

// Either a success that holds the given result value,
// or a failure, which holds the error for what went wrong.
enum Result<T> {
    case success(T)
    case failure(Error)
}

// A protocol that describes a type that can perform a data request.
// The request is expected to be asynchronous, but can be implemented
// synchronously.
protocol DataRequest {
    func requestData(completion: @escaping (Result<Data>) -> Void)
}

// A data request that is recieved from a given URL.
struct URLDataRequest : DataRequest {
    
    var url: URL
    
    func requestData(completion: @escaping (Result<Data>) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(error!))
            }
            
            }.resume()
    }
}

// A protocol that describes a type that can be decoded from a given dictionary representing a JSON object.
protocol JSONObjectDecodable {
    init(from jsonObject: [String: Any]) throws
}

// An error that can be thrown upon decoding JSON.
enum JSONParsingError : Error {
    case unexpectedType(forKey: String?, expected: Any.Type, found: Any.Type)
    case missingKey(String)
}

struct JSONRequest {
    
    /// The given data source to recieve the JSON data from.
    /// Must return valid JSON data.
    var dataSource: DataRequest
    
    /// Decode a JSONObjectDecodable type from given JSON data.
    static func decodeJSONObject<T : JSONObjectDecodable>(_: T.Type, from data: Data) throws -> T {
        
        let decoded = try JSONSerialization.jsonObject(with: data)
        
        // if it's not a [String: Any] (JSON object), throw an error.
        guard let jsonObject = decoded as? [String: Any] else {
            throw JSONParsingError.unexpectedType(forKey: nil, expected: [String: Any].self, found: type(of: decoded))
        }
        
        // forward onto the concrete type.
        return try T(from: jsonObject)
    }
    
    /// Perform a new request in order to fetch and decode JSON data.
    func requestJSONObject<T : JSONObjectDecodable>(
        _: T.Type, completion: @escaping (Result<T>) -> Void) {
        
        dataSource.requestData { response in
            
            switch response {
            case let .success(data):
                do {
                    
                    let result = try JSONRequest.decodeJSONObject(T.self, from: data)
                    completion(.success(result))
                    
                } catch {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

struct TestDate : JSONObjectDecodable {
    
    var timeString: String
    var millisecondsSinceEpoch: Int
    var dateString: String
    
    enum JSONObjectKey : String {
        case timeString = "time"
        case millisecondsSinceEpoch = "milliseconds_since_epoch"
        case dateString = "date"
    }
    
    init(from jsonObject: [String : Any]) throws {
        
        // convenience nested function to decode a given value for a key.
        // throws the appropriate errors upon keys missing or value being the wrong type.
        func valueForKey<Value>(_: Value.Type, key: JSONObjectKey) throws -> Value {
            
            guard let value = jsonObject[key.rawValue] else {
                throw JSONParsingError.missingKey(key.rawValue)
            }
            
            guard let castedValue = value as? Value else {
                throw JSONParsingError.unexpectedType(forKey: key.rawValue, expected: Value.self, found: type(of: value))
            }
            
            return castedValue
        }
        
        self.timeString = try valueForKey(String.self, key: .timeString)
        self.millisecondsSinceEpoch = try valueForKey(Int.self, key: .millisecondsSinceEpoch)
        self.dateString = try valueForKey(String.self, key: .dateString)
    }
}


let url = URL(string: "http://date.jsontest.com")!
let dataSource = URLDataRequest(url: url)

// simply use a semaphore to ensure that we wait for the request before exiting the program.
let sema = DispatchSemaphore(value: 0)

JSONRequest(dataSource: dataSource).requestJSONObject(TestDate.self) { result in
    switch result {
    case let .success(testDate):
        print("success:", testDate)
    case let .failure(error):
        print("failure:", error)
    }
    sema.signal()
}

sema.wait()


