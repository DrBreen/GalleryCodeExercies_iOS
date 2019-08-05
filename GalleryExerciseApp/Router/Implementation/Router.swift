//
//  Router.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import UIKit

class Router: RouterProtocol {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func go(to destination: RouterDestination) {
        switch destination {
        case .gallery:
            goToGallery()
        case .upload:
            goToUpload()
        case .viewImage(let image):
            //TODO: implement
            fatalError("NOT IMPLEMENTED")
        case .editImage(let image):
            //TODO: implement
            fatalError("NOT IMPLEMENTED")
        }
    }
    
    private func goToGallery() {
        let controller = RootComponent.rootComponent.galleryScreenComponent.galleryScreenViewController
        navigationController.setViewControllers([controller], animated: true)
    }
    
    private func goToUpload() {
        
    }
    
}
