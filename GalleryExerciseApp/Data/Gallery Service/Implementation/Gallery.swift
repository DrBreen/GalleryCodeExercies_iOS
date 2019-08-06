//
//  Gallery.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import RxSwift


//TODO: find a solution to potential race condition problems
//TODO: add id->image cache with expiration time
//TODO: add test for id->image cache
//probably we can have some observable that blocks next one until current fetch returns
class Gallery: GalleryProtocol {
    
    private let computationsScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    private static let defaultThumbnailSize: CGFloat = 100.0
    
    private var cacheValid = false
    private var cache = [GalleryImage]()
    
    private let galleryService: GalleryService
    private let thumbnailSize: CGFloat
    
    init(galleryService: GalleryService, thumbnailSize: CGFloat = Gallery.defaultThumbnailSize, cacheContent: [GalleryImage]? = nil) {
        self.galleryService = galleryService
        self.thumbnailSize = thumbnailSize
        
        if let cacheContent = cacheContent {
            cacheValid = true
            cache = cacheContent
        }
    }
    
    func fetchImages() -> Observable<[GalleryImage]> {
        
        //this observable should be only subscribed to after we have some content in cache
        //what does it do? It launches image request for every image, updates images and notifies the subscriber on every image download event
        let updatesObservable = Observable.deferred { Observable.just(self.cache) }
            .concatMap { _ in Observable<GalleryImage>.from(self.cache) }
            .filter { $0.image == nil && $0.showPlaceholder == true }
            .flatMap { (galleryImage: GalleryImage) -> Observable<(String?, UIImage?)> in
                //send request to server and transform response to pair of ID/Image so we'll know what image to update
                let id = galleryImage.id
                return self.galleryService.image(id: id).map { img -> (String?, UIImage?) in (id, img) }.catchErrorJustReturn((id, nil))
            }
            .observeOn(computationsScheduler)
            .do(onNext: { (id: String?, image: UIImage?) in
                //update placeholders with actual images
                guard let idx = self.cache.firstIndex(where: { $0.id == id }) else {
                    return
                }
                
                self.cache[idx].imageThumbnail = image?.scaled(toWidth: self.thumbnailSize)
                self.cache[idx].showPlaceholder = false
                self.cache[idx].image = image
            })
            .map { _ in self.cache }
        
        //requested the whole gallery
        //if we already reached the end of gallery, let's just return cached value
        //if not, let's first fetch it
        
        if cacheValid {
            return Observable<[GalleryImage]>.just(cache)
        }
        
        //this observable will fetch gallery and then transform it into models with placeholder images
        let galleryObservable = galleryService
            .getGallery()
            .do(onNext: { galleryListResponse in
                self.cache = []
                
                for id in galleryListResponse.imageIds {
                    self.cache.append(GalleryImage(id: id, imageThumbnail: nil, image: nil, showPlaceholder: true))
                }
            })
            .map { _ in self.cache  } //this is needed so that we'll return first update with all images as placeholders
        
        //this observable will emit:
        //1) Immediately after fetching of image list - it will emit placeholders
        //2) After every image update
        return galleryObservable.concat(updatesObservable)
    }
    
    func invalidateCache() {
        cacheValid = false
    }
}


