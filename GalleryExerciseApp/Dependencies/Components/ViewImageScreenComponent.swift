//
//  ViewImageScreenComponent.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 06/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import Swinject

class ViewImageScreenComponent: Component, ViewImageScreenFactory {
    
    func viewImageScreenViewController(image: GalleryImage) -> UIViewController {
        let presenter = container.resolve(ViewImageScreenPresenter.self, argument: image)!
        return ViewImageViewController(viewImageScreenPresenter: presenter)
    }
    
}
