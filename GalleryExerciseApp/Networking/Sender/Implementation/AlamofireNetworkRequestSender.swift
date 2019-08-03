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
    
    func get(url: URL, query: [String : Any]?, headers: [String : String]?) -> Observable<Any> {
        return Observable.create { observer in
            
            let request = Alamofire.request(url, method: .get, parameters: query, encoding: URLEncoding(), headers: headers).responseJSON { response in
                
                switch response.result {
                case .success(let json):
                    observer.onNext(json)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create { request.cancel() }
        }
        
    }
    
    func getData(url: URL, query: [String: Any]?, headers: [String: String]?) -> Observable<Data> {
        return Observable.create { observer in
            
            let request = Alamofire.request(url, method: .get, parameters: query, encoding: URLEncoding(), headers: headers).responseData { response in
                
                switch response.result {
                case .success(let data):
                    observer.onNext(data)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create { request.cancel() }
        }
    }
    
    func upload(url: URL, body: Data, headers: [String: String]?) -> Observable<Any> {
        return Observable.create { observer in
            let request = Alamofire.upload(body, to: url).responseJSON { response in
                switch response.result {
                case .success(let json):
                    observer.onNext(json)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create { request.cancel() }
        }
    }
    
}
