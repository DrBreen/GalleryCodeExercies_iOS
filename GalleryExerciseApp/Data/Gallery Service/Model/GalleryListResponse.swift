//
//  GalleryListResponse.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 04/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation

struct GalleryListResponse: Codable {
    let count: Int
    let imageIds: [String]
    let comments: [String : String]
}

extension GalleryListResponse: Equatable {}
