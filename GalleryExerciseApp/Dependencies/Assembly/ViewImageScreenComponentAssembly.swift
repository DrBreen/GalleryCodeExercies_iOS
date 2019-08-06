
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
        container.register(ViewImageScreenPresenter.self) { _ in
            ViewImageScreenPresenter()
        }
        
        return ViewImageScreenComponent(parent: container)
    }
    
    
}
