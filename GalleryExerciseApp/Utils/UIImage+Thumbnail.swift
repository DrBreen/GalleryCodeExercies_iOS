//
//  UIImage+Thumbnail.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import UIKit

extension UIImage {
    
    func scaled(toWidth newWidth: CGFloat) -> UIImage {
        let oldWidth = self.size.width
        let scaleFactor = newWidth / oldWidth
        
        let newHeight = self.size.height * scaleFactor
        let rect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        UIGraphicsBeginImageContext(rect.size)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
