//
//  Gallery.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import RxSwift

class Gallery: GalleryProtocol {
    
    private var storage: [GalleryImage]
    private(set) var fetchedAll = false
    
    private let galleryService: GalleryService
    
    init(galleryService: GalleryService, prePopulatedStorage: [GalleryImage]? = nil, storageFullyFetched: Bool = false) {
        self.galleryService = galleryService
        
        var storage = [GalleryImage]()
        if let prePopulatedStorage = prePopulatedStorage {
            storage.append(contentsOf: prePopulatedStorage)
            fetchedAll = storageFullyFetched
        }
        self.storage = storage
    }
    
    func fetchImages(offset: Int?, count: Int?) -> Observable<[GalleryImage]> {
        if let offset = offset, let count = count {
            
            //let's check if we're fetching cached values
            let fetchingCached = offset + count <= storage.count
            if fetchingCached {
                let cachedSlice = Array<GalleryImage>(storage[offset..<offset + count])
                return Observable<[GalleryImage]>.just(cachedSlice)
            } else {
                //TODO: implement
                return Observable.never()
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
                .do(onNext: { [weak self] ids in
                    self?.fetchedAll = true
                    
                    for id in ids {
                        self?.storage.append(GalleryImage(id: id, image: nil, showPlaceholder: true))
                    }
                })
                .map { [weak self] _ in self?.storage ?? [] } //this is needed so that we'll return first update with all images as placeholders
            
            let updatesObservable = Observable.deferred { [weak self] in Observable.just(self?.storage ?? []) }
                .concatMap { [weak self] _ in Observable<GalleryImage>.from(self?.storage ?? []) }
                .flatMap { [weak self] (galleryImage: GalleryImage) -> Observable<(String, UIImage?)> in
                    guard let strongSelf = self else {
                        //this object is dead, it doesn't matter anymore
                        return Observable<(String, UIImage?)>.never()
                    }
                    
                    //send request to server and transform response to pair of ID/Image so we'll know what image to update
                    let id = galleryImage.id
                    return strongSelf.galleryService.image(id: id).map { img -> (String, UIImage?) in (id, img) }.catchErrorJustReturn((id, nil))
                }
                .do(onNext: { [weak self] (id: String, image: UIImage?) in
                    //update placeholders with actual images
                    guard let idx = self?.storage.firstIndex(where: { $0.id == id }) else {
                        return
                    }
                    
                    self?.storage[idx].showPlaceholder = false
                    self?.storage[idx].image = image
                })
                .map { _ in self.storage }
            
            //this observable will emit:
            //1) Immediately after fetching of image list - it will emit placeholders
            //2) After every image update
            return galleryObservable.concat(updatesObservable)
        }
    }
}


