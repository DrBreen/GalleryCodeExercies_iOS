//
//  Component.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Swinject

class Component {
    
    let container: Container
    
    init(parent: Container? = nil) {
        self.container = Container(parent: parent)
    }
    
}
