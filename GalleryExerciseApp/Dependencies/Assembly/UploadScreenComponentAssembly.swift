//
//  UploadScreenComponentAssembly.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import Swinject

class UploadScreenComponentAssembly: Assembly {
    
    typealias Assembled = UploadScreenComponent
    
    private let container: Container
    
    required init(parent: Container?) {
        self.container = Container(parent: parent)
    }
    
    func assemble() -> UploadScreenComponent {
        
        container.register(UploadScreenPresenter.self) { resolver in
            let gallery = resolver.resolve(GalleryProtocol.self)!
            let router = resolver.resolve(RouterProtocol.self)!
            let galleryService = resolver.resolve(GalleryService.self)!
            
            return UploadScreenPresenter(galleryService: galleryService, gallery: gallery, router: router)
        }.inObjectScope(.transient)
        
        return UploadScreenComponent(parent: container)
    }
    
}
