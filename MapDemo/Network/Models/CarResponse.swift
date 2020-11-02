//
//  CarResponse.swift
//  MapDemo
//
//  Created by Ilgiz Fazlyev on 26.10.2020.
//

import Foundation
struct CarResponse: Codable, Updatable {

    let id: Int
    let plateNumber, name, color: String
    let angle, fuelPercentage: Int
    let latitude, longitude: Double

    enum CodingKeys: String, CodingKey {
        case id
        case plateNumber = "plate_number"
        case name, color, angle
        case fuelPercentage = "fuel_percentage"
        case latitude, longitude
    }
    
    func update(dict: [AnyHashable : Any]) {
        fatalError("Responce model can't be update")
    }
    
    func convertToDictionary() -> [AnyHashable: Any] {
        var dict:[AnyHashable: Any] = [:]
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let key = child.label else {
                continue
            }
            dict[key] = child.value
        }
        return dict
    }
}

typealias CarResponseList = [CarResponse]
