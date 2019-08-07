
//
//  ViewImageScreenComponentAssembl->.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 06/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import Swinject

class ViewImageScreenComponentAssembly: Assembly {

    typealias Assembled = ViewImageScreenComponent
    
    private let container: Container
    
    required init(parent: Container?) {
        self.container = Container(parent: parent)
    }
    
    func assemble() -> ViewImageScreenComponent {
        container.register(ViewImageScreenPresenter.self) { (resolver: Resolver, image: GalleryImage) -> ViewImageScreenPresenter in
            let router = resolver.resolve(RouterProtocol.self)!
            let presenter = ViewImageScreenPresenter(galleryImage: image, router: router)
            return presenter
        }.inObjectScope(.transient)
        
        return ViewImageScreenComponent(parent: container)
    }
    
    
}
