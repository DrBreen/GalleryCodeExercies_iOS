//
//  Array+ExtendingReplaceSubrange.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 04/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation

extension Array {
    
    mutating func extendingReplaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where Element == C.Element, C : Collection, C.Index == Int {
        let arrayRange = (0..<count)
        
        //if range is inside array range
        if arrayRange.startIndex <= subrange.startIndex && arrayRange.endIndex >= subrange.endIndex {
            replaceSubrange(subrange, with: newElements)
        } else if subrange.startIndex >= arrayRange.startIndex && subrange.startIndex <= arrayRange.endIndex && subrange.endIndex > arrayRange.endIndex {
            removeLast(arrayRange.endIndex - subrange.startIndex)
            append(contentsOf: newElements)
        } else {
            fatalError("Subrange start index can't be smaller than collection start index")
        }
    }
    
}
