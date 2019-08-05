//
//  MockNetworkRequestSender.swift
//  GalleryExerciseAppTests
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import InstantMock
import RxSwift

class MockNetworkRequestSender: Mock, NetworkRequestSender {
    
    var errorMapper: NetworkRequestErrorMapper?
    
    func getData(url: URL, query: [String : Any]?, headers: [String : String]?) -> Observable<Data> {
        return super.call(url, query, headers)!
    }
    
    func upload(url: URL, body: [String : MultipartFormDataDescription], headers: [String : String]?) -> Observable<Any> {
        return super.call(url, body, headers)!
    }
    
    func get(url: URL, query: [String : Any]?, headers: [String : String]?) -> Observable<Any> {
        return super.call(url, query, headers)!
    }
    
    
}
