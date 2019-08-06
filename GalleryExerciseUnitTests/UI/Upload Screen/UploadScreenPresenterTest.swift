//
//  UploadScreenPresenterTest.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 06/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import XCTest
import InstantMock
import RxSwift
import RxCocoa

class UploadScreenPresenterTest: XCTestCase {
    
    private var presenter: UploadScreenPresenter!
    
    private let mockGallery = MockGallery()
    private let mockRouter = MockRouter()
    private let mockGalleryService = MockGalleryService()
    private let mockView = MockUploadScreenView()
    
    override func setUp() {
        continueAfterFailure = false
        presenter = UploadScreenPresenter(galleryService: mockGalleryService, gallery: mockGallery, router: mockRouter)
    }
    
    private func reset() {
        [mockGalleryService, mockGallery, mockRouter, mockView].forEach {
            $0.resetStubs()
            $0.resetExpectations()
        }
    }

    //test for presenter attachment
    func test_viewAttach() {
        //basiscally, test that we're subscribed to everything
        //and also test that we show the picker menu
        reset()
        
        expectMultiple(counts: [1, 1, 1, 1, 1], [
            "didCancelImagePick",
            "didCancelUpload",
            "didPickUploadMode",
            "didPickImageForUpload",
            "showUploadModePicker"
        ]) { expectations in
            
            mockView.expect().call(mockView.didCancelImagePick()).andDo { _ in
                expectations[0].fulfill()
            }
            
            mockView.expect().call(mockView.didCancelUpload()).andDo { _ in
                expectations[1].fulfill()
            }
            
            mockView.expect().call(mockView.didPickUploadMode()).andDo { _ in
                expectations[2].fulfill()
            }
            
            mockView.expect().call(mockView.didPickImageForUpload()).andDo { _ in
                expectations[3].fulfill()
            }
            
            mockView.expect().call(mockView.showUploadModePicker()).andDo { _ in
                expectations[4].fulfill()
            }
            
            presenter.uploadScreenView = mockView
        }
    }
    
    //test for chain of events: "start picking image", "image is correct", "upload image", "got correct response" -> should invalidate cache and go to gallery and hide indicator
    func test_successfulUpload() {
        reset()

        expectMultiple(counts: [2, 1, 1], ["showActivityIndicator", "invalidateCache", "goToGallery"]) { expectations in

            let imagePickResult = PickImageResult(image: .catImage, error: nil)
            mockView.stub()
                .call(mockView.didPickImageForUpload())
                .andReturn(ControlEvent(events: Observable<PickImageResult>.just(imagePickResult)))

            mockGalleryService.stub()
                .call(mockGalleryService.upload(image: Arg.any(), name: Arg.any()))
                .andReturn(Observable<GalleryServiceUploadResponse>.just(GalleryServiceUploadResponse(imageId: "testId")))

            var expectedSequence = [true, false]
            mockView.expect()
                .call(mockView.setActivityIndicator(visible: Arg.any()))
                .andDo { args in
                    let value = args[0] as! Bool

                    XCTAssert(expectedSequence.count > 0)
                    XCTAssertEqual(expectedSequence[0], value)
                    expectedSequence.remove(at: 0)
                    expectations[0].fulfill()
            }

            mockGallery.expect()
                .call(mockGallery.invalidateCache())
                .andDo { _ in
                    expectations[1].fulfill()
                }

            mockRouter.expect()
                .call(mockRouter.go(to: Arg.verify { $0.id == RouterDestination.galleryId }, animated: Arg.any())).andDo { _ in
                    expectations[2].fulfill()
            }

            presenter.uploadScreenView = mockView

        }
    }
    
    //test for chain of events: "started picking image", "image is incorrect, got error" -> should show error and still deliver events after second picking
    func test_failedUploadPickImageFailed() {
        reset()
        
        expectMultiple(counts: [2, 2], ["showActivityIndicator", "showError"]) { expectations in
            
            let imagePickSubject = PublishSubject<PickImageResult>()
            
            let imagePickResult = PickImageResult(image: nil, error: GeneralError(text: "Test error"))
            mockView.stub()
                .call(mockView.didPickImageForUpload())
                .andReturn(ControlEvent(events: imagePickSubject))
            
            mockView.expect()
                .call(mockView.setActivityIndicator(visible: Arg.eq(false)))
                .andDo { _ in
                    expectations[0].fulfill()
            }
            
            mockView.expect()
                .call(mockView.show(message: Arg.eq("Test error")))
                .andDo { _ in
                    expectations[1].fulfill()
            }
            
            presenter.uploadScreenView = mockView
            
            //now let's send the pick event
            imagePickSubject.onNext(imagePickResult)
            
            //now let's send another one. It should still trigger error
            imagePickSubject.onNext(imagePickResult)
        }
    }
    
    //test for chain of events: "started picking image", "image is correct", "upload image", "got error when uploading" -> should show error and still deliver events after second picking
    func test_failedUploadUploadImageFailed() {
        reset()
        
        expectMultiple(counts: [4, 2], ["showActivityIndicator", "showError"]) { expectations in
            
            
            let imagePickSubject = PublishSubject<PickImageResult>()
            
            let imagePickResult = PickImageResult(image: .catImage, error: nil)
            mockView.stub()
                .call(mockView.didPickImageForUpload())
                .andReturn(ControlEvent(events: imagePickSubject))
            
            mockGalleryService.stub()
                .call(mockGalleryService.upload(image: Arg.any(), name: Arg.any()))
                .andReturn(Observable<GalleryServiceUploadResponse>.error(GalleryServiceError(error: "Test service error")))
            
            var expectedSequence = [true, false, true, false]
            mockView.expect()
                .call(mockView.setActivityIndicator(visible: Arg.any()))
                .andDo { args in
                    let value = args[0] as! Bool
                    
                    XCTAssert(expectedSequence.count > 0)
                    XCTAssertEqual(expectedSequence[0], value)
                    expectedSequence.remove(at: 0)
                    expectations[0].fulfill()
            }
            
            mockView.expect()
                .call(mockView.show(message: Arg.eq("Test service error")))
                .andDo { _ in
                    expectations[1].fulfill()
            }
            
            presenter.uploadScreenView = mockView
            
            //now let's send the pick event
            imagePickSubject.onNext(imagePickResult)

            Thread.sleep(forTimeInterval: 0.1)
            
            //and then send next one
            imagePickSubject.onNext(imagePickResult)
        }
    }
    
    //upload cancel - should just go to gallery
    func test_uploadCancel() {
        reset()
        
        expect(count: 1) { expectation in
            let didCancelUploadSubject = PublishSubject<Void>()
            
            mockRouter.expect().call(mockRouter.go(to: Arg.verify { $0.id == RouterDestination.galleryId }, animated: Arg.any())).andDo { _ in
                expectation.fulfill()
            }
            
            mockView.stub().call(mockView.didCancelUpload()).andReturn(ControlEvent(events: didCancelUploadSubject))
            presenter.uploadScreenView = mockView
            didCancelUploadSubject.onNext(())
        }
    }
    
    //image picker cancel - should show picker menu
    func test_imagePickerCancel() {
        reset()
        
        expect(count: 1) { expectation in
            let delayedCancel = Observable.just(()).delay(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
            mockView.stub().call(mockView.didCancelImagePick()).andReturn(ControlEvent(events: delayedCancel))
            
            mockView.expect().call(mockView.showUploadModePicker()).andDo { _ in
                expectation.fulfill()
            }
            
            presenter.uploadScreenView = mockView
        }
    }
    
}
