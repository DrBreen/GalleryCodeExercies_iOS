//
//  AlamofireNetworkRequestSender.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

class AlamofireNetworkRequestSender: NetworkRequestSender {
    
    var errorMapper: NetworkRequestErrorMapper?
    
    private static func createJSONCallback(observer: AnyObserver<Any>, errorMapper: NetworkRequestErrorMapper?) -> ((DataResponse<Any>) -> Void) {
        return { response in
            switch response.result {
            case .success(let json):
                observer.onNext(json)
                observer.onCompleted()
            case .failure(let error):
                let reportedError: Error
                if let errorMapper = errorMapper {
                    reportedError = errorMapper.map(error, data: response.data)
                } else {
                    reportedError = error
                }
                
                observer.onError(reportedError)
            }
        }
    }
    
    private static func createDataCallback(observer: AnyObserver<Data>, errorMapper: NetworkRequestErrorMapper?) -> ((DataResponse<Data>) -> Void) {
        return { response in
            switch response.result {
            case .success(let json):
                observer.onNext(json)
                observer.onCompleted()
            case .failure(let error):
                let reportedError: Error
                if let errorMapper = errorMapper {
                    reportedError = errorMapper.map(error, data: response.data)
                } else {
                    reportedError = error
                }
                
                observer.onError(reportedError)
            }
        }
    }
    
    func get(url: URL, query: [String : Any]?, headers: [String : String]?) -> Observable<Any> {
        
        //capture to avoid dealing with weak self
        let errorMapper = self.errorMapper
        
        return Observable.create { observer in
            
            let request = Alamofire.request(url, method: .get, parameters: query, encoding: URLEncoding(), headers: headers).responseJSON(completionHandler: AlamofireNetworkRequestSender.createJSONCallback(observer: observer, errorMapper: errorMapper))
            
            return Disposables.create { request.cancel() }
        }
        
    }
    
    func getData(url: URL, query: [String: Any]?, headers: [String: String]?) -> Observable<Data> {
        //capture to avoid dealing with weak self
        let errorMapper = self.errorMapper
        
        return Observable.create { observer in
            
            let request = Alamofire.request(url, method: .get, parameters: query, encoding: URLEncoding(), headers: headers).responseData(completionHandler: AlamofireNetworkRequestSender.createDataCallback(observer: observer, errorMapper: errorMapper))
            
            return Disposables.create { request.cancel() }
        }
    }
    
    func upload(url: URL, body: Data, headers: [String: String]?) -> Observable<Any> {
        
        //capture to avoid dealing with weak self
        let errorMapper = self.errorMapper
        
        return Observable.create { observer in
            let request = Alamofire.upload(body, to: url).responseJSON(completionHandler: AlamofireNetworkRequestSender.createJSONCallback(observer: observer, errorMapper: errorMapper))
            
            return Disposables.create { request.cancel() }
        }
    }
    
}
