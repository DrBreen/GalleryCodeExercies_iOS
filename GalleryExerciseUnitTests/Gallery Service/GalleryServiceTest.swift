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

//TODO: add error tests
//TODO: add test for named upload
class GalleryServiceTest: XCTestCase {
    
    private static let offsetResult = GalleryListResponse(count: 3, imageIds: ["1", "2", "3"])
    private static let offsetResultJson = try! JSONSerialization.data(withJSONObject: ["count": 3, "imageIds": ["1", "2", "3"]], options: [])
    private static let noOffsetResult = GalleryListResponse(count: 1, imageIds: ["2"])
    private static let noOffsetResultJson = try! JSONSerialization.data(withJSONObject: ["count": 1, "imageIds": ["2"]], options: []) 
    
    var disposeBag: DisposeBag?
    
    private let mockNetworkRequestSender = MockNetworkRequestSender()
    private lazy var galleryService = {
        return DefaultGalleryService(galleryServiceURL: URL(string: "https://test.com")!, networkRequestSender: mockNetworkRequestSender)
        
    }()
    
    override func setUp() {
        disposeBag = DisposeBag()
        
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
            .andReturn(Observable<Data>.just(GalleryServiceTest.offsetResultJson))
        
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
    }
    
    override func tearDown() {
        disposeBag = nil
    }
    
    //should return full array
    func test_getGalleryNoOffset() {
        let gotResponseExpectation = XCTestExpectation()
        
        galleryService.getGallery(offset: nil, count: nil).subscribe(onNext: { imageIds in
            XCTAssertEqual(imageIds, GalleryServiceTest.noOffsetResult)
            gotResponseExpectation.fulfill()
        }).disposed(by: disposeBag!)

        wait(for: [gotResponseExpectation], timeout: 1.0)
    }
    
    //should return offset array when sending count and offset
    func test_getGalleryWithOffset() {
        let gotResponseExpectation = XCTestExpectation()
        
        galleryService.getGallery(offset: 1, count: 1).subscribe(onNext: { imageIds in
            XCTAssertEqual(imageIds, GalleryServiceTest.offsetResult)
            gotResponseExpectation.fulfill()
        }).disposed(by: disposeBag!)
        
        wait(for: [gotResponseExpectation], timeout: 1.0)
    }
    
    //should receive UIImage
    func test_image() {
        let gotResponseExpectation = XCTestExpectation()
        
        galleryService.image(id: "testId").subscribe(onNext: { image in
            gotResponseExpectation.fulfill()
        }).disposed(by: disposeBag!)
        
        wait(for: [gotResponseExpectation], timeout: 1.0)
    }
    
    //should upload successfully and receive GallertServiceUploadResponse with imageId == "testId"
    func test_upload() {
        let gotResponseExpectation = XCTestExpectation()
        
        galleryService.upload(image: UIImage.catImage, name: nil).subscribe(onNext: { response in
            XCTAssertEqual(response.imageId, "testId");
            gotResponseExpectation.fulfill()
        }).disposed(by: disposeBag!)
        
        wait(for: [gotResponseExpectation], timeout: 1.0)
    }
}
