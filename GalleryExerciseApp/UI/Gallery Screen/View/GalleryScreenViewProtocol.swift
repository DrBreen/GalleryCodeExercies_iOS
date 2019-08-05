//
//  GalleryScreenViewProtocol.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum GalleryScreenLoadingMode {
    case none
    case newPictures
    case initialLoading
}

protocol GalleryScreenViewProtocol: class {
    
    //MARK: Commands
    
    ///update pictures with provided ones
    func set(pictures: [GalleryImage])
    
    ///set visibility for loading indicator
    func show(loadingMode: GalleryScreenLoadingMode)
    
    ///show error
    func show(error: String)
    
    //MARK: Events
    
    ///reached bottom part of screen - maybe we need to load additional images
    func reachedScreenBottom() -> ControlEvent<Void>
    
    ///did tap upload image button
    func didTapUploadImage() -> ControlEvent<Void>
    
    ///did tap image
    func didTapImage() -> ControlEvent<GalleryImage>
}
