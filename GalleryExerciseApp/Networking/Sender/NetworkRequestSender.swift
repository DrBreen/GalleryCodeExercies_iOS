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
    
    var errorMapper: NetworkRequestErrorMapper? { get set }
    
    func get(url: URL,
        query: [String: Any]?,
        headers: [String: String]?) -> Observable<Any>
    
    func getData(url: URL,
             query: [String: Any]?,
             headers: [String: String]?) -> Observable<Data>
    
    func upload(url: URL,
              body: Data,
              headers: [String: String]?) -> Observable<Any>
    
}
