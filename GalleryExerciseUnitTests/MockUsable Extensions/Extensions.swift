//
//  URL+MockUsable.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import InstantMock

// MARK: Single
extension Single: MockUsable {
    
    public static var anyValue: MockUsable {
        return Single<Element>.never()
    }
    
    public func equal(to: MockUsable?) -> Bool {
        return false
    }
}

// MARK: GalleryImage
extension GalleryImage: MockUsable {
    
    static var anyValue: MockUsable {
        return GalleryImage(id: "", imageThumbnail: nil, image: nil, showPlaceholder: false)
    }
    
    func equal(to: MockUsable?) -> Bool {
        guard let image = to as? GalleryImage else {
            return false
        }
        
        return image.id == id
    }
    
    
}


// MARK: UIViewController
extension UIViewController: MockUsable {
    public static var anyValue: MockUsable {
        return UIViewController(nibName: nil, bundle: nil)
    }
    
    public func equal(to: MockUsable?) -> Bool {
        return false
    }
}

// MARK: UIImage
extension UIImage: MockUsable {
    
    public static var anyValue: MockUsable {
        return UIImage()
    }
    
    public func equal(to: MockUsable?) -> Bool {
        return false
    }
    
    
    
    
}

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

// MARK: GalleryScreenLoadingMode
extension GalleryScreenLoadingMode: MockUsable {
    
    static var anyValue: MockUsable {
        return GalleryScreenLoadingMode.none
    }
    
    func equal(to: MockUsable?) -> Bool {
        guard let mode = to as? GalleryScreenLoadingMode else {
            return false
        }
        
        return self == mode
    }
}

extension RouterDestination: MockUsable {
    
    static var anyValue: MockUsable {
        return RouterDestination.gallery
    }
    
    func equal(to: MockUsable?) -> Bool {
        guard let destination = to as? RouterDestination else {
            return false
        }
        
        return destination.id == self.id
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

// MARK: ControlEvent
extension ControlEvent: MockUsable {
    
    public static var anyValue: MockUsable {
        return ControlEvent(events: Observable.never())
    }
    
    public func equal(to: MockUsable?) -> Bool {
        return false
    }
    
}

// MARK: URL
extension URL: MockUsable {
    
    public static var anyValue: MockUsable {
        return URL(string: "http://any.com")!
    }
    
    public func equal(to: MockUsable?) -> Bool {
        guard let url = to as? URL else {
            return false
        }
        
        return url == self
    }
}
