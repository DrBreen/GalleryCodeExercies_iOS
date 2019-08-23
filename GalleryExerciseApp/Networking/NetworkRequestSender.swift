//
//  File.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import RxSwift

struct MultipartFormDataDescription {
    let filename: String
    let data: Data
    let mimetype: String
}

protocol NetworkRequestSender {
    
    var errorMapper: NetworkRequestErrorMapper? { get set }
    
    func getData(url: URL,
                 query: [String: Any]?,
                 headers: [String: String]?) -> Observable<Data>
    
    func upload(url: URL,
                body: [String : MultipartFormDataDescription],
                headers: [String: String]?) -> Observable<Any>
    
    func put(url: URL, body: [String : Any], headers: [String: String]?) -> Single<Any>
    
}
