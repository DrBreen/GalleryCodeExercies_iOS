//
//  RootComponent+Global.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import UIKit

extension RootComponent {
    
    static var rootComponent: RootComponent {
        return (UIApplication.shared.delegate as! AppDelegate).rootComponent
    }
    
}

