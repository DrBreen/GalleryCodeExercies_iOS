//
//  AlamofireNetworkRequestSenderTest.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 04/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import XCTest
import Alamofire
import RxSwift
import OHHTTPStubs

fileprivate class MockErrorMapper: NetworkRequestErrorMapper {
    
    func map(_ error: Error, data: Data?) -> Error {
        
        var userInfo = [String : Any]()
        if let data = data {
            userInfo["data"] = data
        }
        
        return NSError(domain: "mappedError", code: 1, userInfo: userInfo)
    }
}

class AlamofireNetworkRequestSenderTest: XCTestCase {
    
    private let sender = AlamofireNetworkRequestSender()
    
    func test_getDataSuccess() {
        sender.errorMapper = nil
        
        let mockedData = "testData".data(using: .utf8)!
        performTest(mockedData: mockedData, verifier: { (data: Data?, error: Error?) in
            XCTAssertEqual(mockedData, data)
        }, expectResponse: true)
    }
    
    func test_getDataErrorNoMapper() {
        sender.errorMapper = nil
        
        let error = NSError(domain: "testDomain", code: 1, userInfo: nil)
        performTest(mockedError: error, verifier: { (data: Data?, responseError: Error?) in
            XCTAssertNotNil(responseError)
            
            let nsError = responseError! as NSError
            
            XCTAssertEqual(error.domain, nsError.domain)
            XCTAssertEqual(error.code, nsError.code)
        }, expectResponse: false, expectError: true)
    }
    
    func test_getDataErrorWithMapper() {
        sender.errorMapper = MockErrorMapper()
        
        let errorData = "errorTestData".data(using: .utf8)!
        performTest(mockedData: errorData, mockedStatus: 400, verifier: { (_: Data?, error: Error?) in
            XCTAssertNotNil(error)
            
            let nsError = error! as NSError
            XCTAssertEqual(nsError.domain, "mappedError")
            
            let data = nsError.userInfo["data"] as? Data
            XCTAssertEqual(errorData, data)
        }, expectResponse: false, expectError: true)
    }
    
    func test_upload() {
        sender.errorMapper = nil
        
        let mockedObject = ["objet" : "d'Art"]
        let mockedData = try! JSONSerialization.data(withJSONObject: mockedObject, options: [])
        performTest(mockedData: mockedData, verifier: { (data: Any?, error: Error?) in
            XCTAssertTrue(data is [String: String])
            
            let dictionary = data as! [String: String]
            XCTAssertEqual(dictionary, mockedObject)
        }, expectResponse: true)
    }
    
    func test_uploadErrorNoMapper() {
        sender.errorMapper = nil
        
        let error = NSError(domain: "testDomain", code: 1, userInfo: nil)
        performTest(mockedError: error, verifier: { (data: Any?, responseError: Error?) in
            XCTAssertNotNil(responseError)
            
            let nsError = responseError! as NSError
            
            XCTAssertEqual(error.domain, nsError.domain)
            XCTAssertEqual(error.code, nsError.code)
        }, expectResponse: false, expectError: true)
    }
    
    func test_uploadErrorWithMapper() {
        sender.errorMapper = MockErrorMapper()
        
        let errorData = "errorTestData".data(using: .utf8)!
        performTest(mockedData: errorData, mockedStatus: 400, verifier: { (_: Any?, error: Error?) in
            XCTAssertNotNil(error)
            
            let nsError = error! as NSError
            XCTAssertEqual(nsError.domain, "mappedError")
            
            let data = nsError.userInfo["data"] as? Data
            XCTAssertEqual(errorData, data)
        }, expectResponse: false, expectError: true)
    }
    
    func performTest<T>(mockedData: Data? = nil,
                        mockedError: Error? = nil,
                        mockedStatus: Int32 = 200,
                        verifier: ((T?, Error?) -> Void)? = nil,
                        expectResponse: Bool = true,
                        expectError: Bool = false) {
        OHHTTPStubs.removeAllStubs()
        
        OHHTTPStubs.stubRequests(passingTest: { request in
            return true
        }) { request -> OHHTTPStubsResponse in
            if let data = mockedData {
                return OHHTTPStubsResponse(data: data, statusCode: mockedStatus, headers: nil)
            } else if let error = mockedError {
                return OHHTTPStubsResponse(error: error)
            } else {
                fatalError("No Data and no Error...what do you want to do?")
            }
        }
        
        let responseExpectation = XCTestExpectation()
        responseExpectation.assertForOverFulfill = true
        responseExpectation.expectedFulfillmentCount = 1
        
        let errorExpectation = XCTestExpectation()
        errorExpectation.assertForOverFulfill = true
        errorExpectation.expectedFulfillmentCount = 1
        
        let disposeBag = DisposeBag()
        
        let observable: Observable<T>
        if T.self == Any.self {
            observable = sender.upload(url: URL(string: "http://test.com")!, body: Data(), headers: nil) as! Observable<T>
        } else if T.self == Data.self {
            observable = sender.getData(url: URL(string: "http://test.com")!, query: nil, headers: nil) as! Observable<T>
        } else {
            fatalError("Unsupported type of response")
        }
        
        observable.subscribe(onNext: { response in
            verifier?(response, nil)
            responseExpectation.fulfill()
        }, onError: { error in
            verifier?(nil, error)
            errorExpectation.fulfill()
        }).disposed(by: disposeBag)
        
        var expectations = [XCTestExpectation]()
        
        if expectError {
            expectations.append(errorExpectation)
        }
        
        if expectResponse {
            expectations.append(responseExpectation)
        }
        
        wait(for: expectations, timeout: 2.0)
        
    }
    
}
