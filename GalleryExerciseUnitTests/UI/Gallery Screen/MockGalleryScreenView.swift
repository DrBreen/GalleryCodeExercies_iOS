//
//  MockGalleryScreenView.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import InstantMock
import RxSwift
import RxCocoa

class MockGalleryScreenView: Mock, GalleryScreenViewProtocol {
    
    func set(pictures: [GalleryImage]) {
        super.call(pictures)
    }
    
    func show(loadingMode: GalleryScreenLoadingMode) {
        super.call(loadingMode)
    }
    
    func show(error: String) {
        super.call(error)
    }
    
    func reachedScreenBottom() -> ControlEvent<Void> {
        return super.call()!
    }
    
    func didTapUploadImage() -> ControlEvent<Void> {
        return super.call()!
    }
    
    func didTapImage() -> ControlEvent<GalleryImage> {
        return super.call()!
    }
    
    
}
