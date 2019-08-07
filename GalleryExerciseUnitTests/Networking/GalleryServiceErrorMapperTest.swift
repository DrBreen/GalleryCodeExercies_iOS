//
//  mapper.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 07/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import XCTest

class GalleryServiceErrorMapperTest: XCTestCase {
    
    private let mapper = GalleryServiceErrorMapper()
    
    func test_mapsToServiceError() {
        let errorData = [
            "error": "Test error"
        ]
        
        let error = GeneralError(text: "Test")
        let data = try! JSONSerialization.data(withJSONObject: errorData, options: [])
        let mappedError = mapper.map(error, data: data)
        XCTAssertTrue(mappedError is GalleryServiceError)
        XCTAssertEqual((mappedError as! GalleryServiceError).error, "Test error")
    }
    
    func test_passesErrorThroughInvalidData() {
        let error = GeneralError(text: "Test")
        
        let data = "string".data(using: .utf8)!
        let mappedError = mapper.map(error, data: data)
        XCTAssertTrue(mappedError is GeneralError)
        XCTAssertEqual((mappedError as! GeneralError).text, error.text)
    }
    
    func test_passesErrorThroughNoData() {
        let error = GeneralError(text: "Test")
        
        let mappedError = mapper.map(error, data: nil)
        XCTAssertTrue(error is GeneralError)
        XCTAssertEqual((mappedError as! GeneralError).text, error.text)
    }
    
}
