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
    
    func fetchImages(offset: Int?, count: Int?) -> Observable<[GalleryImage]> {
        return super.call(offset, count)!
    }
    
    func fetchNext(count: Int) -> Observable<[GalleryImage]> {
        return super.call(count)!
    }
    
    func clear() {
        fetchedAll = false
    }
    
    func invalidateFetchedStatus() {
        fetchedAll = true
    }
    
    
}
