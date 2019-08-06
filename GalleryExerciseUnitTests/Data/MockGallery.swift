//
//  MockGallery.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import InstantMock
import RxSwift

class MockGallery: Mock, GalleryProtocol {
    
    var fetchedAll = false
    
    func fetchImages() -> Observable<[GalleryImage]> {
        return super.call()!
    }
    
    func invalidateCache() {
        return super.call()!
    }
    
    
}
