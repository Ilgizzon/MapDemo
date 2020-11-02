//
//  RequestManager.swift
//  MapDemo
//
//  Created by Ilgiz Fazlyev on 26.10.2020.
//

import Foundation
import Alamofire
class RequestManager {

    public static let shared = RequestManager()

    func run(
        url: String,
        method: HTTPMethod,
        encoding: URLEncoding? = nil,
        parameters: [String: Any]? = nil,
        completed: @escaping (DataResponse<Data>) -> Void
    ){
        
        var encodingMethod: ParameterEncoding!
        if encoding == nil {
            encodingMethod = method == .get ? URLEncoding.default : JSONEncoding.default
        } else {
            encodingMethod = encoding
        }
        Alamofire.request(
            url,
            method: method,
            parameters: parameters,
            encoding: encodingMethod
        ).responseData { response in
            completed(response)
        }
    }
    
    func download(
        fileName:String,
        url: String,
        completed: @escaping (DownloadResponse<Data>) -> Void,
        downloadProgress: @escaping (Double) -> Void
    ){
        Alamofire.SessionManager.default.session.configuration.httpCookieStorage = nil
        let fileUrl = Constants.CACHE_IMAGES_URL.appendingPathComponent("\(fileName)")
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
        }

        Alamofire.download(
            url,
            to: destination
        )
            .downloadProgress (queue: DispatchQueue.global(qos: .utility)) { (progress) in
                downloadProgress(progress.fractionCompleted)
            }
            .responseData { response in
                completed(response)
        }
    }
    
    func upload(
        file: URL,
        url: String,
        completed: @escaping (DataResponse<Data>) -> Void,
        uploadProgress: @escaping (Double) -> Void
    ){

        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(file, withName: "file")
        }, to: url) { encodingResult in
            
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseData { responseData in
                        completed(responseData)
                    }
                    upload.uploadProgress (queue: DispatchQueue.global(qos: .utility)) { progress in
                        uploadProgress(progress.fractionCompleted)
                    }
                case .failure(let encodingError):
                    print("Upload error: \(encodingError)")
                }
            }
            
        }
        
}
