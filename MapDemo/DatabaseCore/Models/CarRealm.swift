//
//  CarRealm.swift
//  MapDemo
//
//  Created by Ilgiz Fazlyev on 25.10.2020.
//

import Foundation
import RealmSwift

class CarRealm: Object, Updatable, Initializable {

    @objc dynamic var id  = 0
    @objc dynamic var timestamp = Date()
    @objc dynamic var imagePath: String? = nil
    @objc dynamic var plateNumber  = ""
    @objc dynamic var name  = ""
    @objc dynamic var color  = ""
    @objc dynamic var angle = 0
    @objc dynamic var fuelPercentage = 0
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0

    required override init() {
        super.init()
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func update(dict: [AnyHashable: Any]) {
        
        let start = CFAbsoluteTimeGetCurrent()
        
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let key = child.label, let dictValue = dict[key] else {
                continue
            }
            
            let thisType = Mirror(reflecting: child.value).subjectType
            let dictValueType = Mirror(reflecting: dictValue).subjectType
            if thisType == dictValueType  {
                self.setValue(dict[key], forKey: "\(key)")
            }
            
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
            dict[key] = self.value(forKeyPath: key)
        }
        return dict
    }
    
}
