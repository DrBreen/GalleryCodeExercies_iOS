//
//  UploadScreenPresenter.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//TODO: add test for chain of events: "started picking image", "image is incorrect, got error" -> should show error and still deliver events after second picking of correct image (and all the things with loading indicators, etc.)
//TODO: add test for chain of events: "started picking image", "image is correct", "upload image", "got error when uploading" -> should show error and still deliver events after second picking of correct image (and all the things with loading indicators, etc.)
//TODO: add test for chain of events: "start picking image", "image is correct", "upload image", "got correct response" -> should invalidate cache and go to gallery and hide indicator
//TODO: add test for upload cancel: should just got to gallery
//TODO: add test for image picker cancel - should show picker menu
class UploadScreenPresenter {
    
    weak var uploadScreenView: UploadScreenViewProtocol? {
        didSet {
            if let _ = uploadScreenView {
                didAttachView()
            } else {
                didDetachView()
            }
        }
    }
    
    private let userInitiatedScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    private var viewDisposeBag = DisposeBag()
    private let disposeBag = DisposeBag()
    
    private let galleryService: GalleryService
    private let router: RouterProtocol
    private let gallery: GalleryProtocol
    
    init(galleryService: GalleryService, gallery: GalleryProtocol, router: RouterProtocol) {
        self.galleryService = galleryService
        self.router = router
        self.gallery = gallery
    }
    
    private func didAttachView() {
        startObservingView()
        
        uploadScreenView?.showUploadModePicker()
    }
    
    private func didDetachView() {
        viewDisposeBag = DisposeBag()
    }
    
    private func startObservingView() {
        let view = uploadScreenView!
        
        view.didCancelUpload()
            .subscribe(onNext: { [unowned self] in
                self.router.go(to: .gallery)
            }).disposed(by: viewDisposeBag)
        
        view.didCancelImagePick()
            .subscribe(onNext: { [unowned self] in
                self.uploadScreenView?.showUploadModePicker()
            }).disposed(by: viewDisposeBag)
        
        view.didPickUploadMode()
            .subscribe(onNext: { [unowned self] uploadMode in
                self.uploadScreenView?.showImagePicker(mode: uploadMode)
            }).disposed(by: viewDisposeBag)
        
        
        let errorHandler = { [unowned self] (error: Error) in
            self.uploadScreenView?.setActivityIndicator(visible: false)
            
            let message: String
            if let error = error as? GalleryServiceError {
                message = error.error
            } else if let error = error as? GeneralError {
                message = error.text
            } else {
                message = "Something went wrong, please try again".localized
            }
            
            self.uploadScreenView?.show(message: message)
            self.uploadScreenView?.showUploadModePicker()
        }
        
        self.uploadScreenView?.didPickImageForUpload()
            .debug("original", trimOutput: true)
            .do(onNext: { [unowned self] result in
                if let error = result.error {
                    errorHandler(error)
                } else {
                    self.uploadScreenView?.setActivityIndicator(visible: true)
                }
            })
            .observeOn(userInitiatedScheduler)
            .filter { $0.image != nil }
            .map { $0.image! }
            .flatMap { [unowned self] image in
                //run error handler on error, and just swallow it so it will never reach downstream
                self.galleryService
                    .upload(image: image, name: nil)
                    .do(onError: errorHandler)
                    .catchError { _ in Observable.empty() }
            }
            .observeOn(MainScheduler.instance)
            .debug("test", trimOutput: true)
            .subscribe(onNext: { [unowned self] _ in
                self.uploadScreenView?.setActivityIndicator(visible: true)
                self.gallery.invalidateCache()
                self.router.go(to: .gallery)
            }).disposed(by: viewDisposeBag)
    }
    
    
}

