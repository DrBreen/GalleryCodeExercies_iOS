//
//  URL+MockUsable.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import RxSwift
import InstantMock

extension Observable: MockUsable {
    
    public static var anyValue: MockUsable {
        return Observable.never()
    }
    
    public func equal(to: MockUsable?) -> Bool {
        guard let o = to as? Observable else {
            return false
        }
        
        return self === o
    }
    
}

extension URL: MockUsable {
    
    public static var anyValue: MockUsable {
        return URL(string: "")!
    }
    
    public func equal(to: MockUsable?) -> Bool {
        guard let url = to as? URL else {
            return false
        }
        
        return url == self
    }
}
