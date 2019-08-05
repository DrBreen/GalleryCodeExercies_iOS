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
//probably we can have some observable that blocks next one until current fetch returns
class Gallery: GalleryProtocol {
    
    private static let defaultThumbnailSize: CGFloat = 100.0
    
    private var storage: [GalleryImage]
    
    private(set) var fetchedAll = false
    
    private let galleryService: GalleryService
    private let thumbnailSize: CGFloat
    
    init(galleryService: GalleryService, thumbnailSize: CGFloat = Gallery.defaultThumbnailSize, prePopulatedStorage: [GalleryImage]? = nil, storageFullyFetched: Bool = false) {
        self.galleryService = galleryService
        self.thumbnailSize = thumbnailSize
        
        var storage = [GalleryImage]()
        if let prePopulatedStorage = prePopulatedStorage {
            storage.append(contentsOf: prePopulatedStorage)
            fetchedAll = storageFullyFetched
        }
        self.storage = storage
    }
    
    func fetchNext(count: Int) -> Observable<[GalleryImage]> {
        return fetchImages(offset: storage.count, count: count)
    }
    
    func fetchImages(offset: Int?, count: Int?) -> Observable<[GalleryImage]> {
        
        //this observable should be only subscribed to after we have some content in storage
        //what it does? It launches image request for every image, updates images and notifies the subscriber on every image download event
        let updatesObservable = Observable.deferred { Observable.just(self.storage) }
            .concatMap { _ in Observable<GalleryImage>.from(self.storage) }
            .filter { $0.image == nil && $0.showPlaceholder == true }
            .flatMap { (galleryImage: GalleryImage) -> Observable<(String?, UIImage?)> in
                //send request to server and transform response to pair of ID/Image so we'll know what image to update
                let id = galleryImage.id
                return self.galleryService.image(id: id).map { img -> (String?, UIImage?) in (id, img) }.catchErrorJustReturn((id, nil))
            }
            .do(onNext: { (id: String?, image: UIImage?) in
                //update placeholders with actual images
                guard let idx = self.storage.firstIndex(where: { $0.id == id }) else {
                    return
                }
                
                self.storage[idx].imageThumbnail = image?.scaled(toWidth: self.thumbnailSize)
                self.storage[idx].showPlaceholder = false
                self.storage[idx].image = image
            })
            .map { _ in self.storage }
        
        if let offset = offset, let count = count {
            
            //let's check if we're fetching cached values
            let fetchingCached = offset + count <= storage.count
            if fetchingCached || fetchedAll {
                let cachedSlice = Array<GalleryImage>(storage[offset..<min(offset + count, storage.count)])
                return Observable<[GalleryImage]>.just(cachedSlice)
            } else {
                let galleryObservable = galleryService
                    .getGallery(offset: offset, count: count)
                    .do(onNext: { galleryListResponse in
                        //create collection to insert to storage
                        var insertedContent = [GalleryImage]()
                        
                        for id in galleryListResponse.imageIds {
                            insertedContent.append(GalleryImage(id: id, imageThumbnail: nil, image: nil, showPlaceholder: true))
                        }
                        
                        if self.storage.count < offset {
                            fatalError("Internal inconsistency - trying to use storage as sparse array; this is not supported, offset can't be larger than your current storage")
                        } else {
                            let actualCount = insertedContent.count
                            
                            if actualCount > 0 {
                                self.storage.extendingReplaceSubrange(offset..<offset + count, with: insertedContent)
                            }
                        }
                        
                        self.fetchedAll = self.storage.count == galleryListResponse.count
                    })
                    .map { _ in self.storage } //this is needed so that we'll return first update with all images as placeholders
                
                //this observable will emit:
                //1) Immediately after fetching of image list - it will emit placeholders
                //2) After every image update
                return galleryObservable.concat(updatesObservable)
            }
        } else {
            //requested the whole gallery
            //if we already reached the end of gallery, let's just return cached value
            //if not, let's first fetch it
            
            if fetchedAll {
                return Observable<[GalleryImage]>.just(storage)
            }
            
            //this observable will fetch gallery and then transform it into models with placeholder images
            let galleryObservable = galleryService
                .getGallery(offset: nil, count: nil)
                .do(onNext: { galleryListResponse in
                    self.fetchedAll = true
                    
                    self.storage = []
                    
                    for id in galleryListResponse.imageIds {
                        self.storage.append(GalleryImage(id: id, imageThumbnail: nil, image: nil, showPlaceholder: true))
                    }
                })
                .map { _ in self.storage  } //this is needed so that we'll return first update with all images as placeholders
            
            //this observable will emit:
            //1) Immediately after fetching of image list - it will emit placeholders
            //2) After every image update
            return galleryObservable.concat(updatesObservable)
        }
    }
    
    func clear() {
        fetchedAll = false
        storage = []
    }
    
    func invalidateFetchedStatus() {
        fetchedAll = false
    }
}

