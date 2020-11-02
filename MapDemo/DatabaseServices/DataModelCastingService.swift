//
//  DataModelCastingService.swift
//  MapDemo
//
//  Created by Ilgiz Fazlyev on 25.10.2020.
//

import Foundation
import RealmSwift

class DataModelCastingService {

   
    
    func castModel(fromData: Any, toData: Any){

        guard let convertable = fromData as? Updatable else {
            return
        }
        
        let dict = convertable.convertToDictionary()
        
        if let updatable = toData as? Updatable {
            updatable.update(dict: dict)
        }
        
    }
    
    
}
