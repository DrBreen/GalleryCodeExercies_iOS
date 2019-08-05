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
    private let galleryScreenFactory: GalleryScreenFactory
    private let uploadScreenFactory: UploadScreenFactory
    
    init(navigationController: UINavigationController,
         galleryScreenFactory: GalleryScreenFactory,
         uploadScreenFactory: UploadScreenFactory) {
        self.navigationController = navigationController
        self.uploadScreenFactory = uploadScreenFactory
        self.galleryScreenFactory = galleryScreenFactory
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
        
        let openGallery = {
            
            if self.navigationController.viewControllers.count == 0 {
                let controller = self.galleryScreenFactory.galleryScreenViewController
                self.navigationController.setViewControllers([controller], animated: true)
            } else {
                
                let controllersCountToRemove = self.navigationController.viewControllers.count - 1
                var newViewControllers = self.navigationController.viewControllers
                newViewControllers.removeLast(controllersCountToRemove)
                
                self.navigationController.setViewControllers(newViewControllers, animated: true)
            }
            
            
        }
        
        if let presentedController = navigationController.topViewController?.presentedViewController {
            presentedController.dismiss(animated: true, completion: openGallery)
        } else {
            openGallery()
        }
        
    }
    
    private func goToUpload() {
        let controller = uploadScreenFactory.uploadScreenViewController
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.navigationController.visibleViewController?.present(controller, animated: true, completion: nil)
    }
    
}
