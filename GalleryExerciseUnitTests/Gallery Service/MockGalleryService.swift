//
//  MockGalleryService.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 06/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import InstantMock
import RxSwift
import RxCocoa

class MockGalleryService: Mock, GalleryService {
    
    func getGallery() -> Observable<GalleryListResponse> {
        return super.call()!
    }
    
    func upload(image: UIImage, name: String?) -> Observable<GalleryServiceUploadResponse> {
        return super.call(image, name)!
    }
    
    func addComment(name: String, comment: String?) -> Single<Void> {
        return super.call(name, comment)!
    }
    
    func image(id: String) -> Observable<UIImage> {
        return super.call(id)!
    }
    
    
}
