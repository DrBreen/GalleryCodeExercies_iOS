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
    
    private static let maximumImageSize: CGFloat = 1024.0
    
    private static let galleryPath = "gallery"
    private static let commentsPath = "comments"
    
    private let networkRequestSender: NetworkRequestSender
    private let galleryServiceURL: URL
    
    init(galleryServiceURL: URL, networkRequestSender: NetworkRequestSender) {
        self.networkRequestSender = networkRequestSender
        self.galleryServiceURL = galleryServiceURL
    }
    
    private func url(path: String...) -> URL {
        return URL(string: path.joined(separator: "/"), relativeTo: galleryServiceURL)!.absoluteURL
    }
    
    func getGallery() -> Observable<GalleryListResponse> {
        return networkRequestSender
            .getData(url: url(path: DefaultGalleryService.galleryPath), query: nil, headers: nil)
            .map { response in
                let decoder = JSONDecoder()
                return try decoder.decode(GalleryListResponse.self, from: response)
            }
    }
    
    func addComment(name: String, comment: String?) -> Single<Void> {
        return networkRequestSender.put(url: url(path: DefaultGalleryService.commentsPath, name), body: [
            "comment" : comment ?? ""
            ], headers: nil).map { _ in () }
    }
    
    func upload(image: UIImage, name: String?) -> Observable<GalleryServiceUploadResponse> {
        
        var sentImage = image
        
        let requestUrl: URL
        if let name = name {
            requestUrl = url(path: DefaultGalleryService.galleryPath, name)
        } else {
            requestUrl = url(path: DefaultGalleryService.galleryPath)
        }
        
        if image.size.width > DefaultGalleryService.maximumImageSize {
            sentImage = image.scaled(toWidth: DefaultGalleryService.maximumImageSize)
        }
        
        if image.size.height > DefaultGalleryService.maximumImageSize {
            sentImage = image.scaled(toHeight: DefaultGalleryService.maximumImageSize)
        }
        
        guard let imageData = sentImage.pngData() else {
            return Observable.error(GeneralError(text: "Invalid image, please select another one".localized))
        }
        
        let multipartImageData = MultipartFormDataDescription(filename: "img", data: imageData, mimetype: "image/png")
        
        return networkRequestSender
            .upload(url: requestUrl, body: ["image" : multipartImageData], headers: nil)
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
