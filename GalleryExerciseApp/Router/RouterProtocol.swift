//
//  RouterProtocol.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation

enum RouterDestination {
    case gallery
    case upload
    case viewImage(image: GalleryImage)
    case editImage(image: GalleryImage)
}

protocol RouterProtocol {
    func go(to: RouterDestination)
}
