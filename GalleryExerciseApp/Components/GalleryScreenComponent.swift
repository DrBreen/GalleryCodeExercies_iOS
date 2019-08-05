//
//  GalleryScreenComponent.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import Swinject

class GalleryScreenComponent: Component {
    
    var galleryScreenViewController: GalleryScreenViewController {
        return GalleryScreenViewController(galleryScreenPresenter: container.resolve(GalleryScreenPresenter.self)!)
    }
    
}
