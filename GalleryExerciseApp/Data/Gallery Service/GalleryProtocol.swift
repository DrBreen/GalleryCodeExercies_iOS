//
//  GalleryProtocol.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import RxSwift

protocol GalleryProtocol {
    
    //fetch images. Will send gallery update on every change, such as "got response from server", "loaded image"
    func fetchImages() -> Observable<[GalleryImage]>
    
    func invalidateCache()
    
}
