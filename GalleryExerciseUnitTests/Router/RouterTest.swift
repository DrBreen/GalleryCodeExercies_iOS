//
//  RouterTest.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 06/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import InstantMock

class RouterTest: XCTestCase, UINavigationControllerDelegate {
    
    private let dummyGalleryImage = GalleryImage(id: "0", imageThumbnail: nil, image: nil, showPlaceholder: false)
    
    private let mockGalleryScreenFactory = MockGalleryScreenFactory()
    private let mockUploadScreenFactory = MockUploadScreenFactory()
    private let mockViewImageScreenFactory = MockViewImageScreenFactory()
    
    private var router: Router!
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        mockGalleryScreenFactory.stub().call(mockGalleryScreenFactory.galleryScreenViewController).andReturn { _ in
            IdViewController(id: RouterDestination.galleryId)
        }
        
        mockUploadScreenFactory.stub().call(mockUploadScreenFactory.uploadScreenViewController).andReturn { _ in
            IdViewController(id: RouterDestination.uploadId)
        }
        
        mockViewImageScreenFactory.stub().call(mockViewImageScreenFactory.viewImageScreenViewController(image: Arg.any())).andReturn { _ in
            IdViewController(id: RouterDestination.viewImageId)
        }
    }
    
    //gallery -> gallery
    func test_galleryToGallery() {
        performTest(path: [.gallery, .gallery], expectTerminalError: true, verifier: { (router, navigationController) in
            XCTAssertEqual(router.currentLocation?.id, RouterDestination.galleryId)
            XCTAssertEqual(navigationController.viewControllers.count, 1)
            
            let viewController = navigationController.viewControllers[0] as! IdViewController
            XCTAssertEqual(viewController.id, RouterDestination.galleryId)
        })
    }
    
    //gallery -> view image
    func test_galleryToViewImage() {
        performTest(path: [.gallery, .viewImage(image: dummyGalleryImage)], verifier: { (router, navigationController) in
            XCTAssertEqual(router.currentLocation?.id, RouterDestination.viewImageId)
            XCTAssertEqual(navigationController.viewControllers.count, 2)
            
            let viewController = navigationController.viewControllers[0] as! IdViewController
            XCTAssertEqual(viewController.id, RouterDestination.galleryId)
            
            let viewController2 = navigationController.viewControllers[1] as! IdViewController
            XCTAssertEqual(viewController2.id, RouterDestination.viewImageId)
        })
    }
    
    //gallery -> upload
    func test_galleryToUpload() {
        performTest(path: [.gallery, .upload], verifier: { (router, navigationController) in
            XCTAssertEqual(router.currentLocation?.id, RouterDestination.uploadId)
            XCTAssertEqual(navigationController.viewControllers.count, 1)
            
            let viewController = navigationController.viewControllers[0] as! IdViewController
            XCTAssertEqual(viewController.id, RouterDestination.galleryId)
            
            let viewController2 = viewController.presentedViewController as! IdViewController
            XCTAssertEqual(viewController2.id, RouterDestination.uploadId)
        })
    }
    
    //upload -> gallery
    func test_uploadToGallery() {
        performTest(path: [.gallery, .upload, .gallery], verifier: { (router, navigationController) in
            XCTAssertEqual(router.currentLocation?.id, RouterDestination.galleryId)
            XCTAssertEqual(navigationController.viewControllers.count, 1)
            
            let viewController = navigationController.viewControllers[0] as! IdViewController
            XCTAssertEqual(viewController.id, RouterDestination.galleryId)
        })
    }
    
    //uploadId -> viewImage
    func test_uploadToViewImage() {
        performTest(path: [.gallery, .upload, .viewImage(image: dummyGalleryImage)], expectTerminalError: true, verifier: { (router, navigationController) in
            XCTAssertEqual(router.currentLocation?.id, RouterDestination.uploadId)
            XCTAssertEqual(navigationController.viewControllers.count, 1)
            
            let viewController = navigationController.viewControllers[0] as! IdViewController
            XCTAssertEqual(viewController.id, RouterDestination.galleryId)
            
            let viewController2 = viewController.presentedViewController as! IdViewController
            XCTAssertEqual(viewController2.id, RouterDestination.uploadId)
        })
    }
    
    //upload -> upload
    func test_uploadToUpload() {
        performTest(path: [.gallery, .upload, .upload], expectTerminalError: true, verifier: { (router, navigationController) in
            XCTAssertEqual(router.currentLocation?.id, RouterDestination.uploadId)
            XCTAssertEqual(navigationController.viewControllers.count, 1)
            
            let viewController = navigationController.viewControllers[0] as! IdViewController
            XCTAssertEqual(viewController.id, RouterDestination.galleryId)
            
            let viewController2 = viewController.presentedViewController as! IdViewController
            XCTAssertEqual(viewController2.id, RouterDestination.uploadId)
        })
    }
    
    //viewImage -> upload
    func test_viewImageToUpload() {
        performTest(path: [.gallery, .viewImage(image: dummyGalleryImage), .upload], expectTerminalError: true, verifier: { (router, navigationController) in
            XCTAssertEqual(router.currentLocation?.id, RouterDestination.viewImageId)
            XCTAssertEqual(navigationController.viewControllers.count, 2)
            
            let viewController = navigationController.viewControllers[0] as! IdViewController
            XCTAssertEqual(viewController.id, RouterDestination.galleryId)
            
            let viewController2 = navigationController.viewControllers[1] as! IdViewController
            XCTAssertEqual(viewController2.id, RouterDestination.viewImageId)
            
            let visibleViewController = navigationController.visibleViewController as! IdViewController
            XCTAssertEqual(visibleViewController.id, RouterDestination.viewImageId)
        })
    }
    
    
    //viewImageId -> gallery
    func test_viewImageToGallery() {
        performTest(path: [.gallery, .viewImage(image: dummyGalleryImage), .gallery], verifier: { (router, navigationController) in
            XCTAssertEqual(router.currentLocation?.id, RouterDestination.galleryId)
            XCTAssertEqual(navigationController.viewControllers.count, 1)
            
            let viewController = navigationController.viewControllers[0] as! IdViewController
            XCTAssertEqual(viewController.id, RouterDestination.galleryId)
            
            let visibleViewController = navigationController.visibleViewController as! IdViewController
            XCTAssertEqual(visibleViewController.id, RouterDestination.galleryId)
        })
    }
    
    //viewImage -> viewImage
    func test_viewImageToViewImage() {
        performTest(path: [.gallery, .viewImage(image: dummyGalleryImage), .viewImage(image: dummyGalleryImage)],
                    expectTerminalError: true,
                    verifier: { (router, navigationController) in
                        XCTAssertEqual(router.currentLocation?.id, RouterDestination.viewImageId)
                        XCTAssertEqual(navigationController.viewControllers.count, 2)
                        
                        let viewController = navigationController.viewControllers[0] as! IdViewController
                        XCTAssertEqual(viewController.id, RouterDestination.galleryId)
                        
                        let viewController2 = navigationController.viewControllers[1] as! IdViewController
                        XCTAssertEqual(viewController2.id, RouterDestination.viewImageId)
                        
                        let visibleViewController = navigationController.visibleViewController as! IdViewController
                        XCTAssertEqual(visibleViewController.id, RouterDestination.viewImageId)
        })
    }
    
    
    private func performTest(path: [RouterDestination], expectTerminalError: Bool = false, verifier: @escaping (Router, UINavigationController) -> Void) {
        
        let disposeBag = DisposeBag()
        
        let expectation = XCTestExpectation()
        expectation.assertForOverFulfill = true
        expectation.expectedFulfillmentCount = path.count
        
        let window = UIWindow()
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        router = Router(navigationController: navigationController, galleryScreenFactory: mockGalleryScreenFactory, uploadScreenFactory: mockUploadScreenFactory, viewImageScreenFactory: mockViewImageScreenFactory)
        
        //verify that observable works
        //map route destinations to their ids, and if we expect terminal error - remove last (as we won't move there)
        var expectedIds = path.map { $0.id }
        if expectTerminalError {
            expectedIds.removeLast()
        }
        
        let routeObservableExpectation = XCTestExpectation(description: "Router didGoTo expectation")
        routeObservableExpectation.assertForOverFulfill = true
        routeObservableExpectation.expectedFulfillmentCount = expectedIds.count
        router.didGoTo().map { $0.id }.subscribe(onNext: { id in
            XCTAssertEqual(id, expectedIds[0])
            expectedIds.removeFirst()
            routeObservableExpectation.fulfill()
        }).disposed(by: disposeBag)
        
        Observable<(offset: Int, element: RouterDestination)>.from(path.enumerated())
            .map { (offset: Int, element: RouterDestination) in
                return (destination: element, isTerminal: offset == path.count - 1)
            }
            .concatMap { pathElement in
                Observable.just(pathElement)
                    .delay(RxTimeInterval.milliseconds(250), scheduler: MainScheduler.instance)
            }
            .subscribe(onNext: { (destination: RouterDestination, isTerminal: Bool) in
                let result = self.router.go(to: destination, animated: false)
                
                //if we received error on non-terminal navigation, fail an assertion - it shouldn't happen
                //terminal destination just passes on
                XCTAssertTrue(isTerminal || !isTerminal && result, "Received error on non-terminal route to \(destination.id)")
                
                //if we received error on terminal destination, check if we expected it
                //non-terminal destination just passes on
                XCTAssertTrue(!isTerminal || isTerminal && (expectTerminalError == !result), "Expected terminal error condition is not fulfilled")
                
                expectation.fulfill()
            }).disposed(by: disposeBag)
        
        wait(for: [expectation, routeObservableExpectation], timeout: 2.0)
        
        let waitExpectation = XCTestExpectation()
        
        //better way would be to implement delegates, etc. to handle "did present", "did push" events
        //but I'd rather just wait a little bit.
        //Is it a great way? No. Is it terrible? No.
        //Not great, not terrible. Perfectly balanced, as all things should be.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            verifier(self.router, navigationController)
            waitExpectation.fulfill()
        }
        
        wait(for: [waitExpectation], timeout: 2.0)
        
    }
    
}
