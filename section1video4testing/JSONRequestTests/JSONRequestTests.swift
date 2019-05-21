
// Volume 2 – Section 1 – Video 4: Testing with protocols

import XCTest

class JSONRequestTests : XCTestCase {
    
    // A mock data request that simply always hands back a given result synchronously.
    struct MockDataRequest : DataRequest {
        
        var result: Result<Data>
        
        func requestData(completion: @escaping (Result<Data>) -> Void) {
            completion(result)
        }
    }
    
    // A JSON decoding spy that just holds onto the jsonObject dictionary that's passed to it.
    struct JSONDecodeSpy : JSONObjectDecodable {
        
        var jsonObject: [String: Any]
        
        init(from jsonObject: [String : Any]) throws {
            self.jsonObject = jsonObject
        }
    }
    
    func testJSONDecoding() {
        
        // create a mock JSON string, and get the UTF-8 data from this string,
        // then pass that into a new MockDataRequest.
        let mockJSON = "{\"foo\": 56, \"bar\": \"qux\"}".data(using: .utf8)!
        let mockRequest = MockDataRequest(result: .success(mockJSON))
        
        // a simple flag to ensure that the given completion handler gets called.
        var requestWasSynchronous = false
        
        JSONRequest(dataSource: mockRequest).requestJSONObject(JSONDecodeSpy.self) { result in
            
            // must be a success, as we passed in a success.
            guard case let .success(decoded) = result else {
                XCTFail("JSON request unexpectedly failed.")
                return
            }
            
            // get the dictionary from the spy.
            let jsonObject = decoded.jsonObject
            
            // assert that the decoding was correct (both keys present and values of the correct type).
            // this could be split up into seperate asserts if desired.
            XCTAssertEqual(56, jsonObject["foo"] as? Int)
            XCTAssertEqual("qux", jsonObject["bar"] as? String)
            
            requestWasSynchronous = true
        }
        
        XCTAssert(requestWasSynchronous)
        
    }
}
