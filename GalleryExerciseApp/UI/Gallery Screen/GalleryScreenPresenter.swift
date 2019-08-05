//
//  GalleryScreenPresenter.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import RxSwift

//TODO: don't forget about cropping/rotating
class GalleryScreenPresenter {
    
    private static let imageBatchSize = 100
    
    private let gallery: GalleryProtocol
    
    var galleryScreenView: GalleryScreenViewProtocol? {
        didSet {
            if let _ = galleryScreenView {
                didAttachView()
            } else {
                didDetachView()
            }
        }
    }
    
    private var viewDisposeBag = DisposeBag()
    private let disposeBag = DisposeBag()
    
    private let router: RouterProtocol
    
    init(gallery: GalleryProtocol, router: RouterProtocol) {
        self.gallery = gallery
        self.router = router
    }
    
    private func didAttachView() {
        //let's subscribe to various view events
        startObservingView()
        
        //first step is to show loading indicator
        galleryScreenView?.show(loadingMode: .initialLoading)
        
        //now let's fetch some images
        gallery
            .fetchImages(offset: 0, count: GalleryScreenPresenter.imageBatchSize)
            .debounce(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { pictures in
                //after we've got some pictures, disable loading
                self.galleryScreenView?.show(loadingMode: .none)
                
                self.galleryScreenView?.set(pictures: pictures)
            }, onError: { error in
                self.galleryScreenView?.show(error: "Sorry, failed to load images".localized)
            }).disposed(by: disposeBag)
    }
    
    private func startObservingView() {
        //TODO: subscribe to observables for View
        
        //force unwrapping because at this point it should never be nil - if it is, that means
        //that's a programming error
        let view = galleryScreenView!
        
        //when we reached bottom of the screen, let's load more images
        view.reachedScreenBottom()
            .debounce(RxTimeInterval.milliseconds(250))
            .filter { !self.gallery.fetchedAll }
            .do(onNext: { self.galleryScreenView?.show(loadingMode: .newPictures) })
            .asObservable()
            .flatMapLatest { _ in
                self.gallery.fetchNext(count: GalleryScreenPresenter.imageBatchSize)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { images in
                
            }, onError: { error in
                self.galleryScreenView?.show(error: "Sorry, failed to load new images".localized)
            }).disposed(by: viewDisposeBag)
        
    }
    
    private func didDetachView() {
        //replace old bag, effectively disposing of everything in it
        viewDisposeBag = DisposeBag()
    }
    
}
