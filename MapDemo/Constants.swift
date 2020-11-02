//
//  Constants.swift
//  MapDemo
//
//  Created by Ilgiz Fazlyev on 26.10.2020.
//

import Foundation

struct Constants {
     static let CARS_URL: String = "https://raw.githubusercontent.com/Gary111/TrashCan/master/2000_cars.json"
    static let IMAGES_URL: String = "https://source.unsplash.com/300x200/?car,"
    static let CACHE_IMAGES_URL: URL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("images")
    
 }
