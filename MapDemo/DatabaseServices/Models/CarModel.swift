//
//  CachedCarModel.swift
//  MapDemo
//
//  Created by Ilgiz Fazlyev on 25.10.2020.
//

import Foundation
class CarModel: Updatable, Initializable {
    

    var id: Int = 0
    var plateNumber: String = ""
    var name: String = ""
    var color: String = ""
    var angle: Int = 0
    var fuelPercentage: Int = 0
    var latitude: Double = 0
    var longitude: Double = 0
    var imagePath: String?
    
    required init() {}
    
    func update(dict: [AnyHashable : Any]) {
            
        let start = CFAbsoluteTimeGetCurrent()
        
        if let angelValue = dict["angle"] as? Int {
            angle = angelValue
        }
        
        if let idValue = dict["id"] as? Int {
            id = idValue
        }
        
        if let imagePathValue = dict["imagePath"] as? String {
            imagePath = imagePathValue
        }
        
        if let plateNumberValue = dict["plateNumber"] as? String {
            plateNumber = plateNumberValue
        }
        
        if let nameValue = dict["name"] as? String {
            name = nameValue
        }
        
        if let colorValue = dict["color"] as? String {
            color = colorValue
        }
        
        if let fuelPercentageValue = dict["fuelPercentage"] as? Int {
            fuelPercentage = fuelPercentageValue
        }
        
        if let latitudeValue = dict["latitude"] as? Double {
            latitude = latitudeValue
        }
        
        if let longitudeValue = dict["longitude"] as? Double {
            longitude = longitudeValue
        }
        
        let diff = CFAbsoluteTimeGetCurrent() - start
        print("Class \(self) execution seconds \(diff)")
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
