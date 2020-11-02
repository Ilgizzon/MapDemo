//
//  Updatable.swift
//  MapDemo
//
//  Created by Ilgiz Fazlyev on 26.10.2020.
//

protocol Updatable {
    func update(dict: [AnyHashable: Any])
    func convertToDictionary() -> [AnyHashable: Any]
}
