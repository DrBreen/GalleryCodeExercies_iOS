//
//  MockUploadScreenFactory.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 06/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import InstantMock
import UIKit

class MockViewImageScreenFactory: Mock, ViewImageScreenFactory {
    
    func viewImageScreenViewController(image: GalleryImage) -> UIViewController {
        return super.call(image)!
    }
    
}
