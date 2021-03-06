//
//  ViewImageScreenViewProtocol.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 06/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol ViewImageScreenViewProtocol: class {
    
    // MARK: Commands
    
    //display message
    func show(message: String)
    
    ///display given image
    func set(image: UIImage)
    
    ///show edit controls
    func set(editing: Bool)
    
    ///show activity indicator
    func setActivityIndicator(visible: Bool)
    
    ///set current visible comment
    func set(comment: String?)
    
    // MARK: Events
    
    ///user did request to leave this screen
    func didRequestToLeave() -> ControlEvent<Void>
    
    ///user did request to edit this image
    func didRequestToEdit() -> ControlEvent<Void>
    
    ///user did finish editing image
    func didFinishEditing() -> ControlEvent<UIImage>
    
    ///user did cancel image editing
    func didCancelEditing() -> ControlEvent<Void>
    
    ///user did confirm he wants to save the comment
    func didRequestToSaveComment() -> ControlEvent<String?>
    
    
}
