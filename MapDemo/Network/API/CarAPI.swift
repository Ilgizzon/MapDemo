//
//  CarAPI.swift
//  MapDemo
//
//  Created by Ilgiz Fazlyev on 26.10.2020.
//

import Foundation
class CarAPI {
    
    static func getCars( result: @escaping (Result<CarResponseList, Error>) -> Void) {
        
        RequestManager.shared.run(
            url: Constants.CARS_URL,
            method: .get)
        {  response in
            
            switch response.result {
            case .success(let data):
                
                guard response.response?.statusCode == 200 else {
                    let error = NSError(
                        domain: "\(String(describing: response.response?.statusCode))",
                        code: 0,
                        userInfo: nil)
                    result(.failure(error))
                    return
                }
                
                do {
                    let parseData = try data.parse(type: CarResponseList.self)
                    result(.success(parseData))
                } catch {
                    result(.failure(error))
                }
            case .failure(let error):
                result(.failure(error))
            }
        }
    }
    
    static func getCarImage(searchImage: String, imageName: String, completion: @escaping (Result<(Data,URL), Error>) -> Void){
        RequestManager.shared.download(
            fileName: imageName,
            url: "\(Constants.IMAGES_URL)\(searchImage)",
            completed: { response in
                
                switch response.result {
                case .success(let data):

                    guard let destinationUrl = response.destinationURL else {
                        let error = NSError(
                            domain: "Destination URL is nil",
                            code: 0, userInfo: nil
                        )
                        completion(.failure(error))
                        return
                    }
                    completion(.success((data,destinationUrl)))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
                
            },
            downloadProgress: { progress in
                print(progress)
            })
    }
}
