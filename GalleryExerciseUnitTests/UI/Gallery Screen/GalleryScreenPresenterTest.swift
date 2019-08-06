//
//  GalleryScreenPresenterTest.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import XCTest
import InstantMock
import RxSwift
import RxCocoa

class GalleryScreenPresenterTest: XCTestCase {
    
    private let mockRouter = MockRouter()
    private let mockGallery = MockGallery()
    private let mockView = MockGalleryScreenView()
    
    private var presenter: GalleryScreenPresenter!
    
    override func setUp() {
        presenter = GalleryScreenPresenter(gallery: mockGallery, router: mockRouter)
    }
    
    //test that images are loaded and set to view when view is attached
    func test_loadImagesOnViewAttach() {
        let galleryReturn = [
            GalleryImage(id: "testId", imageThumbnail: .catImageThumbnail, image: .catImage, showPlaceholder: false)
        ]
        
        setMockData(gallery: galleryReturn)
        
        expect(count: 1) { expectation in
            mockView.expect().call(mockView.set(pictures: Arg.any())).andDo { (args) in
                let images = args[0] as! [GalleryImage]
                XCTAssertEqual(images[0].id, galleryReturn[0].id)
                XCTAssertEqual(images[0].showPlaceholder, galleryReturn[0].showPlaceholder)
                expectation.fulfill()
            }
            
            presenter.galleryScreenView = mockView
        }
    }
    
    //test that loading indicator is shown before load and is hidden after loading
    func test_showLoadingIndicatorAndHide() {
        let galleryReturn = [
            GalleryImage(id: "testId", imageThumbnail: .catImageThumbnail, image: .catImage, showPlaceholder: false)
        ]
        setMockData(gallery: galleryReturn)
        
        var modeSequence = [GalleryScreenLoadingMode.initialLoading, GalleryScreenLoadingMode.none]
        expect(count: 2) { expectation in
            //expect call to show(loadingMode:) 2 times, with .initialLoading first and .none after that
            mockView.expect().call(mockView.show(loadingMode: Arg.any())).andDo { (args) in
                let mode = args[0] as! GalleryScreenLoadingMode
                XCTAssertEqual(modeSequence[0], mode)
                modeSequence.remove(at: 0) //knock out valid event
                expectation.fulfill()
            }
            
            presenter.galleryScreenView = mockView
        }
        
        //check that there's no events left
        XCTAssertEqual(modeSequence.count, 0)
    }
    
    //test that all view observables are disposed on view detach
    func test_viewObservablesDisposed() {
        expect(count: 2) { expectToDispose in
            mockView.stub()
                .call(mockView.didTapImage())
                .andReturn(ControlEvent(events: Observable<GalleryImage>.never().do(onDispose: { expectToDispose.fulfill() })))
            
            mockView.stub()
                .call(mockView.didTapUploadImage())
                .andReturn(ControlEvent(events: Observable<Void>.never().do(onDispose: { expectToDispose.fulfill() })))
            
            presenter.galleryScreenView = mockView
            presenter.galleryScreenView = nil
        }
    }
    
    //test that presenter instructs router to go upload screen on upload button click
    func test_openUploadScreenOnUploadButtonClick() {
        expect(count: 1) { expectation in
            mockView.stub()
                .call(mockView.didTapUploadImage())
                .andReturn(ControlEvent(events: Observable<Void>.just(())))
            
            mockRouter.expect()
                .call(mockRouter.go(to: Arg.eq(RouterDestination.upload)))
                .andDo { args in
                expectation.fulfill()
            }
            
            presenter.galleryScreenView = mockView
        }
    }
    
    //test that presenter instructs router to go image view screen on upload button click
    func test_openViewImageScreenOnImageClick() {
        expect(count: 1) { expectation in
            let image = GalleryImage(id: "test", imageThumbnail: nil, image: nil, showPlaceholder: false)
            mockView.stub().call(mockView.didTapImage()).andReturn(ControlEvent(events: Observable<GalleryImage>.just(image)))
            mockRouter.expect().call(mockRouter.go(to: Arg.eq(RouterDestination.viewImage(image: image)))).andDo { args in
                expectation.fulfill()
            }
            
            presenter.galleryScreenView = mockView
        }
    }
    
    //test that correct error message is shown on initial load gallery (GalleryServiceError) and loading indicator is hidden
    func test_galleryErrorOnLoad() {
        expect(count: 2) { expectation in
            setMockData(galleryError: GalleryServiceError(error: "Test error"))
            
            mockView.expect()
                .call(mockView.show(loadingMode: Arg.eq(.none)))
                .andDo { _ in expectation.fulfill() } //expect that show(loadingMode:) is called with .none argument
            
            mockView.expect()
                .call(mockView.show(error: Arg.eq("Test error")))
                .andDo { _ in expectation.fulfill() } //expect that show(error:) is called with correct error
            
            presenter.galleryScreenView = mockView
        }
    }
    
    //test that correct error message is shown on initial load gallery (general error) and loading indicator is hidden
    func test_errorOnLoad() {
        expectMultiple(counts: [1, 1], ["Disable loading indicator", "Showed error"]) { expectations in
            setMockData(galleryError: NSError(domain: "test", code: 1, userInfo: nil))
            
            mockView.expect()
                .call(mockView.show(loadingMode: Arg.eq(.none)))
                .andDo { _ in expectations[0].fulfill() } //expect that show(loadingMode:) is called with .none argument
            
            mockView.expect()
                .call(mockView.show(error: Arg.eq("Sorry, failed to load images")))
                .andDo { _ in expectations[1].fulfill() } //expect that show(error:) is called with correct error
            
            presenter.galleryScreenView = mockView
        }
    }
    
    // MARK: Helpers
    private func setMockData(gallery: [GalleryImage]) {
        mockGallery.resetStubs()
        mockGallery.stub().call(mockGallery.fetchImages()).andReturn(Observable<[GalleryImage]>.just(gallery))
    }
    
    private func setMockData(galleryError: Error) {
        mockGallery.resetStubs()
        mockGallery.stub().call(mockGallery.fetchImages()).andReturn(Observable<[GalleryImage]>.error(galleryError))
    }
    
    private func expect(count: Int, _ action: (XCTestExpectation) -> Void) {
        let expectataion = XCTestExpectation()
        expectataion.assertForOverFulfill = true
        expectataion.expectedFulfillmentCount = count
        
        action(expectataion)
        
        wait(for: [expectataion], timeout: 2.0)
    }
    
    private func expectMultiple(counts: [Int], _ descriptions: [String]? = nil, _ action: ([XCTestExpectation]) -> Void) {

        if let descriptions = descriptions, descriptions.count != counts.count {
            fatalError("Please provide descriptions for all expectations")
        }
        
        let expectations = counts.enumerated().map { (index: Int, count: Int) -> XCTestExpectation in
            let expectation = XCTestExpectation(description: descriptions?[index] ?? "Expectation #\(index)")
            expectation.assertForOverFulfill = true
            expectation.expectedFulfillmentCount = count
            return expectation
        }
        
        action(expectations)
        
        wait(for: expectations, timeout: 2.0)
    }
}
