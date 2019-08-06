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
        return GalleryScreenComponentAssembly(parent: container).assemble()
    }
    
    var uploadScreenComponent: UploadScreenComponent {
        return UploadScreenComponentAssembly(parent: container).assemble()
    }
    
    var viewImageScreenComponent: ViewImageScreenComponent {
        return ViewImageScreenComponentAssembly(parent: container).assemble()
    }
    
    var router: RouterProtocol {
        return container.resolve(RouterProtocol.self)!
    }
    
}
