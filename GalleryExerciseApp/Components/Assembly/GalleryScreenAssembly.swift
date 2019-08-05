//
//  GalleryScreenAssembly.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import Swinject

class GalleryScreenAssembly: Assembly {
    
    typealias Assembled = GalleryScreenComponent
    
    private let container: Container
    
    required init(parent: Container?) {
        self.container = Container(parent: parent)
    }
    
    func assemble() -> GalleryScreenComponent {
        container.register(GalleryScreenPresenter.self, factory: { resolver in
            
            let router = resolver.resolve(RouterProtocol.self)!
            let gallery = resolver.resolve(GalleryProtocol.self)!
            
            return GalleryScreenPresenter(gallery: gallery, router: router)
        }).inObjectScope(.transient)
        
        return GalleryScreenComponent(parent: container)
    }
    
}
