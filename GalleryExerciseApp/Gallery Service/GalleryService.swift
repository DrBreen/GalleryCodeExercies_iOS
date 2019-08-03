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
    func getGallery(offset: Int?, count: Int?) -> Observable<[String]>
    func upload(data: Data, mimeType: String) -> Observable<GallertServiceUploadResponse>
    func image(id: String) -> Observable<UIImage>
}
