//
//  ViewModel.swift
//  MapDemo
//
//  Created by Ilgiz Fazlyev on 02.11.2020.
//

import Foundation
class ViewModel: ViewModelProtocol {

    weak var delegate: ViewControllerDelegate?
    private let networkQueue = DispatchQueue(label: "network queue")
    private var carsDict: [String: CarModel] = [:]
    private var currentCarModel: CarModel?
    init(with delegate: ViewControllerDelegate) {
        self.delegate = delegate
    }
    
    
    func getCars() {
        networkQueue.async {
            DatabaseManager.shared.getActualCars { [weak self] (result: Result<[CarModel], Error>) in
                guard let self = self else {
                    return
                }
                
                switch result {
                
                case .success(let data):
                    self.delegate?.loadCars(cars: data)
                    self.saveToDict(cars: data)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getCurrentCar(id: String) -> CarModel? {
        currentCarModel = carsDict[id]
        loadImage(car: currentCarModel)
        return currentCarModel
    }
    
    private func loadImage(car: CarModel?){
        guard let strongCar = car else {
            return
        }
        networkQueue.async {
            DatabaseManager.shared.getImage(searchImage: strongCar.name, carId: strongCar.id) { [weak self] (result: Result<(Data, String), Error>) in
                
                guard let self = self else { return }
                
                switch result{
                
                case .success((let data, let id)):
                    let oldId = "\(self.currentCarModel?.id ?? 0)"
                    if id != oldId {
                        
                        return
                    }
                    self.delegate?.loadImage(data: data)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func saveToDict(cars: [CarModel]){
        carsDict.removeAll()
        for car in cars {
            carsDict["\(car.id)"] = car
        }
    }
}
