//
//  GalleryServiceTest.swift
//  GalleryExerciseAppTests
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import XCTest
import RxSwift
import InstantMock

class GalleryServiceTest: XCTestCase {
    
    private static let noOffsetResult = GalleryListResponse(count: 3, imageIds: ["1", "2", "3"], comments: ["1": "testComment"])
    private static let noOffsetResultJson = try! JSONSerialization.data(withJSONObject: ["count": 3, "imageIds": ["1", "2", "3"], "comments": ["1": "testComment"]], options: [])
    
    
    var disposeBag: DisposeBag?
    
    private let mockNetworkRequestSender = MockNetworkRequestSender()
    private lazy var galleryService = {
        return DefaultGalleryService(galleryServiceURL: URL(string: "https://test.com")!, networkRequestSender: mockNetworkRequestSender)
        
    }()
    
    override func setUp() {
        disposeBag = DisposeBag()
        
        continueAfterFailure = false
        
        //for no offset and count return ["1", "2", "3"]
        mockNetworkRequestSender.stub()
            .call(mockNetworkRequestSender.getData(url: Arg.eq(URL(string: "https://test.com/gallery")!),
                                               query: Arg.any(),
                                               headers: Arg.any())).andReturn(Observable<Data>.just(GalleryServiceTest.noOffsetResultJson))
        
        //for offset == 1 and count == 1 return ["2"]
        mockNetworkRequestSender.stub()
            .call(mockNetworkRequestSender.getData(url: Arg.eq(URL(string: "https://test.com/gallery")!),
                                               query: Arg.eq(["offset" : 1, "count" : 1]),
                                               headers: Arg.any()))
            .andReturn(Observable<Data>.just(GalleryServiceTest.noOffsetResultJson))
        
        //for /gallery/testId return data that is an image
        let catImage = UIImage(named: "cat", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let catImageData = catImage.pngData()!
        mockNetworkRequestSender.stub()
            .call(mockNetworkRequestSender.getData(url: Arg.eq(URL(string: "https://test.com/gallery/testId")!),
                                               query: Arg.any(),
                                               headers: Arg.any()))
            .andReturn(Observable<Data>.just(catImageData))
        
        //for POST /gallery return JSON with { imageId: "testId" }
        mockNetworkRequestSender.stub()
            .call(mockNetworkRequestSender.upload(url: Arg.eq(URL(string: "https://test.com/gallery")!),
                                               body: Arg.any(),
                                               headers: Arg.any()))
            .andReturn(Observable<Any>.just(["imageId" : "testId"]))
        
        //for POST /gallery/testReplaceId return JSON with { imageId: "testReplaceId" }
        mockNetworkRequestSender.stub()
            .call(mockNetworkRequestSender.upload(url: Arg.eq(URL(string: "https://test.com/gallery/testReplaceId")!),
                                                  body: Arg.any(),
                                                  headers: Arg.any()))
            .andReturn(Observable<Any>.just(["imageId" : "testReplaceId"]))
    }
    
    override func tearDown() {
        disposeBag = nil
    }
    
    //should return full array
    func test_getGalleryNoOffset() {
        let gotResponseExpectation = XCTestExpectation(description: "gotResponseExpectation")
        
        galleryService.getGallery().debug().subscribe(onNext: { imageIds in
            XCTAssertEqual(imageIds, GalleryServiceTest.noOffsetResult)
            gotResponseExpectation.fulfill()
        }).disposed(by: disposeBag!)

        wait(for: [gotResponseExpectation], timeout: 1.0)
    }
    
    
    //should receive UIImage
    func test_image() {
        let gotResponseExpectation = XCTestExpectation(description: "gotResponseExpectation")
        
        galleryService.image(id: "testId").subscribe(onNext: { image in
            gotResponseExpectation.fulfill()
        }).disposed(by: disposeBag!)
        
        wait(for: [gotResponseExpectation], timeout: 1.0)
    }
    
    //should upload successfully and receive GallertServiceUploadResponse with imageId == "testId"
    func test_upload() {
        let gotResponseExpectation = XCTestExpectation(description: "gotResponseExpectation")
        
        galleryService.upload(image: UIImage.catImage, name: nil).subscribe(onNext: { response in
            XCTAssertEqual(response.imageId, "testId")
            gotResponseExpectation.fulfill()
        }).disposed(by: disposeBag!)
        
        wait(for: [gotResponseExpectation], timeout: 1.0)
    }
    
    //should upload successfully and receive GallertServiceUploadResponse with imageId == "testId"
    func test_uploadReplace() {
        let gotResponseExpectation = XCTestExpectation(description: "gotResponseExpectation")
        
        galleryService.upload(image: UIImage.catImage, name: "testReplaceId").subscribe(onNext: { response in
            XCTAssertEqual(response.imageId, "testReplaceId")
            gotResponseExpectation.fulfill()
        }).disposed(by: disposeBag!)
        
        wait(for: [gotResponseExpectation], timeout: 1.0)
    }
}
