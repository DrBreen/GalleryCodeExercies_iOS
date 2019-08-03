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
    func fetchImages(offset: Int?, count: Int?) -> Observable<[GalleryImage]>
}
