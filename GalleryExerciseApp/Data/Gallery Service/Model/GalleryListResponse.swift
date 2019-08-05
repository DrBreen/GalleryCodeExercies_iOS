//
//  GalleryListResponse.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 04/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation

struct GalleryListResponse: Codable, Equatable {
    
    static func == (lhs: GalleryListResponse, rhs: GalleryListResponse) -> Bool {
        return lhs.count == rhs.count && lhs.imageIds == rhs.imageIds
    }
    
    let count: Int
    let imageIds: [String]
}
