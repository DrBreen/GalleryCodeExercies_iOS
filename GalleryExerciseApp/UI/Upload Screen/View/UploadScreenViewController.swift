//
//  UploadScreenViewController.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

//TODO: test upload from camera
class UploadScreenViewController: UIViewController,
    UploadScreenViewProtocol,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    //presenter and everything related
    private let uploadScreenPresenter: UploadScreenPresenter
    
    //everything reactive
    private let didCancelUploadSubject = PublishSubject<Void>()
    private let didPickImageForUploadSubject = PublishSubject<UIImage>()
    private let didPickUploadModeSubject = PublishSubject<UploadMode>()
    private let didCancelImagePickSubject = PublishSubject<Void>()
    
    //views
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(uploadScreenPresenter: UploadScreenPresenter) {
        self.uploadScreenPresenter = uploadScreenPresenter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if uploadScreenPresenter.uploadScreenView == nil {
            uploadScreenPresenter.uploadScreenView = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.1) {
            self.view.backgroundColor = .clear
        }
    }
    
    private func buildView() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    // MARK: UploadScreenViewProtocol
    func showUploadModePicker() {
        let picker = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        picker.addAction(UIAlertAction(title: "Take photo".localized, style: .default, handler: { _ in
            self.didPickUploadModeSubject.onNext(.takePhoto)
        }))
        
        picker.addAction(UIAlertAction(title: "Select from gallery".localized, style: .default, handler: { _ in
            self.didPickUploadModeSubject.onNext(.pickFromGallery)
        }))
        
        picker.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { _ in
            self.didCancelUploadSubject.onNext(())
        }))
        
        present(picker, animated: true, completion: nil)
    }
    
    func setActivityIndicator(visible: Bool) {
        if visible {
            view.bringSubviewToFront(activityIndicator)
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func showImagePicker(mode: UploadMode) {
        let sourceType: UIImagePickerController.SourceType
        
        switch mode {
        case .pickFromGallery:
            sourceType = .photoLibrary
        case .takePhoto:
            sourceType = .camera
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func show(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "OK".localized, style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func didPickUploadMode() -> ControlEvent<UploadMode> {
        return ControlEvent(events: didPickUploadModeSubject)
    }
    
    func didCancelUpload() -> ControlEvent<Void> {
        return ControlEvent(events: didCancelUploadSubject)
    }
    
    func didPickImageForUpload() -> Observable<UIImage> {
        return didPickImageForUploadSubject.asObservable()
    }
    
    func didCancelImagePick() -> ControlEvent<Void> {
        return ControlEvent(events: didCancelImagePickSubject)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            didPickImageForUploadSubject.onError(GeneralError(text: "There was an error during image selection, please try again".localized))
            return
        }
        
        didPickImageForUploadSubject.onNext(image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.didCancelImagePickSubject.onNext(())
        }
    }
    
}
