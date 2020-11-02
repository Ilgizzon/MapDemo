//
//  DataExtension.swift
//  MapDemo
//
//  Created by Ilgiz Fazlyev on 26.10.2020.
//

import Foundation
extension Data {
    
    func parse<T>(type: T.Type)
        throws -> T where T : Decodable {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let responseObject = try decoder.decode(type, from: self)
        return responseObject
    }
}
