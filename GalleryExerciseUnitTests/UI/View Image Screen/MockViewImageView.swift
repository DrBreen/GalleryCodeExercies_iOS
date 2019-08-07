//
//  MockViewImageView.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 07/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import InstantMock
import RxSwift
import RxCocoa

class MockViewImageScreenView: Mock, ViewImageScreenViewProtocol {
    
    func show(message: String) {
        super.call(message)
    }
    
    func set(image: UIImage) {
        super.call(image)
    }
    
    func set(editing: Bool) {
        super.call(editing)
    }
    
    func setActivityIndicator(visible: Bool) {
        super.call(visible)
    }
    
    func didRequestToLeave() -> ControlEvent<Void> {
        return super.call()!
    }
    
    func didRequestToEdit() -> ControlEvent<Void> {
        return super.call()!
    }
    
    func didFinishEditing() -> ControlEvent<UIImage> {
        return super.call()!
    }
    
    func didCancelEditing() -> ControlEvent<Void> {
        return super.call()!
    }
    
    
}
