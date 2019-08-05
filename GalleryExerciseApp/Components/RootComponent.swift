//
//  RootComponent.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation

class RootComponent: Component {
    
    var galleryScreenComponent: GalleryScreenComponent {
        return GalleryScreenAssembly(parent: container).assemble()
    }
    
    var router: RouterProtocol {
        return container.resolve(RouterProtocol.self)!
    }
    
}
