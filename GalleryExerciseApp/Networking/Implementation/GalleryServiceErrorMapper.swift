//
//  GalleryServiceErrorMapper.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation

class GalleryServiceErrorMapper: NetworkRequestErrorMapper {
    
    func map(_ error: Error, data: Data?) -> Error {
        guard let data = data else {
            return error
        }
        
        let jsonDecoder = JSONDecoder()
        guard let galleryServiceError = try? jsonDecoder.decode(GalleryServiceError.self, from: data) else {
            return error
        }
        
        return galleryServiceError
    }
    
}
