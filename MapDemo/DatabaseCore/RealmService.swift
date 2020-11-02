//
//  RealmService.swift
//  MapDemo
//
//  Created by Ilgiz Fazlyev on 25.10.2020.
//

import Foundation
import RealmSwift
import Realm

final class RealmService {
    
    static let realmQueue = DispatchQueue(label: "RealmQueue", qos: .userInteractive)
    

    
    public static func clearAll(_ done: () -> Void) {
        do {
            let realm = Realm.db
            try? FileManager.default.removeItem(at: Constants.CACHE_IMAGES_URL)
            try! realm.safeWrite {
                realm.deleteAll()
            }
        }
        done()
    }

    

    
    static func getData<T>(type: T.Type) -> Results<T>
    where T : Object   {
        let realm = Realm.db
        return realm.objects(type)
    }
    
    

    

    
    static func save(_ models: [Object], complete: (([Object]) -> Void)? = nil) {
        realmQueue.async {
            autoreleasepool {
                
                let realm = Realm.db
                realm.beginWrite()
                try! realm.safeWrite {
                    realm.add(models, update: .modified)
                }
                
                complete?(models)
            }
        }
    }
    
}
