//
//  GalleryService.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol GalleryService {
    func getGallery() -> Observable<GalleryListResponse>
    func upload(image: UIImage, name: String?) -> Observable<GalleryServiceUploadResponse>
    func image(id: String) -> Observable<UIImage>
}
