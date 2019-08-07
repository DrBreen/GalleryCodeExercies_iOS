//
//  ViewImageScreenFactory.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 06/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import UIKit

protocol ViewImageScreenFactory {
    
    func viewImageScreenViewController(image: GalleryImage) -> UIViewController
    
}
