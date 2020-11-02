//
//  DatabaseManager.swift
//  MapDemo
//
//  Created by Ilgiz Fazlyev on 25.10.2020.
//

import Foundation
import Realm
import RealmSwift
class DatabaseManager {
    
    public static let shared = DatabaseManager()
    private let castingService: DataModelCastingService
    
    init() {
        castingService = DataModelCastingService()
    }
    
    func getActualCars(completion: @escaping (Result<[CarModel], Error>) -> Void){
        
        if cacheActual() {
            
            let carsRealm = getDataFromStorage(model: CarRealm.self).toArray()
            let carsList = castingModels(fromList: carsRealm, to: CarModel.self)
            
            completion(.success(carsList))
            
        } else {
            
            CarAPI.getCars { [weak self] (result: Result<CarResponseList, Error>)  in
                guard let self = self else {
                    return
                }
                
                switch result {
                
                case .success(let data):
                    let realmList = self.castingModels(fromList: data, to: CarRealm.self)
                    RealmService.clearAll {
                        RealmService.save(realmList) { [weak self] modelsRealm in
                            guard let self = self else {
                                return
                            }
                            let carsList = self.castingModels(fromList: modelsRealm, to: CarModel.self)
                            
                            completion(.success(carsList))
                        } failed: { error in
                            completion(.failure(error))
                        }
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
        }
    }
    
    func getCarsFromCache(completion: @escaping ([CarModel]) -> Void){
        let carsRealm = getDataFromStorage(model: CarRealm.self).toArray()
        let carsList = castingModels(fromList: carsRealm, to: CarModel.self)
        completion(carsList)
    }
    
    private func cacheActual() -> Bool {
        guard let cacheObject = RealmService.getData(type: CarRealm.self).first,
              let cacheTime = Calendar.current.dateComponents(
                [.minute],
                from: cacheObject.timestamp,
                to: Date()).minute else {
            
            return false
        }
        return !(cacheTime > 1)
    }
    
    private func getDataFromStorage<T>(model: T.Type) -> Results<T>
    where T : Object {

        return RealmService.getData(type: model)
    }
    
    private func castingModels<T>(fromList: [Any], to: T.Type) -> [T]
    where T : Initializable{
        
        var returnList: [T] = []
        
        for element in fromList {
            let toElement  = T.init()
            castingService.castModel(fromData: element, toData: toElement)
            returnList.append(toElement)
        }
        return returnList
    }
}
