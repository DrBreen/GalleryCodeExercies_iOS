//
//  NetworkRequestErrorMapper.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 04/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation

protocol NetworkRequestErrorMapper {
    func map(_ error: Error, data: Data?) -> Error
}
