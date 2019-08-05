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
        mockGallery.stub().call(mockGallery.fetchNext(count: Arg.any())).andReturn(Observable<[GalleryImage]>.just(galleryReturn))
        
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
        let expectToDispose = XCTestExpectation()
        expectToDispose.expectedFulfillmentCount = 3
        expectToDispose.assertForOverFulfill = true

        mockView.stub().call(mockView.didTapImage()).andReturn(ControlEvent(events: Observable<GalleryImage>.never().do(onDispose: { expectToDispose.fulfill() })))
        mockView.stub().call(mockView.didTapUploadImage()).andReturn(ControlEvent(events: Observable<Void>.never().do(onDispose: { expectToDispose.fulfill() })))
        mockView.stub().call(mockView.reachedScreenBottom()).andReturn(ControlEvent(events: Observable<Void>.never().do(onDispose: { expectToDispose.fulfill() })))
        
        presenter.galleryScreenView = mockView
        presenter.galleryScreenView = nil
        
        wait(for: [expectToDispose], timeout: 2.0)
    }
    
    //TODO: test upload image click
    //TODO: test scroll down event
    //TODO: test error on scroll down event
    //TODO: test error on initial load event
    //TODO: test image click
    
    // MARK: Helpers
    private func setMockData(gallery: [GalleryImage]) {
        mockGallery.stub().call(mockGallery.fetchNext(count: Arg.any())).andReturn(Observable<[GalleryImage]>.just(gallery))
    }
    
    private func expect(count: Int, _ action: (XCTestExpectation) -> Void) {
        let expectataion = XCTestExpectation()
        expectataion.assertForOverFulfill = true
        expectataion.expectedFulfillmentCount = count
        
        action(expectataion)
        
        wait(for: [expectataion], timeout: 2.0)
    }
}
