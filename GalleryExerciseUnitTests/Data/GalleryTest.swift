//
//  GalleryTest.swift
//  GalleryExerciseUnitTests
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import InstantMock

class GalleryTest: XCTestCase {
    
    private let mockNetworkRequestSender = MockNetworkRequestSender()
    
    //TODO: test failure of gallery fetch
    //TODO: test partial fetch when it's from storage
    //TODO: test partial fetch when it's from web
    //TODO: test fetch from storage
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    }

    //test full fetch
    func test_fetchImagesEmptyStorageFullFetch() {
        //first, let's mock the listing
        let galleryContent = ["t1", "t2", "t3", "t4", "t5"]
        setMockData(gallery: galleryContent)
        
        //second, let's mock the actual image response
        setMockData(images: [
            "t1" : true,
            "t2" : true,
            "t3" : true,
            "t4" : true,
            "t5" : true])
        
        performTestFetch(offset: nil, count: nil, expectedUpdatesCount: galleryContent.count + 1, imageVerifier: {
            XCTAssertEqual($0.showPlaceholder, false)
            XCTAssertTrue($0.image != nil)
        })
    }
    
    //test fetch when some images fail to load
    func test_fetchImagesEmptyStorageFullFetchWithSomeImageFailures() {
        //first, let's mock the listing
        let galleryContent = ["t1", "t2", "t3", "t4", "t5"]
        setMockData(gallery: galleryContent)
        
        //second, let's mock the actual image response
        setMockData(images: [
            "t1" : true,
            "t2" : true,
            "t3" : false,
            "t4" : true,
            "t5" : true])
        
        performTestFetch(offset: nil, count: nil, expectedUpdatesCount: galleryContent.count + 1, imageVerifier: {
            XCTAssertEqual($0.showPlaceholder, false)
            
            if ($0.id != "t3") {
                XCTAssertTrue($0.image != nil)
            } else {
                XCTAssertTrue($0.image == nil)
            }
        })
    }
    
    //test fetch that brings empty listing
    func test_fetchImagesEmptyStorageFullFetchWithNoImagesOnServer() {
        //first, let's mock the listing
        let galleryContent = [String]()
        setMockData(gallery: galleryContent)
        performTestFetch(offset: nil, count: nil, expectedUpdatesCount: 1, imageVerifier: nil)
    }
    
    // MARK: Helpers
    private func createMockGallery() -> Gallery {
        let galleryService = DefaultGalleryService(galleryServiceURL: URL(string: "https://test.com")!, networkRequestSender: mockNetworkRequestSender)
        return Gallery(galleryService: galleryService)
    }
    
    //sets mock data for whole gallery
    //if gallery is nil, send error instead of gallery
    private func setMockData(gallery: [String]?) {
        let stub = mockNetworkRequestSender.stub()
            .call(mockNetworkRequestSender.get(url: Arg.eq(URL(string: "https://test.com/gallery")!),
                                               query: Arg.any(),
                                               headers: Arg.any()))
        if let gallery = gallery {
            stub.andReturn(Observable<Any>.just(gallery))
        } else {
            let errorObservable = Observable<Data>.error(NSError(domain: "test", code: 1, userInfo: nil))
            stub.andReturn(errorObservable)
        }
    }
    
    //sets mock data according to images dictionary: true is "serve image", false is "error out"
    private func setMockData(images: [String : Bool]) {
        for id in images.keys {
            
            let shouldServeImage = images[id] ?? false
            
            let stub = mockNetworkRequestSender.stub()
                .call(mockNetworkRequestSender.getData(url: Arg.verify { (arg: URL) in arg.absoluteString == "https://test.com/gallery/\(id)" },
                                                       query: Arg.any(),
                                                       headers: Arg.any()))
            if shouldServeImage {
                let catImage = UIImage(named: "cat", in: Bundle(for: type(of: self)), compatibleWith: nil)!
                let catImageData = catImage.pngData()!
                
                //randomly delay emission of images
                let randomDelayCatObservable = Observable<Data>.just(catImageData)
                    .delay(DispatchTimeInterval.milliseconds(Int.random(in: (500...1000))), scheduler: MainScheduler.instance)
                
                stub.andReturn(randomDelayCatObservable)
            } else {
                let errorObservable = Observable<Data>.error(NSError(domain: "test", code: 1, userInfo: nil))
                stub.andReturn(errorObservable)
            }
        }
    }
    
    private func performTestFetch(offset: Int?, count: Int?, expectedUpdatesCount: Int, imageVerifier: ((GalleryImage) -> Void)?, expectComplete: Bool = true, expectError: Bool = false) {
        
        let gallery = createMockGallery()
        
        //set up expectations
        let observableCompletesExpectation = XCTestExpectation(description: "Observable completes") //it's expected that Observable completes
        
        let gotResponseExpectation = XCTestExpectation(description: "Correct amount of updates") //it's expected that we have correct number of updates for response
        gotResponseExpectation.assertForOverFulfill = true
        gotResponseExpectation.expectedFulfillmentCount = expectedUpdatesCount
        
        let observableErrorsOutExpectation = XCTestExpectation(description: "Observable errors out") //it's expected that Observable errors out
        observableErrorsOutExpectation.assertForOverFulfill = true
        observableErrorsOutExpectation.expectedFulfillmentCount = 1
        
        var loadedContent: [GalleryImage]?
        
        //fetch and save the gallery
        let disposeBag = DisposeBag()
        gallery.fetchImages(offset: offset, count: count).subscribe(onNext: { content in
            loadedContent = content
            gotResponseExpectation.fulfill()
        }, onError: { _ in observableErrorsOutExpectation.fulfill() },
           onCompleted: { observableCompletesExpectation.fulfill() }).disposed(by: disposeBag)
        
        var expectations = [gotResponseExpectation]
        if expectError {
            expectations.append(observableErrorsOutExpectation)
        }
        
        if expectComplete {
            expectations.append(observableCompletesExpectation)
        }
        
        wait(for: expectations, timeout: 2.0)
        
        //verify contents of gallery
        loadedContent?.forEach {
            imageVerifier?($0)
        }
    }

    
}
