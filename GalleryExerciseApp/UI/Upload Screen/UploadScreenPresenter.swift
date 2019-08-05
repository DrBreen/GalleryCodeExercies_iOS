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

//TODO: insert [unowned self] to blocks to avoid memory leaks
//TODO: test it
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
        
        view.didPickImageForUpload()
            .do(onNext: { [unowned self] _ in
                self.uploadScreenView?.setActivityIndicator(visible: true)
            })
            .observeOn(userInitiatedScheduler)
            .flatMap { image in
                self.galleryService.upload(image: image, name: nil)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                self.uploadScreenView?.setActivityIndicator(visible: true)
                self.gallery.invalidateFetchedStatus()
                self.router.go(to: .gallery)
            }, onError: { [unowned self] error in
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
                
                //TODO: fix that - present after dismissing
                #warning("UNCOMMENT")
                //self.uploadScreenView?.showUploadModePicker()
                self.router.go(to: .gallery)
            }).disposed(by: viewDisposeBag)
    }
    
    
}

