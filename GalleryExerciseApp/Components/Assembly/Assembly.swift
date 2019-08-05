//
//  Assembly.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Swinject

protocol Assembly {
    
    associatedtype Assembled where Assembled: Component
    
    init(parent: Container?)
    
    func assemble() -> Assembled
}
