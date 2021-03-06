//
//  GalleryScreenPictureModel.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import UIKit
import DeepDiff

struct GalleryImage: DiffAware {
    
    typealias DiffId = String
    
    let id: String
    var imageThumbnail: UIImage?
    var image: UIImage?
    var showPlaceholder: Bool
    var comment: String?
    
    var diffId: GalleryImage.DiffId {
        return id
    }
    
    static func compareContent(_ a: GalleryImage, _ b: GalleryImage) -> Bool {
        if a.id != b.id {
            return false
        }
        
        //lightweight image comparison, we don't want to bother with actual image content comparison
        if a.image !== b.image {
            return false
        }
        
        if a.showPlaceholder != b.showPlaceholder {
            return false
        }
        
        return true
    }
}

extension GalleryImage {
    
    init(id: String,
    imageThumbnail: UIImage?,
    image: UIImage?,
        showPlaceholder: Bool) {
        self.init(id: id, imageThumbnail: imageThumbnail, image: image, showPlaceholder: showPlaceholder, comment: nil)
    }
    
}
