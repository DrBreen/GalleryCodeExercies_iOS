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
}

protocol RouterProtocol {
    func go(to: RouterDestination)
}
