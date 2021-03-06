//
//  MockRouter.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import InstantMock
import RxSwift

class MockRouter: Mock, RouterProtocol {
    
    func didGoTo() -> Observable<RouterDestination> {
        return super.call()!
    }
    
    var validRoutes: [RouterDestination.Id: [RouterDestination.Id]] = [:]
    
    var currentLocation: RouterDestination? {
        return super.call()!
    }
    
    func go(to: RouterDestination, animated: Bool) -> Bool {
        return super.call(to, animated)!
    }

}
