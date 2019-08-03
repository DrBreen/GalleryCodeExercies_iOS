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
    
    private var storage = [GalleryImage]()
    private var fetchedAll = false
    
    private let galleryService: GalleryService
    
    init(galleryService: GalleryService) {
        self.galleryService = galleryService
    }
    
    func fetchImages(offset: Int?, count: Int?) -> Observable<[GalleryImage]> {
        if let offset = offset, let count = count {
            //TODO: implement
            return Observable.never()
        } else {
            //requested the whole gallery
            //if we already reached the end of gallery, let's just return cached value
            //if not, let's first fetch it
            
            if fetchedAll {
                return Observable<[GalleryImage]>.just(storage)
            }
            
            //this observable will emit whole array for every update of image
            //currently it does not send initial update when every image is a placeholder
            //IMPROVE: add initial update
            
            
            //this observable will fetch gallery and then transform it into models with placeholder images
            let galleryObservable = galleryService
                .getGallery(offset: nil, count: nil)
                .do(onNext: { [weak self] ids in
                    for id in ids {
                        self?.storage.append(GalleryImage(id: id, image: nil, showPlaceholder: true))
                    }
                })
                .map { [weak self] _ in self?.storage ?? [] }
            
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
            
            return galleryObservable.concat(updatesObservable)
        }
    }
}


