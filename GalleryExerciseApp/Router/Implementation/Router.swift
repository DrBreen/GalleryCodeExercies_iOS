//
//  Router.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class Router: RouterProtocol {
    
    private static let dummyImage = GalleryImage(id: "", imageThumbnail: nil, image: nil, showPlaceholder: true, comment: nil)
    
    var validRoutes: [RouterDestination.Id : [RouterDestination.Id]] = [
        RouterDestination.galleryId: [
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
    private let viewImageScreenFactory: ViewImageScreenFactory
    
    private let didGoToRelay = PublishRelay<RouterDestination>()
    private(set) var currentLocation: RouterDestination? {
        didSet {
            guard let currentLocation = currentLocation else {
                return
            }
            
            didGoToRelay.accept(currentLocation)
        }
    }
    
    init(navigationController: UINavigationController,
         galleryScreenFactory: GalleryScreenFactory,
         uploadScreenFactory: UploadScreenFactory,
         viewImageScreenFactory: ViewImageScreenFactory) {
        self.navigationController = navigationController
        self.uploadScreenFactory = uploadScreenFactory
        self.galleryScreenFactory = galleryScreenFactory
        self.viewImageScreenFactory = viewImageScreenFactory
    }
    
    @discardableResult
    func go(to destination: RouterDestination, animated: Bool) -> Bool {
        
        if let currentLocation = currentLocation {
            if !validRoutes[currentLocation.id]!.contains(destination.id) {
                return false
            }
        }
        
        switch destination {
        case .gallery:
            goToGallery(animated: animated)
        case .upload:
            goToUpload(animated: animated)
        case .viewImage(let image):
            goToViewImage(image: image, animated: animated)
        }
        
        currentLocation = destination
        
        return true
    }
    
    func didGoTo() -> Observable<RouterDestination> {
        return didGoToRelay.asObservable()
    }
    
    private func goToGallery(animated: Bool) {
        
        let presentedController = navigationController.visibleViewController
        
        var presentingController = presentedController?.presentingViewController
        while presentingController != nil  {
            presentingController?.dismiss(animated: true, completion: nil)
            presentingController = presentingController?.presentingViewController
        }
        
        if self.navigationController.viewControllers.count == 0 {
            let controller = self.galleryScreenFactory.galleryScreenViewController
            self.navigationController.setViewControllers([controller], animated: animated)
        } else {
            let controllersCountToRemove = self.navigationController.viewControllers.count - 1
            var newViewControllers = self.navigationController.viewControllers
            newViewControllers.removeLast(controllersCountToRemove)
            
            self.navigationController.setViewControllers(newViewControllers, animated: animated)
        }
        
    }
    
    private func goToUpload(animated: Bool) {
        let controller = uploadScreenFactory.uploadScreenViewController
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.navigationController.topViewController?.present(controller, animated: animated, completion: nil)
    }
    
    private func goToViewImage(image: GalleryImage, animated: Bool) {
        let controller = viewImageScreenFactory.viewImageScreenViewController(image: image)
        self.navigationController.pushViewController(controller, animated: animated)
    }
    
}
