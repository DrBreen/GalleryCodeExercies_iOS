//
//  Array+ExtendingReplaceRangeTests.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 04/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import XCTest

class ArrayExtendingReplaceSubrangeTests: XCTestCase {
    
    func test_extendingReplaceSubrangeInside() {
        var array = [1, 2, 3, 4, 5, 6, 7]
        
        array.extendingReplaceSubrange((2..<4), with: [10, 11])
        
        XCTAssertEqual(array, [1, 2, 10, 11, 5, 6, 7])
    }
    
    func test_extendingReplaceSubrangeOutside() {
        var array = [1, 2, 3, 4, 5, 6, 7]
        
        array.extendingReplaceSubrange((4..<8), with: [10, 11, 12, 13])
        
        XCTAssertEqual(array, [1, 2, 3, 4, 10, 11, 12, 13])
    }
    
    func test_extendingReplaceSubrangeOutsideSmallerArray() {
        var array = [1, 2, 3, 4, 5, 6, 7]
        
        array.extendingReplaceSubrange((4..<8), with: [10])
        
        XCTAssertEqual(array, [1, 2, 3, 4, 10])
    }
    
    func test_extendingReplaceSubrangeWholeArray() {
        var array = [1, 2, 3, 4, 5, 6, 7]
        
        array.extendingReplaceSubrange((0..<10), with: [9, 10, 11, 12, 13, 14, 15, 16, 17, 18])
        
        XCTAssertEqual(array, [9, 10, 11, 12, 13, 14, 15, 16, 17, 18])
    }
    
}
