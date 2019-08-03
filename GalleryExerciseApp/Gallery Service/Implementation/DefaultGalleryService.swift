//
//  DefaultGalleryService.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import RxSwift

class DefaultGalleryService: GalleryService {
    
    private static let galleryPath = "gallery"
    
    private let networkRequestSender: NetworkRequestSender
    private let galleryServiceURL: URL
    
    init(galleryServiceURL: URL, networkRequestSender: NetworkRequestSender) {
        self.networkRequestSender = networkRequestSender
        self.galleryServiceURL = galleryServiceURL
    }
    
    private func url(path: String...) -> URL {
        return URL(string: path.joined(separator: "/"), relativeTo: galleryServiceURL)!.absoluteURL
    }
    
    func getGallery(offset: Int?, count: Int?) -> Observable<[String]> {
        
        let query: [String : Any]?
        if let count = count, let offset = offset {
            query = [
                "count" : count,
                "offset" : offset
            ]
        } else {
            query = nil
        }
        
        return networkRequestSender
            .get(url: url(path: DefaultGalleryService.galleryPath), query: query, headers: nil)
            .map { response in response as? [String] ?? [] }
    }
    
    func upload(data: Data, mimeType: String) -> Observable<GallertServiceUploadResponse> {
        return Observable.never()
    }
    
    func image(id: String) -> Observable<UIImage> {
        return networkRequestSender
            .get(url: url(path: DefaultGalleryService.galleryPath, id), query: nil, headers: nil)
            .map { data in
                guard let data = data as? Data, let image = UIImage(data: data) else {
                    throw NSError(domain: "DefaultGalleryService", code: 1, userInfo: nil)
                }
                
                return image
        }
    }
    
    
}
