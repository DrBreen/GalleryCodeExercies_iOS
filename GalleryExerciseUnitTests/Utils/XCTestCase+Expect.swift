//
//  XCTestCase+Expect.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 06/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {
    
    func expect(count: Int, _ action: (XCTestExpectation) -> Void) {
        let expectataion = XCTestExpectation()
        expectataion.assertForOverFulfill = true
        expectataion.expectedFulfillmentCount = count
        
        action(expectataion)
        
        wait(for: [expectataion], timeout: 2.0)
    }
    
    func expectMultiple(counts: [Int], _ descriptions: [String]? = nil, _ action: ([XCTestExpectation]) -> Void) {
        
        if let descriptions = descriptions, descriptions.count != counts.count {
            fatalError("Please provide descriptions for all expectations")
        }
        
        let expectations = counts.enumerated().map { (index: Int, count: Int) -> XCTestExpectation in
            let expectation = XCTestExpectation(description: descriptions?[index] ?? "Expectation #\(index)")
            expectation.assertForOverFulfill = true
            expectation.expectedFulfillmentCount = count
            return expectation
        }
        
        action(expectations)
        
        wait(for: expectations, timeout: 2.0)
    }
    
}
