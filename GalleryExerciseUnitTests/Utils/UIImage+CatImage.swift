//
//  UIImage+CatImage.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import UIKit

extension UIImage {
    
    static var catImage: UIImage {
        return UIImage(named: "cat", in: Bundle(for: MockRouter.self), compatibleWith: nil)!
    }
    
    static var catImageThumbnail: UIImage {
        return UIImage.catImage.scaled(toWidth: 10.0)
    }
    
}
