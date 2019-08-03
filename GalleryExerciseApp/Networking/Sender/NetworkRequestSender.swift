//
//  File.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import RxSwift

protocol NetworkRequestSender {
    
    func get(url: URL,
        query: [String: Any]?,
        headers: [String: String]?) -> Observable<Any>
    
}
