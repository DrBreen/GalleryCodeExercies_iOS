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

//TODO: refactor this, it's dangerous for human eye to read this
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
        let galleryService = DefaultGalleryService(galleryServiceURL: URL(string: "https://test.com")!, networkRequestSender: mockNetworkRequestSender)
        
        let gallery = Gallery(galleryService: galleryService)
        
        //let's mock the gallery service
        
        //first, let's mock the listing
        let galleryContent = ["t1", "t2", "t3", "t4", "t5"]
        mockNetworkRequestSender.stub()
            .call(mockNetworkRequestSender.get(url: Arg.eq(URL(string: "https://test.com/gallery")!),
                                               query: Arg.any(),
                                               headers: Arg.any())).andReturn(Observable<Any>.just(galleryContent))
        
        //second, let's mock the actual image response
        let catImage = UIImage(named: "cat", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let catImageData = catImage.pngData()!
        
        //randomly delay emission of images
        let randomDelayCatObservable = Observable<Data>.just(catImageData)
            .delay(DispatchTimeInterval.milliseconds(Int.random(in: (500...1000))), scheduler: MainScheduler.instance)
        
        mockNetworkRequestSender.stub()
            .call(mockNetworkRequestSender.getData(url: Arg.verify { (arg: URL) in arg.absoluteString.starts(with: "https://test.com/gallery/t") },
                                                   query: Arg.any(),
                                                   headers: Arg.any()))
            .andReturn(randomDelayCatObservable)
        
        var loadedContent: [GalleryImage]?
        
        let observableCompletesExpectation = XCTestExpectation(description: "Observable completes") //it's expected that Observable completes
        let gotResponseExpectation = XCTestExpectation(description: "Correct amount of responses") //it's expected that we have correct number of updates for response
        gotResponseExpectation.assertForOverFulfill = true
        gotResponseExpectation.expectedFulfillmentCount = galleryContent.count + 1
        
        let disposeBag = DisposeBag()
        var howMuch = 0
        gallery.fetchImages(offset: nil, count: nil).subscribe(onNext: { content in
            loadedContent = content
            gotResponseExpectation.fulfill()
            howMuch += 1
        }, onCompleted: { observableCompletesExpectation.fulfill() }).disposed(by: disposeBag)
        
        wait(for: [gotResponseExpectation], timeout: 2.0)
        wait(for: [observableCompletesExpectation], timeout: 2.0)
        
        loadedContent!.forEach {
            XCTAssertEqual($0.showPlaceholder, false)
            XCTAssertTrue($0.image != nil)
        }
    }
    
    //test fetch when some images fail to load
    func test_fetchImagesEmptyStorageFullFetchWithSomeImageFailures() {
        let galleryService = DefaultGalleryService(galleryServiceURL: URL(string: "https://test.com")!, networkRequestSender: mockNetworkRequestSender)
        
        let gallery = Gallery(galleryService: galleryService)
        
        //let's mock the gallery service
        
        //first, let's mock the listing
        let galleryContent = ["t1", "t2", "t3", "t4", "t5"]
        mockNetworkRequestSender.stub()
            .call(mockNetworkRequestSender.get(url: Arg.eq(URL(string: "https://test.com/gallery")!),
                                               query: Arg.any(),
                                               headers: Arg.any())).andReturn(Observable<Any>.just(galleryContent))
        
        //second, let's mock the actual image response. t3 should fail
        let catImage = UIImage(named: "cat", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let catImageData = catImage.pngData()!
        
        //randomly delay emission of images
        let randomDelayCatObservable = Observable<Data>.just(catImageData)
            .delay(DispatchTimeInterval.milliseconds(Int.random(in: (500...1000))), scheduler: MainScheduler.instance)
        
        //mock valid images
        mockNetworkRequestSender.stub()
            .call(mockNetworkRequestSender.getData(url: Arg.verify { (arg: URL) in arg.absoluteString != "https://test.com/gallery/t3" && arg.absoluteString.starts(with: "https://test.com/gallery/t") },
                                                   query: Arg.any(),
                                                   headers: Arg.any()))
            .andReturn(randomDelayCatObservable)
        
        //mock failed image t3
        mockNetworkRequestSender.stub()
            .call(mockNetworkRequestSender.getData(url: Arg.verify { (arg: URL) in arg.absoluteString == "https://test.com/gallery/t3" },
                                                   query: Arg.any(),
                                                   headers: Arg.any()))
            .andReturn(Observable<Data>.error(NSError(domain: "test", code: 1, userInfo: nil)))
        
        var loadedContent: [GalleryImage]?
        
        let observableCompletesExpectation = XCTestExpectation(description: "Observable completes") //it's expected that Observable completes
        let gotResponseExpectation = XCTestExpectation(description: "Correct amount of responses") //it's expected that we have correct number of updates for response
        gotResponseExpectation.assertForOverFulfill = true
        gotResponseExpectation.expectedFulfillmentCount = galleryContent.count + 1
        
        let disposeBag = DisposeBag()
        gallery.fetchImages(offset: nil, count: nil).subscribe(onNext: { content in
            loadedContent = content
            gotResponseExpectation.fulfill()
        }, onCompleted: { observableCompletesExpectation.fulfill() }).disposed(by: disposeBag)
        
        wait(for: [gotResponseExpectation], timeout: 2.0)
        wait(for: [observableCompletesExpectation], timeout: 2.0)
        
        loadedContent!.forEach {
            XCTAssertEqual($0.showPlaceholder, false)
            
            if ($0.id != "t3") {
                XCTAssertTrue($0.image != nil)
            } else {
                XCTAssertTrue($0.image == nil)
            }
        }
    }
    
    //test fetch that brings empty listing
    func test_fetchImagesEmptyStorageFullFetchWithNoImagesOnServer() {
        let galleryService = DefaultGalleryService(galleryServiceURL: URL(string: "https://test.com")!, networkRequestSender: mockNetworkRequestSender)
        
        let gallery = Gallery(galleryService: galleryService)
        
        //let's mock the gallery service
        
        //first, let's mock the listing
        let galleryContent = [String]()
        mockNetworkRequestSender.stub()
            .call(mockNetworkRequestSender.get(url: Arg.eq(URL(string: "https://test.com/gallery")!),
                                               query: Arg.any(),
                                               headers: Arg.any())).andReturn(Observable<Any>.just(galleryContent))

        var loadedContent: [GalleryImage]?
        
        let observableCompletesExpectation = XCTestExpectation(description: "Observable completes") //it's expected that Observable completes
        let gotResponseExpectation = XCTestExpectation(description: "Correct amount of responses") //it's expected that we have correct number of updates for response
        gotResponseExpectation.assertForOverFulfill = true
        gotResponseExpectation.expectedFulfillmentCount = 1
        
        let disposeBag = DisposeBag()
        gallery.fetchImages(offset: nil, count: nil).subscribe(onNext: { content in
            loadedContent = content
            gotResponseExpectation.fulfill()
        }, onCompleted: {
            observableCompletesExpectation.fulfill()
        }).disposed(by: disposeBag)
        
        wait(for: [gotResponseExpectation], timeout: 2.0)
        wait(for: [observableCompletesExpectation], timeout: 2.0)
        
        XCTAssertEqual(loadedContent?.count, 0)
    }

    
}
