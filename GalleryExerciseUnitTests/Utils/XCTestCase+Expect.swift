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
        let exc = XCTestExpectation(description: "Expect \(count) fulfills")
        exc.assertForOverFulfill = true
        exc.expectedFulfillmentCount = count
        
        action(exc)
        
        wait(for: [exc], timeout: 2.0)
    }
    
    func expectMultiple(counts: [Int], _ descriptions: [String]? = nil, _ action: ([XCTestExpectation]) -> Void) {
        
        if let descriptions = descriptions, descriptions.count != counts.count {
            fatalError("Please provide descriptions for all expectations")
        }
        
        let expectations = counts.enumerated().map { (index: Int, count: Int) -> XCTestExpectation in
            let exc = XCTestExpectation(description: descriptions?[index] ?? "Expectation #\(index)")
            exc.assertForOverFulfill = true
            exc.expectedFulfillmentCount = count
            return exc
        }
        
        action(expectations)
        
        wait(for: expectations, timeout: 2.0)
    }
    
}
