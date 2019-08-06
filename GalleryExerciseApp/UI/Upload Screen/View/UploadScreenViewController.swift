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

class UploadScreenViewController: UIViewController,
    UploadScreenViewProtocol,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    private enum PendingShow {
        case uploadModePicker
        case message(_ message: String)
    }
    
    //presenter and everything related
    private let uploadScreenPresenter: UploadScreenPresenter
    
    //everything reactive
    private let didCancelUploadSubject = PublishSubject<Void>()
    private let didPickImageForUploadSubject = PublishSubject<PickImageResult>()
    private let didPickUploadModeSubject = PublishSubject<UploadMode>()
    private let didCancelImagePickSubject = PublishSubject<Void>()
    
    //views
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    //state
    private var presentingMessage = false
    private var presentingUploadModePicker = false
    private var showQueue = [PendingShow]()
    
    
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
    
    private func pollShowQueue() {
        guard let showNow = showQueue.first else {
            return
        }
        
        switch showNow {
        case .message(let message):
            show(message: message)
        case .uploadModePicker:
            showUploadModePicker()
        }
    }
    
    // MARK: UploadScreenViewProtocol
    func showUploadModePicker() {
        guard !presentingMessage && !presentingUploadModePicker else {
            showQueue.append(.uploadModePicker)
            return
        }
        
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
        guard !presentingMessage && !presentingUploadModePicker else {
            showQueue.append(.message(message))
            return
        }
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { _ in
            self.presentingMessage = false
            
            self.pollShowQueue()
        }))
        presentingMessage = true
        present(alertController, animated: true, completion: nil)
        
    }
    
    func didPickUploadMode() -> ControlEvent<UploadMode> {
        return ControlEvent(events: didPickUploadModeSubject)
    }
    
    func didCancelUpload() -> ControlEvent<Void> {
        return ControlEvent(events: didCancelUploadSubject)
    }
    
    func didPickImageForUpload() -> ControlEvent<PickImageResult> {
        return ControlEvent(events: didPickImageForUploadSubject)
    }
    
    func didCancelImagePick() -> ControlEvent<Void> {
        return ControlEvent(events: didCancelImagePickSubject)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
    
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            didPickImageForUploadSubject.onNext(PickImageResult(image: nil, error: GeneralError(text: "There was an error during image selection, please try again".localized)))
            return
        }
        
        didPickImageForUploadSubject.onNext(PickImageResult(image: image, error: nil))
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.didCancelImagePickSubject.onNext(())
        }
    }
    
}
