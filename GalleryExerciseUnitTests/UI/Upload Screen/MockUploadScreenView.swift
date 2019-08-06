//
//  MockUploadScreenView.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 06/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import InstantMock
import RxSwift
import RxCocoa

class MockUploadScreenView: Mock, UploadScreenViewProtocol {
    
    func showUploadModePicker() {
        super.call()
    }
    
    func setActivityIndicator(visible: Bool) {
        super.call(visible)
    }
    
    func showImagePicker(mode: UploadMode) {
        super.call(mode)
    }
    
    func show(message: String) {
        super.call(message)
    }
    
    func didPickUploadMode() -> ControlEvent<UploadMode> {
        return super.call()!
    }
    
    func didCancelUpload() -> ControlEvent<Void> {
        return super.call()!
    }
    
    func didPickImageForUpload() -> ControlEvent<PickImageResult> {
        return super.call()!
    }
    
    func didCancelImagePick() -> ControlEvent<Void> {
        return super.call()!
    }
    
    
}
