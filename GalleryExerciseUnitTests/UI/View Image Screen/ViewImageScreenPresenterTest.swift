//
//  ViewImageScreenPresenterTest.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 07/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import XCTest
import InstantMock
import RxSwift
import RxCocoa

class ViewImageScreenPresenterTest: XCTestCase {
    
    private let dummyImage = GalleryImage(id: "testId", imageThumbnail: .catImageThumbnail, image: .catImage, showPlaceholder: false)
    
    private let mockView = MockViewImageScreenView()
    private let mockGalleryService = MockGalleryService()
    private let mockGallery = MockGallery()
    private let mockRouter = MockRouter()
    
    private var presenter: ViewImageScreenPresenter!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        presenter = ViewImageScreenPresenter(galleryImage: dummyImage, galleryService: mockGalleryService, gallery: mockGallery, router: mockRouter)
    }
    
    
    //test that image is shown on initialization
    func test_initializationFlow() {
        reset()
        
        expectMultiple(counts: [4, 1], ["subscription", "showImage"]) { expectations in
            
            //should subscribe to everything
            mockView.expect().call(mockView.didCancelEditing()).andDo { _ in
                expectations[0].fulfill()
            }
            
            mockView.expect().call(mockView.didFinishEditing()).andDo { _ in
                expectations[0].fulfill()
            }
            
            mockView.expect().call(mockView.didRequestToEdit()).andDo { _ in
                expectations[0].fulfill()
            }
            
            mockView.expect().call(mockView.didRequestToLeave()).andDo { _ in
                expectations[0].fulfill()
            }
            
            mockView.expect().call(mockView.set(image: Arg.any())).andDo { _ in
                expectations[1].fulfill()
            }
            
            presenter.viewImageScreenView = mockView
        }
    }
    
    //test "Edit" button click
    func test_editClick() {
        reset()
        
        expect(count: 1) { expectation in
            mockView.stub()
                .call(mockView.didRequestToEdit())
                .andReturn(ControlEvent(events: Observable<Void>.just(())))
            
            mockView.expect()
                .call(mockView.set(editing: Arg.eq(true)))
                .andDo { _ in
                    expectation.fulfill()
            }
            
            presenter.viewImageScreenView = mockView
        }
        
    }
    
    //test "Cancel" button click when editing
    func test_cancelEditClick() {
        reset()
        
        expect(count: 1) { expectation in
            mockView.stub()
                .call(mockView.didCancelEditing())
                .andReturn(ControlEvent(events: Observable<Void>.just(())))
            
            mockView.expect()
                .call(mockView.set(editing: Arg.eq(false)))
                .andDo { _ in
                    expectation.fulfill()
            }
            
            presenter.viewImageScreenView = mockView
        }
    }
    
    //test back button click
    func test_backButtonClick() {
        reset()
        
        expect(count: 1) { expectation in
            mockView.stub()
                .call(mockView.didRequestToLeave())
                .andReturn(ControlEvent(events: Observable<Void>.just(())))
            
            mockRouter.expect()
                .call(mockRouter.go(to: Arg.verify { $0.id == RouterDestination.galleryId }, animated: Arg.any()))
                .andDo { _ in
                    expectation.fulfill()
            }
            
            presenter.viewImageScreenView = mockView
        }
    }
    
    //test edit failure
    func test_editFailed() {
        reset()
        
        expectMultiple(counts: [2, 1, 1], ["setActivityIndicator", "showMessage", "setEditing"]) { expectations in
            mockGalleryService.stub()
                .call(mockGalleryService.upload(image: Arg.any(), name: Arg.any())) .andReturn(Observable<GalleryServiceUploadResponse>.error(GalleryServiceError(error: "Test error")))
            
            mockView.stub()
                .call(mockView.didFinishEditing())
                .andReturn(ControlEvent(events: Observable<UIImage>.just(.catImage)))
            
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
            
            mockView.expect()
                .call(mockView.show(message: Arg.eq("Test error")))
                .andDo { _ in
                    expectations[1].fulfill()
            }
            
            mockView.expect()
                .call(mockView.set(editing: Arg.eq(false)))
                .andDo { _ in
                    expectations[2].fulfill()
            }
            
            presenter.viewImageScreenView = mockView
        }
    }
    
    //test edit comment fail
    func test_saveCommentFailed() {
        reset()
        
        expectMultiple(counts: [2, 1], ["setActivityIndicator", "showMessage"]) { expectations in
            mockGalleryService.stub()
                .call(mockGalleryService.addComment(name: Arg.any(), comment: Arg.any())) .andReturn(Single<Void>.error(GalleryServiceError(error: "Test error")))
            
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
            
            mockView.expect()
                .call(mockView.show(message: Arg.eq("Test error")))
                .andDo { _ in
                    expectations[1].fulfill()
            }
            
            
            let didRequestToSaveCommentRelay = PublishRelay<String?>()
            mockView.stub().call(mockView.didRequestToSaveComment()).andReturn(ControlEvent<String?>(events: didRequestToSaveCommentRelay))
            
            presenter.viewImageScreenView = mockView
            didRequestToSaveCommentRelay.accept("test comment")
        }
    }
    
    func test_saveCommentSuccess() {
        reset()
        
        expectMultiple(counts: [2, 1], ["setActivityIndicator", "invalidateCache"]) { expectations in
            
            mockGalleryService.stub()
                .call(mockGalleryService.addComment(name: Arg.any(), comment: Arg.any())) .andReturn(Single<Void>.just(()))
            
            
            let didRequestToSaveCommentRelay = PublishRelay<String?>()
            mockView.stub().call(mockView.didRequestToSaveComment()).andReturn(ControlEvent<String?>(events: didRequestToSaveCommentRelay))
            
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
            
            mockGallery.expect().call(mockGallery.invalidateCache()).andDo { _ in
                expectations[1].fulfill()
            }
            
            presenter.viewImageScreenView = mockView
            didRequestToSaveCommentRelay.accept("Test comment")
        }
    }
    
    //test edit success
    func test_editSuccess() {
        reset()
        
        expectMultiple(counts: [2, 1, 1, 1],
                       ["setActivityIndicator",
                        "invalidateCache",
                        "setEditing",
                        "setImage"]) { expectations in
                            
                            mockGalleryService.stub()
                                .call(mockGalleryService.upload(image: Arg.any(), name: Arg.any())) .andReturn(Observable<GalleryServiceUploadResponse>.just(GalleryServiceUploadResponse(imageId: "testId")))
                            
                            
                            let imagePickSubject = PublishSubject<UIImage>()
                            
                            mockView.stub()
                                .call(mockView.didFinishEditing())
                                .andReturn(ControlEvent(events: imagePickSubject))
                            
                            presenter.viewImageScreenView = mockView
                            
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
                            
                            //expect presenter to call to invalidateCache()
                            mockGallery.expect()
                                .call(mockGallery.invalidateCache())
                                .andDo { _ in
                                    expectations[1].fulfill()
                            }
                            
                            //expect presenter to call to set(editing: false)
                            mockView.expect()
                                .call(mockView.set(editing: Arg.eq(false)))
                                .andDo { _ in
                                    expectations[2].fulfill()
                            }
                            
                            //expect presenter to call to set(image:)
                            mockView.expect()
                                .call(mockView.set(image: Arg.any()))
                                .andDo { _ in
                                    expectations[3].fulfill()
                            }
                            
                            
                            
                            imagePickSubject.onNext(.catImage)
        }
        
    }
    
    private func reset() {
        mockView.resetStubs()
        mockView.resetExpectations()
        
        mockRouter.resetExpectations()
        mockRouter.resetStubs()
        
        mockGalleryService.resetExpectations()
        mockGalleryService.resetStubs()
        
        mockGallery.resetExpectations()
        mockGallery.resetStubs()
    }
}
