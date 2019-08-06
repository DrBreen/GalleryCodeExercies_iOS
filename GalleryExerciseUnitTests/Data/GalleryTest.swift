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
        
        performTestFetch(expectedUpdatesCount: galleryContent.count + 1, imageVerifier: {
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
        
        performTestFetch(expectedUpdatesCount: galleryContent.count + 1, imageVerifier: {
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
        performTestFetch(expectedUpdatesCount: 1, imageVerifier: nil)
    }
    
    //test fetch that errors out
    func test_fetchImagesError() {
        setMockData(gallery: nil)
        performTestFetch(expectComplete: false, expectError: true)
    }
    
    //test fetch that brings cached values
    func test_fetchImagesFromStorage() {

        //make call error out to check network call wasn't made
        setMockData(gallery: nil)

        let gallery = ["t1", "t2", "t3", "t4", "t5"].map {
            GalleryImage(id: $0, imageThumbnail: UIImage.catImageThumbnail, image: UIImage.catImage, showPlaceholder: false)
        }
        performTestFetch(cache: gallery, expectedUpdatesCount: 1, expectComplete: true, expectError: false)
    }
    
    
    //test that invalidateCache() actually makes cache invalid and forces gallery to request data from network
    func test_fetchImagesAfterClear() {

        //first of all, let's build the gallery ourselves
        let galleryContent = ["t1", "t2", "t3", "t4", "t5"].map {
            GalleryImage(id: $0, imageThumbnail: UIImage.catImageThumbnail, image: UIImage.catImage, showPlaceholder: false)
        }

        let gallery = createMockGallery(cache: galleryContent)

        //mock gallery response
        setMockData(gallery: ["t1", "t2"])
        setMockData(images: [
            "t1" : true,
            "t2" : true
            ])

        gallery.invalidateCache()
        
        let result = performTestFetch(gallery: gallery, expectedUpdatesCount: 3, imageVerifier: {
            XCTAssertNotNil($0.image)
            XCTAssertFalse($0.showPlaceholder)
        })?.map { $0.id }

        XCTAssertEqual(["t1", "t2"], result)
    }
    
    // MARK: Helpers
    private func createMockGallery(cache: [GalleryImage]? = nil) -> GalleryProtocol {
        let galleryService = DefaultGalleryService(galleryServiceURL: URL(string: "https://test.com")!, networkRequestSender: mockNetworkRequestSender)
        return Gallery(galleryService: galleryService, cacheContent: cache)
    }
    
    //sets mock data for whole gallery
    //if gallery is nil, send error instead of gallery
    private func setMockData(gallery: [String]?, count: Int? = nil) {
        let stub = mockNetworkRequestSender.stub()
            .call(mockNetworkRequestSender.getData(url: Arg.eq(URL(string: "https://test.com/gallery")!),
                                               query: Arg.any(),
                                               headers: Arg.any()))
        if let gallery = gallery {
            let totalCount: Int
            if let count = count {
                totalCount = count
            } else {
                totalCount = gallery.count
            }
            
            let json: [String: Any] = [
                "count" : totalCount,
                "imageIds" : gallery
            ]
            
            let data = try! JSONSerialization.data(withJSONObject: json, options: [])
            stub.andReturn(Observable<Data>.just(data))
        } else {
            let errorObservable = Observable<Data>.error(GalleryServiceError(error: "Test error"))
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
                let catImage = UIImage.catImage
                let catImageData = catImage.pngData()!
                
                //randomly delay emission of images
                let randomDelayCatObservable = Observable<Data>.just(catImageData)
                    .delay(DispatchTimeInterval.milliseconds(Int.random(in: (50...100))), scheduler: MainScheduler.instance).debug("randomDelay", trimOutput: true)
                
                stub.andReturn(randomDelayCatObservable)
            } else {
                let errorObservable = Observable<Data>.error(GalleryServiceError(error: "Test error"))
                stub.andReturn(errorObservable)
            }
        }
    }
    
    @discardableResult
    private func performTestFetch(gallery providedGallery: GalleryProtocol? = nil,
                                  cache: [GalleryImage]? = nil,
                                  expectedUpdatesCount: Int? = nil,
                                  imageVerifier: ((GalleryImage) -> Void)? = nil,
                                  expectComplete: Bool = true,
                                  expectError: Bool = false) -> [GalleryImage]? {
        
        let gallery: GalleryProtocol
        if let providedGallery = providedGallery {
            gallery = providedGallery
        } else {
            gallery = createMockGallery(cache: cache)
        }
        
        //set up expectations
        let observableCompletesExpectation = XCTestExpectation(description: "Observable completes") //it's expected that Observable completes
        
        let gotResponseExpectation = XCTestExpectation(description: "Correct amount of updates") //it's expected that we have correct number of updates for response
        gotResponseExpectation.assertForOverFulfill = true
        
        if let expectedUpdatesCount = expectedUpdatesCount {
            gotResponseExpectation.expectedFulfillmentCount = expectedUpdatesCount
        }
        
        let observableErrorsOutExpectation = XCTestExpectation(description: "Observable errors out") //it's expected that Observable errors out
        observableErrorsOutExpectation.assertForOverFulfill = true
        observableErrorsOutExpectation.expectedFulfillmentCount = 1
        
        var loadedContent: [GalleryImage]?
        
        //fetch and save the gallery
        let disposeBag = DisposeBag()
        gallery.fetchImages().debug("obs", trimOutput: true)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { content in
            loadedContent = content
            gotResponseExpectation.fulfill()
        }, onError: { _ in
            observableErrorsOutExpectation.fulfill()
        }, onCompleted: {
            observableCompletesExpectation.fulfill()
        }).disposed(by: disposeBag)
        
        var expectations = [XCTestExpectation]()
        if let _ = expectedUpdatesCount {
            expectations.append(gotResponseExpectation)
        }
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
        
        return loadedContent
    }

    
}
