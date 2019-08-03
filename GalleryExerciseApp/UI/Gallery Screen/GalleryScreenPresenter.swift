//
//  GalleryScreenPresenter.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation

class GalleryScreenPresenter {
    
    private let gallery: GalleryProtocol
    private var galleryScreenView: GalleryScreenViewProtocol?
    
    init(gallery: GalleryProtocol) {
        self.gallery = gallery
    }
    
    func attach(view: GalleryScreenViewProtocol) {
        galleryScreenView = view
        
        didAttachView()
    }
    
    private func didAttachView() {
        //
    }
    
}
