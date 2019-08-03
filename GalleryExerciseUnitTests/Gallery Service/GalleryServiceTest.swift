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
    
    private static let offsetResult = ["1", "2", "3"]
    private static let noOffsetResult = ["2"]
    
    var disposeBag: DisposeBag?
    
    private let mockNetworkRequestSender = MockNetworkRequestSender()
    private lazy var galleryService = {
        return DefaultGalleryService(galleryServiceURL: URL(string: "https://test.com")!, networkRequestSender: mockNetworkRequestSender)
        
    }()
    
    override func setUp() {
        disposeBag = DisposeBag()
        
        //for no offset and count return ["1", "2", "3"]
        mockNetworkRequestSender.stub()
            .call(mockNetworkRequestSender.get(url: Arg.eq(URL(string: "https://test.com/gallery")!),
                                               query: Arg.any(),
                                               headers: Arg.any())).andReturn(Observable<Any>.just(GalleryServiceTest.noOffsetResult))
        
        //for offset == 1 and count == 1 return ["2"]
        mockNetworkRequestSender.stub()
            .call(mockNetworkRequestSender.get(url: Arg.eq(URL(string: "https://test.com/gallery")!),
                                               query: Arg.eq(["offset" : 1, "count" : 1]),
                                               headers: Arg.any()))
            .andReturn(Observable<Any>.just(GalleryServiceTest.offsetResult))
        
        //for /gallery/testId return data that is an image
        let catImage = UIImage(named: "cat", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let catImageData = catImage.pngData()!
        mockNetworkRequestSender.stub()
            .call(mockNetworkRequestSender.get(url: Arg.eq(URL(string: "https://test.com/gallery/testId")!),
                                               query: Arg.any(),
                                               headers: Arg.any()))
            .andReturn(Observable<Any>.just(catImageData))
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
    
    func test_image() {
        let gotResponseExpectation = XCTestExpectation()
        
        galleryService.image(id: "testId").subscribe(onNext: { image in
            gotResponseExpectation.fulfill()
        }).disposed(by: disposeBag!)
        
        wait(for: [gotResponseExpectation], timeout: 1.0)
    }
    
}
