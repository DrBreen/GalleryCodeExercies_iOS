//
//  Router.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import UIKit

//TODO: add test for galleryId -> galleryId
//TODO: add test for galleryId -> viewImageId
//TODO: add test for galleryId -> uploadId
//TODO: add test for galleryId -> any other ID

//TODO: add test for editImageId -> galleryId
//TODO: add test for editImageId -> viewImageId
//TODO: add test for editImageId -> any other ID

//TODO: add test for uploadId -> galleryId
//TODO: add test for uploadId -> any other ID

//TODO: add test for viewImageId -> editImageId
//TODO: add test for viewImageId -> galleryId
//TODO: add test for viewImageId -> any other ID
class Router: RouterProtocol {
    
    private static let dummyImage = GalleryImage(id: "", imageThumbnail: nil, image: nil, showPlaceholder: true)
    
    var validRoutes: [RouterDestination.Id : [RouterDestination.Id]] = [
        RouterDestination.galleryId: [
            RouterDestination.galleryId,
            RouterDestination.viewImageId,
            RouterDestination.uploadId
        ],
        
        RouterDestination.uploadId: [
            RouterDestination.galleryId
        ],
        
        RouterDestination.viewImageId: [
            RouterDestination.galleryId
        ]
        
    ]
    
    private let navigationController: UINavigationController
    private let galleryScreenFactory: GalleryScreenFactory
    private let uploadScreenFactory: UploadScreenFactory
    
    private var currentLocation: RouterDestination!
    
    init(navigationController: UINavigationController,
         galleryScreenFactory: GalleryScreenFactory,
         uploadScreenFactory: UploadScreenFactory) {
        self.navigationController = navigationController
        self.uploadScreenFactory = uploadScreenFactory
        self.galleryScreenFactory = galleryScreenFactory
    }
    
    func go(to destination: RouterDestination) {
        
        if let currentLocation = currentLocation {
            if !validRoutes[currentLocation.id]!.contains(destination.id) {
                fatalError("Route \(currentLocation.id) -> \(destination.id) is not valid")
            }
        }
        
        switch destination {
        case .gallery:
            goToGallery()
        case .upload:
            goToUpload()
        case .viewImage(let image):
            //TODO: implement
            fatalError("NOT IMPLEMENTED")
        }
        
        currentLocation = destination
    }
    
    private func goToGallery() {
        
        let presentedController = navigationController.visibleViewController
        
        var presentingController = presentedController?.presentingViewController
        while presentingController != nil  {
            presentingController?.dismiss(animated: true, completion: nil)
            presentingController = presentingController?.presentingViewController
        }
        
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
    
    private func goToUpload() {
        let controller = uploadScreenFactory.uploadScreenViewController
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.navigationController.visibleViewController?.present(controller, animated: true, completion: nil)
    }
    
}
