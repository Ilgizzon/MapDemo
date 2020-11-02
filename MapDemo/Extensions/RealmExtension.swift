//
//  RealmExtension.swift
//  MapDemo
//
//  Created by Ilgiz Fazlyev on 25.10.2020.
//

import Foundation
import RealmSwift

extension Realm {
    
    public static var version: UInt64 {
        let dictionary  = Bundle.main.infoDictionary!
        let version     = dictionary["CFBundleShortVersionString"] as! String
        let build       = dictionary["CFBundleVersion"] as! String
        var schemaVersion: UInt64 = UInt64(build) ?? 0
        var i = 0
        version.components(separatedBy: ".").reversed().forEach { (versionPart) in
            i += 1
            let versionPartValue = UInt64(versionPart) ?? 0
            schemaVersion += versionPartValue * UInt64(10000 ^ i)
        }
        return schemaVersion
    }
    
    public static var db: Realm {
        return try! Realm(configuration : Configuration(
            schemaVersion: version,
            deleteRealmIfMigrationNeeded: true)
        )
    }
    
    public func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}

extension Results {
    func toArray() -> [Element] {
      return compactMap {
        $0
      }
    }
 }
