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

// MARK: Data
extension Data: MockUsable {
    
    public static var anyValue: MockUsable {
        return Data()
    }
    
    public func equal(to: MockUsable?) -> Bool {
        guard let data = to as? Data else {
            return false
        }
        
        return self == data
    }

}

// MARK: Observable
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

// MARK: URL
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
