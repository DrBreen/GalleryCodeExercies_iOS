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
    
    private let sessionManager: SessionManager
    
    init(sessionManager: SessionManager = SessionManager.default) {
        self.sessionManager = sessionManager
    }
    
    var errorMapper: NetworkRequestErrorMapper?
    
    private static func createJSONCallback(onNext: @escaping (Any) -> Void,
                                           onError: @escaping (Error) -> Void,
                                           onCompleted: @escaping () -> Void,
                                           errorMapper: NetworkRequestErrorMapper?) -> ((DataResponse<Any>) -> Void) {
        return { response in
            switch response.result {
            case .success(let json):
                onNext(json)
                onCompleted()
            case .failure(let error):
                let reportedError: Error
                if let errorMapper = errorMapper {
                    reportedError = errorMapper.map(error, data: response.data)
                } else {
                    reportedError = error
                }
                
                onError(reportedError)
            }
        }
    }
    
    private static func createJSONCallback(observer: AnyObserver<Any>, errorMapper: NetworkRequestErrorMapper?) -> ((DataResponse<Any>) -> Void) {
        
        return createJSONCallback(onNext: {
            observer.onNext($0)
        }, onError: {
            observer.onError($0)
        }, onCompleted: {
            observer.onCompleted()
        }, errorMapper: errorMapper)
        
    }
    
    private static func createDataCallback(onNext: @escaping (Data) -> Void,
                                           onError: @escaping (Error) -> Void,
                                           onCompleted: @escaping () -> Void,
                                           errorMapper: NetworkRequestErrorMapper?) -> ((DataResponse<Data>) -> Void) {
        return { response in
            switch response.result {
            case .success(let data):
                onNext(data)
                onCompleted()
            case .failure(let error):
                let reportedError: Error
                if let errorMapper = errorMapper {
                    reportedError = errorMapper.map(error, data: response.data)
                } else {
                    reportedError = error
                }
                
                onError(reportedError)
            }
        }
    }
    
    private static func createDataCallback(observer: AnyObserver<Data>, errorMapper: NetworkRequestErrorMapper?) -> ((DataResponse<Data>) -> Void) {
        return createDataCallback(onNext: {
            observer.onNext($0)
        }, onError: {
            observer.onError($0)
        }, onCompleted: {
            observer.onCompleted()
        }, errorMapper: errorMapper)
    }
    
    func getData(url: URL, query: [String: Any]?, headers: [String: String]?) -> Observable<Data> {
        
        return Observable.create { observer in
            
            let request = self.sessionManager.request(url, method: .get, parameters: query, encoding: URLEncoding(), headers: headers).validate(statusCode: 200..<300).responseData(completionHandler: AlamofireNetworkRequestSender.createDataCallback(observer: observer, errorMapper: self.errorMapper))
            
            return Disposables.create { request.cancel() }
        }
    }
    
    func upload(url: URL, body: [String : MultipartFormDataDescription], headers: [String: String]?) -> Observable<Any> {
        
        let multipart = MultipartFormData()
        for name in body.keys {
            let description = body[name]!
            multipart.append(description.data, withName: name, fileName: description.filename, mimeType: description.mimetype)
        }
        
        let multipartData: Data
        do {
            multipartData = try multipart.encode()
        } catch (let error) {
            return Observable.error(error)
        }
        
        return Observable.create { observer in
            let request = self.sessionManager.upload(multipartData, to: url, headers: ["Content-Type" : multipart.contentType]).validate(statusCode: 200..<300).responseJSON(completionHandler: AlamofireNetworkRequestSender.createJSONCallback(observer: observer, errorMapper: self.errorMapper))
            
            return Disposables.create { request.cancel() }
        }
    }
    
    func put(url: URL, body: [String : Any], headers: [String: String]?) -> Single<Any> {
        return Single<Any>.create { observer in
            
            let callback = AlamofireNetworkRequestSender.createDataCallback(onNext: {
                observer(SingleEvent.success($0))
            }, onError: {
                observer(SingleEvent.error($0))
            }, onCompleted: {}, errorMapper: self.errorMapper)
            
            let request = self.sessionManager.request(url, method: .put, parameters: body, encoding: URLEncoding.httpBody, headers: headers).responseData(completionHandler: callback)
            
            
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
}
