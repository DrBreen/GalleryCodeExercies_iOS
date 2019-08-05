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

//TODO: add upload for named image
protocol GalleryService {
    func getGallery(offset: Int?, count: Int?) -> Observable<GalleryListResponse>
    func upload(data: Data) -> Observable<GalleryServiceUploadResponse>
    func image(id: String) -> Observable<UIImage>
}