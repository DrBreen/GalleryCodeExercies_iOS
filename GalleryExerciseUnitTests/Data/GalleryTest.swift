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
        performTestFetch(expectedUpdatesCount: 1, prePopulatedStorage: gallery, isStorageFullyFetched: true, expectComplete: true, expectError: false)
    }
    
    //test fetch that brings partial cached values
    func test_fetchImagesFromStoragePartial() {
        //make call error out to check network call wasn't made
        setMockData(gallery: nil)
        
        let gallery = ["t1", "t2", "t3", "t4", "t5"].map {
            GalleryImage(id: $0, imageThumbnail: UIImage.catImageThumbnail, image: UIImage.catImage, showPlaceholder: false)
        }
        
        let offset = 1
        let count = 2
        let expectedResult = Array<GalleryImage>(gallery[offset..<(offset + count)])
        
        let result = performTestFetch(offset: 1, count: 2, expectedUpdatesCount: 1, prePopulatedStorage: gallery, isStorageFullyFetched: true, expectComplete: true, expectError: false)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, expectedResult.count)
        
        for (index, galleryImage) in result!.enumerated() {
            XCTAssertEqual(galleryImage.id, expectedResult[index].id)
            XCTAssertEqual(galleryImage.showPlaceholder, expectedResult[index].showPlaceholder)
            
            XCTAssertTrue(galleryImage.image === expectedResult[index].image)
        }
    }
    
    //test fetch that brings partial cached values from the web, and they do overlap with current values
    func test_fetchImagesFromWebPartial() {
        //first of all, let's build the gallery ourselves
        let galleryContent = ["t1", "t2", "t3", "t4", "t5"].map {
            GalleryImage(id: $0, imageThumbnail: UIImage.catImageThumbnail, image: UIImage.catImage, showPlaceholder: false)
        }
        
        let gallery = createMockGallery(prePopulatedStorage: galleryContent, isStorageFullyFetched: false)
        
        //mock gallery response
        setMockData(gallery: ["t6", "t7"])
        setMockData(images: [
            "t1" : true,
            "t2" : true,
            "t3" : true,
            "t4" : true,
            "t5" : true,
            "t6" : true,
            "t7" : true
            ])
        
        let expectedIds = ["t1", "t2", "t3", "t4", "t5", "t6", "t7"]
        let result = performTestFetch(gallery: gallery, offset: 5, count: 2, expectedUpdatesCount: 3, prePopulatedStorage: galleryContent, isStorageFullyFetched: true, imageVerifier: {
            XCTAssertFalse($0.showPlaceholder)
            XCTAssertNotNil($0.image)
        }, expectComplete: true)
        
        XCTAssertEqual(result?.map { $0.id }, expectedIds)
    }
    
    //test fetch that brings partial cached values from the web, and they do overlap with current values
    func test_fetchImagesFromWebPartialWithOverlap() {
        //first of all, let's build the gallery ourselves
        let galleryContent = ["t1", "t2", "t3", "t4", "t5"].map { id -> GalleryImage in
            let hasImage = id != "t4"
            return GalleryImage(id: id, imageThumbnail: hasImage ? UIImage.catImageThumbnail : nil, image: hasImage ? UIImage.catImage : nil, showPlaceholder: !hasImage)
        }
        
        let gallery = createMockGallery(prePopulatedStorage: galleryContent, isStorageFullyFetched: false)
        
        //mock gallery response
        setMockData(gallery: ["t4", "t5", "t6", "t7"])
        setMockData(images: [
            "t1" : true,
            "t2" : true,
            "t3" : true,
            "t4" : true,
            "t5" : true,
            "t6" : true,
            "t7" : true
            ])
        
        let expectedIds = ["t1", "t2", "t3", "t4", "t5", "t6", "t7"]
        let result = performTestFetch(gallery: gallery, offset: 3, count: 4, expectedUpdatesCount: 5, prePopulatedStorage: galleryContent, isStorageFullyFetched: true, imageVerifier: {
            XCTAssertFalse($0.showPlaceholder)
            XCTAssertNotNil($0.image)
        }, expectComplete: true)
        
        XCTAssertEqual(result?.map { $0.id }, expectedIds)
    }
    
    //test full fetch that marks gallery as fully fetched
    func test_fetchImagesFullMarksAsFullyFetched() {
        
        let gallery = createMockGallery(prePopulatedStorage: nil, isStorageFullyFetched: false)
        
        //first, let's mock the listing
        let galleryContent = [String]()
        setMockData(gallery: galleryContent)
        performTestFetch(gallery: gallery, expectedUpdatesCount: 1)
        
        XCTAssertTrue(gallery.fetchedAll)
    }
    
    //test partial fetch that marks gallery as fully fetched
    func test_fetchImagesPartialMarksAsFullyFetched() {
        
        let galleryContent = [GalleryImage(id: "t1", imageThumbnail: UIImage.catImageThumbnail, image: UIImage.catImage, showPlaceholder: false)]
        let gallery = createMockGallery(prePopulatedStorage: galleryContent, isStorageFullyFetched: false)
        
        //first, let's mock the listing
        let serverGalleryContent = ["t2"]
        setMockData(gallery: serverGalleryContent, count: 2)
        setMockData(images: ["t2" : true])
        performTestFetch(gallery: gallery, offset: 1, count: 1, expectedUpdatesCount: 2)
        
        XCTAssertTrue(gallery.fetchedAll)
    }
    
    //test that clear() after full fetch will force next fetch to not be made from storage
    func test_fetchImagesAfterClear() {
        //first of all, let's build the gallery ourselves
        let galleryContent = ["t1", "t2", "t3", "t4", "t5"].map {
            GalleryImage(id: $0, imageThumbnail: UIImage.catImageThumbnail, image: UIImage.catImage, showPlaceholder: false)
        }
        
        let gallery = createMockGallery(prePopulatedStorage: galleryContent, isStorageFullyFetched: true)
        XCTAssertTrue(gallery.fetchedAll)
        gallery.clear()
        XCTAssertFalse(gallery.fetchedAll)
        
        //mock gallery response
        setMockData(gallery: ["t1", "t2"])
        setMockData(images: [
            "t1" : true,
            "t2" : true
            ])
        
        let result = performTestFetch(gallery: gallery, expectedUpdatesCount: 3, imageVerifier: {
            XCTAssertNotNil($0.image)
            XCTAssertFalse($0.showPlaceholder)
        })?.map { $0.id }
        
        XCTAssertTrue(gallery.fetchedAll)
        XCTAssertEqual(["t1", "t2"], result)
    }
    
    // MARK: Helpers
    private func createMockGallery(prePopulatedStorage: [GalleryImage]?, isStorageFullyFetched: Bool) -> GalleryProtocol {
        let galleryService = DefaultGalleryService(galleryServiceURL: URL(string: "https://test.com")!, networkRequestSender: mockNetworkRequestSender)
        return Gallery(galleryService: galleryService, prePopulatedStorage: prePopulatedStorage, storageFullyFetched: isStorageFullyFetched)
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
                    .delay(DispatchTimeInterval.milliseconds(Int.random(in: (50...100))), scheduler: MainScheduler.instance)
                
                stub.andReturn(randomDelayCatObservable)
            } else {
                let errorObservable = Observable<Data>.error(GalleryServiceError(error: "Test error"))
                stub.andReturn(errorObservable)
            }
        }
    }
    
    @discardableResult
    private func performTestFetch(gallery providedGallery: GalleryProtocol? = nil,
                                  offset: Int? = nil,
                                  count: Int? = nil,
                                  expectedUpdatesCount: Int? = nil,
                                  prePopulatedStorage: [GalleryImage]? = nil,
                                  isStorageFullyFetched: Bool = false,
                                  imageVerifier: ((GalleryImage) -> Void)? = nil,
                                  expectComplete: Bool = true,
                                  expectError: Bool = false) -> [GalleryImage]? {
        
        let gallery: GalleryProtocol
        if let providedGallery = providedGallery {
            gallery = providedGallery
        } else {
            gallery = createMockGallery(prePopulatedStorage: prePopulatedStorage, isStorageFullyFetched: isStorageFullyFetched)
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
        gallery.fetchImages(offset: offset, count: count).subscribe(onNext: { content in
            loadedContent = content
            gotResponseExpectation.fulfill()
        }, onError: { _ in
            observableErrorsOutExpectation.fulfill()
        },onCompleted: {
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
