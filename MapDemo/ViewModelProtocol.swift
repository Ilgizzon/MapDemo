//
//  ViewModelProtocol.swift
//  MapDemo
//
//  Created by Ilgiz Fazlyev on 02.11.2020.
//

import Foundation
protocol ViewModelProtocol: class {

    var delegate: ViewControllerDelegate? { get }
    func getCars()
}

protocol ViewControllerDelegate: class {
    
    func loadCars(cars: [CarModel])
    
}
