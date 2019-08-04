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
    
    func getGallery(offset: Int?, count: Int?) -> Observable<GalleryListResponse> {
        
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
            .getData(url: url(path: DefaultGalleryService.galleryPath), query: query, headers: nil)
            .map { response in
                let decoder = JSONDecoder()
                return (try? decoder.decode(GalleryListResponse.self, from: response)) ?? GalleryListResponse(count: 0, imageIds: [])
            }
    }
    
    func upload(data: Data) -> Observable<GalleryServiceUploadResponse> {
        return networkRequestSender
            .upload(url: url(path: DefaultGalleryService.galleryPath), body: data, headers: nil)
            .map { data in
                
                guard let dict = data as? [AnyHashable : Any] else {
                    throw NSError(domain: "DefaultGalleryService.upload",
                                  code: 1,
                                  userInfo: [NSLocalizedDescriptionKey : "Failed to convert server response to dictionary"])
                }
                
                guard let rawData = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
                    throw NSError(domain: "DefaultGalleryService.upload",
                                  code: 1,
                                  userInfo: [NSLocalizedDescriptionKey : "Failed to convert dictionary to data"])
                }
                
                let decoder = JSONDecoder()
                guard let response = try? decoder.decode(GalleryServiceUploadResponse.self, from: rawData) else {
                    throw NSError(domain: "DefaultGalleryService.upload",
                                  code: 1,
                                  userInfo: [NSLocalizedDescriptionKey : "Failed to convert data to image"])
                }
                
                return response
            }
    }
    
    func image(id: String) -> Observable<UIImage> {
        return networkRequestSender
            .getData(url: url(path: DefaultGalleryService.galleryPath, id), query: nil, headers: nil)
            .map { data in
                guard let image = UIImage(data: data) else {
                    throw NSError(domain: "DefaultGalleryService",
                                  code: 1,
                                  userInfo: [NSLocalizedDescriptionKey : "Failed to convert data to image"])
                }
                
                return image
        }
    }
    
    
}
