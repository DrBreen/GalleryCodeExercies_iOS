//
//  UploadScreenViewProtocol.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum UploadMode {
    case takePhoto
    case pickFromGallery
}

protocol UploadScreenViewProtocol: class {

    /// MARK: Commands
    
    ///show picker for upload mode
    func showUploadModePicker()
    
    ///show activity indicator
    func setActivityIndicator(visible: Bool)
    
    ///show "Take photo" view
    func showImagePicker(mode: UploadMode)
    
    ///show a message
    func show(message: String)
    
    /// MARK: Events
    
    ///user selected upload mode
    func didPickUploadMode() -> ControlEvent<UploadMode>
    
    ///user cancelled upload
    func didCancelUpload() -> ControlEvent<Void>
    
    ///user selected image
    func didPickImageForUpload() -> Observable<UIImage>
    
    ///user cancelled image picking
    func didCancelImagePick() -> ControlEvent<Void>
    
}
