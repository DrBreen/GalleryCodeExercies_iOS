//
//  MockRouter.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import InstantMock

class MockRouter: Mock, RouterProtocol {
    
    var validRoutes: [RouterDestination.Id: [RouterDestination.Id]] = [:]
    
    func go(to: RouterDestination) {
        super.call(to)
    }

}
